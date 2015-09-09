#!/usr/bin/env cwl-runner

class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerImageId: 'dukegcb/fastqc'
requirements:
  - import: ../py-expr-engine/py-expr-engine.cwl
  - class: EnvVarRequirement
    envDef:
      - envName: PATH
        envValue:
          engine: ../py-expr-engine/py-expr-engine.cwl
          script: self.job['fastqc_tool_path'] if 'fastqc_tool_path' in self.job else '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

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

