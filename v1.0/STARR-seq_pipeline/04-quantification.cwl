#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.0
doc: STARR-seq 04 quantification
requirements:
 - class: ScatterFeatureRequirement
 - class: StepInputExpressionRequirement
 - class: InlineJavascriptRequirement
 - class: SubworkflowFeatureRequirement
inputs:
   input_bam_files:
     type: File[]
     secondaryFiles:
       - .bai
   input_dedup_bam_files:
     type: File[]
     secondaryFiles:
       - .bai
   ENCODE_blacklist_bedfile:
     doc: Bedfile containing ENCODE consensus blacklist regions to be excluded.
     type: File
   nthreads:
     default: 1
     type: int
outputs:
   bw_dedup_norm_files:
     doc: Normalized by RPKM bigWig files.
     type: File[]
     outputSource: bamcoverage-dedup/output_bam_coverage
   bw_with_dups_norm_files:
     doc: Normalized by RPKM bigWig files.
     type: File[]
     outputSource: bamcoverage-with-dups/output_bam_coverage
steps:
   bamcoverage-dedup:
     run: ../quant/deeptools-bamcoverage.cwl
     scatter: bam
     in:
       bam: input_dedup_bam_files
       blackListFileName: ENCODE_blacklist_bedfile
       extendReads:
         valueFrom: $(true)
       binSize:
         valueFrom: ${return 1}
       numberOfProcessors: nthreads
       outFileName:
         valueFrom: $(inputs.bam.nameroot.replace(/\.[^/.]+$/, '.rpkm.bw'))
       normalizeUsing:
         valueFrom: RPKM
     out:
     - output_bam_coverage
   bamcoverage-with-dups:
     run: ../quant/deeptools-bamcoverage.cwl
     scatter: bam
     in:
       bam: input_bam_files
       blackListFileName: ENCODE_blacklist_bedfile
       extendReads:
         valueFrom: $(true)
       binSize:
         valueFrom: ${return 1}
       numberOfProcessors: nthreads
       outFileName:
         valueFrom: $(inputs.bam.nameroot.replace(/\.[^/.]+$/, '.rpkm.bw'))
       normalizeUsing:
         valueFrom: RPKM
     out:
     - output_bam_coverage
