import sys
import pandas as pd
from pathlib import Path

wildcard_constraints:
    sample = 'SRR[0-9]+'

configfile: 'config.yaml'

include: 'rules/star.smk'
include: 'rules/rsem.smk'
include: 'rules/trim-galore.smk'
include: 'rules/fastqc.smk'
include: 'rules/download.smk'

ruleorder: trim_galore_pe > trim_galore_se

manifest = pd.read_csv(config['manifest'])
RESULT_DIR = Path(config['result_dir'])

SAMPLES = manifest.run_accession.values
SAMPLE2LIB = {r.run_accession:r.library_layout for r in manifest.to_records()}
SE_MASK = manifest.library_layout.str.upper().str.contains('SINGLE')
PE_MASK = manifest.library_layout.str.upper().str.contains('PAIRED')
SE_SAMPLES = manifest[SE_MASK].run_accession.values
PE_SAMPLES = manifest[PE_MASK].run_accession.values

print(f'There are {len(SE_SAMPLES)} single-read and {len(PE_SAMPLES)} paired-end samples.')
print(f'Single-read sample examples: {SE_SAMPLES[:3]}')
print(f'Paired-read sample examples: {PE_SAMPLES[:3]}')
proc = input('Proceed? [y/n]: ')
if proc != 'y':
    sys.exit(1)

RAW_QC_SE = expand(str(DATA_DIR / '{sample}_fastqc.html'), sample=SE_SAMPLES)
RAW_QC_PE = expand(str(DATA_DIR / '{sample}.read1_fastqc.html'), sample=PE_SAMPLES)
TRIMMED_QC_SE = expand(str(RESULT_DIR / '01_trim_galore' / '{sample}.trimmed_fastqc.html'), sample=SE_SAMPLES)
TRIMMED_QC_PE = expand(str(RESULT_DIR / '01_trim_galore' / '{sample}.read1.trimmed_fastqc.html'), sample=PE_SAMPLES)
ALIGNED_BAM = expand(str(RESULT_DIR / '02_star' / '{sample}.sorted.bam'), sample=SAMPLES)
EXPRESSIONS = expand(str(RESULT_DIR / '03_rsem' / '{sample}.genes.results'), sample=SAMPLES)

RESULT_FILES = []
RESULT_FILES.append(RAW_QC_SE)
RESULT_FILES.append(RAW_QC_PE)
RESULT_FILES.append(ALIGNED_BAM)
RESULT_FILES.append(EXPRESSIONS)

rule all:
    input: RESULT_FILES
