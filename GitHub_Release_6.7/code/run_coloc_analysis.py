import pandas as pd
import numpy as np
import os
from pathlib import Path

# ==========================================
# 0. 全局路径配置
# ==========================================
ROOT_DIR = Path(r"F:\文献数据")

# 输入文件
TARGET_GENES_FILE = ROOT_DIR / "coloc" / "prioritised_genes_for_coloc.csv"
BRAIN_EQTL_FILE = ROOT_DIR / "formatted_brain_BA9.csv"
GWAS_FILE = ROOT_DIR / "finngen_R11_F5_VASCDEM.gz"

# 输出文件
OUTPUT_FILE = ROOT_DIR / "coloc" / "Result_Coloc_Final.csv"
os.makedirs(OUTPUT_FILE.parent, exist_ok=True)

# 共定位先验概率 (Priors) - 国际顶刊标准默认值
P1 = 1e-4   # SNP 仅与 eQTL 相关的先验概率
P2 = 1e-4   # SNP 仅与 VaD 相关的先验概率
P12 = 1e-5  # SNP 同时与 eQTL 和 VaD 相关的先验概率 (共定位)

# ==========================================
# 1. 核心数学引擎：近似贝叶斯因子 (ABF) 
# ==========================================
def logsumexp(x):
    """防止指数爆炸的防溢出算法 (等同于 scipy.special.logsumexp)"""
    xmax = np.max(x)
    return xmax + np.log(np.sum(np.exp(x - xmax)))

def calc_abf(z, v, w):
    """计算单个 SNP 的 Log ABF (Approximate Bayes Factor)"""
    r = w / (v + w)
    lbf = 0.5 * (np.log(1 - r) + (r * z**2))
    return lbf

def perform_colocalization(df, gene_name):
    """
    执行贝叶斯共定位分析，完全等效于 R 语言的 coloc.abf()
    """
    n_snps = len(df)
    if n_snps == 0:
        return None

    # W: 真实效应的先验方差
    W1 = 0.15**2  # 连续型变量 (eQTL) 的标准先验
    W2 = 0.20**2  # 二分类变量 (GWAS 病例对照) 的标准先验

    # 提取并计算 Trait 1 (脑组织 eQTL) 的参数
    V1 = df['se_exp']**2
    Z1 = df['beta_exp'] / df['se_exp']
    lbf1 = calc_abf(Z1, V1, W1).values

    # 提取并计算 Trait 2 (FinnGen VaD) 的参数
    V2 = df['se_out']**2
    Z2 = df['beta_out'] / df['se_out']
    lbf2 = calc_abf(Z2, V2, W2).values

    # --- 计算 5 种假设的未归一化对数后验概率 ---
    sum_lbf1 = logsumexp(lbf1)
    sum_lbf2 = logsumexp(lbf2)
    sum_lbf12 = logsumexp(lbf1 + lbf2)

    lH0 = 0.0
    lH1 = np.log(P1) + sum_lbf1
    lH2 = np.log(P2) + sum_lbf2
    
    # H3: 两个独立信号 (需要减去重叠部分)
    A = sum_lbf1 + sum_lbf2
    B = sum_lbf12
    if A > B:
        lH3 = np.log(P1) + np.log(P2) + A + np.log(1 - np.exp(B - A))
    else:
        lH3 = -np.inf # 极少发生的边缘情况
        
    lH4 = np.log(P12) + sum_lbf12

    # --- 归一化，得到真正的 PP (Posterior Probabilities) ---
    lH_all = np.array([lH0, lH1, lH2, lH3, lH4])
    lH_max = np.max(lH_all)
    
    # 再次使用防溢出技巧转回普通概率
    PP = np.exp(lH_all - lH_max) / np.sum(np.exp(lH_all - lH_max))

    return {
        "Gene": gene_name,
        "n_SNPs": n_snps,
        "PP0": round(PP[0], 6), # 均不相关
        "PP1": round(PP[1], 6), # 仅与 eQTL 相关
        "PP2": round(PP[2], 6), # 仅与 VaD 相关
        "PP3": round(PP[3], 6), # 独立位点分别相关
        "PP4": round(PP[4], 6)  # 🏆 同一位点共定位！(我们要找的)
    }

