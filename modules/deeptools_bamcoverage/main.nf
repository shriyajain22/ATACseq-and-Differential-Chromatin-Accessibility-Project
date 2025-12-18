#!/usr/bin/env nextflow

process BAMCOVERAGE {
    label 'process_high'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir "${params.outdir}/deeptools_bam", mode: "copy"

    input:
    tuple val(sample_id), path(bam), path(bai)
    
    output:
    tuple val(sample_id), path("${sample_id}.bw"), emit: bigwig
    
    script:
    """
    bamCoverage -b ${bam} -o ${sample_id}.bw
    """

    stub:
    """
    touch ${sample_id}.bw
    """
}