#!/bin/bash

# Example to run ChIP-seq_pipeline/01-qc.cwl
# Requires cwltool and docker
#   https://github.com/common-workflow-language/cwltool
#   https://www.docker.com

# When running Docker on OS X, all data files must be under $HOME

TMP_OUTDIR_PREFIX=$HOME/cwl/out
TMPDIR_PREFIX=$HOME/cwl/tmp

FASTQ_FILE2=/Users/abarrera/data/TEST.t05_rep1.fastq
ADAPTERS_FILE1=/Users/abarrera/data/output/TEST.t00_rep1.custom_adapters.fasta
ADAPTERS_FILE2=/Users/abarrera/data/output/TEST.t05_rep1.custom_adapters.fasta
OUTDIR=$HOME/data/output/

cwl-runner \
  --non-strict \
  --debug \
  --outdir=$OUTDIR \
  --tmp-outdir-prefix=$TMP_OUTDIR_PREFIX \
  --tmpdir-prefix=$TMPDIR_PREFIX \
  /Users/abarrera/workspace/GGR-cwl/trimmomatic/trimmomatic.cwl \
  --threads=1 \
  --quality_score='-phred33' \
  --input_fastq_file /Users/abarrera/data/TEST.t00_rep1.fastq \
  --input_adapters_file $ADAPTERS_FILE1
