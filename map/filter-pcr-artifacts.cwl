#!/usr/bin/env cwl-runner

class: Workflow
description: "DNase-seq - map - Filter PCR Artifacts"

requirements:
  - class: ScatterFeatureRequirement

inputs:
  - id: "#input_bam_files"
    type:
      type: array
      items: File

outputs:
  - id: "#filtered_bedfile"
    source: "#window_trimmer.filtered_file"
    type:
      type: array
      items: File

steps:
  - id: "#bedtools_bamtobed"
    run: {$import: "bedtools-bamtobed.cwl"}
    scatter: "#bedtools_bamtobed.bam"
    inputs:
      - id: "#bedtools_bamtobed.bam"
        source: "#input_bam_files"
    outputs:
      - id: "#bedtools_bamtobed.output_bedfile"
  - id: "#window_trimmer"
    run: {$import: "windowtrimmer.cwl"}
    scatter: "#window_trimmer.input_file"
    inputs:
      - id: "#window_trimmer.input_file"
        source: "#bedtools_bamtobed.output_bedfile"
    outputs:
      - id: "#window_trimmer.filtered_file"