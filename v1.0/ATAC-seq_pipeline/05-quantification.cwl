class: Workflow
cwlVersion: v1.0
doc: ATAC-seq - Quantification
requirements:
 - class: ScatterFeatureRequirement
 - class: StepInputExpressionRequirement
 - class: InlineJavascriptRequirement
inputs:
   input_bam_files:
     type: File[]
   input_pileup_bedgraphs:
     type: File[]
   input_peak_xls_files:
     type: File[]
   input_read_count_dedup_files:
     type: File[]
   input_genome_sizes:
     type: File
   nthreads:
     default: 1
     type: int
steps:
   bamcoverage:
     run: ../quant/deeptools-bamcoverage.cwl
     scatter: bam
     in:
       bam: input_bam_files
       numberOfProcessors: nthreads
       extendReads:
         valueFrom: ${return 200}
       normalizeUsing:
         valueFrom: RPKM
       binSize:
         valueFrom: ${return 1}
       output_suffix:
         valueFrom: .rpkm.bw
     out:
     - output_bam_coverage
   scale-bedgraph:
     run: ../peak_calling/scale-bedgraph.cwl
     scatterMethod: dotproduct
     scatter:
     - bedgraph_file
     - read_count_file
     in:
       bedgraph_file: input_pileup_bedgraphs
       read_count_file: input_read_count_dedup_files
     out:
     - bedgraph_scaled
   bedsort_scaled_bdg:
     run: ../quant/bedSort.cwl
     scatter: bed_file
     in:
       bed_file: scale-bedgraph/bedgraph_scaled
     out:
     - bed_file_sorted
   bdg2bw-extend-norm:
     run: ../quant/bedGraphToBigWig.cwl
     scatter: bed_graph
     in:
       output_suffix:
         valueFrom: .fragment_extended.bw
       genome_sizes: input_genome_sizes
       bed_graph: bedsort_scaled_bdg/bed_file_sorted
     out:
     - output_bigwig
   bedsort_genomecov:
     run: ../quant/bedSort.cwl
     scatter: bed_file
     in:
       bed_file: bedtools_genomecov/output_bedfile
     out:
     - bed_file_sorted
   bedsort_clipped_bedfile:
     scatter: bed_file
     run: ../quant/bedSort.cwl
     in:
       bed_file: clip-off-chrom/bed_file_clipped
     out:
     - bed_file_sorted
   bdg2bw-raw:
     run: ../quant/bedGraphToBigWig.cwl
     scatter: bed_graph
     in:
       output_suffix:
         valueFrom: .raw.bw
       genome_sizes: input_genome_sizes
       bed_graph: bedsort_genomecov/bed_file_sorted
     out:
     - output_bigwig
   bedtools_genomecov:
     run: ../map/bedtools-genomecov.cwl
     scatter: ibam
     in:
       bg:
         valueFrom: ${return true}
       g: input_genome_sizes
       ibam: input_bam_files
     out:
     - output_bedfile
   bdg2bw-extend:
     run: ../quant/bedGraphToBigWig.cwl
     scatter: bed_graph
     in:
       bed_graph: bedsort_clipped_bedfile/bed_file_sorted
       output_suffix:
         valueFrom: .fragment_extended.bw
       genome_sizes: input_genome_sizes
     out:
     - output_bigwig
   clip-off-chrom:
     run: ../quant/bedClip.cwl
     scatter: bed_file
     in:
       bed_file: extend-reads/stdoutfile
       genome_sizes: input_genome_sizes
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
