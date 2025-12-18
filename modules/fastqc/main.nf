#!/usr/bin/env nextflow

process FASTQC {
    label 'process_low'
    container 'ghcr.io/bf528/fastqc:latest'
    publishDir "${params.outdir}/fastqc", mode: "copy"

    input:
    tuple val(sample), path(fastq)

    output:
    tuple val(sample), path("*_fastqc.zip"), emit: zip

    script:
    """
    set +e
    fastqc -t ${task.cpus} --noextract -o . ${fastq}
    status=\$?

    if ls *_fastqc.zip >/dev/null 2>&1; then
        exit 0
    fi

    exit \$status
    """
}
