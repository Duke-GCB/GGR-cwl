#!/usr/bin/env cwl-runner

class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerImageId: 'dukegcb/trimmomatic'

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement

inputs:
  - id: "#nthreads"
    type: int
    default: 1
    inputBinding:
      position: 4
      prefix: -threads
  - id: "#quality_score"
    type: string
    default: "-phred33" # or "-phred64"
    inputBinding:
      position: 4
  - id: "#input_fastq_file"
    type: File
    inputBinding:
      position: 5
  - id: "#input_adapters_file"
    type: File
  - id: "#trimmomatic_jar_path"
    type: string
    inputBinding:
      position: 2
      prefix: "-jar"
  - id: "#java_opts"
    type:
      - 'null'
      - string
    description: "JVM arguments should be a quoted, space separated list (e.g. \"-Xms128m -Xmx512m\")"
    inputBinding:
      position: 1
      shellQuote: false


outputs:
  - id: "#output_trimmed_file"
    type: File
    outputBinding:
      glob: $(inputs.input_fastq_file.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.trimmed.fastq')

baseCommand: java
arguments:
  - valueFrom: "SE"
    position: 3
  - valueFrom: $(inputs.input_fastq_file.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.trimmed.fastq')
    position: 6
  - valueFrom: $("ILLUMINACLIP:" + inputs.input_adapters_file.path + ":2:30:15")
    position: 7
    shellQuote: false
  - valueFrom: $("LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:10")
    position: 8
    shellQuote: false
