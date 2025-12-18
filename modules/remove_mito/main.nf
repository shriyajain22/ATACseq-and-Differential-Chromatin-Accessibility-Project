#!/usr/bin/env nextflow

process REMOVE_MITO {
    label 'process_medium'
    container 'ghcr.io/bf528/samtools:latest'
    publishDir "${params.outdir}/bam_no_mito", mode: "copy"

    input:
    tuple val(sample_id), path(bam)

    output:
    tuple val(sample_id), path("${sample_id}.noMT.bam"), emit: bam

    script:
    """
    samtools index ${bam}
    samtools idxstats ${bam} | cut -f1 | grep -v -E '${params.mito_chrom ?: "chrM|MT"}' > chroms.txt
    samtools view -b ${bam} \$(cat chroms.txt) \
    | samtools sort -@ ${task.cpus ?: 1} -o ${sample_id}.noMT.bam
    samtools index ${sample_id}.noMT.bam
    """
    
    stub:
    """
    touch ${sample_id}.noMT.bam
    """
}
