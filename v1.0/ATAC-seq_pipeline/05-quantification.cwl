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
       normalizeUsing:
         valueFrom: RPKM
       binSize:
         valueFrom: ${return 1}
       output_suffix:
         valueFrom: .rpkm.bw
       extendReads:
         valueFrom: ${return 200}
     out:
     - output_bam_coverage
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
   bedsort_genomecov:
     run: ../quant/bedSort.cwl
     scatter: bed_file
     in:
       bed_file: bedtools_genomecov/output_bedfile
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
outputs:
   bigwig_raw_files:
     doc: Raw reads bigWig (signal) files
     type: File[]
     outputSource: bdg2bw-raw/output_bigwig
   bigwig_norm_files:
     doc: signal files of pileup reads in RPKM
     type: File[]
     outputSource: bamcoverage/output_bam_coverage
