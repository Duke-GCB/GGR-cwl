class: Workflow
cwlVersion: v1.0
doc: 'STARR-seq pipeline - reads: PE'
requirements:
 - class: ScatterFeatureRequirement
 - class: SubworkflowFeatureRequirement
 - class: StepInputExpressionRequirement
inputs:
   input_fastq_read1_files:
     doc: Input read1 fastq files
     type: File[]
   input_fastq_read2_files:
     doc: Input read2 fastq files
     type: File[]
   genome_sizes_file:
     doc: Genome sizes tab-delimited file (used in samtools)
     type: File
   ENCODE_blacklist_bedfile:
     doc: Bedfile containing ENCODE consensus blacklist regions to be excluded.
     type: File
   regions_bed_file:
     doc: Regions bed file used to filter-in reads (used in samtools, for example chromosomes of interest)
     type: File
   genome_ref_first_index_file:
     doc: '"First index file of Bowtie2 reference genome with extension 1.bt2. \ (Note: the rest of the index files MUST be in the same folder)" '
     type: File
     secondaryFiles:
       - ^^.2.bt2
       - ^^.3.bt2
       - ^^.4.bt2
       - ^^.rev.1.bt2
       - ^^.rev.2.bt2
   nthreads_qc:
     doc: Number of threads - qc.
     type: int
   nthreads_trimm:
     doc: Number of threads - trim.
     type: int
   nthreads_map:
     doc: Number of threads - map.
     type: int
   nthreads_quant:
     doc: Number of threads - quantification.
     type: int
   default_adapters_file:
     doc: Adapters file
     type: File
   trimmomatic_jar_path:
     doc: Trimmomatic Java jar file
     type: string
   trimmomatic_java_opts:
     doc: JVM arguments should be a quoted, space separated list (e.g. "-Xms128m -Xmx512m")
     type: string?
   picard_java_opts:
     doc: JVM arguments should be a quoted, space separated list (e.g. "-Xms128m -Xmx512m")
     type: string?
   picard_jar_path:
     doc: Picard Java jar file
     type: string
outputs:
   output_fastqc_report_files_read1:
     doc: FastQC reports in zip format for paired read 1
     type: File[]
     outputSource: qc/output_fastqc_report_files_read1
   output_fastqc_data_files_read1:
     doc: FastQC data files for paired read 1
     type: File[]
     outputSource: qc/output_fastqc_data_files_read1
   output_count_raw_reads_read1:
     outputSource: qc/output_count_raw_reads_read1
     type: File[]
   output_custom_adapters_read1:
     outputSource: qc/output_custom_adapters_read1
     type: File[]
   output_diff_counts_read1:
     outputSource: qc/output_diff_counts_read1
     type: File[]
   output_trimmed_read1_fastq_read_count:
     doc: Trimmed read counts of paired read 1 fastq files
     type: File[]
     outputSource: trim/output_trimmed_read1_fastq_read_count
   output_data_fastq_read1_trimmed_files:
     doc: Trimmed fastq files for paired read 1
     type: File[]
     outputSource: trim/output_data_fastq_read1_trimmed_files
   output_fastqc_report_files_read2:
     doc: FastQC reports in zip format for paired read 2
     type: File[]
     outputSource: qc/output_fastqc_report_files_read2
   output_fastqc_data_files_read2:
     doc: FastQC data files for paired read 2
     type: File[]
     outputSource: qc/output_fastqc_data_files_read2
   output_count_raw_reads_read2:
     outputSource: qc/output_count_raw_reads_read2
     type: File[]
   output_custom_adapters_read2:
     outputSource: qc/output_custom_adapters_read2
     type: File[]
   output_diff_counts_read2:
     outputSource: qc/output_diff_counts_read2
     type: File[]
   output_trimmed_read2_fastq_read_count:
     doc: Trimmed read counts of paired read 2 fastq files
     type: File[]
     outputSource: trim/output_trimmed_read2_fastq_read_count
   output_data_fastq_read2_trimmed_files:
     doc: Trimmed fastq files for paired read 2
     type: File[]
     outputSource: trim/output_data_fastq_read2_trimmed_files
   map_mark_duplicates_files:
     doc: Summary of duplicates removed with Picard tool MarkDuplicates (for multiple reads aligned to the same positions)
     type: File[]
     outputSource: map/output_picard_mark_duplicates_files
   map_dups_marked_bam_files:
     doc: Filtered BAM files with duplicates marked (post-processing end point)
     type: File[]
     outputSource: map/output_data_bam_files
   map_unmapped_fastq_files:
     doc: Gzip compressed FASTQ ummaped and unpaired sequences
     type: File[]
     outputSource: map/output_data_unmapped_fastq_files
   map_bowtie_log_files:
     doc: Bowtie log file with mapping stats
     type: File[]
     outputSource: map/output_bowtie_log
   map_genomic_template_files:
     doc: BEDPE files with fragment/template coordinates
     type: File[]
     outputSource: map/output_templates_files
   map_preseq_c_curve_files:
     doc: Preseq c_curve output files
     type: File[]
     outputSource: map/output_preseq_c_curve_files
   quant_bw_dedup_norm_files:
     doc: Signal files with RPKM normalization ignoring duplicates.
     type: File[]
     outputSource: quant/bw_dedup_norm_files
   quant_bw_dedup_raw_files:
     doc: Signal files with 1bp raw read pileup ignoring duplicates.
     type: File[]
     outputSource: quant/bw_dedup_raw_files
   quant_bw_with_dups_norm_files:
     doc: Signal files with RPKM normalization including duplicates.
     type: File[]
     outputSource: quant/bw_with_dups_norm_files
