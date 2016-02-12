#!/usr/bin/env cwl-runner

class: Workflow
description: "GGR_ChIP-seq - Bowtie"

requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  - id: "#input_fastq_read1_files"
    type: 
      type: array
      items: File
    description: "Input fastq files"
  - id: "#input_fastq_read2_files"
    type:
      type: array
      items: File
    description: "Input fastq files"
  - id: "#genome_ref_index_files"
    type:
      type: array
      items: File
    description: "Bowtie index files for reference genome (*1.ebwt, *.2.ebwt, ...)"
  - id: "#genome_sizes_file"
    type: File
    description: "Genome sizes tab-delimited file (used in samtools)"
  - id: "#ENCODE_blacklist_bedfile"
    type: File
    description: "Bedfile containing ENCODE consensus blacklist regions to be excluded."
  - id: "#nthreads_mapping"
    type: int
    default: 1

outputs:
  - id: "#output_data_sorted_filtered_bam_files"
    source: "#filtered2sorted.sorted_file"
    description: "Filtered sorted aligned BAM files with Bowtie."
    type:
      type: array
      items: File
  - id: "#output_picard_mark_duplicates_files"
    source: "#remove_duplicates.output_metrics_file"
    description: "Picard MarkDuplicates metrics files."
    type:
      type: array
      items: File
  - id: "#output_data_sorted_dedup_bam_files"
    source: "#sort_dedup_bams.sorted_file"
    description: "BAM files without duplicate reads."
    type:
      type: array
      items: File
  - id: "#output_index_dedup_bam_files"
    source: "#index_dedup_bams.index_file"
    description: "Index for BAM files without duplicate reads."
    type:
      type: array
      items: File
  - id: "#pbc_files"
    source: "#execute_pcr_bottleneck_coef.pbc_file"
    description: "PCR Bottleneck Coeficient files."
    type:
      type: array
      items: File

steps:
  - id: "#extract_basename"
    run: {import: "../utils/extract-basename.cwl" }
    scatter: "#extract_basename.input_file"
    inputs:
      - id: "#extract_basename.input_file"
        source: "#input_fastq_read1_files"
    outputs:
      - id: "#extract_basename.output_basename"
  - id: "#bowtie-pe"
    run: {import: "../map/bowtie-pe.cwl"}
    scatter:
      - "#bowtie-pe.input_fastq_read1_file"
      - "#bowtie-pe.input_fastq_read2_file"
      - "#bowtie-pe.output_filename"
    scatterMethod: dotproduct
    inputs:
      - id: "#bowtie-pe.input_fastq_read1_file"
        source: "#input_fastq_read1_files"
      - id: "#bowtie-pe.input_fastq_read2_file"
        source: "#input_fastq_read2_files"
      - id: "#bowtie-pe.output_filename"
        source: "#extract_basename.output_basename"
      - id: "#bowtie-pe.genome_ref_index_files"
        source: "#genome_ref_index_files"
      - id: "bowtie-pe.nthreads"
        source: "#nthreads_mapping"
    outputs:
      - id: "#bowtie-pe.output_aligned_file"
  - id: "#sam2bam"
    run: {import: "../map/samtools2bam.cwl"}
    scatter:
      - "#sam2bam.input_file"
    inputs:
      - id: "#sam2bam.input_file"
        source: "#bowtie-pe.output_aligned_file"
    outputs:
      - id: "#sam2bam.bam_file"
  - id: "#sort_bams"
    run: {import: "../map/samtools-sort.cwl"}
    scatter:
      - "#sort_bams.input_file"
    inputs:
      - id: "#sort_bams.input_file"
        source: "#sam2bam.bam_file"
    outputs:
      - id: "#sort_bams.sorted_file"
  - id: "#filter-unmapped"
    run: {import: "../map/samtools-filter-unmapped.cwl"}
    scatter:
      - "#filter-unmapped.input_file"
    inputs:
      - id: "#filter-unmapped.input_file"
        source: "#sort_bams.sorted_file"
    outputs:
      - id: "#filter-unmapped.filtered_file"
  - id: "#filtered2sorted"
    run: {import: "../map/samtools-sort.cwl"}
    scatter:
      - "#filtered2sorted.input_file"
    inputs:
      - id: "#filtered2sorted.input_file"
        source: "#filter-unmapped.filtered_file"
    outputs:
      - id: "#filtered2sorted.sorted_file"
#  - id: "#extract_basename_sorted_bam"
#    run: {import: "../utils/extract-basename.cwl" }
#    scatter: "#extract_basename_sorted_bam.input_file"
#    inputs:
#      - id: "#extract_basename_sorted_bam.input_file"
#        source: "#filtered2sorted.sorted_file"
#    outputs:
#      - id: "#extract_basename_sorted_bam.output_basename"
#  - id: "#preseq-c-curve"
#    run: {import: "../map/preseq-c_curve.cwl"}
#    scatter:
#      - "#preseq-c-curve.input_sorted_file"
#      - "#preseq-c-curve.output_filename"
#    scatterMethod: dotproduct
#    inputs:
#      - id: "#preseq-c-curve.input_sorted_file"
#        source: "#filtered2sorted.sorted_file"
#      - id: "#preseq-c-curve.output_filename"
#        source: "#extract_basename_sorted_bam.output_basename"
#    outputs:
#      - id: "#preseq-c-curve.output_file"
# TODO: Check why preseq is not working..
  - id: "#execute_pcr_bottleneck_coef"
    run: {import: "../map/pcr-bottleneck-coef.cwl"}
    inputs:
      - id: "#execute_pcr_bottleneck_coef.input_bam_files"
        source: "#filtered2sorted.sorted_file"
      - id: "#execute_pcr_bottleneck_coef.genome_sizes"
        source: "#genome_sizes_file"
    outputs:
      - id: "#execute_pcr_bottleneck_coef.pbc_file"
  - id: "#remove_duplicates"
    run: {import: "../map/picard-MarkDuplicates.cwl"}
    scatter:
      - "#remove_duplicates.input_file"
    inputs:
      - id: "#remove_duplicates.input_file"
        source: "#filtered2sorted.sorted_file"
      - id: "#absolute_path_to_picard_jar"
        default: "/usr/picard/picard.jar"
    outputs:
      - id: "#remove_duplicates.output_metrics_file"
      - id: "#remove_duplicates.output_dedup_bam_file"
  - id: "#remove_encode_blacklist"
    run: {import: "../map/bedtools-intersect.cwl"}
    scatter:
      - "#remove_encode_blacklist.a"
    inputs:
      - id: "#remove_encode_blacklist.v"
        default: true
      - id: "#remove_encode_blacklist.a"
        source: "#remove_duplicates.output_dedup_bam_file"
      - id: "#remove_encode_blacklist.b"
        source: "#ENCODE_blacklist_bedfile"
    outputs:
      - id: "#remove_encode_blacklist.file_wo_blacklist_regions"
  - id: "#sort_dedup_bams"
    run: {import: "../map/samtools-sort.cwl"}
    scatter:
      - "#sort_dedup_bams.input_file"
    inputs:
      - id: "#sort_dedup_bams.input_file"
        source: "#remove_encode_blacklist.file_wo_blacklist_regions"
    outputs:
      - id: "#sort_dedup_bams.sorted_file"
  - id: "#index_dedup_bams"
    run: {import: "../map/samtools-index.cwl"}
    scatter:
      - "#index_dedup_bams.input_file"
    inputs:
      - id: "#index_dedup_bams.input_file"
        source: "#sort_dedup_bams.sorted_file"
    outputs:
      - id: "#index_dedup_bams.index_file"
