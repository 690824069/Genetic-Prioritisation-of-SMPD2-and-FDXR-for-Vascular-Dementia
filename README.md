# Genetic Prioritisation of SMPD2 and FDXR for Vascular Dementia

This repository contains reproducibility materials, derived data, supplementary tables, figure source data, and audit files for the manuscript:

**Genetic prioritisation of SMPD2 and FDXR for vascular dementia through multi-tissue Mendelian randomization, colocalization, and transcriptomic contextualisation**

Version: 6.7 single-SNP audit  
Prepared: 2026-06-14

## Contents

- `code/`: analysis and document-generation scripts used to format eQTL inputs, run Mendelian randomization, perform colocalization, generate tables, generate figure source data, and add the 6.7 instrument-resolution audit.
- `data/supplementary_tables/`: final Supplementary Tables S1-S5 for the 6.7 manuscript.
- `data/processed/`: derived, manuscript-level processed outputs and post hoc single-SNP instrument-resolution audit files.
- `data/figure_source/`: source data for Figure 2, Figure 4, and Supplementary Figure S2.
- `figures/`: rendered figure files included for review and reuse.
- `docs/`: data availability, third-party data provenance, file manifest, and reuse notes.

## Important Data-Use Note

Large third-party datasets are **not redistributed** here. In particular, the full FinnGen GWAS, eQTLGen cis-eQTL, GTEx eQTL, 1000 Genomes LD reference, GEO processed profile data, and CZ CELLxGENE resources should be obtained from their original providers under their own terms of use.

This repository provides derived manuscript outputs and small audit/source-data files needed to reproduce the reported tables and figures, together with scripts describing the analysis workflow.

## Key Result-Version Note

The final primary blood MR estimate for **SMPD2** remains the single-SNP rs7372 Wald ratio estimate:

- OR = 1.29
- 95% CI = 1.08-1.55
- P = 0.00462

The 6.7 post hoc instrument-resolution audit identified a possible alternative two-instrument blood cis-eQTL configuration for SMPD2:

- rs13220304
- rs1113666
- pairwise LD r2 = 0.000274 in 1000 Genomes EUR

This audit is reported as supplementary sensitivity/audit evidence and does **not** replace the primary rs7372 result. FDXR remains single-instrument in the audited blood and brain resources.
  
