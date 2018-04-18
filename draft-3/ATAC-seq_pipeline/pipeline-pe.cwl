#!/usr/bin/env cwl-runner
cwlVersion: "cwl:draft-3"
class: Workflow
description: "ATAC-seq pipeline - reads: PE, samples: ."
requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: StepInputExpressionRequirement
inputs:
  - id: "#input_fastq_read1_files"
    type:
      type: array
      items: File
    description: "Input fastq paired-end read 1 files"
  - id: "#input_fastq_read2_files"
    type:
      type: array
      items: File
    description: "Input fastq paired-end read 2 files"
  - id: "#default_adapters_file"
    type: File
    description: "Adapters file"
  - id: "#genome_ref_first_index_file"
    type: File
    description: |
        "First index file of Bowtie reference genome with extension 1.ebwt. \
        (Note: the rest of the index files MUST be in the same folder)"
  - id: "#genome_sizes_file"
    type: File
    description: "Genome sizes tab-delimited file (used in samtools)"
  - id: "#as_narrowPeak_file"
    type: File
    description: "Definition narrowPeak file in AutoSql format (used in bedToBigBed)"
  - id: "#nthreads_qc"
    type: int
    description: "Number of threads required for the 01-qc step"
  - id: "#nthreads_trimm"
    type: int
    description: "Number of threads required for the 02-trim step"
  - id: "#nthreads_map"
    type: int
    description: "Number of threads required for the 03-map step"
  - id: "#nthreads_peakcall"
    type: int
    description: "Number of threads required for the 04-peakcall step"
  - id: "#nthreads_quant"
    type: int
    description: "Number of threads required for the 05-quantification step"
  - id: "#trimmomatic_jar_path"
    type: string
    description: "Trimmomatic Java jar file"
  - id: "#trimmomatic_java_opts"
    type:
      - 'null'
      - string
    description: "JVM arguments should be a quoted, space separated list (e.g. \"-Xms128m -Xmx512m\")"
  - id: "#picard_jar_path"
    type: string
    description: "Picard Java jar file"
  - id: "#picard_java_opts"
    type:
      - 'null'
      - string
    description: "JVM arguments should be a quoted, space separated list (e.g. \"-Xms128m -Xmx512m\")"
  - id: "#genome_effective_size"
    type: string
    default: "hs"
    description: "Effective genome size used by MACS2. It can be numeric or a shortcuts:'hs' for human (2.7e9), 'mm' for mouse (1.87e9), 'ce' for C. elegans (9e7) and 'dm' for fruitfly (1.2e8), Default:hs"
