#!/usr/bin/env cwl-runner

class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerImageId: 'dukegcb/star'

inputs:
  - id: "#out_file_name_prefix"
    type: string
    default: ""
    inputBinding:
      position: 1
      prefix: "--outFileNamePrefix"
      valueFrom:
        engine: cwl:JsonPointer
        script: "outdir"
  - id: "#threads"
    type: int
    default: 4
    inputBinding:
      position: 2
      prefix: "--runThreadN"
  - id: "#input_genome_dir"
    type: File
    inputBinding:
      position: 3
      prefix: --genomeDir
  - id: "#input_read1_fastq_file" #TODO: this should be an array
    type: File
    inputBinding:
      position: 4
      prefix: "--readFilesIn"
  - id: "#input_read2_fastq_file"
    type: File
    inputBinding:
      position: 5
  - id: "#sam_attributes"
    type: string
    default: "NH HI AS NM MD"
    inputBinding:
      position: 6
      prefix: "--outSAMattributes"
  - id: "#filter_intron_motifs"
    type: string
    default: "RemoveNoncanonical"
    inputBinding:
      position: 7
      prefix: "--outFilterIntronMotifs"

outputs:
  - id: "#output_aligned_file"
    type: File
    outputBinding:
      glob: "Aligned.out.sam"

baseCommand: STAR
