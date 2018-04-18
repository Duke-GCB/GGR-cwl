#!/usr/bin/env cwl-runner
cwlVersion: "cwl:draft-3"
class: Workflow
description: "RNA-seq pipeline - reads: PE"
requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: StepInputExpressionRequirement
inputs:
  - id: "#input_fastq_read1_files"
    type: {type: array, items: File}
    description: "Input read1 fastq files"
  - id: "#input_fastq_read2_files"
    type: {type: array, items: File}
    description: "Input read2 fastq files"
  - id: "#default_adapters_file"
    type: File
    description: "Adapters file"
  - id: "#trimmomatic_jar_path"
    type: string
    description: "Trimmomatic Java jar file"
  - id: "#trimmomatic_java_opts"
    type: ['null', string]
    description: "JVM arguments should be a quoted, space separated list (e.g. \"-Xms128m -Xmx512m\")"
  - id: "#genome_sizes_file"
    type: File
    description: "Genome sizes tab-delimited file (used in samtools)"
  - id: "#sjdbOverhang"
    type: string
    description:  "Length of the genomic sequence around the annotated junction to be used in constructing the splice junctions database."
  - id: "#annotation_file"
    type: File
    description: "GTF annotation file"
  - id: "#genome_fasta_files"
    type: {type: array, items: File}
    description: "STAR genome generate - Genome FASTA file with all the genome sequences in FASTA format"
  - id: "#genomeDirFiles"
    type: {type: array, items: File}
    description: "STAR genome reference/indices files."
  - id: "#bamtools_forward_filter_file"
    type: File
    description: "JSON filter file for forward strand used in bamtools (see bamtools-filter command)"
  - id: "#bamtools_reverse_filter_file"
    type: File
    description: "JSON filter file for reverse strand used in bamtools (see bamtools-filter command)"
  - id: "#rsem_reference_files"
    type: {type: array, items: File}
    description: "RSEM genome reference files - generated with the rsem-prepare-reference command"
  - id: "#nthreads_qc"
    description: "Number of threads - qc."
    type: int
  - id: "#nthreads_trimm"
    description: "Number of threads - trim."
    type: int
  - id: "#nthreads_map"
    description: "Number of threads - map."
    type: int
  - id: "#nthreads_quant"
    description: "Number of threads - quantification."
    type: int
outputs:
  - id: "#output_fastqc_report_files_read1"
    source: "#qc.output_fastqc_report_files_read1"
    description: "FastQC reports in zip format for paired read 1"
    type: {type: array, items: File}
  - id: "#output_fastqc_data_files_read1"
    source: "#qc.output_fastqc_data_files_read1"
    description: "FastQC data files for paired read 1"
    type: {type: array, items: File}
  - id: "#output_custom_adapters_read1"
    source: "#qc.output_custom_adapters_read1"
    type: {type: array, items: File}
  - id: "#output_count_raw_reads_read1"
    source: "#qc.output_count_raw_reads_read1"
    type: {type: array, items: File}
  - id: "#output_diff_counts_read1"
    source: "#qc.output_diff_counts_read1"
    type: {type: array, items: File}
  - id: "#output_data_fastq_read1_trimmed_files"
    source: "#trim.output_data_fastq_read1_trimmed_files"
    description: "Trimmed fastq files for paired read 1"
    type: {type: array, items: File}
  - id: "#output_trimmed_read1_fastq_read_count"
    source: "#trim.output_trimmed_read1_fastq_read_count"
    description: "Trimmed read counts of paired read 1 fastq files"
    type: {type: array, items: File}
  - id: "#output_fastqc_report_files_read2"
    source: "#qc.output_fastqc_report_files_read2"
    description: "FastQC reports in zip format for paired read 2"
    type: {type: array, items: File}
  - id: "#output_fastqc_data_files_read2"
    source: "#qc.output_fastqc_data_files_read2"
    description: "FastQC data files for paired read 2"
    type: {type: array, items: File}
  - id: "#output_custom_adapters_read2"
    source: "#qc.output_custom_adapters_read2"
    type: {type: array, items: File}
  - id: "#output_count_raw_reads_read2"
    source: "#qc.output_count_raw_reads_read2"
    type: {type: array, items: File}
  - id: "#output_diff_counts_read2"
    source: "#qc.output_diff_counts_read2"
    type: {type: array, items: File}
  - id: "#output_data_fastq_read2_trimmed_files"
    source: "#trim.output_data_fastq_read2_trimmed_files"
    description: "Trimmed fastq files for paired read 2"
    type: {type: array, items: File}
  - id: "#output_trimmed_read2_fastq_read_count"
    source: "#trim.output_trimmed_read2_fastq_read_count"
    description: "Trimmed read counts of paired read 2 fastq files"
    type: {type: array, items: File}
  - id: "#star_aligned_unsorted_file"
    source: "#map.star_aligned_unsorted_file"
    description: "STAR mapped unsorted file."
    type: {type: array, items: File}
  - id: "#star_aligned_sorted_file"
    source: "#map.star_aligned_sorted_file"
    description: "STAR mapped unsorted file."
    type: {type: array, items: File}
  - id: "#star_aligned_sorted_index_file"
    source: "#map.star_aligned_sorted_index_file"
    description: "STAR mapped unsorted file."
    type: {type: array, items: File}
  - id: "#pcr_bottleneck_coef_file"
    source: "#map.pcr_bottleneck_coef_file"
    description: "PCR Bottleneck Coefficient"
    type: {type: array, items: File}
  - id: "#percentage_uniq_reads_star2"
    source: "#map.percentage_uniq_reads_star2"
    description: "Percentage of uniq reads from preseq c_curve output"
    type: {type: array, items: File}
  - id: "#star2_stat_files"
    source: "#map.star2_stat_files"
    description: "STAR pass-2 stat files."
    type: {type: array, items: ['null', {items: File, type: array}]}
  - id: "#star2_readspergene_file"
    source: "#map.star2_readspergene_file"
    description: "STAR pass-2 reads per gene counts file."
    type: ['null', {type: array, items: File}]
  - id: "#read_count_mapped_star2"
    source: "#map.read_count_mapped_star2"
    description: "Read counts of the mapped BAM files after STAR pass2"
    type: {type: array, items: File}
  - id: "#transcriptome_star_aligned_file"
    source: "#map.transcriptome_star_aligned_file"
    description: "STAR mapped unsorted file."
    type: {type: array, items: File}
