#!/bin/bash

# Example to run ChIP-seq_pipeline/01-qc.cwl
# Requires cwltool and docker
#   https://github.com/common-workflow-language/cwltool
#   https://www.docker.com

# When running Docker on OS X, all data files must be under $HOME

TMP_OUTDIR_PREFIX=$HOME/cwl/out
TMPDIR_PREFIX=$HOME/cwl/tmp

FASTQ_FILE1_R1=/Users/abarrera/data/TEST_1.ERR242959_R1.fastq
FASTQ_FILE1_R2=/Users/abarrera/data/TEST_1.ERR242959_R2.fastq
FASTQ_FILE2_R1=/Users/abarrera/data/TEST_2.ERR242959_R1.fastq
FASTQ_FILE2_R2=/Users/abarrera/data/TEST_2.ERR242959_R2.fastq
ADAPTERS_FILE1_R1=/Users/abarrera/data/output/TEST_1.ERR242959_R1.custom_adapters.fasta
ADAPTERS_FILE1_R2=/Users/abarrera/data/output/TEST_1.ERR242959_R2.custom_adapters.fasta
ADAPTERS_FILE2_R1=/Users/abarrera/data/output/TEST_2.ERR242959_R1.custom_adapters.fasta
ADAPTERS_FILE2_R2=/Users/abarrera/data/output/TEST_2.ERR242959_R2.custom_adapters.fasta
OUTDIR=$HOME/data/output_trimmomatic_pe/

cwl-runner \
  --debug \
  --outdir=$OUTDIR \
  --tmp-outdir-prefix=$TMP_OUTDIR_PREFIX \
  --tmpdir-prefix=$TMPDIR_PREFIX \
  ../GGR-cwl/ChIP-seq_pipeline/02-trimmomatic-pe.cwl \
  --input_read1_fastq_files $FASTQ_FILE1_R1 \
  --input_read1_fastq_files $FASTQ_FILE2_R1 \
  --input_read2_fastq_files $FASTQ_FILE1_R2 \
  --input_read2_fastq_files $FASTQ_FILE2_R2 \
  --input_read1_adapters_file $ADAPTERS_FILE1_R1 \
  --input_read1_adapters_file $ADAPTERS_FILE2_R1 \
  --input_read2_adapters_file $ADAPTERS_FILE1_R2 \
  --input_read2_adapters_file $ADAPTERS_FILE2_R2
