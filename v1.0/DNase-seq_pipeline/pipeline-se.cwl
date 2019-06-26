 class: Workflow
 cwlVersion: v1.0
 doc: 'DNase-seq pipeline - reads: SE'
 requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
 inputs:
    genome_sizes_file:
      doc: Genome sizes tab-delimited file (used in samtools)
      type: File
    default_adapters_file:
      doc: Adapters file
      type: File
    nthreads_quant:
      doc: Number of threads required for the 05-quantification step
      type: int
    nthreads_peakcall:
      doc: Number of threads required for the 04-peakcall step
      type: int
    input_fastq_files:
      type: File[]
    ENCODE_blacklist_bedfile:
      doc: Bedfile containing ENCODE consensus blacklist regions to be excluded.
      type: File
    nthreads_map:
      doc: Number of threads required for the 03-map step
      type: int
    genome_ref_first_index_file:
      doc: '"First index file of Bowtie reference genome with extension 1.ebwt. \ (Note: the rest of the index files MUST be in the same folder)" '
      type: File
 steps:
    map:
      in:
        genome_sizes_file: genome_sizes_file
        ENCODE_blacklist_bedfile: ENCODE_blacklist_bedfile
        genome_ref_first_index_file: genome_ref_first_index_file
        nthreads: nthreads_map
        input_fastq_files: input_fastq_files
      run: 01-map-se.cwl
      out:
      - output_data_filtered_bam_files
      - output_pbc_files
      - output_bowtie_log
      - output_preseq_c_curve_files
      - original_fastq_read_count
      - output_read_count_mapped
      - output_read_count_mapped_filtered
      - output_percentage_uniq_reads
    quant:
      in:
        nthreads: nthreads_quant
        input_pileup_bedgraphs: peak_call/output_extended_narrowpeak_file
        input_bam_files: map/output_data_filtered_bam_files
        input_peak_xls_files: peak_call/output_peak_xls_file
        input_read_count_dedup_files: peak_call/output_read_in_peak_count_within_replicate
        input_genome_sizes: genome_sizes_file
      run: 03-quantification.cwl
      out:
      - bigwig_raw_files
      - bigwig_norm_files
      - bigwig_extended_files
      - bigwig_extended_norm_files
    peak_call:
      in:
        input_bam_format:
          valueFrom: BAM
        input_bam_files: map/output_data_filtered_bam_files
        nthreads: nthreads_peakcall
      run: 02-peakcall.cwl
      out:
      - output_spp_x_cross_corr
      - output_spp_cross_corr_plot
      - output_narrowpeak_file
      - output_extended_narrowpeak_file
      - output_peak_xls_file
      - output_filtered_read_count_file
      - output_peak_count_within_replicate
      - output_read_in_peak_count_within_replicate
 outputs:
    quant_bigwig_raw_files:
      doc: Raw reads bigWig (signal) files
      type: File[]
      outputSource: quant/bigwig_raw_files
    quant_bigwig_extended_files:
      doc: Fragment extended reads bigWig (signal) files
      type: File[]
      outputSource: quant/bigwig_extended_files
    map_preseq_c_curve_files:
      doc: Preseq c_curve output files
      type: File[]
      outputSource: map/output_preseq_c_curve_files
    map_percentage_uniq_reads:
      doc: Percentage of uniq reads from preseq c_curve output
      type: File[]
      outputSource: map/output_percentage_uniq_reads
    peak_call_spp_x_cross_corr:
      doc: SPP strand cross correlation summary
      type: File[]
      outputSource: peak_call/output_spp_x_cross_corr
    peak_call_peak_xls_file:
      doc: Peak calling report file
      type: File[]
      outputSource: peak_call/output_peak_xls_file
    map_filtered_bam_files:
      doc: Filtered BAM files (post-processing end point)
      type: File[]
      outputSource: map/output_data_filtered_bam_files
    peak_call_extended_narrowpeak_file:
      doc: Extended fragment peaks in narrowPeak file format
      type: File[]
      outputSource: peak_call/output_extended_narrowpeak_file
    peak_call_read_in_peak_count_within_replicate:
      doc: Peak counts within replicate
      type: File[]
      outputSource: peak_call/output_read_in_peak_count_within_replicate
    quant_bigwig_extended_norm_files:
      doc: Normalized fragment extended reads bigWig (signal) files
      type: File[]
      outputSource: quant/bigwig_extended_norm_files
    map_bowtie_log_files:
      doc: Bowtie log file with mapping stats
      type: File[]
      outputSource: map/output_bowtie_log
    map_pbc_files:
      doc: PCR Bottleneck Coefficient files (used to flag samples when pbc<0.5)
      type: File[]
      outputSource: map/output_pbc_files
    map_filtered_read_count:
      doc: Read counts of the mapped and filtered BAM files
      type: File[]
      outputSource: map/output_read_count_mapped_filtered
    peak_call_peak_count_within_replicate:
      doc: Peak counts within replicate
      type: File[]
      outputSource: peak_call/output_peak_count_within_replicate
    fastq_read_count:
      doc: Read counts of the (unprocessed) input fastq files
      type: File[]
      outputSource: map/original_fastq_read_count
    peak_call_narrowpeak_file:
      doc: Peaks in narrowPeak file format
      type: File[]
      outputSource: peak_call/output_narrowpeak_file
    peak_call_spp_x_cross_corr_plot:
      doc: SPP strand cross correlation plot
      type: File[]
      outputSource: peak_call/output_spp_cross_corr_plot
    peak_call_filtered_read_count_file:
      doc: Filtered read count after peak calling
      type: File[]
      outputSource: peak_call/output_filtered_read_count_file
    map_read_count:
      doc: Read counts of the mapped BAM files
      type: File[]
      outputSource: map/output_read_count_mapped
    quant_bigwig_norm_files:
      doc: Normalized reads bigWig (signal) files
      type: File[]
      outputSource: quant/bigwig_norm_files
