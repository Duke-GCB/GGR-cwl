#!/usr/bin/env cwl-runner
cwlVersion: "cwl:draft-3"
class: Workflow
description: "RNA-seq 04 quantification"
requirements:
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
  - class: SubworkflowFeatureRequirement
inputs:
  - id: "#input_bam_files"
    type: {type: array, items: File}
  - id: "#input_transcripts_bam_files"
    type: {type: array, items: File}
  - id: "#rsem_reference_files"
    type: {type: array, items: File}
    description: "RSEM genome reference files - generated with the rsem-prepare-reference command"
  - id: "#input_genome_sizes"
    type: File
  - id: "#annotation_file"
    type: File
    description: "GTF annotation file"
  - id: "#nthreads"
    type: int
    default: 1
outputs:
  - id: "#featurecounts_counts"
    source: "#featurecounts.output_files"
    description: "Normalized fragment extended reads bigWig (signal) files"
    type: {type: array, items: File}
  - id: "#rsem_isoforms_files"
    source: "#rsem-calc-expr.isoforms"
    description: "RSEM isoforms files"
    type: {type: array, items: File}
  - id: "#rsem_genes_files"
    source: "#rsem-calc-expr.genes"
    description: "RSEM genes files"
    type: {type: array, items: File}
  - id: "#bw_raw_files"
    source: "#bdg2bw-raw.output_bigwig"
    description: "Raw bigWig files."
    type: {type: array, items: File}
  - id: "#bw_norm_files"
    source: "#bamcoverage.output_bam_coverage"
    description: "Normalized by RPKM bigWig files."
    type: {type: array, items: File}
steps:
  - id: "#basename"
    run: {$import: "../utils/basename.cwl" }
    scatter: "#basename.file_path"
    inputs:
      - id: "#basename.file_path"
        source: "#input_bam_files"
        valueFrom: $(self.path)
      - id: "#sep"
        valueFrom: '\.Aligned\.out\.sorted'
    outputs:
      - id: "#basename.basename"
  - id: "#featurecounts"
    run: {$import: "../quant/subread-featurecounts.cwl"}
    scatter:
      - "#featurecounts.input_files"
      - "#featurecounts.output_filename"
    scatterMethod: dotproduct
    inputs:
      - id: "#featurecounts.input_files"
        source: "#input_bam_files"
        valueFrom: ${if (Array.isArray(self)) return self; return [self]; }
      - id: "#featurecounts.output_filename"
        source: "#basename.basename"
        valueFrom: $(self + ".featurecounts.counts.txt")
      - { id: "#featurecounts.annotation_file", source: "#annotation_file" }
      - { id: "#featurecounts.p", valueFrom: $(true) }
      - { id: "#featurecounts.B", valueFrom: $(true) }
      - { id: "#featurecounts.t", valueFrom: "exon" }
      - { id: "#featurecounts.g", valueFrom: "gene_id" }
      - { id: "#featurecounts.s", valueFrom: $(1) }
      - { id: "#featurecounts.T", source: "#nthreads" }
    outputs:
      - id: "#featurecounts.output_files"
  - id: "#rsem-calc-expr"
    run: {$import: "../quant/rsem-calculate-expression.cwl"}
    scatter:
      - "#rsem-calc-expr.bam"
      - "#rsem-calc-expr.sample_name"
    scatterMethod: dotproduct
    inputs:
      - { id: "#rsem-calc-expr.bam", source: "#input_transcripts_bam_files"}
      - { id: "#rsem-calc-expr.reference_files", source: "#rsem_reference_files"}
      - id: "#rsem-calc-expr.sample_name"
        source: "#basename.basename"
        valueFrom: $(self + ".rsem")
      - id: "#rsem-calc-expr.reference_name"
        source: "#rsem_reference_files"
        valueFrom: |
          ${
            var trans_file_str = self.map(function(e){return e.path}).filter(function(e){return e.match(/\.transcripts\.fa$/)})[0];
            return trans_file_str.match(/.*[\\\/](.*)\.transcripts\.fa$/)[1];
          }
      - { id: "#rsem-calc-expr.no-bam-output", valueFrom: $(true) }
      - { id: "#rsem-calc-expr.strand-specific", valueFrom: $(true) }
      - { id: "#rsem-calc-expr.seed", valueFrom: $(1234) }
      - { id: "#rsem-calc-expr.num-threads", source: "#nthreads" }
      - { id: "#rsem-calc-expr.quiet", valueFrom: $(true) }
    outputs:
      - id: "#rsem-calc-expr.isoforms"
      - id: "#rsem-calc-expr.genes"
      - id: "#rsem-calc-expr.rsem_stat"
  - id: "#bedtools_genomecov"
    run: {$import: "../map/bedtools-genomecov.cwl"}
    scatter: "#bedtools_genomecov.ibam"
    inputs:
      - { id: "#bedtools_genomecov.ibam",  source: "#input_bam_files" }
      - { id: "#bedtools_genomecov.g", source: "#input_genome_sizes"}
      - { id: "#bedtools_genomecov.bg", valueFrom: $(true) }
    outputs:
      - id: "#bedtools_genomecov.output_bedfile"
  - id: "#bedsort_genomecov"
    run: {$import: "../quant/bedSort.cwl"}
    scatter: "#bedsort_genomecov.bed_file"
    inputs:
      - { id: "#bedsort_genomecov.bed_file",  source: "#bedtools_genomecov.output_bedfile" }
    outputs:
      - id: "#bedsort_genomecov.bed_file_sorted"
  - id: "#bdg2bw-raw"
    run: {$import: "../quant/bedGraphToBigWig.cwl"}
    scatter: "#bdg2bw-raw.bed_graph"
    inputs:
      - { id: "#bdg2bw-raw.bed_graph", source: "#bedsort_genomecov.bed_file_sorted" }
      - { id: "#bdg2bw-raw.genome_sizes", source: "#input_genome_sizes" }
      - { id: "#bdg2bw-raw.output_suffix", valueFrom: ".raw.bw" }
    outputs:
      - id: "#bdg2bw-raw.output_bigwig"
  - id: "#bamcoverage"
    run: {$import: "../quant/deeptools-bamcoverage.cwl"}
    scatter: "#bamcoverage.bam"
    inputs:
      - { id: "#bamcoverage.bam", source: "#input_bam_files" }
      - { id: "#bamcoverage.output_suffix", valueFrom: ".norm.bw" }
      - { id: "#bamcoverage.numberOfProcessors", source: "#nthreads" }
      - { id: "#bamcoverage.normalizeUsingRPKM", valueFrom: $(true) }
    outputs:
      - id: "#bamcoverage.output_bam_coverage"