#  - id: "#transcriptome_star_aligned_sorted_index_file"
#    source: "#map.transcriptome_star_aligned_sorted_index_file"
#    description: "STAR mapped unsorted file."
#    type: {type: array, items: File}
  - id: "#transcriptome_star_stat_files"
    source: "#map.transcriptome_star_stat_files"
    description: "STAR pass-2 aligned to transcriptome stat files."
    type: {type: array, items: ['null', {items: File, type: array}]}
  - id: "#read_count_transcriptome_mapped_star2"
    source: "#map.read_count_transcriptome_mapped_star2"
    description: "Read counts of the mapped to transcriptome BAM files after STAR pass1"
    type: {type: array, items: File}
  - id: "#featurecounts_counts"
    source: "#quant.featurecounts_counts"
    description: "Normalized fragment extended reads bigWig (signal) files"
    type: {type: array, items: File}
  - id: "#rsem_isoforms_files"
    source: "#quant.rsem_isoforms_files"
    description: "RSEM isoforms files"
    type: {type: array, items: File}
  - id: "#rsem_genes_files"
    source: "#quant.rsem_genes_files"
    description: "RSEM genes files"
    type: {type: array, items: File}
  - id: "#bam_plus_files"
    source: "#quant.bam_plus_files"
    description: "BAM files containing only reads in the forward (plus) strand."
    type: {type: array, items: File}
  - id: "#bam_minus_files"
    source: "#quant.bam_minus_files"
    description: "BAM files containing only reads in the reverse (minus) strand."
    type: {type: array, items: File}
  - id: "#index_bam_plus_files"
    source: "#quant.index_bam_plus_files"
    description: "Index files for BAM files containing only reads in the forward (plus) strand."
    type: {type: array, items: File}
  - id: "#index_bam_minus_files"
    source: "#quant.index_bam_minus_files"
    description: "Index files for BAM files containing only reads in the reverse (minus) strand."
    type: {type: array, items: File}
  - id: "#bw_raw_plus_files"
    source: "#quant.bw_raw_plus_files"
    description: "Raw bigWig files from BAM files containing only reads in the forward (plus) strand."
    type: {type: array, items: File}
  - id: "#bw_raw_minus_files"
    source: "#quant.bw_raw_minus_files"
    description: "Raw bigWig files from BAM files containing only reads in the reverse (minus) strand."
    type: {type: array, items: File}
  - id: "#bw_norm_plus_files"
    source: "#quant.bw_norm_plus_files"
    description: "Normalized by RPKM bigWig files from BAM files containing only reads in the forward (plus) strand."
    type: {type: array, items: File}
  - id: "#bw_norm_minus_files"
    source: "#quant.bw_norm_minus_files"
    description: "Normalized by RPKM bigWig files from BAM files containing only reads in the forward (plus) strand."
    type: {type: array, items: File}
