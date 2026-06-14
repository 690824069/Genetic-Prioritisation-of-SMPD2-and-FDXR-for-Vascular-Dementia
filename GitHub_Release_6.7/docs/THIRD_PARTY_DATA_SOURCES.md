# Third-Party Data Sources

This project depends on public or controlled-access resources that should be downloaded by users from the original providers.

## Required External Inputs

1. eQTLGen whole-blood cis-eQTL summary statistics  
   Used for blood cis-eQTL instrument selection and post hoc SMPD2/FDXR instrument-resolution audit.

2. FinnGen R11 vascular dementia GWAS summary statistics  
   Used as the primary vascular dementia outcome.

3. GTEx v8 Brain Frontal Cortex BA9 eQTL data  
   Used for brain BA9 cross-tissue assessment and independent eQTL audit.

4. 1000 Genomes European LD reference panel  
   Used for LD clumping and pairwise LD checks.

5. GEO datasets GSE186798, GSE22255, and GSE58294  
   Used for targeted transcriptomic contextualisation.

6. CZ CELLxGENE Human Brain Cell Atlas v1.0  
   Used for descriptive single-cell expression mapping.

## Why These Files Are Not Included

The full source datasets are large and subject to provider-specific licences, attribution requirements, or data-use terms. This release therefore includes only derived manuscript-level outputs and source-data tables generated from the analysis.

