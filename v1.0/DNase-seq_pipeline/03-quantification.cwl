 class: Workflow
 cwlVersion: v1.0
 doc: DNase-seq 03 quantification
 requirements:
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
 inputs:
    nthreads:
      default: 1
      type: int
    input_pileup_bedgraphs:
      type: File[]
    input_bam_files:
      type: File[]
    input_peak_xls_files:
      type: File[]
    input_read_count_dedup_files:
      type: File[]
    input_genome_sizes:
      type: File
 steps:
    bedsort_scaled_bdg:
      run: ../quant/bedSort.cwl
      in:
        bed_file: scale-bedgraph/bedgraph_scaled
      scatter: bed_file
      out:
      - bed_file_sorted
    bedsort_genomecov:
      run: ../quant/bedSort.cwl
      in:
        bed_file: bedtools_genomecov/output_bedfile
      scatter: bed_file
      out:
      - bed_file_sorted
    bdg2bw-extend-norm:
      run: ../quant/bedGraphToBigWig.cwl
      in:
        output_suffix:
          valueFrom: .fragment_extended.bw
        genome_sizes: input_genome_sizes
        bed_graph: bedsort_scaled_bdg/bed_file_sorted
      scatter: bed_graph
      out:
      - output_bigwig
    scale-bedgraph:
      run: ../peak_calling/scale-bedgraph.cwl
      in:
        bedgraph_file: input_pileup_bedgraphs
        read_count_file: input_read_count_dedup_files
      scatterMethod: dotproduct
      scatter:
      - bedgraph_file
      - read_count_file
      out:
      - bedgraph_scaled
    bedsort_clipped_bedfile:
      run: ../quant/bedSort.cwl
      in:
        bed_file: clip-off-chrom/bed_file_clipped
      scatter: bed_file
      out:
      - bed_file_sorted
    bdg2bw-raw:
      run: ../quant/bedGraphToBigWig.cwl
      in:
        output_suffix:
          valueFrom: .raw.bw
        genome_sizes: input_genome_sizes
        bed_graph: bedsort_genomecov/bed_file_sorted
      scatter: bed_graph
      out:
      - output_bigwig
    bedtools_genomecov:
      run: ../map/bedtools-genomecov.cwl
      in:
        bg:
          valueFrom: ${return true}
        g: input_genome_sizes
        ibam: input_bam_files
      scatter: ibam
      out:
      - output_bedfile
    bamcoverage:
      run: ../quant/deeptools-bamcoverage.cwl
      in:
        numberOfProcessors: nthreads
        extendReads:
          valueFrom: ${return 200}
        normalizeUsing:
          valueFrom: RPKM
        binSize:
          valueFrom: ${return 50}
        bam: input_bam_files
        output_suffix:
          valueFrom: .norm.bw
      scatter: bam
      out:
      - output_bam_coverage
    bdg2bw-extend:
      run: ../quant/bedGraphToBigWig.cwl
      in:
        output_suffix:
          valueFrom: .fragment_extended.bw
        genome_sizes: input_genome_sizes
        bed_graph: bedsort_clipped_bedfile/bed_file_sorted
      scatter: bed_graph
      out:
      - output_bigwig
    clip-off-chrom:
      run: ../quant/bedClip.cwl
      in:
        bed_file: extend-reads/stdoutfile
        genome_sizes: input_genome_sizes
      scatter: bed_file
      out:
      - bed_file_clipped
    extend-reads:
      run: ../quant/bedtools-slop.cwl
      in:
        i: input_pileup_bedgraphs
        b:
          valueFrom: ${return 0}
        g: input_genome_sizes
      scatter: i
      out:
      - stdoutfile
 outputs:
    bigwig_raw_files:
      doc: Raw reads bigWig (signal) files
      type: File[]
      outputSource: bdg2bw-raw/output_bigwig
    bigwig_norm_files:
      doc: Normalized reads bigWig (signal) files
      type: File[]
      outputSource: bamcoverage/output_bam_coverage
    bigwig_extended_norm_files:
      doc: Normalized fragment extended reads bigWig (signal) files
      type: File[]
      outputSource: bdg2bw-extend-norm/output_bigwig
    bigwig_extended_files:
      doc: Fragment extended reads bigWig (signal) files
      type: File[]
      outputSource: bdg2bw-extend/output_bigwig
