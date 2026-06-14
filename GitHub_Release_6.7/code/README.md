# 🧬 Vascular Dementia Targets Prioritization Pipeline

[![Python Version](https://img.shields.io/badge/python-3.8%2B-blue.svg)](https://www.python.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.YOUR_DOI_HERE.svg)](https://doi.org/10.5281/zenodo.19952480)

> **Analytical pipeline and custom Python scripts for the multi-tissue Mendelian randomization and Bayesian colocalization study prioritizing candidate targets for vascular dementia.**

## 📌 Overview

This repository contains the complete analytical pipeline used in our study to identify and prioritize candidate therapeutic targets (*e.g.*, *SMPD2* and *FDXR*) for vascular dementia (VaD). By integrating large-scale genetic and transcriptomic data, the workflow performs a systematic, multi-layer analysis:

1.  **Multi-tissue Mendelian Randomization (MR):** Leverages eQTL data from blood (eQTLGen) and brain frontal cortex BA9 (GTEx v8) to assess causal relationships with VaD risk (FinnGen R11).
2.  **Bayesian Colocalization:** Calculates Approximate Bayes Factors (ABF) to distinguish shared causal variants from linkage disequilibrium confounding.
3.  **Data Harmonization & Result Compilation:** Automates the rigorous alignment of effect alleles and generates publication-ready summary tables.

## 🛠️ Prerequisites & Environment Setup

This pipeline is built entirely in Python. We recommend using a virtual environment (like `conda` or `venv`) to manage dependencies.

### Required Packages
- `pandas` (>= 1.3.0)
- `numpy` (>= 1.21.0)
- `scipy` (>= 1.7.0)
- `requests` (for OpenGWAS API calls and MyGene API mapping)

### Installation
You can install the required packages using pip:
```bash
pip install pandas numpy scipy requests

Project Structure
The workflow is divided into four main steps, each corresponding to a specific Python script:

vad-multiomics-pipeline/
├── data/
│   ├── (Place your downloaded raw GWAS/eQTL files here)
│   └── (Intermediate and final results will be generated here)
├── 1_format_brain_gtex_offline.py     # Extracts and formats GTEx brain eQTL data
├── 2_run_mendelian_randomization.py   # Performs 2-sample MR analysis
├── 3_run_colocalization.py            # Executes Bayesian colocalization
└── 4_generate_table_S2.py             # Compiles harmonized IVs for Table S2
└── README.md                          # This documentation file
🚀 Usage Guide
Important Note: The raw input datasets (e.g., eQTLGen summary statistics, GTEx v8 archive, FinnGen R11 summary statistics) are too large to be hosted on GitHub. Please download them from their respective official repositories and place them in the data/ directory.

Before running the scripts, please update the file paths within each script's Configuration & Paths section to match your local setup.

Step 1: Format Brain eQTL Data
Extracts targeted gene eQTLs from the GTEx v8 frontal cortex BA9 dataset and maps coordinates to rsIDs using the FinnGen reference dictionary.

Bash
python 1_format_brain_gtex_offline.py
Step 2: Run Mendelian Randomization
Performs two-sample Mendelian randomization (Wald ratio/IVW) using harmonized eQTL and GWAS data.
Note: This script requires a free API token from OpenGWAS for LD clumping. Replace 'YOUR_OPENGWAS_API_TOKEN_HERE' in the script with your actual token.

Bash
python 2_run_mendelian_randomization.py
Step 3: Run Bayesian Colocalization
Calculates Approximate Bayes Factors (ABF) to estimate the posterior probability (PP4) of a shared causal variant. It evaluates the regional association landscape to prioritize robust targets.

Bash
python 3_run_colocalization.py
Step 4: Generate Publication Tables
Automates the extraction and compilation of harmonized instrument-level data for prioritized targets, outputting a clear, formatted CSV file suitable for Supplementary Material.

Bash
python 4_generate_table_S2.py
📝 Citation
If you use this code or our analytical framework in your research, please cite our paper:

Zhou, Y., Lv, D., Li, Q., et al. "Genetic prioritisation of SMPD2 and FDXR for vascular dementia through multi-tissue Mendelian randomization, colocalization, and transcriptomic validation." [Journal Name, if accepted/published], 2026. DOI: [Insert DOI if available]

(Please update the citation details once the manuscript is officially published.)

📜 License
This project is licensed under the MIT License - see the LICENSE file for details. This open-source license allows for broad reuse, provided appropriate credit is given.
