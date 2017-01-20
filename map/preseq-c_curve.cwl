#!/usr/bin/env cwl-runner

class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/preseq'

requirements:
  - class: InlineJavascriptRequirement

inputs:
  - id: output_file_basename
    type: string
  - id: input_sorted_file
    type: File
    description: 'Sorted bed or BAM file'
    inputBinding:
      position: 2
  - id: s
    type:
      - 'null'
      - float
    description: "-step     step size in extrapolations (default: 1e+06) \n"
    inputBinding:
      position: 1
      prefix: '-s'
  - id: v
    type: boolean
    default: false
    description: "-verbose  print more information \n"
    inputBinding:
      position: 1
      prefix: '-v'
  - id: pe
    type:
      - 'null'
      - boolean
    description: "-pe       input is paired end read file \n"
    inputBinding:
      position: 1
      prefix: '-P'
  - id: H
    type:
      - 'null'
      - File
    description: "-hist     input is a text file containing the observed histogram \n"
    inputBinding:
      position: 1
      prefix: '-H'
  - id: V
    type:
      - 'null'
      - File
    description: "-vals     input is a text file containing only the observed counts \n"
    inputBinding:
      position: 1
      prefix: '-V'
  - id: B
    type: boolean
    default: true
    description: "-bam      input is in BAM format \n"
    inputBinding:
      position: 1
      prefix: '-B'
  - id: l
    type:
      - 'null'
      - int
    description: "-seg_len  maximum segment length when merging paired end bam reads \n(default: 5000)\nHelp options:\n-?, -help     print this help message\n-about    print about message\n"
    inputBinding:
      position: 1
      prefix: '-l'
outputs:
  - id: '#output_file'
    type: File
    outputBinding:
      glob: $(inputs.output_file_basename + '.preseq_c_curve.txt')
stdout: $(inputs.output_file_basename + '.preseq_c_curve.txt')
baseCommand:
  - preseq
  - c_curve
description: "Usage: c_curve [OPTIONS] <sorted-bed-file>\n\nOptions:\n  -o, -output   yield output file (default: stdout) \n  -s, -step     step size in extrapolations (default: 1e+06) \n  -v, -verbose  print more information \n  -P, -pe       input is paired end read file \n  -H, -hist     input is a text file containing the observed histogram \n  -V, -vals     input is a text file containing only the observed counts \n  -B, -bam      input is in BAM format \n  -l, -seg_len  maximum segment length when merging paired end bam reads \n                (default: 5000) \n\nHelp options:\n  -?, -help     print this help message \n      -about    print about message"

#/data/reddylab/software/preseq_v2.0/preseq c_curve -o ${SAMPLE}.preseq.out.txt -B ${SAMPLE}.accepted_hits.bam
