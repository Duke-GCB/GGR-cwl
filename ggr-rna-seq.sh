#!/bin/bash
#
#SBATCH --job-name=GGR_RNA-seq
#SBATCH --output=ggr-rna-seq.out
#SBATCH --mail-user=dan.leehr@duke.edu
#SBATCH --mail-type=FAIL

source ~/env-cwl/bin/activate
export PATH="/data/reddylab/software/FastQC:/home/dcl9/bin:/usr/local/bin:/data/reddylab/software/STAR_2.4.2a/STAR-STAR_2.4.2a/bin/Linux_x86_64_static:$PATH"
srun cwltool --debug --preserve-environment PATH --outdir ~/ggr-cwl-data --no-container ~/ggr-cwl/ggr-rna-seq.cwl ~/ggr-cwl/rna-seq-hardac.json
