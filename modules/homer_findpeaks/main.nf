#!/usr/bin/env nextflow

process FINDPEAKS {
    label 'process_medium'
    container 'ghcr.io/bf528/homer_samtools:latest'
    publishDir "${params.outdir}/findpeaks", mode: "copy"

    input:
    tuple val(rep), path(ip_tagdir), path(ctrl_tagdir)

    output:
    tuple val(rep), path("${rep}_peaks.txt"), emit: peaks

    script: 
    """
    findPeaks ${ip_tagdir} -style factor -o auto -i ${ctrl_tagdir}
    mv ${ip_tagdir}/peaks.txt ${rep}_peaks.txt
    """
    
    stub:
    """
    touch ${rep}_peaks.txt
    """
}
