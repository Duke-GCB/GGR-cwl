#!/usr/bin/env cwl-runner
cwlVersion: "cwl:draft-3"
class: Workflow
description: "DNase-seq 02 quantification"
requirements:
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
inputs:
  - id: "#input_bam_files"
    type:
      type: array
      items: File
  - id: "#input_bam_format"
    type: string
    description: "BAM or BAMPE for single-end and paired-end reads respectively (default: BAM)"
    default: "BAM"
  - id: "#nthreads"
    type: int
    default: 1
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
  - id: "#output_narrowpeak_file"
    source: "#peak-calling-narrow.output_peak_file"
    description: "peakshift/phantomPeak results file"
    type:
      type: array
      items: File
  - id: "#output_extended_narrowpeak_file"
    source: "#peak-calling-narrow.output_ext_frag_bdg_file"
    description: "peakshift/phantomPeak extended fragment results file"
    type:
      type: array
      items: File
  - id: "#output_peak_xls_file"
    source: "#peak-calling-narrow.output_peak_xls_file"
    description: "Peak calling report file (*_peaks.xls file produced by MACS2)"
    type:
      type: array
      items: File
  - id: "#output_filtered_read_count_file"
    source: "#count-reads-filtered.read_count_file"
    description: "Filtered read count reported by MACS2"
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
    run: {$import: "../spp/spp.cwl"}
    scatter:
      - "#spp.input_bam"
    scatterMethod: dotproduct
    inputs:
      - id: "#spp.input_bam"
        source: "#input_bam_files"
      - id: "#spp.savp"
        valueFrom: $(true)
      - id: "#spp.nthreads"
        source: "#nthreads"
    outputs:
      - id: "#spp.output_spp_cross_corr"
      - id: "#spp.output_spp_cross_corr_plot"
  - id: "#extract-peak-frag-length"
    run: {$import: "../spp/extract-best-frag-length.cwl"}
    scatter: "#extract-peak-frag-length.input_spp_txt_file"
    inputs:
      - id: "#extract-peak-frag-length.input_spp_txt_file"
        source: "#spp.output_spp_cross_corr"
    outputs:
      - id: "#extract-peak-frag-length.output_best_frag_length"
  - id: "#peak-calling-narrow"
    run: {$import: "../peak_calling/macs2-callpeak.cwl"}
    scatter:
      - "#peak-calling-narrow.treatment"
    inputs:
      - id: "#peak-calling-narrow.treatment"
        source: "#input_bam_files"
        valueFrom: $([self])
      - id: "#peak-calling-narrow.extsize"
        valueFrom: $(200)
      - id: "#peak-calling-narrow.nomodel"
        valueFrom: $(true)
      - id: "#peak-calling-narrow.q"
        valueFrom: $(0.10)
      - id: "#peak-calling-narrow.shift"
        valueFrom: $(-100)
      - id: "#peak-calling-narrow.bdg"
        valueFrom: $(true)
      - id: "#peak-calling-narrow.format"
        source: "#input_bam_format"
    outputs:
      - id: "#peak-calling-narrow.output_peak_file"
      - id: "#peak-calling-narrow.output_ext_frag_bdg_file"
      - id: "#peak-calling-narrow.output_peak_xls_file"
  - id: "#count-reads-filtered"
    run: {$import: "../peak_calling/count-reads-after-filtering.cwl"}
    scatter: "#count-reads-filtered.peak_xls_file"
    inputs:
      - id: "#count-reads-filtered.peak_xls_file"
        source: "#peak-calling-narrow.output_peak_xls_file"
    outputs:
      - id: "#count-reads-filtered.read_count_file"
  - id: "#count-peaks"
    run: {$import: "../utils/count-with-output-suffix.cwl"}
    scatter: "#count-peaks.input_file"
    inputs:
      - id: "#count-peaks.input_file"
        source: "#peak-calling-narrow.output_peak_file"
      - id: "#count-peaks.output_suffix"
        valueFrom: ".peak_count.within_replicate.txt"
    outputs:
      - id: "#count-peaks.output_counts"
  - id: "#filter-reads-in-peaks"
    run: {$import: "../peak_calling/samtools-filter-in-bedfile.cwl"}
    scatter:
      - "#filter-reads-in-peaks.input_bam_file"
      - "#filter-reads-in-peaks.input_bedfile"
    scatterMethod: dotproduct
    inputs:
      - id: "#filter-reads-in-peaks.input_bam_file"
        source: "#input_bam_files"
      - id: "#filter-reads-in-peaks.input_bedfile"
        source: "#peak-calling-narrow.output_peak_file"
    outputs:
      - id: "#filter-reads-in-peaks.filtered_file"

  - id: "#extract-count-reads-in-peaks"
    run: {$import: "../peak_calling/samtools-extract-number-mapped-reads.cwl"}
    scatter: "#extract-count-reads-in-peaks.input_bam_file"
    inputs:
      - id: "#extract-count-reads-in-peaks.input_bam_file"
        source: "#filter-reads-in-peaks.filtered_file"
      - id: "#extract-count-reads-in-peaks.output_suffix"
        valueFrom: ".read_count.in_peaks.within_reps.txt"
    outputs:
      - id: "#extract-count-reads-in-peaks.output_read_count"
