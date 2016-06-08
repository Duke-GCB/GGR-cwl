#!/bin/bash
#
#SBATCH --job-name=cwl_chipseq
#SBATCH --output=/data/reddylab/Alex/chipseq-test/se-narrow.out
#SBATCH --error=/data/reddylab/Alex/chipseq-test/se-narrow.err
#SBATCH --mail-user=alejandro.barrera@duke.edu
#SBATCH --mail-type=FAIL
#SBATCH --mem=12000
#SBATCH --cpus-per-task=16

source /data/reddylab/software/anaconda/bin/activate cwldev
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
cwltool --non-strict  --preserve-environment PATH R_LIBS DISPLAY --outdir /data/reddylab/Alex/chipseq-test/out-se-narrow --no-container /home/aeb84/workspace/GGR-cwl/GGR_ChIP-seq_pipeline/pipeline-se-narrow.cwl /home/aeb84/workspace/GGR-cwl/scripts_slurm_run/pipeline-se-narrow.json

