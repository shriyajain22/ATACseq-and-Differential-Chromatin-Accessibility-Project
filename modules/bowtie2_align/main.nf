#!/usr/bin/env nextflow

process BOWTIE2_ALIGN {
    label 'process_high'
    container 'ghcr.io/bf528/bowtie2:latest'
    publishDir "${params.outdir}/bowtie2_align", mode: "copy"

    input:
    path index_dir
    tuple val(sample_id), path(reads)
    
    output:
    tuple val(sample_id), path("${sample_id}.bam"), emit: bam

    script:
    """
    bowtie2 -x ${index_dir}/genome_index -U ${reads} -p ${task.cpus ?: 1} 2> ${sample_id}.bowtie2.log | \
    samtools sort -@ ${task.cpus ?: 1} -o ${sample_id}.bam
    """

    stub:
    """
    touch ${sample_id}.bam
    """
}