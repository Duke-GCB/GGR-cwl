#!/bin/bash
#
#SBATCH --job-name=GGR_ChIP_seq
#SBATCH --output=ggr-chip-seq.out
#SBATCH --mail-user=dan.leehr@duke.edu
#SBATCH --mail-type=FAIL

source ~/env-cwl/bin/activate
export PATH="$PATH:/data/reddylab/software/FastQC/:/home/dcl9/bin/:/usr/local/bin/"
srun cwltool --outdir ~/ggr-cwl-data --no-container ~/ggr-cwl/ggr-chip-seq.cwl ~/ggr-cwl/chip-seq.json
