Final Project
1) Raw ATAC-seq and ChIP-seq reads were quality-checked using FastQC and trimmed to remove adapters and low-quality bases.
2) Cleaned reads were aligned to the reference mouse genome using Bowtie2.
3) Mitochondrial reads were removed, and aligned BAM files were sorted and indexed using SAMtools.
4) Peaks from the open chromatin were called using MACS2.
5) DiffBind was used to quantify peak read counts and perform differential chromatin accessibility analysis 
6) Sample reproducibility and condition separation were assessed using correlation heatmaps and principal component analysis (PCA).
7) Motif enrichment analysis was performed on ATAC-seq peaks to identify transcription factors associated with the regulatory regions.
8) Figures from the original paper were reproduced from our data.
