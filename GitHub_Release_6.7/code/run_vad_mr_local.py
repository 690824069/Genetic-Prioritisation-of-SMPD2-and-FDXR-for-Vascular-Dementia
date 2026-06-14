import pandas as pd
import numpy as np
import subprocess
import os
from scipy import stats
from pathlib import Path

# ==========================================
# 0. 路径与环境配置 (适配您的 F 盘)
# ==========================================
ROOT_DIR = Path(r"F:\文献数据")

# 原始文件
EQTL_FILE = ROOT_DIR / "2019-12-11-cis-eQTLsFDR-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt"
OUTCOME_FILE = ROOT_DIR / "finngen_R11_F5_VASCDEM.gz"

# 本地软件与参考面板
PLINK_EXE = ROOT_DIR / "plink.exe"
REF_PANEL = ROOT_DIR / "EUR"  # 不需要加后缀，PLINK 会自动找 .bed/.bim/.fam

# 输出结果
OUTPUT_FILE = ROOT_DIR / "Result_VaD_MR_Local_Final.csv"
TEMP_DIR = ROOT_DIR / "temp_clump"
os.makedirs(TEMP_DIR, exist_ok=True)

# 统计参数
BONFERRONI_P = 2.96e-6   # 0.05 / 16845

# ==========================================
# 1. 核心：本地 PLINK Clumping 函数
# ==========================================
def local_ld_clumping(df, gene_name):
    """
    调用本地 plink.exe 进行 LD Clumping，彻底替代 API
    参数: r2 < 0.001, kb = 10000
    """
    if len(df) <= 1:
        return df

    # 1. 准备 PLINK 输入用的临时文件 (包含 SNP 和 P 值的文本)
    input_txt = TEMP_DIR / f"{gene_name}_to_clump.txt"
    df[['rsid', 'pval_exp']].to_csv(input_txt, sep='\t', index=False)

    out_prefix = TEMP_DIR / f"{gene_name}_clumped"
    
    # 2. 构造 PLINK 命令行命令
    # --clump-p1: 显著性阈值
    # --clump-r2: 独立性阈值
    # --clump-kb: 距离窗口
    cmd = [
        str(PLINK_EXE),
        "--bfile", str(REF_PANEL),
        "--clump", str(input_txt),
        "--clump-field", "pval_exp",
        "--clump-snp-field", "rsid",
        "--clump-p1", "1", # 因为输入的已经是显著的，这里设为1即可
        "--clump-r2", "0.001",
        "--clump-kb", "10000",
        "--out", str(out_prefix),
        "--noweb" # 防止老版本 plink 联网检查
    ]

    try:
        # 执行命令 (不显示黑窗口)
        subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
        
        # 3. 读取 PLINK 的输出结果 (.clumped 文件)
        clumped_result_file = Path(str(out_prefix) + ".clumped")
        if clumped_result_file.exists():
            # PLINK 的输出是固定宽度的格式
            clumped_data = pd.read_csv(clumped_result_file, sep=r'\s+', usecols=['SNP'])
            clumped_rsids = clumped_data['SNP'].tolist()
            
            # 清理临时文件
            for f in TEMP_DIR.glob(f"{gene_name}_*"): os.remove(f)
            
            return df[df['rsid'].isin(clumped_rsids)].copy()
        else:
            return df.head(1)
    except Exception as e:
        return df.head(1)

