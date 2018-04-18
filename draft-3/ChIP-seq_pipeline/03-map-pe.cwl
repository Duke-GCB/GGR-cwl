#!/usr/bin/env cwl-runner
cwlVersion: "cwl:draft-3"
class: Workflow
description: "ChIP-seq 03 mapping - reads: PE"
requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
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
  - id: "#genome_ref_first_index_file"
    type: File
    description: "Bowtie first index files for reference genome (e.g. *1.ebwt). The rest of the files should be in the same folder."
  - id: "#genome_sizes_file"
    type: File
    description: "Genome sizes tab-delimited file (used in samtools)"
  - id: "#ENCODE_blacklist_bedfile"
    type: File
    description: "Bedfile containing ENCODE consensus blacklist regions to be excluded."
  - id: "#nthreads"
    type: int
    default: 1
  - id: "#picard_jar_path"
    type: string
    default: "/usr/picard/picard.jar"
    description: "Picard Java jar file"
  - id: "#picard_java_opts"
    type:
      - 'null'
      - string
    description: "JVM arguments should be a quoted, space separated list (e.g. \"-Xms128m -Xmx512m\")"
outputs:
  - id: "#output_picard_mark_duplicates_files"
    source: "#remove_duplicates.output_metrics_file"
    description: "Picard MarkDuplicates metrics files."
    type:
      type: array
      items: File
  - id: "#output_data_sorted_dedup_bam_files"
    source: "#sort_dedup_bams.sorted_file"
    description: "BAM files without duplicate reads."
    type:
      type: array
      items: File
  - id: "#output_index_dedup_bam_files"
    source: "#index_dedup_bams.index_file"
    description: "Index for BAM files without duplicate reads."
    type:
      type: array
      items: File
  - id: "#output_preseq_c_curve_files"
    source: "#preseq-c-curve.output_file"
    description: "Preseq c_curve output files."
    type:
      type: array
      items: File
#  - id: "#output_preseq_lc_extrap_files"
#    source: "#preseq-lc-extrap.output_file"
#    description: "Preseq lc_extrap output files."
#    type:
#      type: array
#      items: File
  - id: "#output_pbc_files"
    source: "#execute_pcr_bottleneck_coef.pbc_file"
    description: "PCR Bottleneck Coeficient files."
    type:
      type: array
      items: File
  - id: "#output_bowtie_log"
    source: "#bowtie-pe.output_bowtie_log"
    description: "Bowtie log file."
    type:
      type: array
      items: File
  - id: "#output_read_count_mapped"
    source: "#mapped_reads_count.output"
    description: "Read counts of the mapped BAM files"
    type:
      type: array
      items: File
  - id: "#output_read_count_mapped_filtered"
    source: "#mapped_filtered_reads_count.output_read_count"
    description: "Read counts of the mapped and filtered BAM files"
    type:
      type: array
      items: File
  - id: "#output_percentage_uniq_reads"
    source: "#percent_uniq_reads.output"
    description: "Percentage of uniq reads from preseq c_curve output"
    type:
      type: array
      items: File
