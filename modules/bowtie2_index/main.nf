#!/usr/bin/env nextflow

process BOWTIE2_INDEX {
    label 'process_high'
    container 'ghcr.io/bf528/bowtie2:latest'
    publishDir "${params.outdir}/bowtie2_index", mode: "copy"

    input:
    path genome   
    
    output:
    path "bowtie2_index", emit: index

    script:
    """
    mkdir -p bowtie2_index
    bowtie2-build ${genome} bowtie2_index/genome_index
    """

    stub:
    """
    mkdir bowtie2_index
    """
}