#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.0
doc: 'ChIP-seq - Quantification - samples: treatment'
requirements:
 - class: ScatterFeatureRequirement
 - class: StepInputExpressionRequirement
 - class: InlineJavascriptRequirement
inputs:
   input_trt_bam_files:
     type: File[]
   input_genome_sizes:
     type: File
   nthreads:
     default: 1
     type: int
steps:
   bedtools_genomecov:
     run: ../map/bedtools-genomecov.cwl
     scatter: ibam
     in:
       bg:
         valueFrom: ${return true}
       g: input_genome_sizes
       ibam: input_trt_bam_files
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
     in:
       output_suffix:
         valueFrom: .raw.bw
       genome_sizes: input_genome_sizes
       bed_graph: bedsort_genomecov/bed_file_sorted
     scatter: bed_graph
     out:
     - output_bigwig
   bamCoverage-rpkm-trt:
     run: ../quant/deeptools-bamcoverage.cwl
     scatter: bam
     in:
       bam: input_trt_bam_files
       numberOfProcessors: nthreads
       outFileFormat:
         valueFrom: bigwig
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
outputs:
   bigwig_raw_files:
     doc: Raw reads bigWig (signal) files
     type: File[]
     outputSource: bdg2bw-raw/output_bigwig
   bigwig_rpkm_extended_files:
     doc: Fragment extended RPKM bigWig (signal) files
     type: File[]
     outputSource: bamCoverage-rpkm-trt/output_bam_coverage