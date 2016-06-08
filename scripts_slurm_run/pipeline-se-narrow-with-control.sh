#!/bin/bash
#
#SBATCH --job-name=cwl_chipseq
#SBATCH --output=/data/reddylab/Alex/chipseq-test/pipeline.out
#SBATCH --error=/data/reddylab/Alex/chipseq-test/pipeline.err
#SBATCH --mail-user=alejandro.barrera@duke.edu
#SBATCH --mail-type=FAIL
#SBATCH --mem=12000
#SBATCH --cpus-per-task=16

source /data/reddylab/software/anaconda/bin/activate cwltool
export PATH="$HOME/workspace/GGR-Docker/workflow-utils/bin:$PATH"
export PATH="/data/reddylab/software/FastQC:$PATH"
export PATH="/data/reddylab/software/preseq_v2.0:$PATH"
export PATH="/data/reddylab/software/samtools-1.3/bin/:$PATH"
export PATH="/data/reddylab/software/phantompeakqualtools/:$PATH"

module load bedtools2

# For SPP 
export R_LIBS="/data/reddylab/software/R_libs"

# For Fastqc
export DISPLAY=:0.0
cwltool --debug --non-strict  --preserve-environment PATH R_LIBS DISPLAY --outdir /data/reddylab/Alex/chipseq-test/out-se-narrow-with-control --no-container --tmpdir-prefix /data/reddylab/Alex/chipseq-test/pipeline-se-w-control-tmp --tmp-outdir-prefix /data/reddylab/Alex/chipseq-test/pipeline-se-w-control-out /home/aeb84/workspace/GGR-cwl/GGR_ChIP-seq_pipeline/pipeline-se-narrow-with-control.cwl /home/aeb84/workspace/GGR-cwl/scripts_slurm_run/pipeline-se-narrow-with-control.json

#FASTQ_FILE1=${HOME}/data-tmp/TEST.t00_rep1.fastq
#FASTQ_FILE2=${HOME}/data-tmp/TEST.t05_rep1.fastq
#DEFAULT_ADAPTERS_FILE=/data/reddylab/projects/GGR/data/auxiliary/adapters/default_adapters.fasta
#
#cwl-runner \
#  --debug \
#  #--tmp-outdir-prefix=$TMP_OUTDIR_PREFIX \
#  #--tmpdir-prefix=$TMPDIR_PREFIX \
#  GGR_ChIP-seq_pipeline/01-qc.cwl \
#  --input_fastq_files $FASTQ_FILE1 \
#  --input_fastq_files $FASTQ_FILE2 \
#  --default_adapters_file $DEFAULT_ADAPTERS_FILE \
#  --se_or_pe se
