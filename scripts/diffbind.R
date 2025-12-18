#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(DiffBind)
  library(DESeq2)
  library(GenomicRanges)
})

# SETTING UP THE PARAMETERS
samplesheet_path <- "results/diffbind_samples.csv"
outdir           <- "results/diffbind_csv"
celltypes        <- c("cDC1", "cDC2")
summit_width     <- 250
fdr_threshold    <- 0.05


dir.create(outdir, showWarnings = FALSE, recursive = TRUE)

stop_if_missing_cols <- function(df, needed) {
  missing <- setdiff(needed, colnames(df))
  if (length(missing) > 0) {
    stop("Sample sheet is missing required columns: ", paste(missing, collapse = ", "))
  }
}

clean_condition <- function(x) {
  x <- as.character(x)
  x <- trimws(x)
  x <- toupper(x)
  x[x %in% c("WILD TYPE", "WILDTYPE", "W T")] <- "WT"
  x[x %in% c("K O")] <- "KO"
  x
}

clean_celltype <- function(x) {
  x <- as.character(x)
  x <- trimws(x)
  x <- gsub("\\s+", "", x)                 
  x <- gsub("^cdc", "cDC", x, ignore.case = TRUE)  
  x
}

# RETREIVING THE PEAK BY SAMPLE COUNTS TABLE ACROSS DIFFBIND VERSIONS 
get_counts_df <- function(dba_obj) {
  x <- NULL
  
  try({ x <- dba.peakset(dba_obj, bRetrieve = TRUE, DataType = DBA_DATA_FRAME) }, silent = TRUE)
  
  if (is.null(x)) x <- dba.peakset(dba_obj, bRetrieve = TRUE)
  
  if (is.data.frame(x)) return(x)
  if (inherits(x, "GRanges")) return(as.data.frame(x))
  if (is.matrix(x)) return(as.data.frame(x))
  
  stop("Could not convert dba.peakset(bRetrieve=TRUE) output to data.frame. Got: ",
       paste(class(x), collapse = ", "))
}

# LOADING AND CLEANING THE SAMPLE SHEET
ss <- read.csv(samplesheet_path, stringsAsFactors = FALSE)

needed <- c("SampleID", "Condition", "Peaks")
stop_if_missing_cols(ss, needed)

if (!("CellType" %in% colnames(ss))) {
  stop("Your sample sheet must contain a 'CellType' column (e.g., cDC1/cDC2).")
}

ss$Condition <- clean_condition(ss$Condition)
ss$CellType  <- clean_celltype(ss$CellType)

bad_levels <- setdiff(unique(ss$Condition), c("WT", "KO"))
if (length(bad_levels) > 0) {
  stop("Condition column contains unexpected values after cleaning: ",
       paste(bad_levels, collapse = ", "),
       "\nFix Condition to WT/KO.")
}

# SAVING THE CLEANED SAMPLESHEET
write.csv(ss, file.path(outdir, "diffbind_samples.cleaned.csv"), row.names = FALSE)

# RUNNING PER CELLTYPE
wrote_any <- FALSE

for (ct in celltypes) {
  message("Processing: ", ct)
  
  ss_ct <- ss[ss$CellType == ct, , drop = FALSE]
  if (nrow(ss_ct) == 0) {
    message("No samples found for ", ct, " — skipping.")
    next
  }
  
  # ENSURING BOTH THE CONDITIONS EXIST 
  message("Group counts (from sample sheet):")
  print(table(ss_ct$Condition, useNA = "ifany"))
  if (sum(ss_ct$Condition == "WT") < 1 || sum(ss_ct$Condition == "KO") < 1) {
    stop("For ", ct, ": missing WT or KO samples. Check your sample sheet.")
  }
  
  # BUILDING THE DBA OBJECT 
  dba_ct <- dba(sampleSheet = ss_ct)
  
  dba_ct$samples$Condition <- clean_condition(dba_ct$samples$Condition)
  
  # EXPORTING THE SAMPLES USED BY DIFFBIND 
  samples_csv <- file.path(outdir, paste0(ct, "_dba_samples.csv"))
  write.csv(dba_ct$samples, samples_csv, row.names = FALSE)
  message("Wrote: ", samples_csv)
  
  # COUNTING READS (RE-CENTERING AROUND SUMMITS) 
  message("Counting reads with summits=", summit_width, " ...")
  dba_ct <- dba.count(dba_ct, summits = summit_width)
  
  # PLOTTING THE QC PLOTS (HEATMAPS AND PCA)

  # CORRELATION HEATMAP 
  heatmap_pdf <- file.path(outdir, paste0("diffbind_", ct, "_QC_correlation_heatmap.pdf"))
  pdf(heatmap_pdf, width = 7, height = 7)
  try(dba.plotHeatmap(dba_ct, correlations = TRUE), silent = TRUE)
  dev.off()
  message("Wrote: ", heatmap_pdf)
  
  # PCA PLOT
  pca_pdf <- file.path(outdir, paste0("diffbind_", ct, "_QC_PCA.pdf"))
  pdf(pca_pdf, width = 7, height = 7)
  try(dba.plotPCA(dba_ct, DBA_CONDITION, label = DBA_ID), silent = TRUE)
  dev.off()
  message("Wrote: ", pca_pdf)
  
  # EXPORTING THE FILES

  # PEAK BY SAMPLE COUNT MATRIX TABLE 
  counts_df <- get_counts_df(dba_ct)
  counts_csv <- file.path(outdir, paste0(ct, "_counts_matrix.csv"))
  write.csv(counts_df, counts_csv, row.names = FALSE)
  message("Wrote: ", counts_csv)
  
  if (is.null(dba_ct$masks$WT) || is.null(dba_ct$masks$KO)) {
    stop("For ", ct, ": DiffBind did not create WT/KO masks. Unique conditions: ",
         paste(unique(dba_ct$samples$Condition), collapse = ", "))
  }
  
  dba_ct <- dba.contrast(
    dba_ct,
    categories = DBA_CONDITION,
    group1     = dba_ct$masks$WT,
    group2     = dba_ct$masks$KO,
    name1      = "WT",
    name2      = "KO"
  )
  
  # DIFFERENTIAL ANALYSIS 
  dba_ct <- dba.analyze(dba_ct, method = DBA_DESEQ2)
  
  # ALL THE DIFFERENTIAL PEAKS 
  rep_all <- as.data.frame(dba.report(dba_ct, method = DBA_DESEQ2, th = 1))
  rep_all_csv <- file.path(outdir, paste0(ct, "_WT_vs_KO_diffpeaks_ALL.csv"))
  write.csv(rep_all, rep_all_csv, row.names = FALSE)
  message("Wrote: ", rep_all_csv)
  
  # SIGNIFICANT DIFFERENTIAL PEAKS 
  rep_sig <- as.data.frame(dba.report(dba_ct, method = DBA_DESEQ2, th = fdr_threshold))
  rep_sig_csv <- file.path(outdir, paste0(ct, "_WT_vs_KO_diffpeaks_FDR", fdr_threshold, ".csv"))
  write.csv(rep_sig, rep_sig_csv, row.names = FALSE)
  message("Wrote: ", rep_sig_csv)
  
  wrote_any <- TRUE
}

if (!wrote_any) {
  stop("No outputs written. Check CellType values in your sample sheet.\n",
       "Look at: ", file.path(outdir, "diffbind_samples.cleaned.csv"))
}

message("\nDone. QC PDFs + CSVs are in: ", outdir)
