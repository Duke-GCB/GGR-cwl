#!/usr/bin/env cwl-runner
cwlVersion: "cwl:draft-3"

class: Workflow
description: "DNase-seq 03 quantification"

requirements:
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement

inputs:
  - id: "#input_bam_files"
    type:
      type: array
      items: File
  - id: "#input_pileup_bedgraphs"
    type:
      type: array
      items: File
  - id: "#input_peak_xls_files"
    type:
      type: array
      items: File
  - id: "#input_read_count_dedup_files"
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
  - id: "#bigwig_norm_files"
    source: "#bamcoverage.output_bam_coverage"
    description: "Normalized reads bigWig (signal) files"
    type:
      type: array
      items: File
  - id: "#bigwig_extended_files"
    source: "#bdg2bw-extend.output_bigwig"
    description: "Fragment extended reads bigWig (signal) files"
    type:
      type: array
      items: File
  - id: "#bigwig_extended_norm_files"
    source: "#bdg2bw-extend-norm.output_bigwig"
    description: "Normalized fragment extended reads bigWig (signal) files"
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
      - id: "#bdg2bw-raw.output_suffix"
        valueFrom: ".raw.bw"
    outputs:
      - id: "#bdg2bw-raw.output_bigwig"
  - id: "#bamcoverage"
    run: {$import: "../quant/deeptools-bamcoverage.cwl"}
    scatter: "#bamcoverage.bam"
    inputs:
      - id: "#bamcoverage.bam"
        source: "#input_bam_files"
      - id: "#bamcoverage.output_suffix"
        valueFrom: ".norm.bw"
      - id: "#bamcoverage.numberOfProcessors"
        source: "#nthreads"
      - id: "#bamcoverage.extendReads"
        valueFrom: $(200)
      - id: "#bamcoverage.normalizeUsingRPKM"
        valueFrom: $(true)
      - id: "#bamcoverage.binSize"
        valueFrom: $(50)
    outputs:
      - id: "#bamcoverage.output_bam_coverage"
  - id: "#extend-reads"
    run: {$import: "../quant/bedtools-slop.cwl"}
    scatter: "#extend-reads.i"
    inputs:
      - id: "#extend-reads.i"
        source: "#input_pileup_bedgraphs"
      - id: "#extend-reads.g"
        source: "#input_genome_sizes"
      - id: "#extend-reads.b"
        valueFrom: $(0)
    outputs:
      - id: "#extend-reads.stdoutfile"
  - id: "#clip-off-chrom"
    run: {$import: "../quant/bedClip.cwl"}
    scatter: "#clip-off-chrom.bed_file"
    inputs:
      - id: "#clip-off-chrom.bed_file"
        source: "#extend-reads.stdoutfile"
      - id: "#clip-off-chrom.genome_sizes"
        source: "#input_genome_sizes"
    outputs:
      - id: "#clip-off-chrom.bed_file_clipped"
  - id: "#bedsort_clipped_bedfile"
    run: {$import: "../quant/bedSort.cwl"}
    scatter: "#bedsort_clipped_bedfile.bed_file"
    inputs:
      - id: "#bedsort_clipped_bedfile.bed_file"
        source: "#clip-off-chrom.bed_file_clipped"
    outputs:
      - id: "#bedsort_clipped_bedfile.bed_file_sorted"
  - id: "#bdg2bw-extend"
    run: {$import: "../quant/bedGraphToBigWig.cwl"}
    scatter: "#bdg2bw-extend.bed_graph"
    inputs:
      - id: "#bdg2bw-extend.bed_graph"
        source: "#bedsort_clipped_bedfile.bed_file_sorted"
      - id: "#bdg2bw-extend.genome_sizes"
        source: "#input_genome_sizes"
      - id: "#bdg2bw-extend.output_suffix"
        valueFrom: ".fragment_extended.bw"
    outputs:
      - id: "#bdg2bw-extend.output_bigwig"
  - id: "#scale-bedgraph"
    run: {$import: "../peak_calling/scale-bedgraph.cwl"}
    scatter:
      - "#scale-bedgraph.bedgraph_file"
      - "#scale-bedgraph.read_count_file"
    scatterMethod: dotproduct
    inputs:
      - id: "#scale-bedgraph.bedgraph_file"
        source: "#input_pileup_bedgraphs"
      - id: "#scale-bedgraph.read_count_file"
        source: "#input_read_count_dedup_files"
    outputs:
      - id: "#scale-bedgraph.bedgraph_scaled"
  - id: "#bedsort_scaled_bdg"
    run: {$import: "../quant/bedSort.cwl"}
    scatter: "#bedsort_scaled_bdg.bed_file"
    inputs:
      - id: "#bedsort_scaled_bdg.bed_file"
        source: "#scale-bedgraph.bedgraph_scaled"
    outputs:
      - id: "#bedsort_scaled_bdg.bed_file_sorted"
  - id: "#bdg2bw-extend-norm"
    run: {$import: "../quant/bedGraphToBigWig.cwl"}
    scatter: "#bdg2bw-extend-norm.bed_graph"
    inputs:
      - id: "#bdg2bw-extend-norm.bed_graph"
        source: "#bedsort_scaled_bdg.bed_file_sorted"
      - id: "#bdg2bw-extend-norm.genome_sizes"
        source: "#input_genome_sizes"
      - id: "#bdg2bw-extend-norm.output_suffix"
        valueFrom: ".fragment_extended.bw"
    outputs:
      - id: "#bdg2bw-extend-norm.output_bigwig"
