 class: Workflow
 cwlVersion: v1.0
 doc: 'DNase-seq 01 mapping - reads: SE'
 requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: StepInputExpressionRequirement
 inputs:
    genome_sizes_file:
      doc: Genome sizes tab-delimited file (used in samtools)
      type: File
    ENCODE_blacklist_bedfile:
      doc: Bedfile containing ENCODE consensus blacklist regions to be excluded.
      type: File
    genome_ref_first_index_file:
      doc: Bowtie first index files for reference genome (e.g. *1.ebwt). The rest of the files should be in the same folder.
      type: File
    nthreads:
      default: 1
      type: int
    input_fastq_files:
      doc: Input fastq files
      type: File[]
 steps:
    filtered2sorted:
      run: ../map/samtools-sort.cwl
      in:
        nthreads: nthreads
        input_file: filter-unmapped/filtered_file
      scatter:
      - input_file
      out:
      - sorted_file
    mapped_filtered_reads_count:
      run: ../peak_calling/samtools-extract-number-mapped-reads.cwl
      in:
        output_suffix:
          valueFrom: .mapped_and_filtered.read_count.txt
        input_bam_file: sort_filtered_bam/sorted_file
      scatter: input_bam_file
      out:
      - output_read_count
    remove_encode_blacklist:
      run: ../map/bedtools-intersect.cwl
      in:
        a: filtered2sorted/sorted_file
        b: ENCODE_blacklist_bedfile
        output_basename_file: extract_basename/output_basename
        v:
          default: true
      scatterMethod: dotproduct
      scatter:
      - a
      - output_basename_file
      out:
      - file_wo_blacklist_regions
    percent_uniq_reads:
      run: ../map/preseq-percent-uniq-reads.cwl
      in:
        preseq_c_curve_outfile: preseq-c-curve/output_file
      scatter: preseq_c_curve_outfile
      out:
      - output
    preseq-c-curve:
      run: ../map/preseq-c_curve.cwl
      in:
        input_sorted_file: sort_bams/sorted_file
        output_file_basename: extract_basename/output_basename
      scatterMethod: dotproduct
      scatter:
      - input_sorted_file
      - output_file_basename
      out:
      - output_file
    filter_pcr_artifacts:
      in:
        input_bam_files: remove_encode_blacklist/file_wo_blacklist_regions
      run: ../map/filter-pcr-artifacts.cwl
      out:
      - filtered_bedfile
    count_fastq_reads:
      run: ../utils/count-fastq-reads.cwl
      in:
        input_basename: extract_basename/output_basename
        input_fastq_file: input_fastq_files
      scatterMethod: dotproduct
      scatter:
      - input_fastq_file
      - input_basename
      out:
      - output_read_count
    sort_bams:
      run: ../map/samtools-sort.cwl
      in:
        nthreads: nthreads
        input_file: sam2bam/bam_file
      scatter:
      - input_file
      out:
      - sorted_file
    sort_filtered_bam:
      run: ../map/samtools-sort.cwl
      in:
        nthreads: nthreads
        input_file: filtered_bed_to_bam/bam_file
      scatter: input_file
      out:
      - sorted_file
    index_filtered_bam:
      run: ../map/samtools-index.cwl
      in:
        input_file: sort_filtered_bam/sorted_file
      scatter:
      - input_file
      out:
      - indexed_file
    sam2bam:
      run: ../map/samtools2bam.cwl
      in:
        input_file: bowtie-se/output_aligned_file
      scatter:
      - input_file
      out:
      - bam_file
    execute_pcr_bottleneck_coef:
      in:
        input_bam_files: filtered2sorted/sorted_file
        genome_sizes: genome_sizes_file
        input_output_filenames: extract_basename/output_basename
      run: ../map/pcr-bottleneck-coef.cwl
      out:
      - pbc_file
    filtered_bed_to_bam:
      run: ../map/bedtools-bedtobam.cwl
      in:
        i: filter_pcr_artifacts/filtered_bedfile
        g: genome_sizes_file
      scatter:
      - i
      out:
      - bam_file
    filter-unmapped:
      run: ../map/samtools-filter-unmapped.cwl
      in:
        output_filename: extract_basename/output_basename
        input_file: sort_bams/sorted_file
      scatterMethod: dotproduct
      scatter:
      - input_file
      - output_filename
      out:
      - filtered_file
    mapped_reads_count:
      run: ../map/bowtie-log-read-count.cwl
      in:
        bowtie_log: bowtie-se/output_bowtie_log
      scatter: bowtie_log
      out:
      - output
    extract_basename:
      run: ../utils/extract-basename.cwl
      in:
        input_file: input_fastq_files
      scatter: input_file
      out:
      - output_basename
    bowtie-se:
      run: ../map/bowtie-se.cwl
      in:
        nthreads: nthreads
        seedmms:
          valueFrom: ${return 1}
        output_filename: extract_basename/output_basename
        seedlen:
          valueFrom: ${return 20}
        trim3:
          valueFrom: ${return 30}
        genome_ref_first_index_file: genome_ref_first_index_file
        input_fastq_file: input_fastq_files
      scatterMethod: dotproduct
      scatter:
      - input_fastq_file
      - output_filename
      out:
      - output_aligned_file
      - output_bowtie_log
 outputs:
    output_data_filtered_bam_files:
      doc: BAM files without PCR artifact reads.
      type: File[]
      outputSource: index_filtered_bam/indexed_file
    output_pbc_files:
      doc: PCR Bottleneck Coeficient files.
      type: File[]
      outputSource: execute_pcr_bottleneck_coef/pbc_file
    output_read_count_mapped:
      doc: Read counts of the mapped BAM files
      type: File[]
      outputSource: mapped_reads_count/output
    output_read_count_mapped_filtered:
      doc: Read counts of the mapped and filtered BAM files
      type: File[]
      outputSource: mapped_filtered_reads_count/output_read_count
    output_preseq_c_curve_files:
      doc: Preseq c_curve output files.
      type: File[]
      outputSource: preseq-c-curve/output_file
    output_percentage_uniq_reads:
      doc: Percentage of uniq reads from preseq c_curve output
      type: File[]
      outputSource: percent_uniq_reads/output
    output_bowtie_log:
      doc: Bowtie log file.
      type: File[]
      outputSource: bowtie-se/output_bowtie_log
    original_fastq_read_count:
      doc: Read counts of the (unprocessed) input fastq files
      type: File[]
      outputSource: count_fastq_reads/output_read_count
