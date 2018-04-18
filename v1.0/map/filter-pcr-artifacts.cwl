 class: Workflow
 cwlVersion: v1.0
 doc: DNase-seq - map - Filter PCR Artifacts
 requirements:
  - class: ScatterFeatureRequirement
 inputs:
    input_bam_files:
      type: File[]
 steps:
    window_trimmer:
      run: windowtrimmer.cwl
      in:
        input_file: bedtools_bamtobed/output_bedfile
      scatter: input_file
      out:
      - filtered_file
    bedtools_bamtobed:
      run: bedtools-bamtobed.cwl
      in:
        bam: input_bam_files
      scatter: bam
      out:
      - output_bedfile
 outputs:
    filtered_bedfile:
      outputSource: window_trimmer/filtered_file
      type: File[]
