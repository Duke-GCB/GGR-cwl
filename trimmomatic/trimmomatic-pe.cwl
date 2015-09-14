#!/usr/bin/env cwl-runner

class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerImageId: 'dukegcb/trimmomatic'

requirements:
  - import: ../py-expr-engine/py-expr-engine.cwl

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
  - id: "#input_read1_fastq_file"
    type: File
    inputBinding:
      position: 3
  - id: "#input_read2_fastq_file"
    type: File
    inputBinding:
      position: 4
  - id: "input_read1_trimmed_paired_file_name"
    type: string
    default: "read1_trimmed_paired.fastq"
    inputBinding:
      position: 5
  - id: "input_read1_trimmed_unpaired_file_name"
    type: string
    default: "read1_trimmed_unpaired.fastq"
    inputBinding:
      position: 6
  - id: "input_read2_trimmed_paired_file_name"
    type: string
    default: "read2_trimmed_paired.fastq"
    inputBinding:
      position: 7
  - id: "input_read2_trimmed_unpaired_file_name"
    type: string
    default: "read2_trimmed_unpaired.fastq"
    inputBinding:
      position: 8
  - id: "#input_adapters_file"
    type: File
  - id: "#illumina_clip_step"
    type: string
    default: ""
    inputBinding:
      position: 9
      valueFrom:
        engine: ../py-expr-engine/py-expr-engine.cwl
        script: |
          'ILLUMINACLIP:{}:2:30:15'.format(self.job['input_adapters_file']['path'])
  - id: "#additional_steps"
    type: string
    default: "LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:10"
    inputBinding:
      position: 10

outputs:
  - id: "#output_read1_trimmed_paired_file"
    type: File
    outputBinding:
      glob: "read1_trimmed_paired.fastq"
  - id: "#output_read1_trimmed_unpaired_file"
    type: File
    outputBinding:
      glob: "read1_trimmed_unpaired.fastq"
  - id: "#output_read2_trimmed_paired_file"
    type: File
    outputBinding:
      glob: "read2_trimmed_paired.fastq"
  - id: "#output_read2_trimmed_unpaired_file"
    type: File
    outputBinding:
      glob: "read2_trimmed_unpaired.fastq"

baseCommand: TrimmomaticPE
