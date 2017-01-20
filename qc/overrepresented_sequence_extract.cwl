#!/usr/bin/env cwl-runner

class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/overrepresented_sequence_extract'

inputs:
  - id: "#input_fastqc_data"
    description: "fastqc_data.txt file from a fastqc report"
    type: File
    inputBinding:
      position: 1
  - id: "#input_basename"
    type: string
    description: "Name of the sample - used as a base name for generating output files"
  - id: "#default_adapters_file"
    description: "Adapters file in fasta format"
    type: File
    inputBinding:
      position: 2

outputs:
  - id: "#output_custom_adapters"
    type: File
    outputBinding:
      glob: $(inputs.input_basename + '.custom_adapters.fasta')

baseCommand: overrepresented_sequence_extract.py
arguments:
  - valueFrom: $(inputs.input_basename + '.custom_adapters.fasta')
    position: 3
