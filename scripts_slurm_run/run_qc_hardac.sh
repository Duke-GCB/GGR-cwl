#!/bin/bash
#
#SBATCH --job-name=FastQC_test
#SBATCH --output=fastqc-test.out
#SBATCH --mail-user=alejandro.barrera@duke.edu
#SBATCH --mail-type=FAIL
#SBATCH --mem=2000

source /data/reddylab/software/anaconda/bin/activate root
export PATH="$HOME/bin/:/data/reddylab/software/FastQC:/data/reddylab/software/anaconda/bin/cwltool:$PATH"

srun cwltool --preserve-environment PATH --outdir ~/data-tmp/fastq-out --no-container ~/workspace/GGR-cwl/ChIP-seq_pipeline/01-qc.cwl  ~/workspace/GGR-cwl/ChIP-seq_pipeline/01-qc.json

#FASTQ_FILE1=${HOME}/data-tmp/TEST.t00_rep1.fastq
#FASTQ_FILE2=${HOME}/data-tmp/TEST.t05_rep1.fastq
#DEFAULT_ADAPTERS_FILE=/data/reddylab/projects/GGR/data/auxiliary/adapters/default_adapters.fasta
#
#cwl-runner \
#  --debug \
#  #--tmp-outdir-prefix=$TMP_OUTDIR_PREFIX \
#  #--tmpdir-prefix=$TMPDIR_PREFIX \
#  ChIP-seq_pipeline/01-qc.cwl \
#  --input_fastq_files $FASTQ_FILE1 \
#  --input_fastq_files $FASTQ_FILE2 \
#  --default_adapters_file $DEFAULT_ADAPTERS_FILE \
#  --se_or_pe se
