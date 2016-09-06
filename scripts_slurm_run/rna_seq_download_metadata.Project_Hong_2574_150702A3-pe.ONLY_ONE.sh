#!/bin/bash
#
#SBATCH --job-name=cwl_rnaseq
#SBATCH --output=/data/reddylab/Alex/rnaseq-test/ggr-one-test.out
###SBATCH --error=/data/reddylab/Alex/rnaseq-test/test.err
#SBATCH --mail-user=alejandro.barrera@duke.edu
####SBATCH --mail-type=FAIL
#SBATCH --mem=16000
#SBATCH --cpus-per-task=16

source /data/reddylab/software/anaconda/bin/activate cwltool
export PATH="$HOME/workspace/GGR-Docker/workflow-utils/bin:$PATH"
export PATH="/data/reddylab/software/FastQC:$PATH"
export PATH="/data/reddylab/software/preseq_v2.0:$PATH"
export PATH="/data/reddylab/software/samtools-1.3/bin/:$PATH"
export PATH="/data/reddylab/software/rsem-1.2.21/:$PATH"
export PATH="/data/reddylab/software/bamtools-2.2.3/bin/:$PATH"
export PATH="/data/reddylab/software/STAR-STAR_2.4.1a/bin/Linux_x86_64/:$PATH"
export PATH="/data/reddylab/software/ggr-cwl/:$PATH"
export PATH="/data/reddylab/software/subread-1.4.6-p4-Linux-x86_64/bin/:$PATH"

module load bedtools2

# For Fastqc
export DISPLAY=:0.0
cwltool --debug --non-strict  --preserve-environment PATH DISPLAY --outdir /data/reddylab/Alex/rnaseq-test/out-test-one --no-container --tmpdir-prefix /data/reddylab/Alex/rnaseq-test/tmp --tmp-outdir-prefix /data/reddylab/Alex/rnaseq-test/tmp-out /home/aeb84/workspace/GGR-cwl/RNA-seq_pipeline/pipeline-pe.cwl /home/aeb84/workspace/GGR-cwl/scripts_slurm_run/rna_seq_download_metadata.Project_Hong_2574_150702A3-pe.ONLY_ONE.json  2>&1 


