 class: Workflow
 cwlVersion: v1.0
 doc: ChIP-seq - map - PCR Bottleneck Coefficients
 requirements:
  - class: ScatterFeatureRequirement
 inputs:
    input_bam_files:
      type: File[]
    genome_sizes:
      type: File
    input_output_filenames:
      type: string[]
 steps:
    compute_pbc:
      run: compute-pbc.cwl
      in:
        bedgraph_file: bedtools_genomecov/output_bedfile
        output_filename: input_output_filenames
      scatterMethod: dotproduct
      scatter:
      - bedgraph_file
      - output_filename
      out:
      - pbc
    bedtools_genomecov:
      run: bedtools-genomecov.cwl
      in:
        bg:
          default: true
        g: genome_sizes
        ibam: input_bam_files
      scatter: ibam
      out:
      - output_bedfile
 outputs:
    pbc_file:
      outputSource: compute_pbc/pbc
      type: File[]
