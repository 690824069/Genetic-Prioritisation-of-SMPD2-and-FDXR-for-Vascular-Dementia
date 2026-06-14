# Reproducibility Notes

## Environment

The original analysis used local Python and PowerShell scripts on Windows, with PLINK used for LD clumping and pairwise LD checks. Some scripts require local paths to third-party resources and should be edited before rerunning in a new environment.

## Key Workflow Stages

1. Format blood and brain eQTL instruments.
2. Harmonise eQTL instruments with FinnGen vascular dementia GWAS.
3. Run blood and brain eQTL-based Mendelian randomization.
4. Identify directionally consistent cross-tissue candidates.
5. Run Bayesian colocalization.
6. Generate Supplementary Tables S1-S3.
7. Perform external transcriptomic contextualisation and resampling analyses.
8. Generate residual limitations table S4.
9. Perform post hoc instrument-resolution audit and generate S5.

## 6.7 Single-SNP Audit

The post hoc audit used eQTLGen whole-blood cis-eQTLs passing P < 5e-8, PLINK clumping with 1000 Genomes EUR, a 1000-kb window, and r2 < 0.001 as the strict screen. A looser r2 < 0.01 screen was reported only as sensitivity information.

SMPD2 had a possible alternative two-instrument configuration, rs13220304 + rs1113666. FDXR did not.

## Caveat

LD clumping is not equivalent to formal conditional eQTL analysis. The SMPD2 alternative two-instrument configuration should therefore be interpreted as audit/sensitivity evidence until fully harmonised and confirmed.

