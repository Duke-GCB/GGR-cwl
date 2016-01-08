#!/usr/bin/env cwl-runner

class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerImageId: 'dukegcb/overrepresented_sequence_extract'

inputs:
  - id: "#input_fastqc_data"
    description: "fastqc_data.txt file from a fastqc report"
    type: File
    inputBinding:
      position: 1
  - id: "#se_or_pe"
    description: "Single ended or paired end read"
    type: string
    inputBinding:
      position: 2
  - id: "#default_adapters_file"
    description: "Adapters file in fasta format"
    type: File
    inputBinding:
      position: 3
  - id: "#adapters_out_dir"
    description: "Output directory for custom adapters"
    type: File
    default: null # Even though we're providing a valueFrom, workflow won't run unless there's a value
    inputBinding:
      position: 1
      prefix: -o
      valueFrom:
        engine: "cwl:JsonPointer"
        script: "outdir"

outputs:
  - id: "#output_custom_adapters"
    type: File
    outputBinding:
      glob: "custom_adapters.fasta"

baseCommand: overrepresented_sequence_extract.py
