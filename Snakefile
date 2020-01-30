import sys
import pandas as pd
from pathlib import Path

wildcard_constraints:
    sample = 'SRR[0-9]+'

configfile: 'config.yaml'

include: 'rules/star.smk'
include: 'rules/rsem.smk'
include: 'rules/download.smk'

manifest = pd.read_csv(config['manifest'])
RESULT_DIR = Path(config['result_dir'])

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

ALIGNED_BAM_SE = expand(str(RESULT_DIR / '01_star' / 'se' / '{sample}.sorted.bam'), sample=SE_SAMPLES)
ALIGNED_BAM_PE = expand(str(RESULT_DIR / '01_star' / 'pe' / '{sample}.sorted.bam'), sample=PE_SAMPLES)
EXPRESSIONS_SE = expand(str(RESULT_DIR / '02_rsem' / 'se' / '{sample}.genes.results'), sample=SE_SAMPLES)
EXPRESSIONS_PE = expand(str(RESULT_DIR / '02_rsem' / 'pe' / '{sample}.genes.results'), sample=PE_SAMPLES)

RESULT_FILES = []
RESULT_FILES.append(ALIGNED_BAM_SE)
RESULT_FILES.append(ALIGNED_BAM_PE)
RESULT_FILES.append(EXPRESSIONS_SE)
RESULT_FILES.append(EXPRESSIONS_PE)

rule all:
    input: RESULT_FILES
