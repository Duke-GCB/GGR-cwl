#!/usr/bin/env cwl-runner

class: CommandLineTool
description: "Unzips a zipped fastqc report and returns the fastqc_data.txt file"

inputs:
  - id: "#input_qc_report_file"
    type: File
    inputBinding:
      position: 4

outputs:
  - id: "#output_fastqc_data_file"
    type: File
    outputBinding:
      glob: "*/fastqc_data.txt"

baseCommand: unzip
