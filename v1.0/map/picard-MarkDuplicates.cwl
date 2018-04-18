 class: CommandLineTool
 cwlVersion: v1.0
 requirements:
    InlineJavascriptRequirement: {}
    ShellCommandRequirement: {}
 hints:
    DockerRequirement:
      dockerPull: dukegcb/picard
 inputs:
    remove_duplicates:
      type: boolean
      default: false
      inputBinding:
        valueFrom: $('REMOVE_DUPLICATES=' + self)
        position: 5
      doc: If true do not write duplicates to the output file instead of writing them with appropriate flags set.  (Default false).
    input_file:
      type: File
      inputBinding:
        position: 4
        valueFrom: $('INPUT=' + self.path)
        shellQuote: false
      doc: One or more input SAM or BAM files to analyze. Must be coordinate sorted.
    java_opts:
      type: string?
      inputBinding:
        position: 1
        shellQuote: false
      doc: JVM arguments should be a quoted, space separated list (e.g. "-Xms128m -Xmx512m")
    picard_jar_path:
      type: string
      inputBinding:
        position: 2
        prefix: -jar
      doc: Path to the picard.jar file
    metrics_suffix:
      type: string
      default: dedup_metrics.txt
      doc: 'Suffix used to create the metrics output file (Default: dedup_metrics.txt)'
    output_filename:
      type: string
      doc: Output filename used as basename
    output_suffix:
      type: string
      default: dedup.bam
      doc: 'Suffix used to identify the output file (Default: dedup.bam)'
 outputs:
    output_metrics_file:
      type: File
      outputBinding:
        glob: $(inputs.output_filename + '.' + inputs.metrics_suffix)
    output_dedup_bam_file:
      type: File
      outputBinding:
        glob: $(inputs.output_filename  + '.' + inputs.output_suffix)
 baseCommand: [java]
 arguments:
  - valueFrom: MarkDuplicates
    position: 3
  - valueFrom: $('OUTPUT=' + inputs.output_filename + '.' + inputs.output_suffix)
    position: 5
    shellQuote: false
  - valueFrom: $('METRICS_FILE='+inputs.output_filename + '.' + inputs.metrics_suffix)
    position: 5
    shellQuote: false
  - valueFrom: $('TMP_DIR='+runtime.tmpdir)
    position: 5
    shellQuote: false
