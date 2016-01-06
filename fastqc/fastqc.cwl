#!/usr/bin/env cwl-runner

class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerImageId: 'dukegcb/fastqc'

inputs:
  - id: "#input_fastq_file"
    type: File
    inputBinding:
      position: 4
  - id: "#outdir"
    type: File
    default: null # Even though we're providing a valueFrom, workflow won't run unless there's a value
    inputBinding:
      position: 1
      prefix: -o
      valueFrom:
        engine: "cwl:JsonPointer"
        script: "outdir"
  - id: "#noeextract"
    type: boolean
    default: true
    inputBinding:
      prefix: "--noextract"
      position: 2
  - id: "#format"
    type: string
    default: "fastq"
    inputBinding:
      position: 3
      prefix: "--format"
  - id: "#threads"
    type: int
    default: 1
    inputBinding:
      position: 4
      prefix: "--threads"

outputs:
  - id: "#output_qc_report_file"
    type: File
    outputBinding:
      glob: "*_fastqc.zip"

baseCommand: fastqc
