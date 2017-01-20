#!/usr/bin/env cwl-runner

class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/bowtie'

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement

inputs:
  - id: "#seedmms"
    type:
      - 'null'
      - int
    description: "max mismatches in seed (between [0, 3], default: 2)"
    inputBinding:
      position: 1
      prefix: "--seedmms"
  - id: "#seedlen"
    type:
      - 'null'
      - int
    description: "seed length for -n (default: 28)"
    inputBinding:
      position: 1
      prefix: "--seedlen"
  - id: "#trim3"
    type:
      - 'null'
      - int
    description: "trim <int> bases from 3' (right) end of reads"
    inputBinding:
      position: 1
      prefix: "--trim3"
  - id: "#trim5"
    type:
      - 'null'
      - int
    description: "trim <int> bases from 5' (left) end of reads"
    inputBinding:
      position: 1
      prefix: "--trim5"
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
    type:
      - 'null'
      - int
    description: "Report end-to-end hits w/ <=v mismatches; ignore qualities"
    inputBinding:
      position: 3
      prefix: "-v"
  - id: "#X"
    type:
      - 'null'
      - int
    description: "maximum insert size for paired-end alignment (default: 250)"
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
  - id: "#chunkmbs"
    type:
      - 'null'
      - int
    description: "The number of megabytes of memory a given thread is given to store path descriptors in --best mode. (Default: 256)"
    inputBinding:
      position: 5
      prefix: "--chunkmbs"
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
  - id: "#nthreads"
    type: int
    default: 1
    description: "<int> number of alignment threads to launch (default: 1)"
    inputBinding:
      position: 8
      prefix: "--threads"
  - id: "#genome_ref_first_index_file"
    description: "First file (extension .1.ebwt) of the Bowtie index files generated for the reference genome (see http://bowtie-bio.sourceforge.net/tutorial.shtml#newi)"
    type: File
    secondaryFiles:
      - "^^.2.ebwt"
      - "^^.3.ebwt"
      - "^^.4.ebwt"
      - "^^.rev.1.ebwt"
      - "^^.rev.2.ebwt"
    inputBinding:
      position: 9
      valueFrom: $(self.path.split('.').splice(0,self.path.split('.').length-2).join("."))
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
      glob: $(inputs.output_filename + '.sam')
  - id: "#output_bowtie_log"
    type: File
    outputBinding:
      glob: $(inputs.output_filename + '.bowtie.log')

baseCommand: bowtie
arguments:
  - valueFrom: $(inputs.output_filename + '.sam')
    position: 11
  - valueFrom: $('2> ' + inputs.output_filename + '.bowtie.log')
    position: 100000
    shellQuote: false
