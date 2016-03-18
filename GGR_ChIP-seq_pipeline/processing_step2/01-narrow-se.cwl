#!/usr/bin/env cwl-runner

class: Workflow
description: "GGR_ChIP-seq - processing step 2 - Peak calling for narrow peaks (SE)"

requirements:
  - class: ScatterFeatureRequirement

inputs:
  - id: "#input_bam_files"
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
  - id: "#output_peak_count_within_replicate"
    source: "#count-peaks.output_counts"
    description: "Peak counts within replicate"
    type:
      type: array
      items: File
  - id: "#output_read_in_peak_count_within_replicate"
    source: "#extract-count-reads-in-peaks.output_read_count"
    description: "Peak counts within replicate"
    type:
      type: array
      items: File

steps:
  - id: "#spp"
    run: {import: "../../spp/spp.cwl"}
    scatter: "#spp.input_bam"
    inputs:
      - id: "#spp.input_bam"
        source: "#input_bam_files"
      - id: "#spp.savp"
        default: True
      - id: "#spp.nthreads"
        default: 2
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
    run: {import: "../../peak_calling/macs2-callpeak-narrow.cwl"}
    scatter:
      - "#peak-calling-narrow.treatment_sample_file"
      - "#peak-calling-narrow.extsize"
    scatterMethod: dotproduct
    inputs:
      - id: "#peak-calling-narrow.treatment_sample_file"
        source: "#input_bam_files"
      - id: "#peak-calling-narrow.extsize"
        source: "#extract-peak-frag-length.output_best_frag_length"
      - id: "#peak-calling-narrow.nomodel"
        default: True
      - id: "#peak-calling-narrow.format"
        default: "BAM"
    outputs:
      - id: "#peak-calling-narrow.output_narrowpeak_file"
  - id: "#count-peaks"
    run: {import: "../../utils/count-with-output-suffix.cwl"}
    scatter: "#count-peaks.input_file"
    inputs:
      - id: "#count-peaks.input_file"
        source: "#peak-calling-narrow.output_narrowpeak_file"
      - id: "#count-peaks.output_suffix"
        default: ".peak_count.within_replicate.txt"
    outputs:
      - id: "#count-peaks.output_counts"
  - id: "#filter-reads-in-peaks"
    run: {import: "../../peak_calling/samtools-filter-in-bedfile.cwl"}
    scatter:
      - "#filter-reads-in-peaks.input_bam_file"
      - "#filter-reads-in-peaks.input_bedfile"
    scatterMethod: dotproduct
    inputs:
      - id: "#filter-reads-in-peaks.input_bam_file"
        source: "#input_bam_files"
      - id: "#filter-reads-in-peaks.input_bedfile"
        source: "#peak-calling-narrow.output_narrowpeak_file"
    outputs:
      - id: "#filter-reads-in-peaks.filtered_file"
  - id: "#extract-count-reads-in-peaks"
    run: {import: "../../peak_calling/samtools-extract-number-mapped-reads.cwl"}
    scatter: "#extract-count-reads-in-peaks.input_bam_file"
    inputs:
      - id: "#extract-count-reads-in-peaks.input_bam_file"
        source: "#filter-reads-in-peaks.filtered_file"
      - id: "#extract-count-reads-in-peaks.output_suffix"
        default: ".read_count.within_replicate.txt"
    outputs:
      - id: "#extract-count-reads-in-peaks.output_read_count"