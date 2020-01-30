rule prefetch_accession:
    output:
        temp('{sample}.sra')
    resources:
        network = 1
    wrapper:
        'http://dohlee-bio.info:9193/sra-tools/prefetch/accession'

rule parallel_fastq_dump_single:
    input:
        # Required input. Recommend using wildcards for sample names,
        # e.g. {sample,SRR[0-9]+}
        '{sample}.sra'
    output:
        # Required output.
        DATA_DIR / '{sample}.fastq.gz'
    params:
        extra = '--tmpdir .'
    threads: config['threads']['parallel_fastq_dump']
    wrapper:
        'http://dohlee-bio.info:9193/parallel-fastq-dump'

rule parallel_fastq_dump_paired:
    input:
        # Required input. Recommend using wildcards for sample names,
        # e.g. {sample,SRR[0-9]+}
        '{sample}.sra'
    output:
        # Required output.
        DATA_DIR / '{sample}.read1.fastq.gz',
        DATA_DIR / '{sample}.read2.fastq.gz',
        temp(DATA_DIR / '{sample}_pass.fastq.gz')
    params:
        # Optional parameters. Omit if unused.
        extra = '--tmpdir .'
    threads: config['threads']['parallel_fastq_dump']
    wrapper:
        'http://dohlee-bio.info:9193/parallel-fastq-dump'