# ==========================================
# 2. 数据读取与对齐流水线
# ==========================================
if __name__ == "__main__":
    print("🧬 正在启动纯 Python 贝叶斯共定位引擎...")
    
    # 1. 加载 44 个黄金靶点
    target_df = pd.read_csv(TARGET_GENES_FILE)
    golden_genes = set(target_df['Gene'])
    print(f"🎯 成功锁定 {len(golden_genes)} 个黄金跨组织靶点。")

    # 2. 加载之前清洗好的脑组织数据 (Trait 1)
    print("🧠 正在提取脑组织区域 SNP...")
    brain_df = pd.read_csv(BRAIN_EQTL_FILE)
    brain_df = brain_df[brain_df['gene'].isin(golden_genes)].copy()
    
    target_rsids = set(brain_df['rsid'])
    print(f"   => 共提取到 {len(target_rsids)} 个相关 SNP。")

    # 3. 极速扫描 FinnGen GWAS 数据 (Trait 2)
    print("🩸 正在扫描 FinnGen 血管性痴呆数据包...")
    usecols_gwas = ['rsids', 'alt', 'ref', 'beta', 'sebeta']
    
    gwas_chunks = []
    for chunk in pd.read_csv(GWAS_FILE, compression='gzip', sep='\t', usecols=usecols_gwas, chunksize=1000000):
        matched = chunk[chunk['rsids'].isin(target_rsids)]
        gwas_chunks.append(matched)
        
    gwas_df = pd.concat(gwas_chunks, ignore_index=True)
    gwas_df.rename(columns={'rsids':'rsid', 'alt':'effect_allele_out', 'ref':'other_allele_out', 
                            'beta':'beta_out', 'sebeta':'se_out'}, inplace=True)
    
    print(f"   => 成功从 GWAS 中提取了对应的 {len(gwas_df)} 个 SNP 数据。")

    # 4. 逐个基因进行共定位分析
    results = []
    print("\n🔬 开始计算后验概率 (PP4)...")
    
    for i, gene in enumerate(golden_genes):
        # 取出该基因的所有 eQTL SNP
        exp = brain_df[brain_df['gene'] == gene].copy()
        
        # 融合 GWAS 数据
        df = pd.merge(exp, gwas_df, on='rsid', how='inner')
        if df.empty:
            continue
            
        # 严格的等位基因方向对齐 (Harmonization)
        df['e_exp'] = df['effect_allele_exp'].str.upper()
        df['o_exp'] = df['other_allele_exp'].str.upper()
        df['e_out'] = df['effect_allele_out'].str.upper()
        df['o_out'] = df['other_allele_out'].str.upper()
        
        match_mask = (df['e_exp'] == df['e_out']) & (df['o_exp'] == df['o_out'])
        flip_mask = (df['e_exp'] == df['o_out']) & (df['o_exp'] == df['e_out'])
        
        df = df[match_mask | flip_mask].copy()
        df.loc[flip_mask, 'beta_out'] *= -1
        
        # 将对齐好的数据送入数学引擎
        res = perform_colocalization(df, gene)
        if res:
            results.append(res)
            # 实时播报高分靶点
            if res['PP4'] > 0.5:
                print(f"  ⭐⭐⭐ 爆款出现！{gene}: PP4 = {res['PP4']*100:.2f}% (支持共定位)")
            elif res['PP4'] > 0.1:
                print(f"  ⭐ 潜力股！{gene}: PP4 = {res['PP4']*100:.2f}%")

    # 5. 保存最终战果
    if results:
        final_coloc_df = pd.DataFrame(results)
        # 按 PP4 从大到小排序，把最好的放在最上面！
        final_coloc_df = final_coloc_df.sort_values(by="PP4", ascending=False)
        final_coloc_df.to_csv(OUTPUT_FILE, index=False)
        
        print(f"\n🎉 惊险刺激的共定位结束！")
        print(f"🏆 最终结果已排序并保存至: {OUTPUT_FILE}")
    else:
        print("计算完毕，但未产生有效结果。")