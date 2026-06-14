"""
Script 2: Mendelian Randomization Analysis
Description: Performs two-sample Mendelian randomization (Wald ratio/IVW) 
between eQTL data and the vascular dementia GWAS outcome.
Note: Requires OpenGWAS API token for LD clumping.
"""
import pandas as pd
import numpy as np
import requests
import time
from scipy import stats
from pathlib import Path

# ==========================================
# 0. Configuration & Paths
# ==========================================
DATA_DIR = Path("./data")
EQTL_FILE = DATA_DIR / "2019-12-11-cis-eQTLsFDR-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt"
OUTCOME_FILE = DATA_DIR / "finngen_R11_F5_VASCDEM.gz"
OUTPUT_FILE = DATA_DIR / "Result_VaD_MR_Blood.csv"

BONFERRONI_P = 2.96e-6
# IMPORTANT: Users must replace this placeholder with their own OpenGWAS API token
MY_JWT_TOKEN = 'YOUR_OPENGWAS_API_TOKEN_HERE' 

# ==========================================
# 1. Functions
# ==========================================
def process_eqtlgen_data(file_path, p_threshold):
    print(f"Scanning eQTL data (P-value threshold: < {p_threshold})...")
    chunk_size = 500000
    significant_chunks = []
    usecols = ['Pvalue', 'SNP', 'AssessedAllele', 'OtherAllele', 'Zscore', 'GeneSymbol']

    for chunk in pd.read_csv(file_path, sep='\t', usecols=usecols, chunksize=chunk_size):
        sig_chunk = chunk[chunk['Pvalue'] < p_threshold].copy()
        if not sig_chunk.empty:
            N = 31684
            sig_chunk['beta_exp'] = sig_chunk['Zscore'] / np.sqrt(N)
            sig_chunk['se_exp'] = 1 / np.sqrt(N)
            sig_chunk.rename(columns={
                'SNP': 'rsid', 'Pvalue': 'pval_exp',
                'AssessedAllele': 'effect_allele_exp', 'OtherAllele': 'other_allele_exp',
                'GeneSymbol': 'gene'
            }, inplace=True)
            significant_chunks.append(sig_chunk)

    full_sig_df = pd.concat(significant_chunks, ignore_index=True)
    return full_sig_df

def ld_clumping(df, r2=0.001, kb=10000, pop='EUR'):
    if len(df) <= 1: return df
    df = df.sort_values('pval_exp')
    variants = [{"rsid": row['rsid'], "pval": row['pval_exp']} for _, row in df.iterrows()]

    url = "https://api.opengwas.io/api/ld/clump"
    headers = {"Authorization": f"Bearer {MY_JWT_TOKEN}"}
    payload = {"rsid": [v["rsid"] for v in variants], "pval": [v["pval"] for v in variants], "pop": pop, "r2": r2, "kb": kb}

    try:
        time.sleep(1.5)
        response = requests.post(url, json=payload, headers=headers)
        if response.status_code == 200:
            clumped_rsids = [item['rsid'] for item in response.json()]
            return df[df['rsid'].isin(clumped_rsids)].copy()
        else:
            return df.head(1) 
    except Exception as e:
        return df.head(1)

def extract_outcome_data(file_path, target_rsids):
    print(f"Scanning GWAS outcome data...")
    usecols = ['rsids', 'alt', 'ref', 'beta', 'sebeta', 'pval']
    matched_chunks = []
    
    for chunk in pd.read_csv(file_path, compression='gzip', sep='\t', usecols=usecols, chunksize=500000):
        matched_chunks.append(chunk[chunk['rsids'].isin(target_rsids)])

    outcome_df = pd.concat(matched_chunks, ignore_index=True)
    outcome_df.rename(columns={
        'rsids': 'rsid', 'alt': 'effect_allele_out', 'ref': 'other_allele_out',
        'beta': 'beta_out', 'sebeta': 'se_out', 'pval': 'pval_out'
    }, inplace=True)
    return outcome_df

def perform_mr(exp_df, out_df):
    df = pd.merge(exp_df, out_df, on='rsid', how='inner')
    if len(df) == 0: return None

    df['effect_allele_exp'] = df['effect_allele_exp'].str.upper()
    df['other_allele_exp'] = df['other_allele_exp'].str.upper()
    df['effect_allele_out'] = df['effect_allele_out'].str.upper()
    df['other_allele_out'] = df['other_allele_out'].str.upper()

    needs_flip = (df['effect_allele_exp'] == df['other_allele_out']) & (df['other_allele_exp'] == df['effect_allele_out'])
    df.loc[needs_flip, 'beta_out'] *= -1

    valid_mask = ((df['effect_allele_exp'] == df['effect_allele_out']) & (df['other_allele_exp'] == df['other_allele_out'])) | needs_flip
    df = df[valid_mask].copy()

    n_snps = len(df)
    if n_snps == 0: return None

    df['F_stat'] = (df['beta_exp'] / df['se_exp']) ** 2
    min_F = df['F_stat'].min()

    b_exp, se_exp = df['beta_exp'].values, df['se_exp'].values
    b_out, se_out = df['beta_out'].values, df['se_out'].values

    if n_snps == 1:
        mr_beta = b_out[0] / b_exp[0]
        mr_se = se_out[0] / abs(b_exp[0])
        method = "Wald ratio"
    else:
        w = (b_exp / se_out) ** 2
        mr_beta = np.sum(w * (b_out / b_exp)) / np.sum(w)
        Q = np.sum(w * (b_out / b_exp - mr_beta) ** 2)
        phi = max(1.0, Q / (n_snps - 1))
        mr_se = np.sqrt(phi / np.sum(w))
        method = "IVW"

    mr_pval = 2 * (1 - stats.norm.cdf(abs(mr_beta / mr_se)))

    return {
        "Method": method, "nSNP": n_snps, "Min_F": round(min_F, 2),
        "Beta": mr_beta, "SE": mr_se, "P_value": mr_pval,
        "OR": np.exp(mr_beta), "OR_lower": np.exp(mr_beta - 1.96 * mr_se), "OR_upper": np.exp(mr_beta + 1.96 * mr_se)
    }

# ==========================================
# 2. Main Execution
# ==========================================
if __name__ == "__main__":
    print("=== Starting MR Analysis ===")
    sig_exposure_df = process_eqtlgen_data(EQTL_FILE, BONFERRONI_P)
    all_target_rsids = set(sig_exposure_df['rsid'])
    outcome_df = extract_outcome_data(OUTCOME_FILE, all_target_rsids)

    results_list = []
    unique_genes = sig_exposure_df['gene'].unique()
    
    print(f"\nProcessing {len(unique_genes)} genes...")
    for i, gene in enumerate(unique_genes):
        gene_exp_df = sig_exposure_df[sig_exposure_df['gene'] == gene].copy()
        clumped_exp = ld_clumping(gene_exp_df)
        res = perform_mr(clumped_exp, outcome_df)
        if res:
            res['Gene'] = gene
            results_list.append(res)
            print(f"[{i+1}/{len(unique_genes)}] {gene}: Success")
        else:
            print(f"[{i+1}/{len(unique_genes)}] {gene}: No valid instruments")

    if results_list:
        final_df = pd.DataFrame(results_list)
        cols = ['Gene', 'Method', 'nSNP', 'Min_F', 'Beta', 'SE', 'OR', 'OR_lower', 'OR_upper', 'P_value']
        final_df = final_df[cols]
        OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
        final_df.to_csv(OUTPUT_FILE, index=False)
        print(f"\nAnalysis complete. Results saved to: {OUTPUT_FILE}")