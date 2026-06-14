import pandas as pd
import numpy as np
import subprocess
import os
from scipy import stats
from pathlib import Path

# ==========================================
# 0. 全局路径配置 (请根据实际情况微调)
# ==========================================
ROOT_DIR = Path(r"F:\文献数据")

# 1. 第一阶段的阳性基因名单
BLOOD_SIG_FILE = ROOT_DIR / "result_blood_mr_sig.csv"

# 2. 清洗好的大脑 BA9 数据 (请确保运行了您的 R 脚本生成此文件)
BRAIN_EQTL_FILE = ROOT_DIR / "formatted_brain_BA9.csv" 

# 3. 结局数据 (血管性痴呆)
OUTCOME_FILE = ROOT_DIR / "finngen_R11_F5_VASCDEM.gz"

# 4. 本地 PLINK 及参考面板
PLINK_EXE = ROOT_DIR / "plink.exe"
REF_PANEL = ROOT_DIR / "EUR"

# 输出结果
OUTPUT_FILE = ROOT_DIR / "Result_Brain_MR_Final.csv"
TEMP_DIR = ROOT_DIR / "temp_clump_brain"
os.makedirs(TEMP_DIR, exist_ok=True)

# ==========================================
# 1. 本地 PLINK Clumping 引擎
# ==========================================
def local_ld_clumping(df, gene_name):
    if len(df) <= 1: return df
    input_txt = TEMP_DIR / f"{gene_name}_brain_to_clump.txt"
    df[['rsid', 'pval_exp']].to_csv(input_txt, sep='\t', index=False)
    out_prefix = TEMP_DIR / f"{gene_name}_brain_clumped"
    
    cmd = [
        str(PLINK_EXE), "--bfile", str(REF_PANEL),
        "--clump", str(input_txt), "--clump-field", "pval_exp", "--clump-snp-field", "rsid",
        "--clump-p1", "1", "--clump-r2", "0.001", "--clump-kb", "10000",
        "--out", str(out_prefix), "--noweb"
    ]
    try:
        subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
        clumped_file = Path(str(out_prefix) + ".clumped")
        if clumped_file.exists():
            clumped_data = pd.read_csv(clumped_file, sep=r'\s+', usecols=['SNP'])
            for f in TEMP_DIR.glob(f"{gene_name}_brain_*"): 
                try: os.remove(f)
                except: pass
            return df[df['rsid'].isin(clumped_data['SNP'].tolist())].copy()
    except Exception: pass
    return df.head(1)

# ==========================================
# 2. 核心 MR 与对齐引擎
# ==========================================
def run_mr(exp, out):
    df = pd.merge(exp, out, on='rsid', how='inner')
    if df.empty: return None
    
    # 大写标准化
    for col in ['e_exp', 'o_exp', 'e_out', 'o_out']:
        col_map = {'e_exp':'effect_allele_exp', 'o_exp':'other_allele_exp', 'e_out':'effect_allele_out', 'o_out':'other_allele_out'}
        df[col] = df[col_map[col]].str.upper()
        
    match_mask = (df['e_exp'] == df['e_out']) & (df['o_exp'] == df['o_out'])
    flip_mask = (df['e_exp'] == df['o_out']) & (df['o_exp'] == df['e_out'])
    df = df[match_mask | flip_mask].copy()
    if df.empty: return None
    
    df.loc[flip_mask, 'beta_out'] *= -1
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
    return {"Method": method, "nSNP_Brain": n_snps, "Min_F_Brain": df['F_stat'].min(), 
            "Beta_Brain": b, "SE_Brain": se, "P_Brain": pval, "OR_Brain": np.exp(b)}

# ==========================================
# 3. 主控制台
# ==========================================
if __name__ == "__main__":
    print("🚀 正在加载第一阶段血液阳性基因名单...")
    blood_sig_df = pd.read_csv(BLOOD_SIG_FILE)
    target_genes = set(blood_sig_df['Gene'])
    print(f"🎯 共有 {len(target_genes)} 个候选基因需要在大脑中进行验证。")
    
    print("🧠 正在加载大脑 BA9 eQTL 数据...")
    # 注意：这里的列名需要根据您 R 脚本清洗后的实际列名进行调整
    brain_df = pd.read_csv(BRAIN_EQTL_FILE) 
    # 重命名列以适配流水线
    brain_df.rename(columns={
        'SNP': 'rsid', 'Pvalue': 'pval_exp', 'GeneSymbol': 'gene',
        'AssessedAllele': 'effect_allele_exp', 'OtherAllele': 'other_allele_exp',
        'Beta': 'beta_exp', 'SE': 'se_exp'
    }, inplace=True, errors='ignore')
    
    # 仅提取目标基因的脑部数据
    brain_exp_df = brain_df[brain_df['gene'].isin(target_genes)].copy()
    valid_brain_genes = brain_exp_df['gene'].unique()
    print(f"⚠️ 在大脑 BA9 数据中，找到了其中 {len(valid_brain_genes)} 个基因的 eQTL 表达。")
    
    print("🧬 正在加载 FinnGen VaD 结局数据...")
    target_rsids = set(brain_exp_df['rsid'])
    out_cols = ['rsids', 'alt', 'ref', 'beta', 'sebeta', 'pval']
    out_chunks = [chunk[chunk['rsids'].isin(target_rsids)] for chunk in pd.read_csv(OUTCOME_FILE, compression='gzip', sep='\t', usecols=out_cols, chunksize=1000000)]
    out_df = pd.concat(out_chunks, ignore_index=True)
    out_df.rename(columns={'rsids':'rsid', 'alt':'effect_allele_out', 'ref':'other_allele_out', 'beta':'beta_out', 'sebeta':'se_out', 'pval':'pval_out'}, inplace=True)
    
    results = []
    print("\n🔬 开始脑组织 MR 验证...")
    for i, gene in enumerate(valid_brain_genes):
        gene_data = brain_exp_df[brain_exp_df['gene'] == gene]
        clumped = local_ld_clumping(gene_data, gene)
        res = run_mr(clumped, out_df)
        if res:
            res['Gene'] = gene
            results.append(res)
            
        if (i+1) % 50 == 0:
            print(f"已验证: {i+1}/{len(valid_brain_genes)} ... 当前基因: {gene}")
            pd.DataFrame(results).to_csv(OUTPUT_FILE, index=False)

    pd.DataFrame(results).to_csv(OUTPUT_FILE, index=False)
    print(f"\n🎉 脑组织验证全部完成！双组织结果已保存至: {OUTPUT_FILE}")