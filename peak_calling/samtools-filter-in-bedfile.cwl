#!/usr/bin/env cwl-runner

class: CommandLineTool
description: "Filter BAM file to only include reads overlapping with a BED file"

hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/samtools'

requirements:
  - class: InlineJavascriptRequirement

inputs:
  - id: "#input_bam_file"
    type: File
    description: "Aligned BAM file to filter"
    inputBinding:
      position: 3
  - id: "#input_bedfile"
    type: File
    description: "Bedfile used to only include reads overlapping this BED FILE"
    inputBinding:
      position: 2
      prefix: "-L"

outputs:
  - id: "#filtered_file"
    type: File
    description: "Filtered aligned BAM file by BED coordinates file"
    outputBinding:
      glob: $(inputs.input_bam_file.path.replace(/^.*[\\\/]/, '') + '.in_peaks.bam')

baseCommand: ["samtools", "view", "-b", "-h" ]
stdout: $(inputs.input_bam_file.path.replace(/^.*[\\\/]/, '') + '.in_peaks.bam')
