#!/usr/bin/env nextflow

process SAMTOOLS_SORT {
label 'process_high'
    container 'ghcr.io/bf528/samtools:latest'
    publishDir "${params.outdir}/samtools_sort", mode: "copy"

    input:
    tuple val(sample_id), path(bam)
    
    output:
    tuple val(sample_id), path("${sample_id}.stub.sorted.bam"), emit: bam 
    
    script:
    """
    samtools sort -@ ${task.cpus ?: 1} \
        -o ${sample_id}.stub.sorted.bam \
        ${bam}
    """

    stub:
    """
    touch ${sample_id}.stub.sorted.bam
    """
}