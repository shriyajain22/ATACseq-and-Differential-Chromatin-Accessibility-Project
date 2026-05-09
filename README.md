# ATAC-seq and Differential Chromatin Accessibility Project

This project reproduces and implements a reproducible ATAC-seq analysis workflow based on a published chromatin accessibility study. The pipeline focuses on identifying genome-wide chromatin accessibility patterns and performing differential chromatin accessibility analysis across biological conditions using Nextflow-based bioinformatics workflows.

ATAC-seq (Assay for Transposase-Accessible Chromatin using sequencing) is a powerful epigenomics technique used to identify open chromatin regions, active regulatory elements, and transcription factor binding sites associated with gene regulation and cellular identity.

## Project Objectives

The primary goals of this project were to:
- Process and analyze raw ATAC-seq sequencing data
- Identify accessible chromatin regions across samples
- Perform differential accessibility analysis between conditions
- Generate ATAC-seq specific quality control metrics
- Perform motif enrichment analysis on differential peaks
- Reproduce figures from the original publication
- Develop reproducible and scalable bioinformatics workflows

## Workflow Overview

The analysis pipeline consists of the following major steps:

### 1. Data Acquisition
- Downloading ATAC-seq datasets from the published study

### 2. Quality Control
- Sequencing read quality assessment
- Adapter contamination evaluation
- Data preprocessing and filtering

### 3. Read Alignment
Sequencing reads were aligned to the reference genome using:
- `Bowtie2`
- `samtools`

Additional processing steps included:
- Removal of mitochondrial alignments
- Alignment filtering and processing

### 4. Peak Calling
Accessible chromatin regions were identified using:
- `MACS2`

### 5. Differential Accessibility Analysis
Differential chromatin accessibility analysis was performed to identify regulatory regions with significant accessibility changes between conditions using:
- `DiffBind`
- `DESeq2`

### 6. ATAC-seq Quality Control Metrics
ATAC-seq specific QC metrics were generated to evaluate experiment quality, including:
- Fragment size distribution
- Fraction of Reads in Peaks (FRiP)
- TSS enrichment analysis
- Signal enrichment visualization

### 7. Motif Enrichment Analysis
Motif enrichment analysis was performed on differentially accessible peaks to identify potential transcription factor binding patterns associated with regulatory changes.

### 8. Biological Interpretation & Visualization
Downstream analysis included:
- PCA analysis
- Heatmaps
- Differential accessibility visualization
- Peak annotation
- Regulatory region interpretation
- Reproduction of selected publication figures

## Tools & Technologies

### Programming & Workflow
`Python` `R` `Bash` `Nextflow` `Docker` `Conda`

### Bioinformatics Tools
`Bowtie2` `samtools` `MACS2` `HOMER`

### Statistical & Visualization Packages
`DESeq2` `DiffBind` `ggplot2` `pheatmap`

## Repository Structure

```bash
ATACseq-and-Differential-Chromatin-Accessibility-Project/
│
├── envs/                   # Environment configuration files
├── materials/              # Supporting project materials
├── modules/                # Workflow modules
├── scripts/                # Analysis scripts
├── main.nf                 # Main Nextflow workflow
├── nextflow.config         # Workflow configuration
├── samplesheet.csv         # Sample metadata
├── project_report.ipynb    # Project notebook/report
└── README.md
```

## Citation

This workflow was implemented using datasets and analysis concepts from the following publication:
De Sá Fernandes, C., Novoszel, P., Gastaldi, T., Krauß, D., Lang, M., Rica, R., Kutschat, A. P., Holcmann, M., Ellmeier, W., Seruggia, D., Strobl, H., & Sibilia, M. (2024). The histone deacetylase HDAC1 controls dendritic cell development and anti-tumor immunity. *Cell reports*, *43*(6), 114308. https://doi.org/10.1016/j.celrep.2024.114308

Note: *This project was developed as part of the Genomic Data Analysis (BF528) coursework at Boston University.* 
