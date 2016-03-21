#!/usr/bin/env cwl-runner

class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerImageId: 'dukegcb/macs2'

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement

inputs:
  - id: "#treatment_sample_file"
    type: File
    description: 'ChIP-seq treatment file. \n'
    inputBinding:
      position: 1
      prefix: -t
  - id: "#control_sample_file"
    type: File
    description: 'ChIP-seq control file. \n'
    inputBinding:
      position: 1
      prefix: -c
  - id: "#nomodel"
    type:
      - 'null'
      - boolean
    description: "\t Whether or not to build the shifting model. If True,
                        \t MACS will not build model. by default it means
                        \t shifting size = 100, try to set extsize to change it.
                        \t DEFAULT: False\n"
    default: true
    inputBinding:
      position: 3
      prefix: --nomodel
  - id: "#extsize"
    type: float
    description: "The arbitrary extension size in bp. When nomodel is
                        \t true, MACS will use this value as fragment size to
                        \t extend each read towards 3' end, then pile them up.
                        \t It's exactly twice the number of obsolete SHIFTSIZE.
                        \t In previous language, each read is moved 5'->3'
                        \t direction to middle of fragment by 1/2 d, then
                        \t extended to both direction with 1/2 d. This is
                        \t equivalent to say each read is extended towards 5'->3'
                        \t into a d size fragment. DEFAULT: 200. EXTSIZE and
                        \t SHIFT can be combined when necessary. Check SHIFT
                        \t option.\n"
    inputBinding:
      position: 2
      prefix: '--extsize'
  - id: "#broad_cutoff"
    type: float
    description: "Cutoff for broad region. If -p is set, this is a pvalue
                        cutoff, otherwise, it's a qvalue cutoff. DEFAULT: 0.1 \n"
    default: 0.1
    inputBinding:
      position: 3
      prefix: '--broad-cutoff'
  - id: "#p"
    type:
      - 'null'
      - float
    description: "Pvalue cutoff for peak detection. DEFAULT: not set.
                      \t -q, and -p are mutually exclusive. If pvalue cutoff is
                      \t set, qvalue will not be calculated and reported as -1
                      \t in the final .xls file..\n"
    inputBinding:
      position: 3
      preix: '-p'
  - id: "#g"
    type: string
    default: 'hs'
    description: "Effective genome size. It can be 1.0e+9 or 1000000000,
                      \t or shortcuts:'hs' for human (2.7e9), 'mm' for mouse
                      \t (1.87e9), 'ce' for C. elegans (9e7) and 'dm' for
                      \t fruitfly (1.2e8), Default:hs.\n"
    inputBinding:
      position: 3
      prefix: '-g'
  - id: "#format"
    type:
      - 'null'
      - string
    description: "-f {AUTO,BAM,SAM,BED,ELAND,ELANDMULTI,ELANDEXPORT,BOWTIE,BAMPE}, --format {AUTO,BAM,SAM,BED,ELAND,ELANDMULTI,ELANDEXPORT,BOWTIE,BAMPE}
                        Format of tag file, \"AUTO\", \"BED\" or \"ELAND\" or
                        \"ELANDMULTI\" or \"ELANDEXPORT\" or \"SAM\" or \"BAM\" or
                        \"BOWTIE\" or \"BAMPE\". The default AUTO option will let
                        MACS decide which format the file is. Note that MACS can't detect \"BAMPE\"
                        or \"BEDPE\" format with \"AUTO\", and you have to implicitly specify the
                        format for \"BAMPE\" and \"BEDPE\". DEFAULT:
                        \"AUTO\".\n"
    inputBinding:
      position: 3
      prefix: '-f'
  - id: "#bdg"
    type: boolean
    description: "  Whether or not to save extended fragment pileup, and \n
                    \tlocal lambda tracks (two files) at every bp into a \n
                    \tbedGraph file. DEFAULT: True"
    default: true
    inputBinding:
      position: 3
      prefix: "--bdg"

outputs:
  - id: "#output_broadpeak_file"
    type: File
    description: "Peak calling output file in broadPeak format."
    outputBinding:
      glob: $(inputs.treatment_sample_file.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '_peaks.broadPeak')
  - id: "#output_ext_frag_bdg_file"
    type: File
    description: "Bedgraph with extended fragment pileup."
    outputBinding:
      glob: $(inputs.treatment_sample_file.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '_treat_pileup.bdg')
  - id: "#output_peak_xls_file"
    type: File
    description: "Peaks information/report file."
    outputBinding:
      glob: $(inputs.treatment_sample_file.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '_peaks.xls')
  - id: "#output_peak_summits_file"
    type: File
    description: "Peaks summits bedfile."
    outputBinding:
      glob: $(inputs.treatment_sample_file.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '_summits.bed')

baseCommand: ["macs2" , "callpeak", "--broad"]

arguments:
  - valueFrom: $('-n=' + inputs.treatment_sample_file.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.'))
    position: 2
