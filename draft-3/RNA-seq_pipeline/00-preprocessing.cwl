#!/usr/bin/env cwl-runner
cwlVersion: "cwl:draft-3"
class: Workflow
description: "RNA-seq 00 preprocessing - To create files that need to be generated only once"
requirements:
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement

inputs:
  - id: "#sjdbOverhang"
    type: string
    description: "STAR genome generate - Junction overhang"
  - id: "#annotation_file"
    type: File
    description: "STAR genome generate - GTF annotation file"
  - id: "#genome_fasta_files"
    type: {type: array, items: File}
    description: "STAR genome generate - Genome FASTA file with all the genome sequences in FASTA format"

outputs:
  - id: "#generated_genome_files"
    source: "#generate_genome_star.indices"
    description: "STAR generated genome files"
    type: {type: array, items: File}
  - id: "#rsem_genome_files"
    source: "#generate_genome_rsem.genome_files"
    description: "RSEM generated genome files (using Bowtie)"
    type: {type: array, items: File}

steps:
  - id: "#generate_genome_star"
    run: {$import: "../workflows/tools/STAR.cwl" }
    inputs:
      - { id: "#generate_genome_star.runMode", valueFrom: "genomeGenerate"}
      - { id: "#generate_genome_star.sjdbGTFfile", source: "#annotation_file"}
      - { id: "#generate_genome_star.genomeFastaFiles", source: "#genome_fasta_files"}
      - { id: "#generate_genome_star.sjdbOverhang", source: "#sjdbOverhang", valueFrom: $(parseInt(self))}
      - { id: "#generate_genome_star.genomeDir", valueFrom: "not_used" }
    outputs:
      - id: "#generate_genome_star.indices"

  - id: "#generate_genome_rsem"
    run: {$import: "../quant/rsem-prepare-reference.cwl" }
    inputs:
      - { id: "#generate_genome_rsem.gtf", source: "#annotation_file"}
      - { id: "#generate_genome_rsem.reference_fasta_files", source: "#genome_fasta_files"}
      - { id: "#generate_genome_rsem.reference_name", valueFrom: "RSEM_genome"}
    outputs:
      - id: "#generate_genome_rsem.genome_files"
