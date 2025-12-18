include{FASTQC} from './modules/fastqc'
include{TRIM} from './modules/trimmomatic'
include{MULTIQC} from './modules/multiqc'
include{BOWTIE2_ALIGN} from './modules/bowtie2_align'
include{BOWTIE2_INDEX} from './modules/bowtie2_index'
include{REMOVE_MITO} from './modules/remove_mito'
include{CALLPEAKS} from './modules/macs3_callpeaks'
include{ANNOTATE} from './modules/homer_annotatepeaks'
include{FIND_MOTIFS_GENOME} from './modules/homer_findmotifsgenome'
include{SAMTOOLS_SORT} from './modules/samtools_sort'
include{SAMTOOLS_IDX} from './modules/samtools_idx'
include{SAMTOOLS_FLAGSTAT} from './modules/samtools_flagstat'
include{BAMCOVERAGE} from './modules/deeptools_bamcoverage'
include{MULTIBWSUMMARY} from './modules/deeptools_multibwsummary'
include{PLOTPROFILE} from './modules/deeptools_plotprofile'
include{COMPUTEMATRIX} from './modules/deeptools_computematrix'

workflow {
    Channel.fromPath(params.samplesheet)
    | splitCsv( header: true )
    | map{ row -> tuple(row.name, file(row.path)) }
    | set { read_ch }

    FASTQC(read_ch)
    TRIM(read_ch)
    BOWTIE2_INDEX(params.genome)
    BOWTIE2_ALIGN(BOWTIE2_INDEX.out.index, TRIM.out.trimmed_reads)
    SAMTOOLS_FLAGSTAT(BOWTIE2_ALIGN.out)
    SAMTOOLS_SORT(BOWTIE2_ALIGN.out)
    SAMTOOLS_IDX(SAMTOOLS_SORT.out)
    BAMCOVERAGE(SAMTOOLS_IDX.out)
    MULTIBWSUMMARY(BAMCOVERAGE.out.bigwig.map { sample, bigwig -> bigwig }.collect())
    MULTIQC(params.outdir)
    bigwig_ch = BAMCOVERAGE.out.bigwig  
    ip_bigwig_ch = bigwig_ch.filter { sample, bigwig -> sample.contains("KO") }
    COMPUTEMATRIX(ip_bigwig_ch, file("refs/GRCm38_genes.bed"))
    PLOTPROFILE(COMPUTEMATRIX.out)
    REMOVE_MITO(BOWTIE2_ALIGN.out.bam)
    CALLPEAKS(REMOVE_MITO.out.bam)
    ANNOTATE(CALLPEAKS.out.peaks, file(params.gtf))
    FIND_MOTIFS_GENOME(CALLPEAKS.out.peaks, params.genome)    
}