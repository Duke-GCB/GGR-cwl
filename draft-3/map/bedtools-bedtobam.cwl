#!/usr/bin/env cwl-runner

cwlVersion: 'cwl:draft-3'
class: CommandLineTool
hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/bedtools'

requirements:
  - class: InlineJavascriptRequirement

inputs:
  - id: i
    type: File
    description: 'Input <bed/gff/vcf> file to be converted to BAM format'
    inputBinding:
      position: 3
      prefix: '-i'
  - id: g
    type: File
    description: 'Genome chromosome sizes file'
    inputBinding:
      position: 4
      prefix: '-g'
  - id: mapq
    type:
      - 'null'
      - int
    description: |
      Set the mappinq quality for the BAM records.
      (INT) Default: 255
    inputBinding:
      position: 1
      prefix: '-mapq'
  - id: bed12
    type:
      - 'null'
      - string
    description: |
      The BED file is in BED12 format.  The BAM CIGAR
      string will reflect BED "blocks".
    inputBinding:
      position: 1
      prefix: '-bed12'
  - id: ubam
    type:
      - 'null'
      - boolean
    description: |
      Write uncompressed BAM output. Default writes compressed BAM.
    inputBinding:
      position: 1
      prefix: '-ubam'
outputs:
  - id: '#bam_file'
    type: File
    outputBinding:
      glob: $(inputs.i.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, "") + '.bam')
stdout: $(inputs.i.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, "") + '.bam')
baseCommand:
  - bedtools
  - bedtobam
description: "Tool:    bedtools bedtobam (aka bedToBam)\nVersion: v2.25.0\nSummary: Converts feature records to BAM format.\n\nUsage:   bedtools bedtobam [OPTIONS] -i <bed/gff/vcf> -g <genome>\n\nOptions: \n\t-mapq\tSet the mappinq quality for the BAM records.\n\t\t(INT) Default: 255\n\n\t-bed12\tThe BED file is in BED12 format.  The BAM CIGAR\n\t\tstring will reflect BED \"blocks\".\n\n\t-ubam\tWrite uncompressed BAM output. Default writes compressed BAM.\n\nNotes: \n\t(1)  BED files must be at least BED4 to create BAM (needs name field)."