steps:
  - id: "#extract_basename_1"
    run: {$import: "../utils/extract-basename.cwl" }
    scatter: "#extract_basename_1.input_file"
    inputs:
      - id: "#extract_basename_1.input_file"
        source: "#input_fastq_read1_files"
    outputs:
      - id: "#extract_basename_1.output_basename"
  - id: "#extract_basename_2"
    run: {$import: "../utils/remove-extension.cwl" }
    scatter: "#extract_basename_2.file_path"
    inputs:
      - id: "#extract_basename_2.file_path"
        source: "#extract_basename_1.output_basename"
    outputs:
      - id: "#extract_basename_2.output_path"
  - id: "#bowtie-pe"
    run: {$import: "../map/bowtie-pe.cwl"}
    scatter:
      - "#bowtie-pe.input_fastq_read1_file"
      - "#bowtie-pe.input_fastq_read2_file"
      - "#bowtie-pe.output_filename"
    scatterMethod: dotproduct
    inputs:
      - id: "#bowtie-pe.input_fastq_read1_file"
        source: "#input_fastq_read1_files"
      - id: "#bowtie-pe.input_fastq_read2_file"
        source: "#input_fastq_read2_files"
      - id: "#bowtie-pe.output_filename"
        source: "#extract_basename_2.output_path"
      - id: "#bowtie-pe.genome_ref_first_index_file"
        source: "#genome_ref_first_index_file"
      - id: "#bowtie-pe.nthreads"
        source: "#nthreads"
      - id: "#bowtie-pe.X"
        valueFrom: $(2000)
      - id: "#bowtie-pe.v"
        valueFrom: $(2)
    outputs:
      - id: "#bowtie-pe.output_aligned_file"
      - id: "#bowtie-pe.output_bowtie_log"
  - id: "#sam2bam"
    run: {$import: "../map/samtools2bam.cwl"}
    scatter:
      - "#sam2bam.input_file"
    inputs:
      - id: "#sam2bam.input_file"
        source: "#bowtie-pe.output_aligned_file"
      - id: "#sam2bam.nthreads"
        source: "#nthreads"
    outputs:
      - id: "#sam2bam.bam_file"
  - id: "#sort_bams"
    run: {$import: "../map/samtools-sort.cwl"}
    scatter:
      - "#sort_bams.input_file"
    inputs:
      - id: "#sort_bams.input_file"
        source: "#sam2bam.bam_file"
      - id: "#sort_bams.nthreads"
        source: "#nthreads"
    outputs:
      - id: "#sort_bams.sorted_file"
  - id: "#filter-unmapped"
    run: {$import: "../map/samtools-filter-unmapped.cwl"}
    scatter:
      - "#filter-unmapped.input_file"
      - "#filter-unmapped.output_filename"
    scatterMethod: dotproduct
    inputs:
      - id: "#filter-unmapped.input_file"
        source: "#sort_bams.sorted_file"
      - id: "#filter-unmapped.output_filename"
        source: "#extract_basename_2.output_path"
    outputs:
      - id: "#filter-unmapped.filtered_file"
  - id: "#filtered2sorted"
    run: {$import: "../map/samtools-sort.cwl"}
    scatter:
      - "#filtered2sorted.input_file"
    inputs:
      - id: "#filtered2sorted.input_file"
        source: "#filter-unmapped.filtered_file"
      - id: "#filtered2sorted.nthreads"
        source: "#nthreads"
    outputs:
      - id: "#filtered2sorted.sorted_file"
  - id: "#preseq-c-curve"
    run: {$import: "../map/preseq-c_curve.cwl"}
    scatter:
      - "#preseq-c-curve.input_sorted_file"
      - "#preseq-c-curve.output_file_basename"
    scatterMethod: dotproduct
    inputs:
      - id: "#preseq-c-curve.input_sorted_file"
        source: "#filtered2sorted.sorted_file"
      - id: "#preseq-c-curve.output_file_basename"
        source: "#extract_basename_2.output_path"
      - id: "#preseq-c-curve.pe"
        default: true
    outputs:
      - id: "#preseq-c-curve.output_file"
