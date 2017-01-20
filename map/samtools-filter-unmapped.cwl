#!/usr/bin/env cwl-runner

class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/samtools'

requirements:
  - class: InlineJavascriptRequirement

inputs:
  - id: "#input_file"
    type: File
    description: "Aligned file to be sorted with samtools"
    inputBinding:
      position: 1000
  - id: "#nthreads"
    type: int
    default: 1
    description: "Number of threads used in sorting"
    inputBinding:
      position: 1
      prefix: "-@"
  - id: "#output_filename"
    type: string
    description: "Basename for the output file"

outputs:
  - id: "#filtered_file"
    type: File
    description: "Filter unmapped reads in aligned file"
    outputBinding:
      glob: $(inputs.output_filename + '.accepted_hits.bam')

baseCommand: ["samtools", "view", "-F", "4", "-b", "-h" ]
stdout: $(inputs.output_filename + '.accepted_hits.bam')
