#!/usr/bin/env cwl-runner

class: CommandLineTool

requirements:
#   - class: DockerRequirement
#     dockerImageId: 'dukegcb/trimmomatic'
  - import: python-engine.cwl

inputs:
  - id: "#threads"
    type: int
    default: 1
    inputBinding:
      position: 1
      prefix: -threads
  - id: "#quality_score"
    type: string
    default: "-phred33" # or "-phred64"
    inputBinding:
      position: 2
  - id: "#input_fastq_file"
    type: File
    inputBinding:
      position: 3
  - id: "#output_trimmed_fastq_file_name"
    type: string
    default: "trimmed.fastq" # Would be nice to have an expression here
    inputBinding:
      position: 4
  - id: "#input_adapters_file"
    type: File
  - id: "#illumina_clip_step"
    type: string
    default: ""
    inputBinding:
      position: 5
      valueFrom:
        engine: python-engine.cwl
        script: "'ILLUMINACLIP:{}:2:30:15'.format(job['input_adapters_file']['path'])"
  - id: "#additional_steps"
    type: string
    default: "LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:10"
    inputBinding:
      position: 6

outputs:
  - id: "#output_trimmed_file"
    type: File
    outputBinding:
      glob: "*trimmed.fastq"

baseCommand: echo
