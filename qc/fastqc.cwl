#!/usr/bin/env cwl-runner

cwlVersion: "cwl:draft-3"
class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/fastqc'

requirements:
  - class: InlineJavascriptRequirement

inputs:
  - id: "#input_fastq_file"
    type: File
    inputBinding:
      position: 4
  - id: "#noextract"
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
      position: 5
      prefix: "--threads"


outputs:
  - id: "#output_qc_report_file"
    type: File
    outputBinding:
      glob: $(inputs.input_fastq_file.path.replace(/^.*[\\\/]/, "").replace(/\.[^/.]+$/, '') + "_fastqc.zip")

baseCommand: fastqc
arguments:
  - valueFrom: $(runtime.tmpdir)
    prefix: "--dir"
    position: 5
  - valueFrom: $(runtime.outdir)
    prefix: "-o"
    position: 5
