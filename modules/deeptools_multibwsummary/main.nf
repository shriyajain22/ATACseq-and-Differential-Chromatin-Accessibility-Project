#!/usr/bin/env nextflow

process MULTIBWSUMMARY {
    label 'process_medium'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir "${params.outdir}/fastqc", mode: "copy"

    input:
    path(bigwig)

    output:
    path("bigwig_summary.npz"), emit: npz
    path("bigwig_summary.tab"), emit: tab

    script: 
    """
    multiBigwigSummary bins \
        --bwfiles ${bigwig.join(' ')} \
        --outFileName bigwig_summary.npz \
        --outRawCounts bigwig_summary.tab
    """

    stub:
    """
    touch bw_all.npz
    """
}