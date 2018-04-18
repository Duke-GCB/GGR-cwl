 class: Workflow
 cwlVersion: v1.0
 doc: RNA-seq 00 preprocessing - To create files that need to be generated only once
 requirements:
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
 inputs:
    genome_fasta_files:
      doc: STAR genome generate - Genome FASTA file with all the genome sequences in FASTA format
      type: File[]
    annotation_file:
      doc: STAR genome generate - GTF annotation file
      type: File
    sjdbOverhang:
      doc: STAR genome generate - Junction overhang
      type: string
 steps:
    generate_genome_star:
      in:
        genomeDir:
          valueFrom: not_used
        runMode:
          valueFrom: genomeGenerate
        sjdbGTFfile: annotation_file
        genomeFastaFiles: genome_fasta_files
        sjdbOverhang:
          source: sjdbOverhang
          valueFrom: $(parseInt(self))
      run: ../workflows/tools/STAR.cwl
      out:
      - indices
    generate_genome_rsem:
      in:
        reference_fasta_files: genome_fasta_files
        reference_name:
          valueFrom: RSEM_genome
        gtf: annotation_file
      run: ../quant/rsem-prepare-reference.cwl
      out:
      - genome_files
 outputs:
    generated_genome_files:
      doc: STAR generated genome files
      type: File[]
      outputSource: generate_genome_star/indices
    rsem_genome_files:
      doc: RSEM generated genome files (using Bowtie)
      type: File[]
      outputSource: generate_genome_rsem/genome_files
