#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.0
doc: 'STARR-seq 03 mapping - reads: PE'
requirements:
 - class: ScatterFeatureRequirement
 - class: SubworkflowFeatureRequirement
 - class: StepInputExpressionRequirement
 - class: InlineJavascriptRequirement
inputs:
   input_fastq_read1_files:
     doc: Input fastq paired-end read 1 files
     type: File[]
   input_fastq_read2_files:
     doc: Input fastq paired-end read 2 files
     type: File[]
   genome_sizes_file:
     doc: Genome sizes tab-delimited file (used in samtools)
     type: File
   regions_bed_file:
     doc: Regions bed file used to filter-in reads (used in samtools)
     type: File
   picard_jar_path:
     default: /usr/picard/picard.jar
     doc: Picard Java jar file
     type: string
   picard_java_opts:
     doc: JVM arguments should be a quoted, space separated list (e.g. "-Xms128m -Xmx512m")
     type: string?
   ENCODE_blacklist_bedfile:
     doc: Bedfile containing ENCODE consensus blacklist regions to be excluded.
     type: File
   genome_ref_first_index_file:
     doc: Bowtie first index files for reference genome (e.g. *1.bt2). The rest of the files should be in the same folder.
     type: File
     secondaryFiles:
       - ^^.2.bt2
       - ^^.3.bt2
       - ^^.4.bt2
       - ^^.rev.1.bt2
       - ^^.rev.2.bt2
   nthreads:
     default: 1
     type: int
