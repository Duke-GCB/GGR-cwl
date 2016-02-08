#!/usr/bin/env cwl-runner

class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerImageId: 'dukegcb/bowtie2'

inputs:
  - id: "#threads"
    type: int
    default: 1
    inputBinding:
      position: 1
      prefix: --threads
  - id: "#index_dir"
    type: File
  - id: "#index_prefix"
    type: string
  - id: "#concatenated_index"
    type: string
    default: ""
    inputBinding:
      position: 2
      prefix: -x
      valueFrom:
        engine: ../py-expr-engine/py-expr-engine.cwl
        script: |
          os.path.join(self.job['index_dir']['path'], self.job['index_prefix'])
  - id: "#input_fastq_file"
    type: File
    inputBinding:
      position: 3
      prefix: -U
  - id: "#output_aligned_file_name"
    type: string
    default: "aligned.sam"
    inputBinding:
      position: 4
      prefix: -S
outputs:
  - id: "#output_aligned_file"
    type: File
    outputBinding:
      glob:
        engine: "cwl:JsonPointer"
        script: "job/output_aligned_file_name"

baseCommand: bowtie2


#      /data/reddylab/software/bowtie-0.12.9/bowtie -t -m 1 -v 2 --best --strata --sam --threads $THREADS -X 2000 \
#      -q $GENOME_REF \
#      ${DATA_DIR}/${SAMPLE}.trimmed.fastq \
#      ${SAMPLE}.sam \
#      2> bowtie.${SAMPLE}.stats.txt