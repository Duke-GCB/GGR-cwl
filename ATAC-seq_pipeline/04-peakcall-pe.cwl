#!/usr/bin/env cwl-runner
cwlVersion: "cwl:draft-3"
class: Workflow
description: "ATAC-seq 04 quantification, samples: ."
requirements:
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
inputs:
  - id: "#input_bam_files"
    type:
      type: array
      items: File
  - id: "#input_bam_format"
    type: string
    description: "BAM or BAMPE for single-end and paired-end reads respectively (default: BAM)"
    default: "BAMPE"
  - id: "#genome_effective_size"
    type: string
    default: "hs"
    description: "Effective genome size used by MACS2. It can be numeric or a shortcuts:'hs' for human (2.7e9), 'mm' for mouse (1.87e9), 'ce' for C. elegans (9e7) and 'dm' for fruitfly (1.2e8), Default:hs"
  - id: "#input_genome_sizes"
    type: File
    description: "Two column tab-delimited file with chromosome size information"
  - id: "#as_narrowPeak_file"
    type: File
    description: "Definition narrowPeak file in AutoSql format (used in bedToBigBed)"
  - id: "#nthreads"
    type: int
    default: 1
outputs:
  - id: "#output_spp_x_cross_corr"
    source: "#spp.output_spp_cross_corr"
    description: "peakshift/phantomPeak results file"
    type:
      type: array
      items: File
  - id: "#output_spp_cross_corr_plot"
    source: "#spp.output_spp_cross_corr_plot"
    description: "peakshift/phantomPeak results file"
    type:
      type: array
      items: File
  - id: "#output_peak_file"
    source: "#peak-calling.output_peak_file"
    description: "peakshift/phantomPeak results file"
    type:
      type: array
      items: File
  - id: "#output_peak_bigbed_file"
    source: "#peaks-bed-to-bigbed.bigbed"
    description: "Peaks in bigBed format"
    type:
      type: array
      items: File
  - id: "#output_peak_summits_file"
    source: "#peak-calling.output_peak_summits_file"
    description: "File containing peak summits"
    type:
      type: array
      items: File
  - id: "#output_extended_peak_file"
    source: "#peak-calling.output_ext_frag_bdg_file"
    description: "peakshift/phantomPeak extended fragment results file"
    type:
      type: array
      items: File
  - id: "#output_peak_xls_file"
    source: "#peak-calling.output_peak_xls_file"
    description: "Peak calling report file (*_peaks.xls file produced by MACS2)"
    type:
      type: array
      items: File
  - id: "#output_filtered_read_count_file"
    source: "#count-reads-filtered.read_count_file"
    description: "Filtered read count reported by MACS2"
    type:
      type: array
      items: File
  - id: "#output_peak_count_within_replicate"
    source: "#count-peaks.output_counts"
    description: "Peak counts within replicate"
    type:
      type: array
      items: File
  - id: "#output_read_in_peak_count_within_replicate"
    source: "#extract-count-reads-in-peaks.output_read_count"
    description: "Reads peak counts within replicate"
    type:
      type: array
      items: File
  - id: "#output_unpaired_peak_file"
    source: "#peak-calling-unpaired.output_peak_file"
    description: "peakshift/phantomPeak results file using each paired mate independently"
    type:
      type: array
      items: File
  - id: "#output_unpaired_peak_bigbed_file"
    source: "#peaks-bed-to-bigbed-unpaired.bigbed"
    description: "Peaks in bigBed format using each paired mate independently"
    type:
      type: array
      items: File
  - id: "#output_unpaired_peak_summits_file"
    source: "#peak-calling-unpaired.output_peak_summits_file"
    description: "File containing peak summits using each paired mate independently"
    type:
      type: array
      items: File
  - id: "#output_unpaired_extended_peak_file"
    source: "#peak-calling-unpaired.output_ext_frag_bdg_file"
    description: "peakshift/phantomPeak extended fragment results file using each paired mate independently"
    type:
      type: array
      items: File
  - id: "#output_unpaired_peak_xls_file"
    source: "#peak-calling-unpaired.output_peak_xls_file"
    description: "Peak calling report file (*_peaks.xls file produced by MACS2) using each paired mate independently"
    type:
      type: array
      items: File
  - id: "#output_unpaired_filtered_read_count_file"
    source: "#count-reads-filtered-unpaired.read_count_file"
    description: "Filtered read count reported by MACS2 using each paired mate independently"
    type:
      type: array
      items: File
  - id: "#output_unpaired_peak_count_within_replicate"
    source: "#count-peaks-unpaired.output_counts"
    description: "Peak counts within replicate using each paired mate independently"
    type:
      type: array
      items: File
