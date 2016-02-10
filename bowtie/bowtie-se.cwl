#!/usr/bin/env cwl-runner

class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerImageId: 'dukegcb/bowtie'

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement

inputs:
  - id: "#t"
    type: boolean
    default: true
    description: "Print wall-clock time taken by search phases"
    inputBinding:
      position: 1
      prefix: "-t"
  - id: "#m"
    type: int
    default: 1
    description: "Suppress all alignments if > <int> exist (def: 1)"
    inputBinding:
      position: 7
      prefix: "-m"
  - id: "#v"
    type: int
    default: 2
    description: "Report end-to-end hits w/ <=v mismatches; ignore qualities"
    inputBindng:
      position: 3
      prefix: "-v"
  - id: "#X"
    type: int
    default: 2000
    description: "maximum insert size for paired-end alignment (default: 2000)"
    inputBinding:
      position: 4
      prefix: "-X"
  - id: "#best"
    type: boolean
    default: true
    description: "Hits guaranteed best stratum; ties broken by quality"
    inputBinding:
      position: 5
      prefix: "--best"
  - id: "#strata"
    type: boolean
    default: true
    description: "Hits in sub-optimal strata aren't reported (requires --best)"
    inputBinding:
      position: 6
      prefix: "--strata"
  - id: "#sam"
    type: boolean
    default: true
    description: "Write hits in SAM format (default: BAM)"
    inputBinding:
      position: 2
      prefix: "--sam"
  - id: "#threads"
    type: int
    default: 1
    description: "<int> number of alignment threads to launch (default: 1)"
    inputBinding:
      position: 8
      prefix: "--threads"
  - id: "#genome_ref_index_files"
    description: "Bowtie index files for the reference genome"
    type:
      type: array
      items: File
  - id: "#input_fastq_file"
    description: "Query input FASTQ file."
    type: File
    inputBinding:
      position: 10
  - id: "#output_filename"
    type: string

outputs:
  - id: "#output_aligned_file"
    type: File
    description: "Aligned bowtie file in [SAM|BAM] format."
    outputBinding:
      glob: "*.sam"
      outputEval: $(self[0])
  - id: "#output_bowtie_log"
    type: File
    outputBinding:
      glob: $(inputs.output_filename + '.log')
      outputEval: $(self[0])

baseCommand: bowtie
arguments:
  - valueFrom: $(inputs.genome_ref_index_files[0].path.split('.').splice(0,inputs.genome_ref_index_files[0].path.split('.').length-2).join("."))
    position: 9
  - valueFrom: $(inputs.output_filename + '.sam')
    position: 11
  - valueFrom: $('2> ' + inputs.output_filename + '.log')
    position: 100000
    shellQuote: false