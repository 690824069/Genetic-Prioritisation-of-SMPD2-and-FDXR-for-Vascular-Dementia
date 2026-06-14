"""
Script 4: Generate Harmonized IVs for Supplementary Table S2
Description: Extracts and formats harmonized instrument-level data 
for prioritized cross-tissue targets.
"""
import pandas as pd
import numpy as np
import requests
import time
from pathlib import Path

# ==========================================
# 0. Configuration & Paths
# ==========================================
DATA_DIR = Path("./data")
EQTL_FILE = DATA_DIR / "2019-12-11-cis-eQTLsFDR-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt"
OUTCOME_FILE = DATA_DIR / "finngen_R11_F5_VASCDEM.gz"
BRAIN_MR_FILE = DATA_DIR / "Result_Brain_MR_Final.csv"
S2_OUTPUT_FILE = DATA_DIR / "Supplementary_Table_S2_Harmonised_IVs.csv"

BONFERRONI_P = 2.96e-6
# IMPORTANT: Provide valid API token before running
MY_JWT_TOKEN = 'YOUR_OPENGWAS_API_TOKEN_HERE'

# ==========================================
# 1. Main Execution
# ==========================================
if __name__ == "__main__":
    print("=== Generating Data for Supplementary Table S2 ===")
    
    brain_df = pd.read_csv(BRAIN_MR_FILE)
    gene_col = 'Gene' if 'Gene' in brain_df.columns else 'gene'
    target_genes = set(brain_df[gene_col].dropna().unique())

    print("Extracting eQTL data for prioritized genes...")
    significant_chunks = []
    usecols = ['Pvalue', 'SNP', 'AssessedAllele', 'OtherAllele', 'Zscore', 'GeneSymbol']

    for chunk in pd.read_csv(EQTL_FILE, sep='\t', usecols=usecols, chunksize=1000000):
        sig_chunk = chunk[(chunk['GeneSymbol'].isin(target_genes)) & (chunk['Pvalue'] < BONFERRONI_P)].copy()
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

    def ld_clumping(df, r2=0.001, kb=10000, pop='EUR'):
        if len(df) <= 1: return df
        df = df.sort_values('pval_exp')
        variants = [{"rsid": row['rsid'], "pval": row['pval_exp']} for _, row in df.iterrows()]
        url = "https://api.opengwas.io/api/ld/clump"
        headers = {"Authorization": f"Bearer {MY_JWT_TOKEN}"}
        payload = {"rsid": [v["rsid"] for v in variants], "pval": [v["pval"] for v in variants], "pop": pop, "r2": r2, "kb": kb}
        try:
            time.sleep(1.0)
            response = requests.post(url, json=payload, headers=headers)
            if response.status_code == 200:
                return df[df['rsid'].isin([item['rsid'] for item in response.json()])].copy()
        except: pass
        return df.head(1)

    print("Applying LD clumping...")
    clumped_dfs = [ld_clumping(full_sig_df[full_sig_df['gene'] == gene]) for gene in target_genes]
    final_exp_df = pd.concat(clumped_dfs, ignore_index=True)

    print("Extracting GWAS outcome data...")
    usecols_out = ['rsids', 'alt', 'ref', 'beta', 'sebeta', 'pval']
    target_rsids = set(final_exp_df['rsid'])
    matched_chunks = [chunk[chunk['rsids'].isin(target_rsids)] for chunk in pd.read_csv(OUTCOME_FILE, compression='gzip', sep='\t', usecols=usecols_out, chunksize=500000)]
    outcome_df = pd.concat(matched_chunks, ignore_index=True)
    outcome_df.rename(columns={'rsids': 'rsid', 'alt': 'effect_allele_out', 'ref': 'other_allele_out', 'beta': 'beta_out', 'sebeta': 'se_out', 'pval': 'pval_out'}, inplace=True)

    print("Harmonizing datasets...")
    df = pd.merge(final_exp_df, outcome_df, on='rsid', how='inner')
    for col in ['effect_allele_exp', 'other_allele_exp', 'effect_allele_out', 'other_allele_out']: df[col] = df[col].str.upper()

    needs_flip = (df['effect_allele_exp'] == df['other_allele_out']) & (df['other_allele_exp'] == df['effect_allele_out'])
    df.loc[needs_flip, 'beta_out'] *= -1
    df['harmonised_direction'] = np.where(needs_flip, 'Flipped', 'Matched')
    
    valid_mask = ((df['effect_allele_exp'] == df['effect_allele_out']) & (df['other_allele_exp'] == df['other_allele_out'])) | needs_flip
    df = df[valid_mask].copy()

    df['F_stat'] = (df['beta_exp'] / df['se_exp']) ** 2

    s2_cols = ['gene', 'rsid', 'effect_allele_exp', 'other_allele_exp', 'beta_exp', 'se_exp', 'pval_exp', 'beta_out', 'se_out', 'pval_out', 'F_stat', 'harmonised_direction']
    df = df[s2_cols].round({'beta_exp': 4, 'se_exp': 4, 'beta_out': 4, 'se_out': 4, 'F_stat': 2})

    df.rename(columns={
        'gene': 'Gene', 'rsid': 'rsID',
        'effect_allele_exp': 'Effect_Allele', 'other_allele_exp': 'Other_Allele',
        'beta_exp': 'eQTL_Beta', 'se_exp': 'eQTL_SE', 'pval_exp': 'eQTL_Pval',
        'beta_out': 'GWAS_Beta', 'se_out': 'GWAS_SE', 'pval_out': 'GWAS_Pval',
        'F_stat': 'F_Statistic', 'harmonised_direction': 'Harmonised_Direction'
    }, inplace=True)

    S2_OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(S2_OUTPUT_FILE, index=False)
    print(f"Table S2 generation complete. Saved to: {S2_OUTPUT_FILE}")