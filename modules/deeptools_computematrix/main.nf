#!/usr/bin/env nextflow

process COMPUTEMATRIX {
    label 'process_medium'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir "${params.outdir}/computematrix", mode: "copy"

    input:
    tuple val(sample_id), path(bigwig)
    path genes_bed

    output:
    tuple val(sample_id), path("${sample_id}_matrix.gz"), emit: matrix

    script:
    """
    computeMatrix scale-regions \
        -S ${bigwig} \
        -R ${genes_bed} \
        --beforeRegionStartLength 2000 \
        --afterRegionStartLength 2000 \
        --regionBodyLength 2000 \
        --skipZeros \
        --missingDataAsZero \
        -o ${sample_id}_matrix.gz
    """

    stub:
    """
    touch ${sample_id}_matrix.gz
    """
}