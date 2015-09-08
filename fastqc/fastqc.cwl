#!/usr/bin/env cwl-runner

class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerImageId: 'dukegcb/fastqc'

inputs:
  - id: "#input_fastq_file"
    type: File
    inputBinding:
      position: 1
  - id: "#outdir"
    type: File
    default: null # Even though we're providing a valueFrom, workflow won't run unless there's a value
    inputBinding:
      position: 2
      prefix: -o
      valueFrom:
        engine: "cwl:JsonPointer"
        script: "outdir"
  - id: "#arguments"
    type: string
    default: "--noextract"
    inputBinding:
      position: 3

outputs:
  - id: "#output_qc_report_file"
    type: File
    outputBinding:
      glob: "*_fastqc.zip"

baseCommand: fastqc
