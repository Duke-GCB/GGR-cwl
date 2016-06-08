#!/bin/bash

# Example to run ChIP-seq_pipeline/01-qc.cwl
# Requires cwltool and docker
#   https://github.com/common-workflow-language/cwltool
#   https://www.docker.com

# When running Docker on OS X, all data files must be under $HOME

TMP_OUTDIR_PREFIX=$HOME/cwl/out
TMPDIR_PREFIX=$HOME/cwl/tmp
OUTDIR=$HOME/data/output_bowtie_se/

FASTQ_FILE=/Users/abarrera/data/output/TEST.t00_rep1.trimmed.fastq
ALIGNED_FILE=TEST.t00_rep1.trimmed.sam
GENOME_REF_IDX1=/Users/abarrera/data/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set.1.ebwt
GENOME_REF_IDX2=/Users/abarrera/data/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set.2.ebwt
GENOME_REF_IDX3=/Users/abarrera/data/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set.3.ebwt
GENOME_REF_IDX4=/Users/abarrera/data/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set.4.ebwt
GENOME_REF_IDX5=/Users/abarrera/data/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set.rev.1.ebwt
GENOME_REF_IDX6=/Users/abarrera/data/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set.rev.2.ebwt


cwl-runner \
  --non-strict \
  --debug \
  --outdir=$OUTDIR \
  --tmp-outdir-prefix=$TMP_OUTDIR_PREFIX \
  --tmpdir-prefix=$TMPDIR_PREFIX \
  /Users/abarrera/workspace/GGR-cwl/bowtie/bowtie-se.cwl \
  --threads=1 \
  --genome_ref_index_files ${GENOME_REF_IDX1} \
  --genome_ref_index_files ${GENOME_REF_IDX2} \
  --genome_ref_index_files ${GENOME_REF_IDX3} \
  --genome_ref_index_files ${GENOME_REF_IDX4} \
  --genome_ref_index_files ${GENOME_REF_IDX5} \
  --genome_ref_index_files ${GENOME_REF_IDX6} \
  --input_fastq_file ${FASTQ_FILE} \
  --output_filename ${ALIGNED_FILE}
