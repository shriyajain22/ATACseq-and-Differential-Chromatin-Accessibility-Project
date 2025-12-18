#!/usr/bin/env nextflow
process ANNOTATE {
    label 'process_high'
    container 'ghcr.io/bf528/homer_samtools:latest'
    publishDir "${params.outdir}/annotation", mode: 'copy'

    input:
    tuple val(sample_id), path(peaks)
    path(gtf)

    output:
    tuple val(sample_id), path("${sample_id}.annotated_peaks.txt"), emit: annotated

    script:
    """
    annotatePeaks.pl ${peaks} \
      none \
      -gtf ${gtf} \
      > ${sample_id}.annotated_peaks.txt
    """

    stub:
    """
    touch ${sample_id}.annotated_peaks.txt
    """
}