#  - id: "#preseq-lc-extrap"
#    run: {$import: "../map/preseq-lc_extrap.cwl"}
#    scatter:
#      - "#preseq-lc-extrap.input_sorted_file"
#      - "#preseq-lc-extrap.output_file_basename"
#    scatterMethod: dotproduct
#    inputs:
#      - id: "#preseq-lc-extrap.input_sorted_file"
#        source: "#filtered2sorted.sorted_file"
#      - id: "#preseq-lc-extrap.output_file_basename"
#        source: "#extract_basename_2.output_path"
#      - id: "#preseq-lc-extrap.s"
#        default: 100000
#      - id: "#preseq-lc-extrap.pe"
#        default: true
#    outputs:
#      - id: "#preseq-lc-extrap.output_file"
  - id: "#execute_pcr_bottleneck_coef"
    run: {$import: "../map/pcr-bottleneck-coef.cwl"}
    inputs:
      - id: "#execute_pcr_bottleneck_coef.input_bam_files"
        source: "#filtered2sorted.sorted_file"
      - id: "#execute_pcr_bottleneck_coef.genome_sizes"
        source: "#genome_sizes_file"
      - id: "#execute_pcr_bottleneck_coef.input_output_filenames"
        source: "#extract_basename_2.output_path"
    outputs:
      - id: "#execute_pcr_bottleneck_coef.pbc_file"
  - id: "#remove_duplicates"
    run: {$import: "../map/picard-MarkDuplicates.cwl"}
    scatter:
      - "#remove_duplicates.input_file"
      - "#remove_duplicates.output_filename"
    scatterMethod: dotproduct
    inputs:
      - id: "#remove_duplicates.input_file"
        source: "#filtered2sorted.sorted_file"
      - id: "#remove_duplicates.output_filename"
        source: "#extract_basename_2.output_path"
      - id: "#remove_duplicates.java_opts"
        source: "#picard_java_opts"
      - id: "#remove_duplicates.picard_jar_path"
        source: "#picard_jar_path"
    outputs:
      - id: "#remove_duplicates.output_metrics_file"
      - id: "#remove_duplicates.output_dedup_bam_file"
  - id: "#mapped_file_basename"
    run: {$import: "../utils/extract-basename.cwl" }
    scatter: "#mapped_file_basename.input_file"
    inputs:
      - id: "#mapped_file_basename.input_file"
        source: "#remove_duplicates.output_dedup_bam_file"
    outputs:
      - id: "#mapped_file_basename.output_basename"
  - id: "#remove_encode_blacklist"
    run: {$import: "../map/bedtools-intersect.cwl"}
    scatter:
      - "#remove_encode_blacklist.a"
      - "#remove_encode_blacklist.output_basename_file"
    scatterMethod: dotproduct
    inputs:
      - id: "#remove_encode_blacklist.v"
        default: true
      - id: "#remove_encode_blacklist.output_basename_file"
        source: "#mapped_file_basename.output_basename"
      - id: "#remove_encode_blacklist.a"
        source: "#remove_duplicates.output_dedup_bam_file"
      - id: "#remove_encode_blacklist.b"
        source: "#ENCODE_blacklist_bedfile"
    outputs:
      - id: "#remove_encode_blacklist.file_wo_blacklist_regions"
  - id: "#sort_dedup_bams"
    run: {$import: "../map/samtools-sort.cwl"}
    scatter:
      - "#sort_dedup_bams.input_file"
    inputs:
      - id: "#sort_dedup_bams.input_file"
        source: "#remove_encode_blacklist.file_wo_blacklist_regions"
      - id: "#sort_dedup_bams.nthreads"
        source: "#nthreads"
    outputs:
      - id: "#sort_dedup_bams.sorted_file"
  - id: "#index_dedup_bams"
    run: {$import: "../map/samtools-index.cwl"}
    scatter:
      - "#index_dedup_bams.input_file"
    inputs:
      - id: "#index_dedup_bams.input_file"
        source: "#sort_dedup_bams.sorted_file"
    outputs:
      - id: "#index_dedup_bams.index_file"
  - id: "#mapped_reads_count"
    run: {$import: "../map/bowtie-log-read-count.cwl"}
    scatter: "#mapped_reads_count.bowtie_log"
    inputs:
      - id: "#mapped_reads_count.bowtie_log"
        source: "#bowtie-pe.output_bowtie_log"
    outputs:
      - id: "#mapped_reads_count.output"
  - id: "#percent_uniq_reads"
    run: {$import: "../map/preseq-percent-uniq-reads.cwl"}
    scatter: "#percent_uniq_reads.preseq_c_curve_outfile"
    inputs:
      - id: "#percent_uniq_reads.preseq_c_curve_outfile"
        source: "#preseq-c-curve.output_file"
    outputs:
      - id: "#percent_uniq_reads.output"
  - id: "#mapped_filtered_reads_count"
    run: {$import: "../peak_calling/samtools-extract-number-mapped-reads.cwl"}
    scatter: "#mapped_filtered_reads_count.input_bam_file"
    inputs:
      - id: "#mapped_filtered_reads_count.input_bam_file"
        source: "#sort_dedup_bams.sorted_file"
      - id: "#mapped_filtered_reads_count.output_suffix"
        valueFrom: ".mapped_and_filtered.read_count.txt"
    outputs:
      - id: "#mapped_filtered_reads_count.output_read_count"