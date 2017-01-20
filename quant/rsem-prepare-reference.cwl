#!/usr/bin/env cwl-runner

# Mantainer: alejandro.barrera@duke.edu
# Partially auto generated with clihp (https://github.com/portah/clihp, developed by Andrey.Kartashov@cchmc.org)
# Developed for GGR project (https://github.com/Duke-GCB/GGR-cwl)

cwlVersion: 'cwl:draft-3'
class: CommandLineTool
hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/rsem:1.2.25'
requirements:
  - class: InlineJavascriptRequirement
inputs:
  - id: reference_fasta_files
    type:
      type: array
      items: File
    description: |
      reference_fasta_file(s)
      Either a comma-separated list of Multi-FASTA formatted files OR a
      directory name. If a directory name is specified, RSEM will read all
      files with suffix ".fa" or ".fasta" in this directory. The files
      should contain either the sequences of transcripts or an entire
      genome, depending on whether the --gtf option is used.
    inputBinding:
      position: 2
      itemSeparator: ","
  - id: reference_name
    type: string
    description: |
      reference name
      The name of the reference used. RSEM will generate several
      reference-related files that are prefixed by this name. This name
      can contain path information (e.g. /ref/mm9).
    inputBinding:
      position: 3

  - id: gtf
    type:
      - 'null'
      - File
    description: |
      <file>
      If this option is on, RSEM assumes that 'reference_fasta_file(s)'
      contains the sequence of a genome, and will extract transcript
      reference sequences using the gene annotations specified in <file>,
      which should be in GTF format.
      If this option is off, RSEM will assume 'reference_fasta_file(s)'
      contains the reference transcripts. In this case, RSEM assumes that
      name of each sequence in the Multi-FASTA files is its transcript_id.
      (Default: off)
    inputBinding:
      position: 1
      prefix: '--gtf'
  - id: transcript-to-gene-map
    type:
      - 'null'
      - File
    description: |
      <file>
      Use information from <file> to map from transcript (isoform) ids to
      gene ids. Each line of <file> should be of the form:
      gene_id transcript_id
      with the two fields separated by a tab character.
      If you are using a GTF file for the "UCSC Genes" gene set from the
      UCSC Genome Browser, then the "knownIsoforms.txt" file (obtained
      from the "Downloads" section of the UCSC Genome Browser site) is of
      this format.
      If this option is off, then the mapping of isoforms to genes depends
      on whether the --gtf option is specified. If --gtf is specified,
      then RSEM uses the "gene_id" and "transcript_id" attributes in the
      GTF file. Otherwise, RSEM assumes that each sequence in the
      reference sequence files is a separate gene.
      (Default: off)
    inputBinding:
      position: 1
      prefix: '--transcript-to-gene-map'
  - id: allele-to-gene-map
    type:
      - 'null'
      - File
    description: |
      <file>
      Use information from <file> to provide gene_id and transcript_id
      information for each allele-specific transcript. Each line of <file>
      should be of the form:
      gene_id transcript_id allele_id
      with the fields separated by a tab character.
      This option is designed for quantifying allele-specific expression.
      It is only valid if '--gtf' option is not specified. allele_id
      should be the sequence names presented in the Multi-FASTA-formatted
      files.
      (Default: off)
    inputBinding:
      position: 1
      prefix: '--allele-to-gene-map'
  - id: polyA
    type:
      - 'null'
      - boolean
    description: |
      Add poly(A) tails to the end of all reference isoforms. The length
      of poly(A) tail added is specified by '--polyA-length' option. STAR
      aligner users may not want to use this option. (Default: do not add
      poly(A) tail to any of the isoforms)
    inputBinding:
      position: 1
      prefix: "--polyA"
  - id: polyA-length
    type:
      - 'null'
      - int
    description: |
      <int>
      The length of the poly(A) tails to be added. (Default: 125)
    inputBinding:
      position: 1
      prefix: '--polyA-length'
  - id: no-polyA-subset
    type:
      - 'null'
      - boolean
    description: |
      <file>
      Only meaningful if '--polyA' is specified. Do not add poly(A) tails
      to those transcripts listed in <file>. <file> is a file containing a
      list of transcript_ids. (Default: off)
    inputBinding:
      position: 1
      prefix: '--no-polyA-subset'
  - id: bowtie
    type:
      - 'null'
      - boolean
    inputBinding:
      position: 1
      prefix: "--bowtie"
    description: |
      Build Bowtie indices. (Default: off)
  - id: bowtie-path
    type:
      - 'null'
      - boolean
    description: |
      <path>
      The path to the Bowtie executables. (Default: the path to Bowtie
      executables is assumed to be in the user's PATH environment
      variable)
    inputBinding:
      position: 1
      prefix: '--bowtie-path'

  - id: bowtie2
    type:
      - 'null'
      - boolean
    inputBinding:
      position: 1
      prefix: "--bowtie2"
    description: |
      Build Bowtie2 indices. (Default: off)

  - id: star
    type:
      - 'null'
      - boolean
    inputBinding:
      position: 1
      prefix: "--star"
    description: |
      Build STAR indices. (Default: off)
  - id: bowtie2-path
    type:
      - 'null'
      - boolean
    description: |
      <path>
      The path to the Bowtie 2 executables. (Default: the path to Bowtie 2
      executables is assumed to be in the user's PATH environment
      variable)
    inputBinding:
      position: 1
      prefix: '--bowtie2-path'
  - id: quiet
    type:
      - 'null'
      - boolean
    description: |
      --quiet
      Suppress the output of logging information. (Default: off)
    inputBinding:
      position: 1
      prefix: '--quiet'
outputs:
  - id: genome_files
    type:
      type: array
      items: File
    outputBinding:
      glob: $(inputs.reference_name + "*")
baseCommand: rsem-prepare-reference
description: |
  This program extracts/preprocesses the reference sequences for RSEM. It
  can optionally build Bowtie indices (with '--bowtie' option) and/or
  Bowtie 2 indices (with '--bowtie2' option) using their default
  parameters. If an alternative aligner is to be used, indices for that
  particular aligner can be built from either 'reference_name.idx.fa' or
  'reference_name.n2g.idx.fa' (see OUTPUT for details). This program is
  used in conjunction with the 'rsem-calculate-expression' program.

