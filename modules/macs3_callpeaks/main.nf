#!/usr/bin/env nextflow

process CALLPEAKS {
    label 'process_high'
    publishDir "${params.outdir}/peaks", mode: 'copy'

    input:
    tuple val(samplename), path(bam)

    output:
    tuple val(samplename), path("${samplename}_peaks.narrowPeak"), emit: peaks
    tuple val(samplename), path("${samplename}_summits.bed"), emit: summits

    script:
    """
    /projectnb/bf527/students/shrjain/.conda/envs/macs3_env/bin/macs3 callpeak \
        -t ${bam} \
        -f BAM \
        -g mm \
        -n ${samplename} \
        --outdir . \
        --nomodel \
        --shift -100 \
        --extsize 200 \
        --keep-dup all \
        --call-summits
    """
    
    stub:
    """
    touch ${samplename}_peaks.narrowPeak
    touch ${samplename}_summits.bed
    """
}
