#!/usr/bin/env nextflow

process MULTIQC {
    label 'process_high'
    container 'ghcr.io/bf528/multiqc:latest'
    publishDir "${params.outdir}/multiqc", mode: "copy"

    input:
    val outdir

    output:
    path "multiqc_report.html", emit: report

    script:
    """
    set -euo pipefail

    DIRS=""
    for d in "${outdir}/fastqc" "${outdir}/flagstat" "${outdir}/trim"; do
      if [ -d "\$d" ]; then
        DIRS="\$DIRS \$d"
      fi
    done

    if [ -z "\$DIRS" ]; then
      echo "<html><body><h1>MultiQC</h1><p>No QC inputs found.</p></body></html>" > multiqc_report.html
      exit 0
    fi

    multiqc \$DIRS -f -o .
    """
}


