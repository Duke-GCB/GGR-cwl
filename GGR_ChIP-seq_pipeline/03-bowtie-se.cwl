#!/usr/bin/env cwl-runner

class: Workflow
description: "GGR_ChIP-seq - Bowtie"

requirements:
  - class: ScatterFeatureRequirement

inputs:
  - id: "#input_fastq_files"
    type: 
      type: array
      items: File
    description: "Input fastq files"
  - id: "#genome_ref_index_files"
    type:
      type: array
      items: File
    description: "Bowtie index files for reference genome (*1.ebwt, *.2.ebwt, ...)"
  - id: "#t"
    type: boolean
    default: true
  - id: "#m"
    type: int
    default: 1
  - id: "#v"
    type: int
    default: 2
  - id: "#X"
    type: int
    default: 2000
  - id: "#best"
    type: boolean
    default: true
  - id: "#strata"
    type: boolean
    default: true
  - id: "#sam"
    type: boolean
    default: true
  - id: "#threads"
    type: int
    default: 1

outputs:
  - id: "#output_data_sam_files"
    source: "#bowtie-se.output_aligned_file"
    description: "Aligned files with Bowtie in SAM format."
    type:
      type: array
      items: File

steps:
  - id: "#extract_basename"
    run: {import: "../utils/extract-basename.cwl" }
    scatter: "#extract_basename.input_file"
    inputs:
      - id: "#extract_basename.input_file"
        source: "#input_fastq_files"
    outputs:
      - id: "#extract_basename.output_basename"
  - id: "#bowtie-se"
    run: {import: "../bowtie/bowtie-se.cwl"}
    scatter:
      - "#bowtie-se.input_fastq_file"
      - "#bowtie-se.output_filename"
    scatterMethod: dotproduct
    inputs:
      - id: "#bowtie-se.input_fastq_file"
        source: "#input_fastq_files"
      - id: "#bowtie-se.output_filename"
        source: "#extract_basename.output_basename"
      - id: "#bowtie-se.genome_ref_index_files"
        source: "#genome_ref_index_files"
    outputs:
      - id: "#bowtie-se.output_aligned_file"
  - id: "#sam2bam"
    run: {import: "../samtools/samtools2bam.cwl"}
    scatter:
      - "#sam2bam.input_file"
    inputs:
      - id: "#sam2bam.input_file"
        source: "#bowtie-se.output_aligned_file"
    outputs:
      - id: "#sam2bam.bam_file"
  - id: "#bam2sorted"
    run: {import: "../samtools/samtools2sorted.cwl"}
    scatter:
      - "#bam2sorted.input_file"
    inputs:
      - id: "#bam2sorted.input_file"
        source: "#sam2bam.bam_file"
    outputs:
      - id: "#sam2sorted.sorted_file"
  - id: "#filter-unmapped"
    run: {import: "../samtools/samtools-filter-unmapped.cwl"}
    scatter:
      - "#filter-unmapped.input_file"
    inputs:
      - id: "#filter-unmapped.input_file"
        source: "#sam2sorted.sorted_file"
    outputs:
      - id: "#filter-unmapped.filtered_file"
