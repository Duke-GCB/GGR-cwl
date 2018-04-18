#!/usr/bin/env cwl-runner
cwlVersion: "cwl:draft-3"
class: Workflow
description: "ChIP-seq - Quantification"
requirements:
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
inputs:
  - id: "#input_bam_files"
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
    source: "#bamCoverage-rpkm.output_bam_coverage"
    description: "Fragment extended RPKM bigWig (signal) files"
    type:
      type: array
      items: File
steps:
  - id: "#bedtools_genomecov"
    run: {$import: "../map/bedtools-genomecov.cwl"}
    scatter: "#bedtools_genomecov.ibam"
    inputs:
      - id: "#bedtools_genomecov.ibam"
        source: "#input_bam_files"
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
  - id: "#bamCoverage-rpkm"
    run: {$import: "../quant/deeptools-bamcoverage.cwl"}
    scatter: "#bamCoverage-rpkm.bam"
    inputs:
      - id: "#bamCoverage-rpkm.bam"
        source: "#input_bam_files"
      - id: "#bamCoverage-rpkm.output_suffix"
        valueFrom: ".rpkm.bw"
      - id: "#bamCoverage-rpkm.numberOfProcessors"
        source: "#nthreads"
      - id: "#bamCoverage-rpkm.extendReads"
        valueFrom: $(200)
      - id: "#bamCoverage-rpkm.normalizeUsingRPKM"
        valueFrom: $(true)
      - id: "#bamCoverage-rpkm.binSize"
        valueFrom: $(1)
      - id: "#bamCoverage-rpkm.outFileFormat"
        valueFrom: "bigwig"
    outputs:
      - id: "#bamCoverage-rpkm.output_bam_coverage"