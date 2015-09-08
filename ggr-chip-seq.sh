#!/bin/bash
#
#SBATCH --job-name=GGR_ChIP_seq
#SBATCH --output=ggr-chip-seq.out
#SBATCH --mail-user=dan.leehr@duke.edu
#SBATCH --mail-type=FAIL

source ~/env-cwl/bin/activate
srun cwltool --outdir ~/ggr-cwl-data --no-container ~/ggr-cwl/ggr-chip-seq.cwl ~/ggr-cwl/chip-seq.json
