#!/usr/bin/env cwl-runner

class: Workflow
description: "GGR_ChIP-seq - Quantification"

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
  - id: "#coverage_bigwig_files"
    source: "#bedgraph2bigwig.output_bigwig"
    type:
      type: array
      items: File
  - id: "#coverage_normalized_bigwig_files"
    source: "#bamcoverage.output_bam_coverage"
    type:
      type: array
      items: File

steps:
  - id: "#bedtools_genomecov"
    run: {import: "../map/bedtools-genomecov.cwl"}
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
  - id: "#bedgraph2bigwig"
    run: {import: "../quant/bedGraphToBigWig.cwl"}
    scatter: "#bedgraph2bigwig.bed_graph"
    inputs:
      - id: "#bedgraph2bigwig.bed_graph"
        source: "#bedtools_genomecov.output_bedfile"
      - id: "#bedgraph2bigwig.genome_sizes"
        source: "#genome_sizes"
    outputs:
      - id: "#bedgraph2bigwig.output_bigwig"
  - id: "#bamcoverage"
    run: {import: "../quant/deeptools-bamcoverage.cwl"}
    scatter: "#bamcoverage.bam"
    inputs:
      - id: "#bamcoverage.bam"
        source: "#input_bam_files"
    outputs:
      - id: "#bamcoverage.output_bam_coverage"
