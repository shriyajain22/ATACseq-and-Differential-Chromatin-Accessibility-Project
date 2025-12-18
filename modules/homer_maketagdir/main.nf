#!/usr/bin/env nextflow

process TAGDIR {
    label 'process_medium'
    container 'ghcr.io/bf528/homer_samtools:latest'
    publishDir "${params.outdir}/tagdir", mode: "copy"

    input:
    tuple val(sample), path(bam)

    output:
    tuple val(sample), path("${sample}_tagdir"), emit: tagdir

    script: 
    """
    makeTagDirectory ${sample}_tagdir ${bam}
    """
    
    stub:
    """
    mkdir ${sample_id}_tags
    """
}
