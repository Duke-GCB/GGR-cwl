#!/usr/bin/env cwl-runner

class: CommandLineTool
description: "Extract mapped reads from BAM file using Samtools flagstat command"

hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/samtools'

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement

inputs:
  - id: "#input_bam_file"
    type: File
    description: "Aligned BAM file to filter"
    inputBinding:
      position: 1
  - id: "#output_suffix"
    type: string
outputs:
  - id: "#output_read_count"
    type: File
    description: "Samtools Flagstat report file"
    outputBinding:
      glob: $(inputs.input_bam_file.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, "") + inputs.output_suffix)

baseCommand: ["samtools", "flagstat"]
stdout: $(inputs.input_bam_file.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, "") + inputs.output_suffix)
arguments:
  - valueFrom: " | head -n1 | cut -f 1 -d ' '"
    position: 10000
    shellQuote: False
