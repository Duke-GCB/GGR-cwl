#!/usr/bin/env cwl-runner
cwlVersion: "cwl:draft-3"
class: Workflow
description: "DNase-seq 01 mapping - reads: SE"
requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: StepInputExpressionRequirement
inputs:
  - id: "#input_fastq_files"
    type:
      type: array
      items: File
    description: "Input fastq files"
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
outputs:
  - id: "#output_data_filtered_bam_files"
    source: "#sort_filtered_bam.sorted_file"
    description: "BAM files without PCR artifact reads."
    type:
      type: array
      items: File
  - id: "#output_index_filtered_bam_files"
    source: "#index_filtered_bam.index_file"
    description: "Index for BAM files without PCR artifact reads."
    type:
      type: array
      items: File
  - id: "#output_preseq_c_curve_files"
    source: "#preseq-c-curve.output_file"
    description: "Preseq c_curve output files."
    type:
      type: array
      items: File
  - id: "#output_pbc_files"
    source: "#execute_pcr_bottleneck_coef.pbc_file"
    description: "PCR Bottleneck Coeficient files."
    type:
      type: array
      items: File
  - id: "#output_bowtie_log"
    source: "#bowtie-se.output_bowtie_log"
    description: "Bowtie log file."
    type:
      type: array
      items: File
  - id: "#original_fastq_read_count"
    source: "#count_fastq_reads.output_read_count"
    description: "Read counts of the (unprocessed) input fastq files"
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
  - id: "#extract_basename"
    run: {$import: "../utils/extract-basename.cwl" }
    scatter: "#extract_basename.input_file"
    inputs:
      - id: "#extract_basename.input_file"
        source: "#input_fastq_files"
    outputs:
      - id: "#extract_basename.output_basename"
  - id: "#count_fastq_reads"
    run: {$import: "../utils/count-fastq-reads.cwl" }
    scatter:
      - "#count_fastq_reads.input_fastq_file"
      - "#count_fastq_reads.input_basename"
    scatterMethod: dotproduct
    inputs:
      - id: "#count_fastq_reads.input_fastq_file"
        source: "#input_fastq_files"
      - id: "#count_fastq_reads.input_basename"
        source: "#extract_basename.output_basename"
    outputs:
      - id: "#count_fastq_reads.output_read_count"

  - id: "#bowtie-se"
    run: {$import: "../map/bowtie-se.cwl"}
    scatter:
      - "#bowtie-se.input_fastq_file"
      - "#bowtie-se.output_filename"
    scatterMethod: dotproduct
    inputs:
      - id: "#bowtie-se.input_fastq_file"
        source: "#input_fastq_files"
      - id: "#bowtie-se.output_filename"
        source: "#extract_basename.output_basename"
      - id: "#bowtie-se.genome_ref_first_index_file"
        source: "#genome_ref_first_index_file"
      - id: "#bowtie-se.trim3"
        valueFrom: $(30)
      - id: "#bowtie-se.seedlen"
        valueFrom: $(20)
      - id: "#bowtie-se.seedmms"
        valueFrom: $(1)
      - id: "#bowtie-se.nthreads"
        source: "#nthreads"
    outputs:
      - id: "#bowtie-se.output_aligned_file"
      - id: "#bowtie-se.output_bowtie_log"
  - id: "#sam2bam"
    run: {$import: "../map/samtools2bam.cwl"}
    scatter:
      - "#sam2bam.input_file"
    inputs:
      - id: "#sam2bam.input_file"
        source: "#bowtie-se.output_aligned_file"
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
  - id: "#preseq-c-curve"
    run: {$import: "../map/preseq-c_curve.cwl"}
    scatter:
      - "#preseq-c-curve.input_sorted_file"
      - "#preseq-c-curve.output_file_basename"
    scatterMethod: dotproduct
    inputs:
      - id: "#preseq-c-curve.input_sorted_file"
        source: "#sort_bams.sorted_file"
      - id: "#preseq-c-curve.output_file_basename"
        source: "#extract_basename.output_basename"
    outputs:
      - id: "#preseq-c-curve.output_file"
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
        source: "#extract_basename.output_basename"
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
  - id: "#execute_pcr_bottleneck_coef"
    run: {$import: "../map/pcr-bottleneck-coef.cwl"}
    inputs:
      - id: "#execute_pcr_bottleneck_coef.input_bam_files"
        source: "#filtered2sorted.sorted_file"
      - id: "#execute_pcr_bottleneck_coef.genome_sizes"
        source: "#genome_sizes_file"
      - id: "#execute_pcr_bottleneck_coef.input_output_filenames"
        source: "#extract_basename.output_basename"
    outputs:
      - id: "#execute_pcr_bottleneck_coef.pbc_file"
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
        source: "#extract_basename.output_basename"
      - id: "#remove_encode_blacklist.a"
        source: "#filtered2sorted.sorted_file"
      - id: "#remove_encode_blacklist.b"
        source: "#ENCODE_blacklist_bedfile"
    outputs:
      - id: "#remove_encode_blacklist.file_wo_blacklist_regions"
  - id: "#filter_pcr_artifacts"
    run: {$import: "../map/filter-pcr-artifacts.cwl"}
    inputs:
      - id: "#filter_pcr_artifacts.input_bam_files"
        source: "#remove_encode_blacklist.file_wo_blacklist_regions"
    outputs:
      - id: "#filter_pcr_artifacts.filtered_bedfile"

  - id: "#filtered_bed_to_bam"
    run: {$import: "../map/bedtools-bedtobam.cwl"}
    scatter:
      - "#filtered_bed_to_bam.i"
    inputs:
      - id: "#filtered_bed_to_bam.i"
        source: "#filter_pcr_artifacts.filtered_bedfile"
      - id: "#filtered_bed_to_bam.g"
        source: "#genome_sizes_file"
    outputs:
      - id: "#filtered_bed_to_bam.bam_file"
  - id: "#sort_filtered_bam"
    run: {$import: "../map/samtools-sort.cwl"}
    scatter:  "#sort_filtered_bam.input_file"
    inputs:
      - id: "#sort_filtered_bam.input_file"
        source: "#filtered_bed_to_bam.bam_file"
      - id: "#sort_filtered_bam.nthreads"
        source: "#nthreads"
    outputs:
      - id: "#sort_filtered_bam.sorted_file"
  - id: "#index_filtered_bam"
    run: {$import: "../map/samtools-index.cwl"}
    scatter:
      - "#index_filtered_bam.input_file"
    inputs:
      - id: "#index_filtered_bam.input_file"
        source: "#sort_filtered_bam.sorted_file"
    outputs:
      - id: "#index_filtered_bam.index_file"
  - id: "#mapped_reads_count"
    run: {$import: "../map/bowtie-log-read-count.cwl"}
    scatter: "#mapped_reads_count.bowtie_log"
    inputs:
      - id: "#mapped_reads_count.bowtie_log"
        source: "#bowtie-se.output_bowtie_log"
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
        source: "#sort_filtered_bam.sorted_file"
      - id: "#mapped_filtered_reads_count.output_suffix"
        valueFrom: ".mapped_and_filtered.read_count.txt"
    outputs:
      - id: "#mapped_filtered_reads_count.output_read_count"