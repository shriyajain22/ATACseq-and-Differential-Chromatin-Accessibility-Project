#!/usr/bin/env nextflow

process FIND_MOTIFS_GENOME {
    label 'process_medium'
    container 'ghcr.io/bf528/homer_samtools:latest'
    publishDir "${params.outdir}/motifs", mode: "copy"

    input:
    tuple val(sample_id), path(peaks)
    val genome

    output:
    tuple val(sample_id), path("${sample_id}_motifs"), emit: motifs

    script:
    """
    mkdir -p ${sample_id}_motifs

    findMotifsGenome.pl \
        ${peaks} \
        ${genome} \
        ${sample_id}_motifs \
        -size given
    """

    stub:
    """
    mkdir -p ${sample_id}_motifs
    """
}

