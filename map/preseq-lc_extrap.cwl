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
  - id: e
    type:
      - 'null'
      - boolean
    description: "-extrap      maximum extrapolation (default: 1e+10) \n"
    inputBinding:
      position: 1
      prefix: '-e'
  - id: s
    type:
      - 'null'
      - float
    description: "-step        step size in extrapolations (default: 1e+06) \n"
    inputBinding:
      position: 1
      prefix: '-s'
  - id: 'n'
    type:
      - 'null'
      - boolean
    description: "-bootstraps  number of bootstraps (default: 100), \n"
    inputBinding:
      position: 1
      prefix: '-n'
  - id: c
    type:
      - 'null'
      - boolean
    description: "-cval        level for confidence intervals (default: 0.95) \n"
    inputBinding:
      position: 1
      prefix: '-c'
  - id: x
    type:
      - 'null'
      - boolean
    description: "-terms       maximum number of terms \n"
    inputBinding:
      position: 1
      prefix: '-x'
  - id: v
    type:
      - 'null'
      - boolean
    description: "-verbose     print more information \n"
    inputBinding:
      position: 1
      prefix: '-v'
  - id: B
    type: boolean
    default: true
    description: "-bam         input is in BAM format \n"
    inputBinding:
      position: 1
      prefix: '-B'
  - id: l
    type:
      - 'null'
      - boolean
    description: "-seg_len     maximum segment length when merging paired end bam reads \n(default: 5000)\n"
    inputBinding:
      position: 1
      prefix: '-l'
  - id: pe
    type:
      - 'null'
      - boolean
    description: "-pe          input is paired end read file \n"
    inputBinding:
      position: 1
      prefix: '-P'
  - id: V
    type:
      - 'null'
      - string
    description: "-vals        input is a text file containing only the observed counts \n"
    inputBinding:
      position: 1
      prefix: '-V'
  - id: H
    type:
      - 'null'
      - string
    description: "-hist        input is a text file containing the observed histogram \n"
    inputBinding:
      position: 1
      prefix: '-H'
  - id: Q
    type:
      - 'null'
      - boolean
    description: "-quick       quick mode, estimate yield without bootstrapping for \nconfidence intervals\n"
    inputBinding:
      position: 1
      prefix: '-Q'
  - id: D
    type:
      - 'null'
      - boolean
    description: "-defects     defects mode to extrapolate without testing for defects \nHelp options:\n-?, -help        print this help message\n-about       print about message\n"
    inputBinding:
      position: 1
outputs:
  - id: '#output_file'
    type: File
    outputBinding:
      glob: $(inputs.output_file_basename + '.preseq_lc_extrap.txt')
stdout: $(inputs.output_file_basename + '.preseq_lc_extrap.txt')
baseCommand:
  - preseq
  - lc_extrap
description: "Usage: lc_extrap [OPTIONS] <sorted-bed-file>\n\nOptions:\n  -o, -output      yield output file (default: stdout) \n  -e, -extrap      maximum extrapolation (default: 1e+10) \n  -s, -step        step size in extrapolations (default: 1e+06) \n  -n, -bootstraps  number of bootstraps (default: 100), \n  -c, -cval        level for confidence intervals (default: 0.95) \n  -x, -terms       maximum number of terms \n  -v, -verbose     print more information \n  -B, -bam         input is in BAM format \n  -l, -seg_len     maximum segment length when merging paired end bam reads \n                   (default: 5000) \n  -P, -pe          input is paired end read file \n  -V, -vals        input is a text file containing only the observed counts \n  -H, -hist        input is a text file containing the observed histogram \n  -Q, -quick       quick mode, estimate yield without bootstrapping for \n                   confidence intervals \n  -D, -defects     defects mode to extrapolate without testing for defects \n\nHelp options:\n  -?, -help        print this help message \n      -about       print about message"
