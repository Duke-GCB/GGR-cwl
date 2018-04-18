#!/usr/bin/env cwl-runner

class: Workflow
description: "ChIP-seq - map - PCR Bottleneck Coefficients"

requirements:
  - class: ScatterFeatureRequirement

inputs:
  - id: "#input_bam_files"
    type:
      type: array
      items: File
  - id: "#input_output_filenames"
    type:
      type: array
      items: string
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
    run: {$import: "bedtools-genomecov.cwl"}
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
    run: {$import: "compute-pbc.cwl"}
    scatter:
      - "#compute_pbc.bedgraph_file"
      - "#compute_pbc.output_filename"
    scatterMethod: dotproduct
    inputs:
      - id: "#compute_pbc.bedgraph_file"
        source: "#bedtools_genomecov.output_bedfile"
      - id: "#compute_pbc.output_filename"
        source: "#input_output_filenames"
    outputs:
      - id: "#compute_pbc.pbc"