steps:
   qc:
     in:
       input_fastq_read1_files: input_fastq_read1_files
       input_fastq_read2_files: input_fastq_read2_files
       default_adapters_file: default_adapters_file
       nthreads: nthreads_qc
     run: 01-qc-pe.cwl
     out:
     - output_fastqc_report_files_read1
     - output_fastqc_data_files_read1
     - output_custom_adapters_read1
     - output_count_raw_reads_read1
     - output_diff_counts_read1
     - output_fastqc_report_files_read2
     - output_fastqc_data_files_read2
     - output_custom_adapters_read2
     - output_count_raw_reads_read2
     - output_diff_counts_read2
   trim:
     in:
       input_read1_adapters_files: qc/output_custom_adapters_read1
       input_fastq_read1_files: input_fastq_read1_files
       input_read2_adapters_files: qc/output_custom_adapters_read2
       input_fastq_read2_files: input_fastq_read2_files
       nthreads: nthreads_trimm
       trimmomatic_java_opts: trimmomatic_java_opts
       trimmomatic_jar_path: trimmomatic_jar_path
     run: 02-trim-pe.cwl
     out:
     - output_data_fastq_read1_trimmed_files
     - output_trimmed_read1_fastq_read_count
     - output_data_fastq_read2_trimmed_files
     - output_trimmed_read2_fastq_read_count
   map:
     in:
       input_fastq_read1_files: trim/output_data_fastq_read1_trimmed_files
       input_fastq_read2_files: trim/output_data_fastq_read2_trimmed_files
       genome_sizes_file: genome_sizes_file
       ENCODE_blacklist_bedfile: ENCODE_blacklist_bedfile
       regions_bed_file: regions_bed_file
       genome_ref_first_index_file: genome_ref_first_index_file
       picard_jar_path: picard_jar_path
       picard_java_opts: picard_java_opts
       fgbio_jar_path: fgbio_jar_path
       nthreads: nthreads_map
     run: 03-map-pe.cwl
     out:
      - output_data_bam_files
      - output_data_dedup_bam_files
      - output_picard_mark_duplicates_files
      - output_data_unmapped_fastq_files
      - output_bowtie_log
      - output_preseq_c_curve_files
      - output_templates_files
   quant:
     in:
       input_bam_files: map/output_data_bam_files
       input_dedup_bam_files: map/output_data_dedup_bam_files
       ENCODE_blacklist_bedfile: ENCODE_blacklist_bedfile
       nthreads: nthreads_quant
     run: 04-quantification.cwl
     out:
     - bw_dedup_norm_files
     - bw_with_dups_norm_files
     - bw_dedup_raw_files