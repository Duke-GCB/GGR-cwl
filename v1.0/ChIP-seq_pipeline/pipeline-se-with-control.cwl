#!/usr/bin/env cwl-runner
 class: Workflow
 cwlVersion: v1.0
 doc: "ChIP-seq pipeline - reads: SE, samples: treatment and control."
 requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: StepInputExpressionRequirement
 inputs:
    input_treatment_fastq_files:
      doc: Input treatment fastq files
      type: File[]
    input_control_fastq_files:
      doc: Input control fastq files
      type: File[]
    genome_sizes_file:
      doc: Genome sizes tab-delimited file (used in samtools)
      type: File
    genome_effective_size:
      default: hs
      doc: Effective genome size used by MACS2. It can be numeric or a shortcuts:'hs' for human (2.7e9), 'mm' for mouse (1.87e9), 'ce' for C. elegans (9e7) and 'dm' for fruitfly (1.2e8), Default:hs
      type: string
    default_adapters_file:
      doc: Adapters file
      type: File
    ENCODE_blacklist_bedfile:
      doc: Bedfile containing ENCODE consensus blacklist regions to be excluded.
      type: File
    genome_ref_first_index_file:
      doc: '"First index file of Bowtie reference genome with extension 1.ebwt. \ (Note: the rest of the index files MUST be in the same folder)" '
      type: File
    as_narrowPeak_file:
      doc: Definition narrowPeak file in AutoSql format (used in bedToBigBed)
      type: File
    as_broadPeak_file:
      doc: Definition broadPeak file in AutoSql format (used in bedToBigBed)
      type: File
    trimmomatic_java_opts:
      doc: JVM arguments should be a quoted, space separated list (e.g. "-Xms128m -Xmx512m")
      type: string?
    trimmomatic_jar_path:
      doc: Trimmomatic Java jar file
      type: string
    picard_java_opts:
      doc: JVM arguments should be a quoted, space separated list (e.g. "-Xms128m -Xmx512m")
      type: string?
    picard_jar_path:
      doc: Picard Java jar file
      type: string
    nthreads_qc:
      doc: Number of threads required for the 01-qc step
      type: int
    nthreads_trimm:
      doc: Number of threads required for the 02-trim step
      type: int
    nthreads_map:
      doc: Number of threads required for the 03-map step
      type: int
    nthreads_peakcall:
      doc: Number of threads required for the 04-peakcall step
      type: int
    nthreads_quant:
      doc: Number of threads required for the 05-quantification step
      type: int
 outputs:
    qc_treatment_count_raw_reads:
      doc: Raw read counts of fastq files after QC for treatment
      type: File[]
      outputSource: qc_treatment/output_count_raw_reads
    qc_treatment_fastqc_data_files:
      doc: FastQC data files
      type: File[]
      outputSource: qc_treatment/output_fastqc_data_files
    qc_treatment_diff_counts:
      doc: Diff file between number of raw reads and number of reads counted by FASTQC, for treatment
      type: File[]
      outputSource: qc_treatment/output_diff_counts
    trimm_treatment_fastq_files:
      doc: FASTQ files after trimming step for control
      type: File[]
      outputSource: trimm_treatment/output_data_fastq_trimmed_files
    trimm_treatment_raw_counts:
      doc: Raw read counts for fastq files after trimming for treatment
      type: File[]
      outputSource: trimm_treatment/output_trimmed_fastq_read_count
    map_treatment_mark_duplicates_files:
      doc: Summary of duplicates removed with Picard tool MarkDuplicates (for multiple reads aligned to the same positions) for treatment
      type: File[]
      outputSource: map_treatment/output_picard_mark_duplicates_files
    map_treatment_dedup_bam_files:
      doc: Filtered BAM files (post-processing end point) for treatment
      type: File[]
      outputSource: map_treatment/output_data_sorted_dedup_bam_files
    map_treatment_dups_marked_bam_files:
      doc: Filtered BAM files with duplicates marked (post-processing end point) for treatment
      type: File[]
      outputSource: map_treatment/output_data_sorted_dups_marked_bam_files
    map_treatment_pbc_files:
      doc: PCR Bottleneck Coefficient files (used to flag samples when pbc<0.5) for control
      type: File[]
      outputSource: map_treatment/output_pbc_files
    map_treatment_preseq_percentage_uniq_reads:
      doc: Preseq percentage of uniq reads
      type: File[]
      outputSource: map_treatment/output_percentage_uniq_reads
    map_treatment_read_count_mapped:
      doc: Read counts of the mapped BAM files
      type: File[]
      outputSource: map_treatment/output_read_count_mapped
    map_treatment_bowtie_log_files:
      doc: Bowtie log file with mapping stats for treatment
      type: File[]
      outputSource: map_treatment/output_bowtie_log
    map_treatment_preseq_c_curve_files:
      doc: Preseq c_curve output files for treatment
      type: File[]
      outputSource: map_treatment/output_preseq_c_curve_files
    map_treatment_preseq_lc_extrap_files:
      doc: Preseq lc_extrap output files for treatment
      type: File[]
      outputSource: map_treatment/output_preseq_lc_extrap_files
    peak_call_treatment_spp_x_cross_corr:
      doc: SPP strand cross correlation summary
      type: File[]
      outputSource: peak_call_treatment/output_spp_x_cross_corr
    peak_call_treatment_spp_x_cross_corr_plot:
      doc: SPP strand cross correlation plot
      type: File[]
      outputSource: peak_call_treatment/output_spp_cross_corr_plot
    peak_call_treatment_filtered_read_count_file:
      doc: Filtered read count after peak calling
      type: File[]
      outputSource: peak_call_treatment/output_filtered_read_count_file
    peak_call_treatment_narrowpeak_peak_xls_file:
      doc: Peak calling report file
      type: File[]
      outputSource: peak_call_treatment/output_narrowpeak_xls_file
    peak_call_treatment_read_in_narrowpeak_count_within_replicate:
      doc: Peak counts within replicate
      type: File[]
      outputSource: peak_call_treatment/output_read_in_narrowpeak_count_within_replicate
    peak_call_treatment_narrowpeak_count:
      doc: Peak counts within replicate
      type: File[]
      outputSource: peak_call_treatment/output_narrowpeak_count
    peak_call_treatment_narrowpeak_file:
      doc: Peaks in narrowPeak file format
      type: File[]
      outputSource: peak_call_treatment/output_narrowpeak_file
    peak_call_treatment_narrowpeak_summits_file:
      doc: Peaks summits in bedfile format
      type:
        type: array
        items:
        - 'null'
        - items: File
          type: array
      outputSource: peak_call_treatment/output_narrowpeak_summits_file
    peak_call_treatment_narrowpeak_bigbed_file:
      doc: narrowPeaks in bigBed format
      type: File[]
      outputSource: peak_call_treatment/output_narrowpeak_bigbed_file
    peak_call_treatment_broadpeak_peak_xls_file:
      doc: Peak calling report file
      type: File[]
      outputSource: peak_call_treatment/output_broadpeak_xls_file
    peak_call_treatment_read_in_broadpeak_count_within_replicate:
      doc: Peak counts within replicate
      type: File[]
      outputSource: peak_call_treatment/output_read_in_broadpeak_count_within_replicate
    peak_call_treatment_broadpeak_count:
      doc: Peak counts within replicate
      type: File[]
      outputSource: peak_call_treatment/output_broadpeak_count
    peak_call_treatment_broadpeak_file:
      doc: Peaks in broadPeak file format
      type: File[]
      outputSource: peak_call_treatment/output_broadpeak_file
    peak_call_treatment_broadpeak_summits_file:
      doc: Peaks summits in bedfile format
      type:
        type: array
        items:
        - 'null'
        - items: File
          type: array
      outputSource: peak_call_treatment/output_broadpeak_summits_file
    peak_call_treatment_broadpeak_bigbed_file:
      doc: broadPeaks in bigBed format
      type: File[]
      outputSource: peak_call_treatment/output_broadpeak_bigbed_file
    qc_control_count_raw_reads:
      doc: Raw read counts of fastq files after QC for control
      type: File[]
      outputSource: qc_control/output_count_raw_reads
    qc_control_fastqc_data_files:
      doc: FastQC data files
      type: File[]
      outputSource: qc_control/output_fastqc_data_files
    qc_control_diff_counts:
      doc: Diff file between number of raw reads and number of reads counted by FASTQC, for control
      type: File[]
      outputSource: qc_control/output_diff_counts
    trimm_control_fastq_files:
      doc: FASTQ files after trimming step for control
      type: File[]
      outputSource: trimm_control/output_data_fastq_trimmed_files
    trimm_control_raw_counts:
      doc: Raw read counts for fastq files after trimming for control
      type: File[]
      outputSource: trimm_control/output_trimmed_fastq_read_count
    map_control_mark_duplicates_files:
      doc: Summary of duplicates removed with Picard tool MarkDuplicates (for multiple reads aligned to the same positions) for control
      type: File[]
      outputSource: map_control/output_picard_mark_duplicates_files
    map_control_dedup_bam_files:
      doc: Filtered BAM files (post-processing end point) for control
      type: File[]
      outputSource: map_control/output_data_sorted_dedup_bam_files
    map_control_dups_marked_bam_files:
      doc: Filtered BAM files with duplicates marked (post-processing end point) for control
      type: File[]
      outputSource: map_control/output_data_sorted_dups_marked_bam_files
    map_control_pbc_files:
      doc: PCR Bottleneck Coefficient files (used to flag samples when pbc<0.5) for control
      type: File[]
      outputSource: map_control/output_pbc_files
    map_control_preseq_percentage_uniq_reads:
      doc: Preseq percentage of uniq reads
      type: File[]
      outputSource: map_control/output_percentage_uniq_reads
    map_control_read_count_mapped:
      doc: Read counts of the mapped BAM files
      type: File[]
      outputSource: map_control/output_read_count_mapped
    map_control_bowtie_log_files:
      doc: Bowtie log file with mapping stats for control
      type: File[]
      outputSource: map_control/output_bowtie_log
    map_control_preseq_c_curve_files:
      doc: Preseq c_curve output files for control
      type: File[]
      outputSource: map_control/output_preseq_c_curve_files
    map_control_preseq_lc_extrap_files:
      doc: Preseq lc_extrap output files for control
      type: File[]
      outputSource: map_control/output_preseq_lc_extrap_files
    peak_call_control_spp_x_cross_corr:
      doc: SPP strand cross correlation summary
      type: File[]
      outputSource: peak_call_control/output_spp_x_cross_corr
    peak_call_control_spp_x_cross_corr_plot:
      doc: SPP strand cross correlation plot
      type: File[]
      outputSource: peak_call_control/output_spp_cross_corr_plot
    peak_call_control_filtered_read_count_file:
      doc: Filtered read count after peak calling
      type: File[]
      outputSource: peak_call_control/output_filtered_read_count_file
    peak_call_control_narrowpeak_peak_xls_file:
      doc: Peak calling report file
      type: File[]
      outputSource: peak_call_control/output_narrowpeak_xls_file
    peak_call_control_read_in_narrowpeak_count_within_replicate:
      doc: Peak counts within replicate
      type: File[]
      outputSource: peak_call_control/output_read_in_narrowpeak_count_within_replicate
    peak_call_control_narrowpeak_count:
      doc: Peak counts within replicate
      type: File[]
      outputSource: peak_call_control/output_narrowpeak_count
    peak_call_control_narrowpeak_file:
      doc: Peaks in narrowPeak file format
      type: File[]
      outputSource: peak_call_control/output_narrowpeak_file
    peak_call_control_narrowpeak_summits_file:
      doc: Peaks summits in bedfile format
      type:
        type: array
        items:
        - 'null'
        - items: File
          type: array
      outputSource: peak_call_control/output_narrowpeak_summits_file
    peak_call_control_narrowpeak_bigbed_file:
      doc: narrowPeaks in bigBed format
      type: File[]
      outputSource: peak_call_control/output_narrowpeak_bigbed_file
    peak_call_control_broadpeak_peak_xls_file:
      doc: Peak calling report file
      type: File[]
      outputSource: peak_call_control/output_broadpeak_xls_file
    peak_call_control_read_in_broadpeak_count_within_replicate:
      doc: Peak counts within replicate
      type: File[]
      outputSource: peak_call_control/output_read_in_broadpeak_count_within_replicate
    peak_call_control_broadpeak_count:
      doc: Peak counts within replicate
      type: File[]
      outputSource: peak_call_control/output_broadpeak_count
    peak_call_control_broadpeak_file:
      doc: Peaks in broadPeak file format
      type: File[]
      outputSource: peak_call_control/output_broadpeak_file
    peak_call_control_broadpeak_summits_file:
      doc: Peaks summits in bedfile format
      type:
        type: array
        items:
        - 'null'
        - items: File
          type: array
      outputSource: peak_call_control/output_broadpeak_summits_file
    peak_call_control_broadpeak_bigbed_file:
      doc: broadPeaks in bigBed format
      type: File[]
      outputSource: peak_call_control/output_broadpeak_bigbed_file
    quant_bigwig_raw_files:
      doc: Raw reads bigWig (signal) files
      type: File[]
      outputSource: quant/bigwig_raw_files
    quant_bigwig_rpkm_extended_files:
      doc: Fragment extended reads bigWig (signal) files
      type: File[]
      outputSource: quant/bigwig_rpkm_extended_files
    quant_bigwig_ctrl_subtracted_rpkm_extended_files:
      doc: Fragment control subtracted extended reads bigWig (signal) files
      type: File[]
      outputSource: quant/bigwig_ctrl_subtracted_rpkm_extended_files
    quant_ctrl_bigwig_rpkm_extended_files:
      doc: Fragment extended reads bigWig (signal) control files
      type: File[]
      outputSource: quant/bigwig_ctrl_rpkm_extended_files
 steps:
    qc_treatment:
      run: 01-qc-se.cwl
      in:
        default_adapters_file: default_adapters_file
        input_fastq_files: input_treatment_fastq_files
        nthreads: nthreads_qc
      out:
      - output_count_raw_reads
      - output_diff_counts
      - output_fastqc_report_files
      - output_fastqc_data_files
      - output_custom_adapters
    trimm_treatment:
      run: 02-trim-se.cwl
      in:
        input_adapters_files: qc_treatment/output_custom_adapters
        input_read1_fastq_files: input_treatment_fastq_files
        trimmomatic_java_opts: trimmomatic_java_opts
        trimmomatic_jar_path: trimmomatic_jar_path
        nthreads: nthreads_trimm
      out:
      - output_data_fastq_trimmed_files
      - output_trimmed_fastq_read_count
    map_treatment:
      run: 03-map-se.cwl
      in:
        input_fastq_files: trimm_treatment/output_data_fastq_trimmed_files
        genome_sizes_file: genome_sizes_file
        ENCODE_blacklist_bedfile: ENCODE_blacklist_bedfile
        genome_ref_first_index_file: genome_ref_first_index_file
        picard_jar_path: picard_jar_path
        picard_java_opts: picard_java_opts
        nthreads: nthreads_map
      out:
      - output_data_sorted_dedup_bam_files
      - output_data_sorted_dups_marked_bam_files
      - output_picard_mark_duplicates_files
      - output_pbc_files
      - output_bowtie_log
      - output_preseq_c_curve_files
      - output_preseq_lc_extrap_files
      - output_percentage_uniq_reads
      - output_read_count_mapped
    peak_call_treatment:
      run: 04-peakcall-with-control.cwl
      in:
        input_bam_files: map_treatment/output_data_sorted_dedup_bam_files
        input_control_bam_files: map_control/output_data_sorted_dedup_bam_files
        input_genome_sizes: genome_sizes_file
        genome_effective_size: genome_effective_size
        as_narrowPeak_file: as_narrowPeak_file
        as_broadPeak_file: as_broadPeak_file
        nthreads: nthreads_peakcall
      out:
      - output_spp_x_cross_corr
      - output_spp_cross_corr_plot
      - output_filtered_read_count_file
      - output_read_in_narrowpeak_count_within_replicate
      - output_narrowpeak_count
      - output_narrowpeak_file
      - output_narrowpeak_summits_file
      - output_narrowpeak_bigbed_file
      - output_narrowpeak_xls_file
      - output_read_in_broadpeak_count_within_replicate
      - output_broadpeak_count
      - output_broadpeak_file
      - output_broadpeak_summits_file
      - output_broadpeak_bigbed_file
      - output_broadpeak_xls_file
    qc_control:
      run: 01-qc-se.cwl
      in:
        default_adapters_file: default_adapters_file
        input_fastq_files: input_control_fastq_files
        nthreads: nthreads_qc
      out:
      - output_count_raw_reads
      - output_diff_counts
      - output_fastqc_report_files
      - output_fastqc_data_files
      - output_custom_adapters
    trimm_control:
      run: 02-trim-se.cwl
      in:
        input_adapters_files: qc_control/output_custom_adapters
        input_read1_fastq_files: input_control_fastq_files
        trimmomatic_java_opts: trimmomatic_java_opts
        trimmomatic_jar_path: trimmomatic_jar_path
        nthreads: nthreads_trimm
      out:
      - output_data_fastq_trimmed_files
      - output_trimmed_fastq_read_count
    map_control:
      run: 03-map-se.cwl
      in:
        input_fastq_files: trimm_control/output_data_fastq_trimmed_files
        genome_sizes_file: genome_sizes_file
        ENCODE_blacklist_bedfile: ENCODE_blacklist_bedfile
        genome_ref_first_index_file: genome_ref_first_index_file
        picard_jar_path: picard_jar_path
        picard_java_opts: picard_java_opts
        nthreads: nthreads_map
      out:
      - output_data_sorted_dedup_bam_files
      - output_data_sorted_dups_marked_bam_files
      - output_picard_mark_duplicates_files
      - output_pbc_files
      - output_bowtie_log
      - output_preseq_c_curve_files
      - output_preseq_lc_extrap_files
      - output_percentage_uniq_reads
      - output_read_count_mapped
    peak_call_control:
      run: 04-peakcall.cwl
      in:
        input_bam_files: map_control/output_data_sorted_dedup_bam_files
        input_genome_sizes: genome_sizes_file
        genome_effective_size: genome_effective_size
        as_narrowPeak_file: as_narrowPeak_file
        as_broadPeak_file: as_broadPeak_file
        nthreads: nthreads_peakcall
      out:
      - output_spp_x_cross_corr
      - output_spp_cross_corr_plot
      - output_filtered_read_count_file
      - output_read_in_narrowpeak_count_within_replicate
      - output_narrowpeak_count
      - output_narrowpeak_file
      - output_narrowpeak_summits_file
      - output_narrowpeak_bigbed_file
      - output_narrowpeak_xls_file
      - output_read_in_broadpeak_count_within_replicate
      - output_broadpeak_count
      - output_broadpeak_file
      - output_broadpeak_summits_file
      - output_broadpeak_bigbed_file
      - output_broadpeak_xls_file
    quant:
      run: 05-quantification-with-control.cwl
      in:
        nthreads: nthreads_quant
        input_trt_bam_files: map_treatment/output_data_sorted_dedup_bam_files
        input_ctrl_bam_files: map_control/output_data_sorted_dedup_bam_files
        input_genome_sizes: genome_sizes_file
      out:
      - bigwig_raw_files
      - bigwig_rpkm_extended_files
      - bigwig_ctrl_rpkm_extended_files
      - bigwig_ctrl_subtracted_rpkm_extended_files