#!/usr/bin/env cwl-runner

cwlVersion: 'cwl:draft-3'
class: CommandLineTool
hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/bedtools'

requirements:
  - class: InlineJavascriptRequirement

inputs:
  - id: bam
    type: File
    description: 'Input BAM file to be converted to BED format'
    inputBinding:
      position: 3
      prefix: '-i'
  - id: bedpe
    type:
      - 'null'
      - boolean
    description: |
      Write BEDPE format.
      - Requires BAM to be grouped or sorted by query.
    inputBinding:
      position: 1
      prefix: '-bedpe'
  - id: mate1
    type:
      - 'null'
      - boolean
    description: "When writing BEDPE (-bedpe) format, \nalways report mate one as the first BEDPE \"block\".\n"
    inputBinding:
      position: 1
      prefix: '-mate1'
  - id: bed12
    type:
      - 'null'
      - boolean
    description: |
      Write "blocked" BED format (aka "BED12"). Forces -split.
    inputBinding:
      position: 1
      prefix: '-bed12'
  - id: split
    type:
      - 'null'
      - boolean
    description: |
      Report "split" BAM alignments as separate BED entries.
      Splits only on N CIGAR operations.
    inputBinding:
      position: 1
      prefix: '-split'
  - id: splitD
    type:
      - 'null'
      - boolean
    description: |
      Split alignments based on N and D CIGAR operators.
      Forces -split.
    inputBinding:
      position: 1
      prefix: '-splitD'
  - id: ed
    type:
      - 'null'
      - boolean
    description: |
      Use BAM edit distance (NM tag) for BED score.
      - Default for BED is to use mapping quality.
      - Default for BEDPE is to use the minimum of
      the two mapping qualities for the pair.
      - When -ed is used with -bedpe, the total edit
      distance from the two mates is reported.
    inputBinding:
      position: 1
      prefix: '-ed'
  - id: tag
    type:
      - 'null'
      - boolean
    description: |
      Use other NUMERIC BAM alignment tag for BED score.
      - Default for BED is to use mapping quality.
      Disallowed with BEDPE output.
    inputBinding:
      position: 1
      prefix: '-tag'
  - id: color
    type:
      - 'null'
      - string
    description: |
      An R,G,B string for the color used with BED12 format.
      Default is (255,0,0).
    inputBinding:
      position: 1
      prefix: '-color'
  - id: cigar
    type:
      - 'null'
      - string
    description: |
      Add the CIGAR string to the BED entry as a 7th column.
    inputBinding:
      position: 1
      prefix: '-cigar'
outputs:
  - id: '#output_bedfile'
    type: File
    outputBinding:
      glob: $(inputs.bam.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, "") + '.bed')

stdout: $(inputs.bam.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, "") + '.bed')
baseCommand:
  - bedtools
  - bamtobed
#description: "Tool:    bedtools bamtobed (aka bamToBed)\nVersion: v2.25.0\nSummary: Converts BAM alignments to BED6 or BEDPE format.\n\nUsage:   bedtools bamtobed [OPTIONS] -i <bam> \n\nOptions: \n\t-bedpe\tWrite BEDPE format.\n\t\t- Requires BAM to be grouped or sorted by query.\n\n\t-mate1\tWhen writing BEDPE (-bedpe) format, \n\t\talways report mate one as the first BEDPE \"block\".\n\n\t-bed12\tWrite \"blocked\" BED format (aka \"BED12\"). Forces -split.\n\n\t\thttp://genome-test.cse.ucsc.edu/FAQ/FAQformat#format1\n\n\t-split\tReport \"split\" BAM alignments as separate BED entries.\n\t\tSplits only on N CIGAR operations.\n\n\t-splitD\tSplit alignments based on N and D CIGAR operators.\n\t\tForces -split.\n\n\t-ed\tUse BAM edit distance (NM tag) for BED score.\n\t\t- Default for BED is to use mapping quality.\n\t\t- Default for BEDPE is to use the minimum of\n\t\t  the two mapping qualities for the pair.\n\t\t- When -ed is used with -bedpe, the total edit\n\t\t  distance from the two mates is reported.\n\n\t-tag\tUse other NUMERIC BAM alignment tag for BED score.\n\t\t- Default for BED is to use mapping quality.\n\t\t  Disallowed with BEDPE output.\n\n\t-color\tAn R,G,B string for the color used with BED12 format.\n\t\tDefault is (255,0,0).\n\n\t-cigar\tAdd the CIGAR string to the BED entry as a 7th column."
