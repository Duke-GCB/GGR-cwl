#!/bin/bash
#
#SBATCH --job-name=ChIP_seq
#SBATCH --output=ggr-chip-seq.out
#SBATCH --mail-user=dan.leehr@duke.edu
#SBATCH --mail-type=FAIL

source ~/env-cwl/bin/activate
export PATH="/data/reddylab/software/FastQC:/home/dcl9/bin:/usr/local/bin:$PATH"
srun cwltool --preserve-environment PATH --outdir ~/ggr-cwl-data --no-container ~/ggr-cwl/ggr-chip-seq.cwl ~/ggr-cwl/chip-seq-hardac.json
