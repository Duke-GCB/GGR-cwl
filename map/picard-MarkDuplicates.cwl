#!/usr/bin/env cwl-runner

cwlVersion: 'cwl:draft-3'
class: CommandLineTool
hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/picard'

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement


inputs:
  - id: "#input_file"
    type: File
    description: 'One or more input SAM or BAM files to analyze. Must be coordinate sorted.'
    inputBinding:
      position: 4
      valueFrom: $('INPUT=' + self.path)
      shellQuote: false
  - id: "#output_filename"
    type: string
    description: "Output filename used as basename"
  - id: "#java_opts"
    type:
      - 'null'
      - string
    description: "JVM arguments should be a quoted, space separated list (e.g. \"-Xms128m -Xmx512m\")"
    inputBinding:
      position: 1
      shellQuote: false
  - id: "#picard_jar_path"
    type: string
    description: 'Path to the picard.jar file'
    inputBinding:
      position: 2
      prefix: "-jar"
  - id: "#remove_duplicates"
    type: boolean
    description: "If true do not write duplicates to the output file instead of writing them with appropriate flags set.  (Default true)."
    default: true
    inputBinding:
      valueFrom: $('REMOVE_DUPLICATES=' + self)
      position: 5
  - id: "#output_suffix"
    type: string
    description: "Suffix used to identify the output file (Default: dedup.bam)"
    default: "dedup.bam"
  - id: "#metrics_suffix"
    type: string
    description: "Suffix used to create the metrics output file (Default: dedup_metrics.txt)"
    default: "dedup_metrics.txt"

outputs:
  - id: '#output_metrics_file'
    type: File
    outputBinding:
      glob: $(inputs.output_filename + '.' + inputs.metrics_suffix)
  - id: '#output_dedup_bam_file'
    type: File
    outputBinding:
      glob: $(inputs.output_filename  + '.' + inputs.output_suffix)

baseCommand: ["java"]
arguments:
  - valueFrom: "MarkDuplicates"
    position: 3
  - valueFrom: $('OUTPUT=' + inputs.output_filename + '.' + inputs.output_suffix)
    position: 5
    shellQuote: false
  - valueFrom: $('METRICS_FILE='+inputs.output_filename + '.' + inputs.metrics_suffix)
    position: 5
    shellQuote: false
  - valueFrom: $('TMP_DIR='+runtime.tmpdir)
    position: 5
    shellQuote: false