steps:
  - id: "#qc"
    run: {$import: "01-qc-pe.cwl" }
    inputs:
      - { id: "#qc.input_fastq_read1_files", source: "#input_fastq_read1_files" }
      - { id: "#qc.input_fastq_read2_files", source: "#input_fastq_read2_files" }
      - { id: "#qc.default_adapters_file", source: "#default_adapters_file" }
      - { id: "#qc.nthreads", source: "#nthreads_qc" }
    outputs:
      - id: "#qc.output_fastqc_report_files_read1"
      - id: "#qc.output_fastqc_data_files_read1"
      - id: "#qc.output_custom_adapters_read1"
      - id: "#qc.output_count_raw_reads_read1"
      - id: "#qc.output_diff_counts_read1"
      - id: "#qc.output_fastqc_report_files_read2"
      - id: "#qc.output_fastqc_data_files_read2"
      - id: "#qc.output_custom_adapters_read2"
      - id: "#qc.output_count_raw_reads_read2"
      - id: "#qc.output_diff_counts_read2"
  - id: "#trim"
    run: {$import: "02-trim-pe.cwl" }
    inputs:
      - { id: "#trim.input_fastq_read1_files", source: "#input_fastq_read1_files" }
      - { id: "#trim.input_read1_adapters_files", source: "#qc.output_custom_adapters_read1" }
      - { id: "#trim.input_fastq_read2_files", source: "#input_fastq_read2_files" }
      - { id: "#trim.input_read2_adapters_files", source: "#qc.output_custom_adapters_read2" }
      - { id: "#trim.trimmomatic_jar_path", source: "#trimmomatic_jar_path" }
      - { id: "#trim.trimmomatic_java_opts", source: "#trimmomatic_java_opts" }
      - { id: "#trim.nthreads", source: "#nthreads_trimm" }
    outputs:
      - id: "#trim.output_data_fastq_read1_trimmed_files"
      - id: "#trim.output_trimmed_read1_fastq_read_count"
      - id: "#trim.output_data_fastq_read2_trimmed_files"
      - id: "#trim.output_trimmed_read2_fastq_read_count"
  - id: "#map"
    run: {$import: "03-map-pe-with-sjdb.cwl" }
    inputs:
      - { id: "#map.input_fastq_read1_files", source: "#trim.output_data_fastq_read1_trimmed_files" }
      - { id: "#map.input_fastq_read2_files", source: "#trim.output_data_fastq_read2_trimmed_files" }
      - { id: "#map.genome_sizes_file", source: "#genome_sizes_file" }
      - { id: "#map.genome_fasta_files", source: "#genome_fasta_files" }
      - { id: "#map.annotation_file", source: "#annotation_file" }
      - { id: "#map.sjdbOverhang", source: "#sjdbOverhang" }
      - { id: "#map.genomeDirFiles", source: "#genomeDirFiles" }
      - { id: "#map.nthreads", source: "#nthreads_map" }
    outputs:
      - id: "#map.star_aligned_unsorted_file"
      - id: "#map.star_aligned_sorted_file"
      - id: "#map.star_aligned_sorted_index_file"
      - id: "#map.star2_stat_files"
      - id: "#map.star2_readspergene_file"
      - id: "#map.read_count_mapped_star2"
      - id: "#map.transcriptome_star_aligned_file"
#      - id: "#map.transcriptome_star_aligned_sorted_index_file"
      - id: "#map.transcriptome_star_stat_files"
      - id: "#map.read_count_transcriptome_mapped_star2"
      - id: "#map.percentage_uniq_reads_star2"
      - id: "#map.pcr_bottleneck_coef_file"
  - id: "#quant"
    run: {$import: "04-quantification-pe-unstranded.cwl" }
    inputs:
      - { id: "#quant.input_bam_files", source: "#map.star_aligned_sorted_file" }
      - { id: "#quant.input_transcripts_bam_files", source: "#map.transcriptome_star_aligned_file" }
      - { id: "#quant.annotation_file", source: "#annotation_file" }
      - { id: "#quant.input_genome_sizes", source: "#genome_sizes_file" }
      - { id: "#quant.rsem_reference_files", source: "#rsem_reference_files" }
      - { id: "#quant.nthreads", source: "#nthreads_quant" }
      - { id: "#quant.bamtools_forward_filter_file", source: "#bamtools_forward_filter_file" }
      - { id: "#quant.bamtools_reverse_filter_file", source: "#bamtools_reverse_filter_file" }
    outputs:
      - id: "#quant.featurecounts_counts"
      - id: "#quant.rsem_isoforms_files"
      - id: "#quant.rsem_genes_files"
      - id: "#quant.bam_plus_files"
      - id: "#quant.bam_minus_files"
      - id: "#quant.index_bam_plus_files"
      - id: "#quant.index_bam_minus_files"
      - id: "#quant.bw_raw_plus_files"
      - id: "#quant.bw_raw_minus_files"
      - id: "#quant.bw_norm_plus_files"
      - id: "#quant.bw_norm_minus_files"