steps:
   basename:
     run: ../utils/basename.cwl
     scatter: file_path
     in:
       file_path:
         source: input_fastq_read1_files
         valueFrom: $(self.basename)
       sep:
         valueFrom: '[\._]R1'
       do_not_escape_sep:
         valueFrom: ${return true}
     out:
     - basename
   extract_basename_1:
     run: ../utils/extract-basename.cwl
     in:
       input_file: input_fastq_read1_files
     scatter: input_file
     out:
     - output_basename
   extract_basename_2:
     run: ../utils/remove-extension.cwl
     in:
       file_path: extract_basename_1/output_basename
     scatter: file_path
     out:
     - output_path
   bowtie2:
     run: ../map/bowtie2.cwl
     scatterMethod: dotproduct
     scatter:
     - input_fastq_read1_file
     - input_fastq_read2_file
     - ungz
     - output_filename
     in:
       input_fastq_read1_file: input_fastq_read1_files
       input_fastq_read2_file: input_fastq_read2_files
       ungz:
         source: basename/basename
         valueFrom: ${return self + ".unmmaped.fastq.gz"}
       output_filename: basename/basename
       sensitive:
         valueFrom: ${return true}
       v:
         valueFrom: ${return 2}
       X:
         valueFrom: ${return 2000}
       genome_ref_first_index_file: genome_ref_first_index_file
       nthreads: nthreads
     out:
     - outfile
     - output_bowtie_log
     - output_unmapped_reads
   sort_bams:
     run: ../map/samtools-sort.cwl
     scatter:
     - input_file
     in:
       nthreads: nthreads
       input_file: bowtie2/outfile
     out:
     - sorted_file
   index_bams:
     run: ../map/samtools-index.cwl
     scatter:
     - input_file
     in:
       input_file: sort_bams/sorted_file
     out:
     - indexed_file
   filter_quality_alignments:
     run: ../map/samtools-view.cwl
     scatter:
     - input_file
     in:
       input_file: bowtie2/outfile
       nthreads: nthreads
       b:
         valueFrom: ${return true}
       u:
         valueFrom: ${return true}
       header:
         valueFrom: ${return true}
       S:
         valueFrom: ${return true}
       f:
         valueFrom: ${return 3}
       q:
         valueFrom: ${return 10}
       L: regions_bed_file
     out:
     - outfile
   sort_bams_by_tag_name:
     run: ../map/samtools-sort.cwl
     scatter:
     - input_file
     in:
       nthreads: nthreads
       n:
         valueFrom: ${return true}
       suffix:
         valueFrom: .f3q10.nsorted_bam
       input_file: filter_quality_alignments/outfile
     out:
     - sorted_file
   remove_encode_blacklist:
     run: ../map/bedtools-pairtobed.cwl
     scatterMethod: dotproduct
     scatter:
     - abam
     in:
       abam: sort_bams_by_tag_name/sorted_file
       bFile: ENCODE_blacklist_bedfile
       type:
         valueFrom: neither
     out:
     - filtered
   sort_masked_bams:
     run: ../map/samtools-sort.cwl
     scatter:
     - input_file
     in:
       nthreads: nthreads
       input_file: remove_encode_blacklist/filtered
     out:
     - sorted_file
   index_masked_bams:
     run: ../map/samtools-index.cwl
     scatter:
     - input_file
     in:
       input_file: sort_masked_bams/sorted_file
     out:
     - indexed_file
   bam_to_bepe:
     run: ../map/bedtools-bamtobed.cwl
     scatterMethod: dotproduct
     scatter:
     - bam
     in:
       bam: sort_bams_by_tag_name/sorted_file
       bedpe:
         valueFrom: ${return true}
     out:
     - output_bedfile
   cut_to_bepe:
     run: ../utils/cut.cwl
     scatterMethod: dotproduct
     scatter:
     - input_file
     in:
       input_file: bam_to_bepe/output_bedfile
       suffix:
         valueFrom: .fragments.txt
       columns:
         valueFrom: 1,2,6
     out:
     - output_file
   sort_to_bepe:
     run: ../utils/sort.cwl
     scatterMethod: dotproduct
     scatter:
     - input_file
     in:
       input_file: cut_to_bepe/output_file
       suffix:
         valueFrom: .bedpe
       k:
         valueFrom: $(["1,1", "2,2g"])
     out:
     - outfile
   mark_duplicates:
     run: ../map/picard-MarkDuplicates.cwl
     scatterMethod: dotproduct
     scatter:
     - input_file
     in:
       java_opts: picard_java_opts
       picard_jar_path: picard_jar_path
       input_file: index_masked_bams/indexed_file
       output_filename:
         valueFrom: $(inputs.input_file.nameroot + ".dups_marked")
       output_suffix:
         valueFrom: bam
     out:
     - output_metrics_file
     - output_dedup_bam_file
   index_dups_marked_bams:
     run: ../map/samtools-index.cwl
     scatter:
     - input_file
     in:
       input_file: mark_duplicates/output_dedup_bam_file
     out:
     - indexed_file
   remove_duplicates:
     run: ../map/samtools-view.cwl
     scatter:
     - input_file
     in:
       input_file: index_dups_marked_bams/indexed_file
       F:
         valueFrom: ${return 1024}
       suffix:
         valueFrom: .dedup.bam
       b:
         valueFrom: ${return true}
       outfile_name:
         valueFrom: ${return inputs.input_file.basename.replace('dups_marked', 'dedup')}
     out:
     - outfile
   sort_dedup_bams:
     run: ../map/samtools-sort.cwl
     scatter:
     - input_file
     in:
       nthreads: nthreads
       input_file: remove_duplicates/outfile
     out:
     - sorted_file
   index_dedup_bams:
     run: ../map/samtools-index.cwl
     scatter:
     - input_file
     in:
       input_file: sort_dedup_bams/sorted_file
     out:
     - indexed_file
   preseq-c-curve:
     run: ../map/preseq-c_curve.cwl
     scatterMethod: dotproduct
     scatter:
     - input_sorted_file
     in:
       input_sorted_file: index_masked_bams/indexed_file
       output_file_basename:
         valueFrom: $(inputs.input_sorted_file.nameroot + ".preseq_ccurve.txt")
       pe:
         valueFrom: ${return true}
     out:
     - output_file
outputs:
   output_picard_mark_duplicates_files:
     doc: Picard MarkDuplicates metrics files.
     type: File[]
     outputSource: mark_duplicates/output_metrics_file
   output_bowtie_log:
     doc: Bowtie log file.
     type: File[]
     outputSource: bowtie2/output_bowtie_log
   output_data_bam_files:
     doc: BAM files with aligned reads.
     type: File[]
     outputSource:   index_dups_marked_bams/indexed_file
   output_data_dedup_bam_files:
     doc: Dedup BAM files with aligned reads.
     type: File[]
     outputSource: index_dedup_bams/indexed_file
   output_data_unmapped_fastq_files:
     doc: FASTQ gzipped files with unmapped reads.
     type: File[]
     outputSource: bowtie2/output_unmapped_reads
   output_templates_files:
     doc: Tags/templates coordinates, sorted by chromosome and position (sort -k1,1 -k2,2g).
     type: File[]
     outputSource: sort_to_bepe/outfile
   output_preseq_c_curve_files:
     doc: Preseq c_curve output files.
     type: File[]
     outputSource: preseq-c-curve/output_file