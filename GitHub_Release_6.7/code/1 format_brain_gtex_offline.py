"""
Script 1: Format GTEx Brain eQTL Data (Offline Mode)
Description: Extracts targeted gene eQTLs from the GTEx v8 frontal cortex BA9 dataset 
and maps coordinates to rsIDs using the FinnGen reference dictionary.
"""
import pandas as pd
import requests
from pathlib import Path

# ==========================================
# 0. Configuration & Paths
# ==========================================
# IMPORTANT: Update these relative/absolute paths to match your local environment before running.
DATA_DIR = Path("./data")
BLOOD_SIG_FILE = DATA_DIR / "result_blood_mr_sig.csv"
GTEX_FILE = DATA_DIR / "Brain_Frontal_Cortex_BA9.v8.signif_variant_gene_pairs.txt.gz"
FINNGEN_FILE = DATA_DIR / "finngen_R11_F5_VASCDEM.gz"
OUTPUT_FILE = DATA_DIR / "formatted_brain_BA9.csv"

# ==========================================
# 1. Gene ID Mapping (MyGene API)
# ==========================================
def map_genes_to_ensembl(gene_symbols):
    print(f"Requesting Ensembl IDs for {len(gene_symbols)} genes via MyGene API...")
    url = 'https://mygene.info/v3/query'
    payload = {'q': ','.join(gene_symbols), 'scopes': 'symbol', 'fields': 'ensembl.gene', 'species': 'human'}

    try:
        res = requests.post(url, data=payload).json()
        gene_map = {}
        for item in res:
            if 'ensembl' in item and 'query' in item:
                ensembl_data = item['ensembl']
                if isinstance(ensembl_data, list):
                    for e in ensembl_data: gene_map[e['gene']] = item['query']
                else:
                    gene_map[ensembl_data['gene']] = item['query']
        print(f"Successfully mapped {len(gene_map)} Ensembl IDs.")
        return gene_map
    except Exception as e:
        print(f"API request failed: {e}")
        return {}

# ==========================================
# 2. Main Processing Pipeline
# ==========================================
if __name__ == "__main__":
    print("=== Starting GTEx Brain Data Formatting ===")

    blood_df = pd.read_csv(BLOOD_SIG_FILE)
    target_genes = blood_df['Gene'].unique().tolist()

    ensembl_to_symbol = map_genes_to_ensembl(target_genes)
    target_ensembl_ids = set(ensembl_to_symbol.keys())

    # --- Step 1: Extract GTEx brain data ---
    print("Extracting target genes from GTEx archive...")
    usecols_gtex = ['variant_id', 'gene_id', 'pval_nominal', 'slope', 'slope_se']
    gtex_chunks = []
    
    for chunk in pd.read_csv(GTEX_FILE, compression='gzip', sep='\t', usecols=usecols_gtex, chunksize=200000):
        chunk['ensembl_base'] = chunk['gene_id'].apply(lambda x: x.split('.')[0])
        matched = chunk[chunk['ensembl_base'].isin(target_ensembl_ids)].copy()
        gtex_chunks.append(matched)

    gtex_df = pd.concat(gtex_chunks, ignore_index=True)
    print(f"Extracted {len(gtex_df)} records for target genes.")

    gtex_df['chrom'] = gtex_df['variant_id'].apply(lambda x: x.split('_')[0].replace('chr', ''))
    gtex_df['pos'] = gtex_df['variant_id'].apply(lambda x: int(x.split('_')[1]))
    gtex_df['coord_key'] = gtex_df['chrom'] + "_" + gtex_df['pos'].astype(str)
    target_coords = set(gtex_df['coord_key'])

    # --- Step 2: Map to rsIDs using FinnGen ---
    print("Mapping coordinates to rsIDs using FinnGen dataset...")
    usecols_finn = ['#chrom', 'pos', 'rsids']
    finn_chunks = []
    try:
        for chunk in pd.read_csv(FINNGEN_FILE, compression='gzip', sep='\t', usecols=usecols_finn, chunksize=500000):
            chunk['#chrom'] = chunk['#chrom'].astype(str)
            chunk['coord_key'] = chunk['#chrom'] + "_" + chunk['pos'].astype(str)
            matched = chunk[chunk['coord_key'].isin(target_coords)]
            finn_chunks.append(matched)
    except ValueError:
        usecols_finn = ['chrom', 'pos', 'rsids']
        for chunk in pd.read_csv(FINNGEN_FILE, compression='gzip', sep='\t', usecols=usecols_finn, chunksize=500000):
            chunk['chrom'] = chunk['chrom'].astype(str)
            chunk['coord_key'] = chunk['chrom'] + "_" + chunk['pos'].astype(str)
            matched = chunk[chunk['coord_key'].isin(target_coords)]
            finn_chunks.append(matched)

    finn_dict_df = pd.concat(finn_chunks, ignore_index=True).drop_duplicates('coord_key')
    rsid_map = dict(zip(finn_dict_df['coord_key'], finn_dict_df['rsids']))
    print(f"Successfully matched {len(rsid_map)} rsIDs.")

    # --- Step 3: Assemble final dataset ---
    print("Assembling and exporting final brain dataset...")
    gtex_df['gene'] = gtex_df['ensembl_base'].map(ensembl_to_symbol)
    gtex_df['rsid'] = gtex_df['coord_key'].map(rsid_map)
    gtex_df = gtex_df.dropna(subset=['rsid']).copy()

    gtex_df['other_allele_exp'] = gtex_df['variant_id'].apply(lambda x: x.split('_')[2])
    gtex_df['effect_allele_exp'] = gtex_df['variant_id'].apply(lambda x: x.split('_')[3])
    gtex_df.rename(columns={'pval_nominal': 'pval_exp', 'slope': 'beta_exp', 'slope_se': 'se_exp'}, inplace=True)

    final_cols = ['gene', 'rsid', 'effect_allele_exp', 'other_allele_exp', 'beta_exp', 'se_exp', 'pval_exp']
    final_df = gtex_df[final_cols]
    
    # Ensure directory exists before saving
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    final_df.to_csv(OUTPUT_FILE, index=False)
    print(f"Done. Saved to: {OUTPUT_FILE}")