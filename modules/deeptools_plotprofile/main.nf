#!/usr/bin/env nextflow

process PLOTPROFILE {
    label 'process_medium'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir "${params.outdir}/plotprofile", mode: "copy"

    input:
    tuple val(sample_id), path(matrix_file)

    output:
    path "${sample_id}_signal_coverage.png", emit: profile

    script:
    """
    plotProfile \
        -m ${matrix_file} \
        -out ${sample_id}_signal_coverage.png \
        --plotTitle "${sample_id} Gene Body Profile" \
        --perGroup
    """

    stub:
    """
    touch ${sample_id}_signal_coverage.png
    """
}