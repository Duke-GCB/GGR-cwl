#!/usr/bin/env cwl-runner

class: Workflow
description: "GGR_ChIP-seq - map - PCR Bottleneck Coefficients"

requirements:
  - class: ScatterFeatureRequirement

inputs:
  - id: "#input_bam_files"
    type:
      type: array
      items: File
  - id: "#genome_sizes"
    type: File

outputs:
  - id: "#pbc_file"
    source: "#compute_pbc.pbc"
    type:
      type: array
      items: File

steps:
  - id: "#bedtools_genomecov"
    run: {import: "bedtools-genomecov.cwl"}
    scatter: "#bedtools_genomecov.ibam"
    inputs:
      - id: "#bedtools_genomecov.ibam"
        source: "#input_bam_files"
      - id: "#bedtools_genomecov.g"
        source: "#genome_sizes"
      - id: "#bedtools_genomecov.bg"
        default: true
    outputs:
      - id: "#bedtools_genomecov.output_bedfile"
  - id: "#compute_pbc"
    run: {import: "compute-pbc.cwl"}
    scatter: "#compute_pbc.bedgraph_file"
    inputs:
      - id: "#compute_pbc.bedgraph_file"
        source: "#bedtools_genomecov.output_bedfile"
    outputs:
      - id: "#compute_pbc.pbc"

## compute PCR bottleneck coefficient
#bedtools genomecov -bg -ibam ${SAMPLE}.sorted.bam -g $GENOME_SIZES > ${SAMPLE}.sorted.bdg
#awk '$4==1 {N1 += $3 - $2 - 1}; $4>=1 {Nd += $3 - $2 - 1} END {print N1/Nd}' ${SAMPLE}.sorted.bdg > ${SAMPLE}.PBC.txt
#rm ${SAMPLE}.sorted.bdg
