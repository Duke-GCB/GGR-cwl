#!/usr/bin/env cwl-runner
cwlVersion: "cwl:draft-3"
class: Workflow
description: "ChIP-seq - Quantification"
requirements:
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
inputs:
  - id: "#input_trt_bam_files"
    type:
      type: array
      items: File
  - id: "#input_ctrl_bam_files"
    type:
      type: array
      items: File
  - id: "#input_genome_sizes"
    type: File
  - id: "#nthreads"
    type: int
    default: 1
outputs:
  - id: "#bigwig_raw_files"
    source: "#bdg2bw-raw.output_bigwig"
    description: "Raw reads bigWig (signal) files"
    type:
      type: array
      items: File
  - id: "#bigwig_rpkm_extended_files"
    source: "#bamCoverage-rpkm-trt.output_bam_coverage"
    description: "Fragment extended RPKM bigWig (signal) files"
    type:
      type: array
      items: File
  - id: "#bigwig_ctrl_rpkm_extended_files"
    source: "#bamCoverage-rpkm-ctrl.output_bam_coverage"
    description: "Fragment extended RPKM bigWig (signal) control files"
    type:
      type: array
      items: File
  - id: "#bigwig_ctrl_subtracted_rpkm_extended_files"
    source: "#bamCompare-ctrl-subtracted-rpkm.output"
    description: "Control subtracted fragment extended RPKM bigWig (signal) files"
    type:
      type: array
      items: File
steps:
  - id: "#bedtools_genomecov"
    run: {$import: "../map/bedtools-genomecov.cwl"}
    scatter: "#bedtools_genomecov.ibam"
    inputs:
      - id: "#bedtools_genomecov.ibam"
        source: "#input_trt_bam_files"
      - id: "#bedtools_genomecov.g"
        source: "#input_genome_sizes"
      - id: "#bedtools_genomecov.bg"
        valueFrom: $(true)
    outputs:
      - id: "#bedtools_genomecov.output_bedfile"
  - id: "#bedsort_genomecov"
    run: {$import: "../quant/bedSort.cwl"}
    scatter: "#bedsort_genomecov.bed_file"
    inputs:
      - id: "#bedsort_genomecov.bed_file"
        source: "#bedtools_genomecov.output_bedfile"
    outputs:
      - id: "#bedsort_genomecov.bed_file_sorted"
  - id: "#bdg2bw-raw"
    run: {$import: "../quant/bedGraphToBigWig.cwl"}
    scatter: "#bdg2bw-raw.bed_graph"
    inputs:
      - id: "#bdg2bw-raw.bed_graph"
        source: "#bedsort_genomecov.bed_file_sorted"
      - id: "#bdg2bw-raw.genome_sizes"
        source: "#input_genome_sizes"
      - id: "bdg2bw-raw.output_suffix"
        valueFrom: ".raw.bw"
    outputs:
      - id: "#bdg2bw-raw.output_bigwig"
  - id: "#bamCoverage-rpkm-trt"
    run: {$import: "../quant/deeptools-bamcoverage.cwl"}
    scatter: "#bamCoverage-rpkm-trt.bam"
    inputs:
      - id: "#bamCoverage-rpkm-trt.bam"
        source: "#input_trt_bam_files"
      - id: "#bamCoverage-rpkm-trt.output_suffix"
        valueFrom: ".rpkm.bw"
      - id: "#bamCoverage-rpkm-trt.numberOfProcessors"
        source: "#nthreads"
      - id: "#bamCoverage-rpkm-trt.extendReads"
        valueFrom: $(200)
      - id: "#bamCoverage-rpkm-trt.normalizeUsingRPKM"
        valueFrom: $(true)
      - id: "#bamCoverage-rpkm-trt.binSize"
        valueFrom: $(100000)
      - id: "#bamCoverage-rpkm-trt.outFileFormat"
        valueFrom: "bigwig"
    outputs:
      - id: "#bamCoverage-rpkm-trt.output_bam_coverage"
  - id: "#bamCoverage-rpkm-ctrl"
    run: {$import: "../quant/deeptools-bamcoverage.cwl"}
    scatter: "#bamCoverage-rpkm-ctrl.bam"
    inputs:
      - id: "#bamCoverage-rpkm-ctrl.bam"
        source: "#input_ctrl_bam_files"
      - id: "#bamCoverage-rpkm-ctrl.output_suffix"
        valueFrom: ".rpkm.bw"
      - id: "#bamCoverage-rpkm-ctrl.numberOfProcessors"
        source: "#nthreads"
      - id: "#bamCoverage-rpkm-ctrl.extendReads"
        valueFrom: $(200)
      - id: "#bamCoverage-rpkm-ctrl.normalizeUsingRPKM"
        valueFrom: $(true)
      - id: "#bamCoverage-rpkm-ctrl.binSize"
        valueFrom: $(100000)
      - id: "#bamCoverage-rpkm-ctrl.outFileFormat"
        valueFrom: "bigwig"
    outputs:
      - id: "#bamCoverage-rpkm-ctrl.output_bam_coverage"
  - id: "#bamCompare-ctrl-subtracted-rpkm"
    run: {$import: "../quant/deeptools-bigwigcompare.cwl"}
    scatterMethod: dotproduct
    scatter:
      - "#bamCompare-ctrl-subtracted-rpkm.bigwig1"
      - "#bamCompare-ctrl-subtracted-rpkm.bigwig2"
    inputs:
      - id: "#bamCompare-ctrl-subtracted-rpkm.bigwig1"
        source: "#bamCoverage-rpkm-trt.output_bam_coverage"
      - id: "#bamCompare-ctrl-subtracted-rpkm.bigwig2"
        source: "#bamCoverage-rpkm-ctrl.output_bam_coverage"
      - id: "#bamCompare-ctrl-subtracted-rpkm.output_suffix"
        valueFrom: ".ctrl_subtracted.bw"
      - id: "#bamCompare-ctrl-subtracted-rpkm.numberOfProcessors"
        source: "#nthreads"
      - id: "#bamCompare-ctrl-subtracted-rpkm.ratio"
        valueFrom: "subtract"
      - id: "#bamCompare-ctrl-subtracted-rpkm.binSize"
        valueFrom: $(100000)
      - id: "#bamCompare-ctrl-subtracted-rpkm.outFileFormat"
        valueFrom: "bigwig"
    outputs:
      - id: "#bamCompare-ctrl-subtracted-rpkm.output"