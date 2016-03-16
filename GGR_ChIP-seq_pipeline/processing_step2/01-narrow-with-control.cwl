#!/usr/bin/env cwl-runner

class: Workflow
description: "GGR_ChIP-seq - Compute strand correlation"

requirements:
  - class: ScatterFeatureRequirement

inputs:
  - id: "#input_bam_files"
    type:
      type: array
      items: File
  - id: "#input_control_bam_files"
    type:
      type: array
      items: File

outputs:
  - id: "#output_spp_x_cross_corr"
    source: "#spp.output_spp_cross_corr"
    description: "peakshift/phantomPeak results file"
    type:
      type: array
      items: File
  - id: "#output_spp_cross_corr_plot"
    source: "#spp.output_spp_cross_corr_plot"
    description: "peakshift/phantomPeak results file"
    type:
      type: array
      items: File
  - id: "#output_callpeak_narrowpeak_file"
    source: "#peak-calling-narrow.output_narrowpeak_file"
    description: "peakshift/phantomPeak results file"
    type:
      type: array
      items: File

steps:
  - id: "#spp"
    run: {import: "../../spp/spp-with-control.cwl"}
    scatter:
      - "#spp.input_bam"
      - "#spp.control_bam"
    scatterMethod: dotproduct
    inputs:
      - id: "#spp.input_bam"
        source: "#input_bam_files"
      - id: "#spp.control_bam"
        source: "#input_control_bam_files"
      - id: "#spp.savp"
        default: True
    outputs:
      - id: "#spp.output_spp_cross_corr"
      - id: "#spp.output_spp_cross_corr_plot"

  - id: "#extract-peak-frag-length"
    run: {import: "../../spp/extract-best-frag-length.cwl"}
    scatter: "#extract-peak-frag-length.input_spp_txt_file"
    inputs:
      - id: "#extract-peak-frag-length.input_spp_txt_file"
        source: "#spp.output_spp_cross_corr"
    outputs:
      - id: "#extract-peak-frag-length.output_best_frag_length"

  - id: "#peak-calling-narrow"
    run: {import: "../../peak_calling/macs2-callpeak-narrow-with-control.cwl"}
    scatter:
      - "#peak-calling-narrow.treatment_sample_file"
      - "#peak-calling-narrow.control_sample_file"
      - "#peak-calling-narrow.extsize"
    scatterMethod: dotproduct
    inputs:
      - id: "#peak-calling-narrow.treatment_sample_file"
        source: "#input_bam_files"
      - id: "#peak-calling-narrow.control_sample_file"
        source: "#input_control_bam_files"
      - id: "#peak-calling-narrow.extsize"
        source: "#extract-peak-frag-length.output_best_frag_length"
      - id: "#peak-calling-narrow.nomodel"
        default: True
    outputs:
      - id: "#peak-calling-narrow.output_narrowpeak_file"