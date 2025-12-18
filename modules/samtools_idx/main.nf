#!/usr/bin/env nextflow

process SAMTOOLS_IDX {
    label 'process_high'
    container 'ghcr.io/bf528/samtools:latest'
    publishDir "${params.outdir}/samtools_index", mode: "copy"

    input:
    tuple val(sample), path(bam)
    
    output:
    tuple val(sample), path(bam), path("*bai"), emit: index 
    
    script:
    """
    samtools index $bam 
    """

    stub:
    """
    touch ${sample_id}.stub.sorted.bam.bai
    """
}