outputs:
  - id: "#qc_count_raw_reads_read1"
    source: "#qc.output_count_raw_reads_read1"
    description: "Raw read counts of fastq files for read 1 after QC"
    type:
      type: array
      items: File
  - id: "#qc_count_raw_reads_read2"
    source: "#qc.output_count_raw_reads_read2"
    description: "Raw read counts of fastq files for read 2 after QC"
    type:
      type: array
      items: File
  - id: "#qc_diff_counts_read1"
    source: "#qc.output_diff_counts_read1"
    description: "Diff file between number of raw reads and number of reads counted by FASTQC, read 1"
    type:
      type: array
      items: File
  - id: "#qc_diff_counts_read2"
    source: "#qc.output_diff_counts_read2"
    description: "Diff file between number of raw reads and number of reads counted by FASTQC, read 2"
    type:
      type: array
      items: File
  - id: "#qc_fastqc_report_files_read1"
    source: "#qc.output_fastqc_report_files_read1"
    description: "FastQC reports in zip format for paired read 1"
    type:
      type: array
      items: File
  - id: "#qc_fastqc_report_files_read2"
    source: "#qc.output_fastqc_report_files_read2"
    description: "FastQC reports in zip format for paired read 2"
    type:
      type: array
      items: File
  - id: "#qc_fastqc_data_files_read1"
    source: "#qc.output_fastqc_data_files_read1"
    description: "FastQC data files for paired read 1"
    type:
      type: array
      items: File
  - id: "#qc_fastqc_data_files_read2"
    source: "#qc.output_fastqc_data_files_read2"
    description: "FastQC data files for paired read 2"
    type:
      type: array
      items: File
  - id: "#trimm_raw_counts_read1"
    source: "#trimm.output_trimmed_read1_fastq_read_count"
    description: "Raw read counts for R1 of fastq files after TRIMM"
    type:
      type: array
      items: File
  - id: "#trimm_raw_counts_read2"
    source: "#trimm.output_trimmed_read2_fastq_read_count"
    description: "Raw read counts for R2 of fastq files after TRIMM"
    type:
      type: array
      items: File
  - id: "#trimm_fastq_files_read1"
    source: "#trimm.output_data_fastq_read1_trimmed_files"
    description: "FASTQ files after trimming step"
    type:
      type: array
      items: File
  - id: "#trimm_fastq_files_read2"
    source: "#trimm.output_data_fastq_read2_trimmed_files"
    description: "FASTQ files after trimming step"
    type:
      type: array
      items: File
  - id: "#map_mark_duplicates_files"
    source: "#map.output_picard_mark_duplicates_files"
    description: "Summary of duplicates removed with Picard tool MarkDuplicates (for multiple reads aligned to the same positions"
    type:
      type: array
      items: File
  - id: "#map_dedup_bam_files"
    source: "#map.output_data_sorted_dedup_bam_files"
    description: "Filtered BAM files (post-processing end point)"
    type:
      type: array
      items: File
  - id: "#map_dedup_bam_index_files"
    source: "#map.output_index_dedup_bam_files"
    description: "Filtered BAM index files"
    type:
      type: array
      items: File
  - id: "#map_pbc_files"
    source: "#map.output_pbc_files"
    description: "PCR Bottleneck Coefficient files (used to flag samples when pbc<0.5)"
    type:
      type: array
      items: File
  - id: "#map_preseq_c_curve_files"
    source: "#map.output_preseq_c_curve_files"
    description: "Preseq c_curve output files"
    type:
      type: array
      items: File
  - id: "#map_preseq_percentage_uniq_reads"
    source: "#map.output_percentage_uniq_reads"
    description: "Preseq percentage of uniq reads"
    type:
      type: array
      items: File
  - id: "#map_read_count_mapped"
    source: "#map.output_read_count_mapped"
    description: "Read counts of the mapped BAM files"
    type:
      type: array
      items: File
  - id: "#map_bowtie_log_files"
    source: "#map.output_bowtie_log"
    description: "Bowtie log file with mapping stats"
    type:
      type: array
      items: File
  - id: "#peak_call_spp_x_cross_corr"
    source: "#peak_call.output_spp_x_cross_corr"
    description: "SPP strand cross correlation summary"
    type:
      type: array
      items: File
  - id: "#peak_call_spp_x_cross_corr_plot"
    source: "#peak_call.output_spp_cross_corr_plot"
    description: "SPP strand cross correlation plot"
    type:
      type: array
      items: File
  - id: "#peak_call_peak_xls_file"
    source: "#peak_call.output_peak_xls_file"
    description: "Peak calling report file"
    type:
      type: array
      items: File
  - id: "#peak_call_filtered_read_count_file"
    source: "#peak_call.output_filtered_read_count_file"
    description: "Filtered read count after peak calling"
    type:
      type: array
      items: File
  - id: "#peak_call_read_in_peak_count_within_replicate"
    source: "#peak_call.output_read_in_peak_count_within_replicate"
    description: "Peak counts within replicate"
    type:
      type: array
      items: File
  - id: "#peak_call_peak_count_within_replicate"
    source: "#peak_call.output_peak_count_within_replicate"
    description: "Peak counts within replicate"
    type:
      type: array
      items: File
  - id: "#peak_call_peak_file"
    source: "#peak_call.output_peak_file"
    description: "Peaks in ENCODE Peak file format"
    type:
      type: array
      items: File
  - id: "#peak_call_peak_summits_file"
    source: "#peak_call.output_peak_summits_file"
    description: "Peaks summits in bedfile format"
    type:
      type: array
      items: File
  - id: "#peak_call_extended_peak_file"
    source: "#peak_call.output_extended_peak_file"
    description: "Extended fragment peaks in ENCODE Peak file format"
    type:
      type: array
      items: File
  - id: "#peak_call_peak_bigbed_file"
    source: "#peak_call.output_peak_bigbed_file"
    description: "Peaks in bigBed format"
    type:
      type: array
      items: File
  - id: "#output_unpaired_peak_file"
    source: "#peak_call.output_unpaired_peak_file"
    description: "peakshift/phantomPeak results file using each paired mate independently"
    type:
      type: array
      items: File
  - id: "#output_unpaired_peak_bigbed_file"
    source: "#peak_call.output_unpaired_peak_bigbed_file"
    description: "peakshift/phantomPeak results bigbed file using each paired mate independently"
    type:
      type: array
      items: File
  - id: "#output_unpaired_peak_summits_file"
    source: "#peak_call.output_unpaired_peak_summits_file"
    description: "File containing peak summits using each paired mate independently"
    type:
      type: array
      items: File
  - id: "#output_unpaired_extended_peak_file"
    source: "#peak_call.output_unpaired_extended_peak_file"
    description: "peakshift/phantomPeak extended fragment results file using each paired mate independently"
    type:
      type: array
      items: File
  - id: "#output_unpaired_peak_xls_file"
    source: "#peak_call.output_unpaired_peak_xls_file"
    description: "Peak calling report file (*_peaks.xls file produced by MACS2) using each paired mate independently"
    type:
      type: array
      items: File
  - id: "#output_unpaired_filtered_read_count_file"
    source: "#peak_call.output_unpaired_filtered_read_count_file"
    description: "Filtered read count reported by MACS2 using each paired mate independently"
    type:
      type: array
      items: File
  - id: "#output_unpaired_peak_count_within_replicate"
    source: "#peak_call.output_unpaired_peak_count_within_replicate"
    description: "Peak counts within replicate using each paired mate independently"
    type:
      type: array
      items: File
  - id: "#quant_bigwig_raw_files"
    source: "#quant.bigwig_raw_files"
    description: "Raw reads bigWig (signal) files"
    type:
      type: array
      items: File
  - id: "#quant_bigwig_norm_files"
    source: "#quant.bigwig_norm_files"
    description: "Normalized reads bigWig (signal) files"
    type:
      type: array
      items: File
  - id: "#quant_bigwig_extended_files"
    source: "#quant.bigwig_extended_files"
    description: "Fragment extended reads bigWig (signal) files"
    type:
      type: array
      items: File
  - id: "#quant_bigwig_extended_norm_files"
    source: "#quant.bigwig_extended_norm_files"
    description: "Normalized fragment extended reads bigWig (signal) files"
    type:
      type: array
      items: File
