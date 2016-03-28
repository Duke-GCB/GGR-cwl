#!/usr/bin/env cwl-runner

class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerImageId: 'dukegcb/spp'

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement

inputs:
  - id: savp
    type:
      - 'null'
      - boolean
    description: "\t save cross-correlation plot\n"
    inputBinding:
      position: 2
      valueFrom: $('-savp=' + inputs.input_bam.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.spp_cross_corr.pdf')
  - id: "#input_bam"
    type: File
    description: "<ChIP_alignFile>, full path and name (or URL) of tagAlign/BAM file (can be gzipped)(FILE EXTENSION MUST BE tagAlign.gz, tagAlign, bam or bam.gz)"
    inputBinding:
      position: 2
      valueFrom: $('-c=' + self.path)
  - id: rf
    type: boolean
    default: true
    description: "\t overwrite (force remove) output files in case they exist \n"
    inputBinding:
      position: 2
      prefix: "-rf"
  - id: "#nthreads"
    type:
      - 'null'
      - int
    description: "\t -p=<nodes> , number of parallel processing nodes, default=0\n"
    inputBinding:
      position: 2
      valueFrom: $("-p=" + self)

outputs:
  - id: "#output_spp_cross_corr"
    type: File
    description: "peakshift/phantomPeak results file"
    outputBinding:
      glob: $(inputs.input_bam.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.spp_cross_corr.txt')
  - id: "#output_spp_cross_corr_plot"
    type: File
    description: "peakshift/phantomPeak results file plot"
    outputBinding:
      glob: $(inputs.input_bam.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.spp_cross_corr.pdf')

baseCommand: run_spp.R
arguments:
  - valueFrom: $('-out=' + inputs.input_bam.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.spp_cross_corr.txt')
    position: 2
