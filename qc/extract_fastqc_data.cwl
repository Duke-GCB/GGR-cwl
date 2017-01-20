#!/usr/bin/env cwl-runner

class: CommandLineTool
description: "Unzips a zipped fastqc report and returns the fastqc_data.txt file. Unzips the file to pipe and uses redirection"

hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/fastqc' # Just so that unzip is installed

inputs:
  - id: "#pipe"
    type: boolean
    default: true
    inputBinding:
      prefix: "-p"
      position: 1
  - id: "#input_qc_report_file"
    type: File
    inputBinding:
      position: 2
  - id: "#input_basename"
    type: string
  - id: "#extract_pattern"
    type: string
    default: "*/fastqc_data.txt"
    inputBinding:
      position: 3

outputs:
  - id: "#output_fastqc_data_file"
    type: File
    outputBinding:
      glob: $(inputs.input_basename + '.fastqc_data.txt')

baseCommand: unzip
stdout: $(inputs.input_basename + '.fastqc_data.txt')
