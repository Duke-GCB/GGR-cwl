 class: CommandLineTool
 cwlVersion: v1.0
 doc: |
    The average score is based on equally sized bins (10 kilobases
    by default), which consecutively cover the entire genome. The
    only exception is the last bin of a chromosome, which is often
    smaller. The output of this mode is commonly used to assess the
    overall similarity of different bigWig files.
 requirements:
    InlineJavascriptRequirement: {}
    ShellCommandRequirement: {}
 hints:
    DockerRequirement:
      dockerPull: reddylab/deeptools:3.0.1
 inputs:
    chromosomesToSkip:
      type: File?
      inputBinding:
        position: 1
        prefix: --chromosomesToSkip
        loadContents: true
        valueFrom: $(self.contents.replace(/\n+/g, ' ').replace(/ $/, ''))
      doc: |
        File listing chromosomes that you do not want to be
        included. Useful to remove "random" or "extra" chr.
        (default: None)
    numberOfProcessors:
      type: string
      default: max
      inputBinding:
        position: 1
        prefix: --numberOfProcessors
      doc: |
        Number of processors to use. Type "max/2" to use half
        the maximum number of processors or "max" to use all
        available processors. (default: max)
    verbose:
      type: boolean?
      inputBinding:
        position: 1
        prefix: --verbose
      doc: |
        Set to see processing messages. (default: False)
    region:
      type: string?
      inputBinding:
        position: 1
        prefix: --region
      doc: |
        CHR:START:END, -r CHR:START:END
        Region of the genome to limit the operation to - this
        is useful when testing parameters to reduce the
        computing time. The format is chr:start:end, for
        example --region chr10 or --region
        chr10:456700:891000. (default: None)
    binSize:
      type: int?
      inputBinding:
        position: 1
        prefix: --binSize
      doc: |
        Size (in bases) of the windows sampled from the
        genome. (default: 10000)
    outMatrixFileName:
      type: string
      default: matrix.npz
      inputBinding:
        position: 1
        prefix: --outFileName
        shellQuote: false
      doc: |
        File name to save the compressed matrix file (npz
        format)needed by the "plotHeatmap" and "plotProfile"
        tools. (default: matrix.npz)
    version:
      type: boolean?
      inputBinding:
        position: 1
        prefix: --version
      doc: "show program's version number and exit\n"
    bwfiles:
      type: File[]
      inputBinding:
        position: 2
        prefix: --bwfiles
        itemSeparator: ' '
      doc: bigWig files to be binned
    distanceBetweenBins:
      type: int?
      inputBinding:
        position: 1
        prefix: --distanceBetweenBins
      doc: |
        By default, multiBigwigSummary considers adjacent bins
        of the specified --binSize. However, to reduce the
        computation time, a larger distance between bins can
        be given. Larger distances results in fewer considered
        bins. (default: 0)
    outRawCountsFileName:
      type: string?
      inputBinding:
        position: 1
        prefix: --outRawCounts
      doc: |
        Save average scores per region for each bigWig file to
        a single tab-delimited file (default: None)
 outputs:
    rawCountsFile:
      type: File?
      outputBinding:
        glob: $(inputs.outRawCountsFileName)
    matrixFile:
      type: File
      outputBinding:
        glob: $(inputs.outMatrixFileName)
 baseCommand:
  - multiBigwigSummary
  - bins
 stdout: $(inputs.outMatrixFileName)