steps:
  - id: "#spp"
    run: {$import: "../spp/spp.cwl"}
    scatter:
      - "#spp.input_bam"
    scatterMethod: dotproduct
    inputs:
      - id: "#spp.input_bam"
        source: "#input_bam_files"
      - id: "#spp.savp"
        valueFrom: $(true)
      - id: "#spp.nthreads"
        source: "#nthreads"
    outputs:
      - id: "#spp.output_spp_cross_corr"
      - id: "#spp.output_spp_cross_corr_plot"
  - id: "#extract-peak-frag-length"
    run: {$import: "../spp/extract-best-frag-length.cwl"}
    scatter: "#extract-peak-frag-length.input_spp_txt_file"
    inputs:
      - id: "#extract-peak-frag-length.input_spp_txt_file"
        source: "#spp.output_spp_cross_corr"
    outputs:
      - id: "#extract-peak-frag-length.output_best_frag_length"
  - id: "#peak-calling"
    run: {$import: "../peak_calling/macs2-callpeak.cwl"}
    scatter:
      - "#peak-calling.treatment"
    scatterMethod: dotproduct
    inputs:
      - id: "#peak-calling.treatment"
        source: "#input_bam_files"
        valueFrom: $([self])
      - id: "#peak-calling.bdg"
        valueFrom: $(true)
      - id: "#peak-calling.format"
        source: "#input_bam_format"
      - id: "#peak-calling.q"
        valueFrom: $(0.1)
      - id: "#peak-calling.g"
        source: "#genome_effective_size"
    outputs:
      - id: "#peak-calling.output_peak_file"
      - id: "#peak-calling.output_peak_summits_file"
      - id: "#peak-calling.output_ext_frag_bdg_file"
      - id: "#peak-calling.output_peak_xls_file"
  - id: "#count-reads-filtered"
    run: {$import: "../peak_calling/count-reads-after-filtering.cwl"}
    scatter: "#count-reads-filtered.peak_xls_file"
    inputs:
      - id: "#count-reads-filtered.peak_xls_file"
        source: "#peak-calling.output_peak_xls_file"
    outputs:
      - id: "#count-reads-filtered.read_count_file"
  - id: "#count-peaks"
    run: {$import: "../utils/count-with-output-suffix.cwl"}
    scatter: "#count-peaks.input_file"
    inputs:
      - id: "#count-peaks.input_file"
        source: "#peak-calling.output_peak_file"
      - id: "#count-peaks.output_suffix"
        valueFrom: ".peak_count.within_replicate.txt"
    outputs:
      - id: "#count-peaks.output_counts"
  - id: "#filter-reads-in-peaks"
    run: {$import: "../peak_calling/samtools-filter-in-bedfile.cwl"}
    scatter:
      - "#filter-reads-in-peaks.input_bam_file"
      - "#filter-reads-in-peaks.input_bedfile"
    scatterMethod: dotproduct
    inputs:
      - id: "#filter-reads-in-peaks.input_bam_file"
        source: "#input_bam_files"
      - id: "#filter-reads-in-peaks.input_bedfile"
        source: "#peak-calling.output_peak_file"
    outputs:
      - id: "#filter-reads-in-peaks.filtered_file"
  - id: "#extract-count-reads-in-peaks"
    run: {$import: "../peak_calling/samtools-extract-number-mapped-reads.cwl"}
    scatter: "#extract-count-reads-in-peaks.input_bam_file"
    inputs:
      - id: "#extract-count-reads-in-peaks.input_bam_file"
        source: "#filter-reads-in-peaks.filtered_file"
      - id: "#extract-count-reads-in-peaks.output_suffix"
        valueFrom: ".read_count.within_replicate.txt"
    outputs:
      - id: "#extract-count-reads-in-peaks.output_read_count"
  - id: "#trunk-peak-score"
    run: "../utils/trunk-peak-score.cwl"
    scatter: "#trunk-peak-score.peaks"
    inputs:
      - id: "#trunk-peak-score.peaks"
        source: "#peak-calling.output_peak_file"
    outputs:
      - id: "#trunk-peak-score.trunked_scores_peaks"
  - id: "#peaks-bed-to-bigbed"
    run: "../quant/bedToBigBed.cwl"
    scatter: "#peaks-bed-to-bigbed.bed"
    inputs:
      - id: "#peaks-bed-to-bigbed.bed"
        source: "#trunk-peak-score.trunked_scores_peaks"
      - id: "#peaks-bed-to-bigbed.genome_sizes"
        source: "#input_genome_sizes"
      - id: "#peaks-bed-to-bigbed.type"
        valueFrom: "bed6+4"
      - id: "#peaks-bed-to-bigbed.as"
        source: "#as_narrowPeak_file"
    outputs:
      - id: "#peaks-bed-to-bigbed.bigbed"
  - id: "#sort-bam-by-name"
    run: {$import: "../map/samtools-sort.cwl"}
    scatter:
      - "#sort-bam-by-name.input_file"
    inputs:
      - id: "#sort-bam-by-name.input_file"
        source: "#input_bam_files"
      - id: "#sort-bam-by-name.nthreads"
        source: "#nthreads"
      - id: "#sort-bam-by-name.n"
        valueFrom: $(true)
    outputs:
      - id: "#sort-bam-by-name.sorted_file"
  - id: "#bedtools_bamtobed"
    run: {$import: "../map/bedtools-bamtobed.cwl"}
    scatter: "#bedtools_bamtobed.bam"
    inputs:
      - id: "#bedtools_bamtobed.bam"
        source: "#sort-bam-by-name.sorted_file"
      - id: "#bedtools_bamtobed.bedpe"
        valueFrom: $(true)
    outputs:
      - id: "#bedtools_bamtobed.output_bedfile"
  - id: "#unpair_bedpe"
    run: {$import: "../peak_calling/bedpe-to-bed.cwl"}
    scatter: "#unpair_bedpe.bedpe"
    inputs:
      - id: "#unpair_bedpe.bedpe"
        source: "#bedtools_bamtobed.output_bedfile"
    outputs:
      - id: "#unpair_bedpe.bed"
  - id: "#peak-calling-unpaired"
    run: {$import: "../peak_calling/macs2-callpeak.cwl"}
    scatter:
      - "#peak-calling-unpaired.treatment"
    scatterMethod: dotproduct
    inputs:
      - id: "#peak-calling-unpaired.treatment"
        source: "#unpair_bedpe.bed"
        valueFrom: $([self])
      - id: "#peak-calling-unpaired.bdg"
        valueFrom: $(true)
      - id: "#peak-calling-unpaired.format"
        valueFrom: "BED"
      - id: "#peak-calling-unpaired.q"
        valueFrom: $(0.1)
      - id: "#peak-calling-unpaired.g"
        source: "#genome_effective_size"
      - id: "#peak-calling-unpaired.nomodel"
        valueFrom: $(true)
      - id: "#peak-calling-unpaired.shift"
        valueFrom: $(-100)
      - id: "#peak-calling-unpaired.extsize"
        valueFrom: $(200)
    outputs:
      - id: "#peak-calling-unpaired.output_peak_file"
      - id: "#peak-calling-unpaired.output_peak_summits_file"
      - id: "#peak-calling-unpaired.output_ext_frag_bdg_file"
      - id: "#peak-calling-unpaired.output_peak_xls_file"
  - id: "#count-reads-filtered-unpaired"
    run: {$import: "../peak_calling/count-reads-after-filtering.cwl"}
    scatter: "#count-reads-filtered-unpaired.peak_xls_file"
    inputs:
      - id: "#count-reads-filtered-unpaired.peak_xls_file"
        source: "#peak-calling-unpaired.output_peak_xls_file"
    outputs:
      - id: "#count-reads-filtered-unpaired.read_count_file"
  - id: "#count-peaks-unpaired"
    run: {$import: "../utils/count-with-output-suffix.cwl"}
    scatter: "#count-peaks-unpaired.input_file"
    inputs:
      - id: "#count-peaks-unpaired.input_file"
        source: "#peak-calling-unpaired.output_peak_file"
      - id: "#count-peaks-unpaired.output_suffix"
        valueFrom: ".peak_count.within_replicate.txt"
    outputs:
      - id: "#count-peaks-unpaired.output_counts"
  - id: "#filter-reads-in-peaks-unpaired"
    run: {$import: "../peak_calling/samtools-filter-in-bedfile.cwl"}
    scatter:
      - "#filter-reads-in-peaks-unpaired.input_bam_file"
      - "#filter-reads-in-peaks-unpaired.input_bedfile"
    scatterMethod: dotproduct
    inputs:
      - id: "#filter-reads-in-peaks-unpaired.input_bam_file"
        source: "#input_bam_files"
      - id: "#filter-reads-in-peaks-unpaired.input_bedfile"
        source: "#peak-calling-unpaired.output_peak_file"
    outputs:
      - id: "#filter-reads-in-peaks-unpaired.filtered_file"
  - id: "#trunk-peak-score-unpaired"
    run: "../utils/trunk-peak-score.cwl"
    scatter: "#trunk-peak-score-unpaired.peaks"
    inputs:
      - id: "#trunk-peak-score-unpaired.peaks"
        source: "#peak-calling-unpaired.output_peak_file"
    outputs:
      - id: "#trunk-peak-score-unpaired.trunked_scores_peaks"
  - id: "#peaks-bed-to-bigbed-unpaired"
    run: "../quant/bedToBigBed.cwl"
    scatter: "#peaks-bed-to-bigbed-unpaired.bed"
    inputs:
      - id: "#peaks-bed-to-bigbed-unpaired.bed"
        source: "#trunk-peak-score-unpaired.trunked_scores_peaks"
      - id: "#peaks-bed-to-bigbed-unpaired.genome_sizes"
        source: "#input_genome_sizes"
      - id: "#peaks-bed-to-bigbed-unpaired.type"
        valueFrom: "bed6+4"
      - id: "#peaks-bed-to-bigbed-unpaired.as"
        source: "#as_narrowPeak_file"
    outputs:
      - id: "#peaks-bed-to-bigbed-unpaired.bigbed"