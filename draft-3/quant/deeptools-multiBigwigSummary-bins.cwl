#!/usr/bin/env cwl-runner

# Mantainer: alejandro.barrera@duke.edu
# Partially Auto generated with clihp (https://github.com/portah/clihp, developed by Andrey.Kartashov@cchmc.org)
# Developed for GGR project (https://github.com/Duke-GCB/GGR-cwl)

cwlVersion: 'cwl:draft-3'
class: CommandLineTool
hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/deeptools'

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement

inputs:
  - id: bwfiles
    description: bigWig files to be binned
    type:
      type: array
      items: File
    inputBinding:
      position: 2
      prefix: '--bwfiles'
      itemSeparator: ' '
  - id: outMatrixFileName
    type: string
    default: 'matrix.npz'
    description: |
      File name to save the compressed matrix file (npz
      format)needed by the "plotHeatmap" and "plotProfile"
      tools. (default: matrix.npz)
    inputBinding:
      position: 1
      prefix: '--outFileName'
      shellQuote: false
  - id: chromosomesToSkip
    type:
      - 'null'
      - File
    description: |
      File listing chromosomes that you do not want to be
      included. Useful to remove "random" or "extra" chr.
      (default: None)
    inputBinding:
      position: 1
      prefix: '--chromosomesToSkip'
      loadContents: true
      valueFrom: $(self.contents.replace(/\n+/g, ' ').replace(/ $/, ''))
  - id: binSize
    type:
      - 'null'
      - int
    description: |
      Size (in bases) of the windows sampled from the
      genome. (default: 10000)
    inputBinding:
      position: 1
      prefix: '--binSize'
  - id: distanceBetweenBins
    type:
      - 'null'
      - int
    description: |
      By default, multiBigwigSummary considers adjacent bins
      of the specified --binSize. However, to reduce the
      computation time, a larger distance between bins can
      be given. Larger distances results in fewer considered
      bins. (default: 0)
    inputBinding:
      position: 1
      prefix: '--distanceBetweenBins'
  - id: version
    type:
      - 'null'
      - boolean
    description: "show program's version number and exit\n"
    inputBinding:
      position: 1
      prefix: '--version'
  - id: region
    type:
      - 'null'
      - string
    description: |
      CHR:START:END, -r CHR:START:END
      Region of the genome to limit the operation to - this
      is useful when testing parameters to reduce the
      computing time. The format is chr:start:end, for
      example --region chr10 or --region
      chr10:456700:891000. (default: None)
    inputBinding:
      position: 1
      prefix: '--region'
  - id: numberOfProcessors
    type: string
    default: "max"
    description: |
      Number of processors to use. Type "max/2" to use half
      the maximum number of processors or "max" to use all
      available processors. (default: max)
    inputBinding:
      position: 1
      prefix: '--numberOfProcessors'
  - id: verbose
    type:
      - 'null'
      - boolean
    description: |
      Set to see processing messages. (default: False)
    inputBinding:
      position: 1
      prefix: '--verbose'
  - id: outRawCountsFileName
    type:
      - 'null'
      - string
    description: |
      Save average scores per region for each bigWig file to
      a single tab-delimited file (default: None)
    inputBinding:
      position: 1
      prefix: '--outRawCounts'
outputs:
  - id: matrixFile
    type: File
    outputBinding:
      glob: $(inputs.outMatrixFileName)
  - id: rawCountsFile
    type:
      - 'null'
      - File
    outputBinding:
      glob: $(inputs.outRawCountsFileName)
stdout: $(inputs.outMatrixFileName)
baseCommand:
  - multiBigwigSummary
  - bins
description: |
  The average score is based on equally sized bins (10 kilobases
  by default), which consecutively cover the entire genome. The
  only exception is the last bin of a chromosome, which is often
  smaller. The output of this mode is commonly used to assess the
  overall similarity of different bigWig files.
