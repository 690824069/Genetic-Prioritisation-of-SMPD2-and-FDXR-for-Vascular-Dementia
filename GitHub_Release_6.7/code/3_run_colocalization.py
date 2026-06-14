"""
Script 3: Bayesian Colocalization Analysis
Description: Calculates Approximate Bayes Factors (ABF) to estimate the posterior 
probability (PP4) of a shared causal variant between eQTL and GWAS signals.
"""
import pandas as pd
import numpy as np
import os
from pathlib import Path

# ==========================================
# 0. Configuration & Paths
# ==========================================
DATA_DIR = Path("./data")
TARGET_GENES_FILE = DATA_DIR / "prioritised_genes_for_coloc.csv"
BRAIN_EQTL_FILE = DATA_DIR / "formatted_brain_BA9.csv"
GWAS_FILE = DATA_DIR / "finngen_R11_F5_VASCDEM.gz"
OUTPUT_FILE = DATA_DIR / "Result_Coloc_Final.csv"

# Colocalization Priors
P1, P2, P12 = 1e-4, 1e-4, 1e-5

# ==========================================
# 1. ABF Calculation Functions
# ==========================================
def logsumexp(x):
    xmax = np.max(x)
    return xmax + np.log(np.sum(np.exp(x - xmax)))

def calc_abf(z, v, w):
    r = w / (v + w)
    return 0.5 * (np.log(1 - r) + (r * z**2))

def perform_colocalization(df, gene_name):
    n_snps = len(df)
    if n_snps == 0: return None

    W1, W2 = 0.15**2, 0.20**2

    # Trait 1 (eQTL)
    V1 = df['se_exp']**2
    Z1 = df['beta_exp'] / df['se_exp']
    lbf1 = calc_abf(Z1, V1, W1).values

    # Trait 2 (GWAS)
    V2 = df['se_out']**2
    Z2 = df['beta_out'] / df['se_out']
    lbf2 = calc_abf(Z2, V2, W2).values

    sum_lbf1 = logsumexp(lbf1)
    sum_lbf2 = logsumexp(lbf2)
    sum_lbf12 = logsumexp(lbf1 + lbf2)

    lH0 = 0.0
    lH1 = np.log(P1) + sum_lbf1
    lH2 = np.log(P2) + sum_lbf2
    
    A, B = sum_lbf1 + sum_lbf2, sum_lbf12
    lH3 = (np.log(P1) + np.log(P2) + A + np.log(1 - np.exp(B - A))) if A > B else -np.inf
    lH4 = np.log(P12) + sum_lbf12

    lH_all = np.array([lH0, lH1, lH2, lH3, lH4])
    lH_max = np.max(lH_all)
    PP = np.exp(lH_all - lH_max) / np.sum(np.exp(lH_all - lH_max))

    return {
        "Gene": gene_name, "n_SNPs": n_snps,
        "PP0": round(PP[0], 6), "PP1": round(PP[1], 6),
        "PP2": round(PP[2], 6), "PP3": round(PP[3], 6), "PP4": round(PP[4], 6)
    }

# ==========================================
# 2. Main Execution
# ==========================================
if __name__ == "__main__":
    print("=== Starting Colocalization Analysis ===")
    
    target_df = pd.read_csv(TARGET_GENES_FILE)
    golden_genes = set(target_df['Gene'])
    
    brain_df = pd.read_csv(BRAIN_EQTL_FILE)
    brain_df = brain_df[brain_df['gene'].isin(golden_genes)].copy()
    target_rsids = set(brain_df['rsid'])

    print("Extracting GWAS outcome data...")
    usecols_gwas = ['rsids', 'alt', 'ref', 'beta', 'sebeta']
    gwas_chunks = [chunk[chunk['rsids'].isin(target_rsids)] for chunk in pd.read_csv(GWAS_FILE, compression='gzip', sep='\t', usecols=usecols_gwas, chunksize=1000000)]
    gwas_df = pd.concat(gwas_chunks, ignore_index=True)
    gwas_df.rename(columns={'rsids':'rsid', 'alt':'effect_allele_out', 'ref':'other_allele_out', 'beta':'beta_out', 'sebeta':'se_out'}, inplace=True)

    results = []
    print("\nCalculating posterior probabilities...")
    for gene in golden_genes:
        exp = brain_df[brain_df['gene'] == gene].copy()
        df = pd.merge(exp, gwas_df, on='rsid', how='inner')
        if df.empty: continue
            
        df['e_exp'] = df['effect_allele_exp'].str.upper()
        df['o_exp'] = df['other_allele_exp'].str.upper()
        df['e_out'] = df['effect_allele_out'].str.upper()
        df['o_out'] = df['other_allele_out'].str.upper()
        
        match_mask = (df['e_exp'] == df['e_out']) & (df['o_exp'] == df['o_out'])
        flip_mask = (df['e_exp'] == df['o_out']) & (df['o_exp'] == df['e_out'])
        df = df[match_mask | flip_mask].copy()
        df.loc[flip_mask, 'beta_out'] *= -1
        
        res = perform_colocalization(df, gene)
        if res:
            results.append(res)
            if res['PP4'] > 0.5:
                print(f"Colocalized Target: {gene} (PP4 = {res['PP4']:.3f})")

    if results:
        final_coloc_df = pd.DataFrame(results).sort_values(by="PP4", ascending=False)
        OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
        final_coloc_df.to_csv(OUTPUT_FILE, index=False)
        print(f"\nAnalysis complete. Saved to: {OUTPUT_FILE}")