steps:
  - id: "#qc"
    run: {$import: "01-qc-pe.cwl" }
    inputs:
      - { id: "#qc.input_read1_fastq_files", source: "#input_fastq_read1_files" }
      - { id: "#qc.input_read2_fastq_files", source: "#input_fastq_read2_files" }
      - { id: "#qc.default_adapters_file", source: "#default_adapters_file" }
      - { id: "#qc.nthreads", source: "#nthreads_qc" }
    outputs:
      - { id:  "#qc.output_count_raw_reads_read1" }
      - { id:  "#qc.output_count_raw_reads_read2" }
      - { id:  "#qc.output_diff_counts_read1" }
      - { id:  "#qc.output_diff_counts_read2" }
      - { id:  "#qc.output_fastqc_report_files_read1" }
      - { id:  "#qc.output_fastqc_report_files_read2" }
      - { id:  "#qc.output_fastqc_data_files_read1" }
      - { id:  "#qc.output_fastqc_data_files_read2" }
      - { id:  "#qc.output_custom_adapters_read1" }
      - { id:  "#qc.output_custom_adapters_read2" }
  - id: "#trimm"
    run: {$import: "02-trim-pe.cwl" }
    inputs:
      - { id: "#trimm.input_read1_fastq_files", source: "#input_fastq_read1_files" }
      - { id: "#trimm.input_read2_fastq_files", source: "#input_fastq_read2_files" }
      - { id: "#trimm.input_read1_adapters_files", source: "#qc.output_custom_adapters_read1" }
      - { id: "#trimm.input_read2_adapters_files", source: "#qc.output_custom_adapters_read2" }
      - { id: "#trimm.nthreads", source: "#nthreads_trimm" }
      - { id: "#trimm.trimmomatic_jar_path", source: "#trimmomatic_jar_path" }
      - { id: "#trimm.trimmomatic_java_opts", source: "#trimmomatic_java_opts" }
    outputs:
      - { id:  "#trimm.output_data_fastq_read1_trimmed_files" }
      - { id:  "#trimm.output_data_fastq_read2_trimmed_files" }
      - { id:  "#trimm.output_trimmed_read1_fastq_read_count" }
      - { id:  "#trimm.output_trimmed_read2_fastq_read_count" }
  - id: "#map"
    run: {$import: "03-map-pe.cwl" }
    inputs:
      - { id: "#map.input_fastq_read1_files", source: "#trimm.output_data_fastq_read1_trimmed_files" }
      - { id: "#map.input_fastq_read2_files", source: "#trimm.output_data_fastq_read2_trimmed_files" }
      - { id: "#map.genome_ref_first_index_file", source: "#genome_ref_first_index_file" }
      - { id: "#map.genome_sizes_file", source: "#genome_sizes_file" }
      - { id: "#map.nthreads", source: "#nthreads_map" }
      - { id: "#map.picard_jar_path", source: "#picard_jar_path" }
      - { id: "#map.picard_java_opts", source: "#picard_java_opts" }
    outputs:
      - { id:  "#map.output_data_sorted_dedup_bam_files" }
      - { id:  "#map.output_index_dedup_bam_files" }
      - { id:  "#map.output_picard_mark_duplicates_files" }
      - { id:  "#map.output_pbc_files" }
      - { id:  "#map.output_bowtie_log" }
      - { id:  "#map.output_preseq_c_curve_files" }
      - { id:  "#map.output_percentage_uniq_reads" }
      - { id:  "#map.output_read_count_mapped" }
  - id: "#peak_call"
    run: {$import: "04-peakcall-pe.cwl" }
    inputs:
      - { id: "#peak_call.input_bam_files", source: "#map.output_data_sorted_dedup_bam_files" }
      - { id: "#peak_call.input_bam_format", valueFrom: "BAMPE" }
      - { id: "#peak_call.genome_effective_size", source: "#genome_effective_size" }
      - { id: "#peak_call.input_genome_sizes", source: "#genome_sizes_file" }
      - { id: "#peak_call.as_narrowPeak_file", source: "#as_narrowPeak_file" }
      - { id: "#peak_call.nthreads", source: "#nthreads_peakcall" }
    outputs:
      - { id: "#peak_call.output_spp_x_cross_corr" }
      - { id: "#peak_call.output_spp_cross_corr_plot" }
      - { id: "#peak_call.output_read_in_peak_count_within_replicate" }
      - { id: "#peak_call.output_peak_file" }
      - { id: "#peak_call.output_peak_bigbed_file" }
      - { id: "#peak_call.output_peak_summits_file" }
      - { id: "#peak_call.output_extended_peak_file" }
      - { id: "#peak_call.output_peak_xls_file" }
      - { id: "#peak_call.output_filtered_read_count_file" }
      - { id: "#peak_call.output_peak_count_within_replicate" }
      - { id: "#peak_call.output_unpaired_peak_file" }
      - { id: "#peak_call.output_unpaired_peak_bigbed_file" }
      - { id: "#peak_call.output_unpaired_peak_summits_file" }
      - { id: "#peak_call.output_unpaired_extended_peak_file" }
      - { id: "#peak_call.output_unpaired_peak_xls_file" }
      - { id: "#peak_call.output_unpaired_filtered_read_count_file" }
      - { id: "#peak_call.output_unpaired_peak_count_within_replicate" }
  - id: "#quant"
    run: {$import: "05-quantification.cwl" }
    inputs:
      - { id: "#quant.input_bam_files", source: "#map.output_data_sorted_dedup_bam_files" }
      - { id: "#quant.input_pileup_bedgraphs", source: "#peak_call.output_extended_peak_file" }
      - { id: "#quant.input_peak_xls_files", source: "#peak_call.output_peak_xls_file" }
      - { id: "#quant.input_read_count_dedup_files", source: "#peak_call.output_filtered_read_count_file" }
      - { id: "#quant.input_genome_sizes", source: "#genome_sizes_file" }
      - { id: "#quant.nthreads", source: "#nthreads_quant" }
    outputs:
      - { id: "#quant.bigwig_raw_files" }
      - { id: "#quant.bigwig_norm_files" }
      - { id: "#quant.bigwig_extended_files" }
      - { id: "#quant.bigwig_extended_norm_files" }