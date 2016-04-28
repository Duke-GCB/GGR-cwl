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
    inputBinding:
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
  - id: "#input_fastq_read1_file"
    description: "Query input FASTQ file."
    type: File
    inputBinding:
      position: 10
      prefix: "-1"
  - id: "#input_fastq_read2_file"
    description: "Query input FASTQ file."
    type: File
    inputBinding:
      position: 11
      prefix: "-2"
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
    position: 12
  - valueFrom: $('2> ' + inputs.output_filename + '.bowtie.log')
    position: 100000
    shellQuote: false