# ==========================================
# 2. 内存优化：数据读取与转换 (与之前一致)
# ==========================================
def load_and_filter_data():
    print("🚀 正在加载 eQTLGen 暴露数据...")
    chunks = []
    usecols = ['Pvalue', 'SNP', 'AssessedAllele', 'OtherAllele', 'Zscore', 'GeneSymbol']
    for chunk in pd.read_csv(EQTL_FILE, sep='\t', usecols=usecols, chunksize=1000000):
        sig = chunk[chunk['Pvalue'] < BONFERRONI_P].copy()
        if not sig.empty:
            N = 31684
            sig['beta_exp'] = sig['Zscore'] / np.sqrt(N)
            sig['se_exp'] = 1 / np.sqrt(N)
            sig.rename(columns={'SNP':'rsid', 'Pvalue':'pval_exp', 'AssessedAllele':'effect_allele_exp', 
                                'OtherAllele':'other_allele_exp', 'GeneSymbol':'gene'}, inplace=True)
            chunks.append(sig)
    exp_df = pd.concat(chunks, ignore_index=True)
    
    print(f"🧬 正在加载 FinnGen VaD 结局数据 (R11)...")
    out_cols = ['rsids', 'alt', 'ref', 'beta', 'sebeta', 'pval']
    target_rsids = set(exp_df['rsid'])
    out_chunks = []
    for chunk in pd.read_csv(OUTCOME_FILE, compression='gzip', sep='\t', usecols=out_cols, chunksize=1000000):
        matched = chunk[chunk['rsids'].isin(target_rsids)]
        out_chunks.append(matched)
    out_df = pd.concat(out_chunks, ignore_index=True)
    out_df.rename(columns={'rsids':'rsid', 'alt':'effect_allele_out', 'ref':'other_allele_out', 
                           'beta':'beta_out', 'sebeta':'se_out', 'pval':'pval_out'}, inplace=True)
    return exp_df, out_df

# ==========================================
# 3. MR 核心引擎
# ==========================================
def run_mr(exp, out):
    df = pd.merge(exp, out, on='rsid', how='inner')
    if df.empty: return None
    
    # 简单的等位基因对齐
    df['effect_allele_exp'] = df['effect_allele_exp'].str.upper()
    df['other_allele_exp'] = df['other_allele_exp'].str.upper()
    df['effect_allele_out'] = df['effect_allele_out'].str.upper()
    df['other_allele_out'] = df['other_allele_out'].str.upper()
    
    needs_flip = (df['effect_allele_exp'] == df['other_allele_out'])
    df.loc[needs_flip, 'beta_out'] *= -1
    
    n_snps = len(df)
    df['F_stat'] = (df['beta_exp'] / df['se_exp'])**2
    
    b_e, se_e = df['beta_exp'].values, df['se_exp'].values
    b_o, se_o = df['beta_out'].values, df['se_out'].values
    
    if n_snps == 1:
        b, se = b_o[0]/b_e[0], se_o[0]/abs(b_e[0])
        method = "Wald ratio"
    else:
        w = (b_e / se_o)**2
        b = np.sum(w * (b_o/b_e)) / np.sum(w)
        phi = max(1.0, np.sum(w * (b_o/b_e - b)**2) / (n_snps - 1))
        se = np.sqrt(phi / np.sum(w))
        method = "IVW"
    
    pval = 2 * (1 - stats.norm.cdf(abs(b / se)))
    return {"Method": method, "nSNP": n_snps, "Min_F": df['F_stat'].min(), "Beta": b, "SE": se, "P": pval, "OR": np.exp(b)}

# ==========================================
# 4. 执行循环
# ==========================================
if __name__ == "__main__":
    exp_full, out_full = load_and_filter_data()
    genes = exp_full['gene'].unique()
    
    results = []
    print(f"\n开始本地极速分析 (共 {len(genes)} 个基因)...")
    
    for i, gene in enumerate(genes):
        gene_data = exp_full[exp_full['gene'] == gene]
        # 调用本地 PLINK
        clumped = local_ld_clumping(gene_data, gene)
        res = run_mr(clumped, out_full)
        if res:
            res['Gene'] = gene
            results.append(res)
            if (i+1) % 100 == 0:
                print(f"已完成: {i+1}/{len(genes)} ... 当前基因: {gene}")
                pd.DataFrame(results).to_csv(OUTPUT_FILE, index=False) # 定期中间保存

    pd.DataFrame(results).to_csv(OUTPUT_FILE, index=False)
    print(f"\n🎉 分析全部完成！结果见: {OUTPUT_FILE}")