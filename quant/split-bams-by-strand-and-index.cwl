#!/usr/bin/env cwl-runner

class: Workflow
description: "Split reads in a BAM file by strands and index forward and reverse output BAM files"

requirements:
  - class: ScatterFeatureRequirement

inputs:
  - id: "#input_bam_files"
    type: { type: array,  items: File }
  - id: "#input_basenames"
    type: {type: array, items: string }
  - id: "#bamtools_forward_filter_file"
    type: File
    description: "JSON filter file for forward strand used in bamtools (see bamtools-filter command)"
  - id: "#bamtools_reverse_filter_file"
    type: File
    description: "JSON filter file for reverse strand used in bamtools (see bamtools-filter command)"

outputs:

  - id: "#bam_plus_files"
    source: "#split-bam-plus.output_file"
    description: "BAM files containing only reads in the forward (plus) strand."
    type: {type: array, items: File}
  - id: "#bam_minus_files"
    source: "#split-bam-minus.output_file"
    description: "BAM files containing only reads in the reverse (minus) strand."
    type: {type: array, items: File}


  - id: "#index_bam_plus_files"
    source: "#index_plus_bam.index_file"
    description: "Index files for BAM files containing only reads in the forward (plus) strand."
    type: {type: array, items: File}
  - id: "#index_bam_minus_files"
    source: "#index_minus_bam.index_file"
    description: "Index files for BAM files containing only reads in the reverse (minus) strand."
    type: {type: array, items: File}

steps:

  - id: "#split-bam-plus"
    run: {$import: "../quant/bamtools-filter.cwl"}
    scatter:
      - "#split-bam-plus.in"
      - "#split-bam-plus.out"
    scatterMethod: dotproduct
    inputs:
      - { id: "#split-bam-plus.script", source: "#bamtools_forward_filter_file" }
      - id: "#split-bam-plus.in"
        source: "#input_bam_files"
        valueFrom: ${return [self]}
      - id: "#split-bam-plus.out"
        source: "#input_basenames"
        valueFrom: $(self + ".Aligned.plus.bam")
    outputs:
      - id: "#split-bam-plus.output_file"
  - id: "#split-bam-minus"
    run: {$import: "../quant/bamtools-filter.cwl"}
    scatter:
      - "#split-bam-minus.in"
      - "#split-bam-minus.out"
    scatterMethod: dotproduct
    inputs:
      - id: "#split-bam-minus.in"
        source: "#input_bam_files"
        valueFrom: ${return [self]}
      - { id: "#split-bam-minus.script", source: "#bamtools_reverse_filter_file" }
      - id: "#split-bam-minus.out"
        source: "#input_basenames"
        valueFrom: $(self + ".Aligned.minus.bam")
    outputs:
      - id: "#split-bam-minus.output_file"


  - id: "#index_plus_bam"
    run: {$import: "../map/samtools-index.cwl"}
    scatter: "#index_plus_bam.input_file"
    inputs:
      - { id: "#index_plus_bam.input_file", source: "#split-bam-plus.output_file" }
    outputs:
      - id: "#index_plus_bam.index_file"
  - id: "#index_minus_bam"
    run: {$import: "../map/samtools-index.cwl"}
    scatter: "#index_minus_bam.input_file"
    inputs:
      - { id: "#index_minus_bam.input_file", source: "#split-bam-minus.output_file" }
    outputs:
      - id: "#index_minus_bam.index_file"
