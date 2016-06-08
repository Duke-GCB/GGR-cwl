# GGR-cwl
## CWL tools and workflows associated with the Genomics of Gene Regulation (GGR) project

[![Join the chat at https://gitter.im/alexbarrera/GGR-cwl](https://badges.gitter.im/alexbarrera/GGR-cwl.svg)](https://gitter.im/alexbarrera/GGR-cwl?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

### [ChIP-seq](ChIP-seq_pipeline):

#### Pipelines
* [SE - Narrow](ChIP-seq_pipeline/pipeline-se-narrow.cwl)
* [SE - Narrow - w/control](ChIP-seq_pipeline/pipeline-se-narrow-with-control.cwl)
* [SE - Broad](ChIP-seq_pipeline/pipeline-se-broad.cwl)
* [SE - Broad - w/control](ChIP-seq_pipeline/pipeline-se-broad-with-control.cwl)
* [PE - Narrow](ChIP-seq_pipeline/pipeline-pe-narrow.cwl)
* [PE - Narrow - w/control](ChIP-seq_pipeline/pipeline-pe-narrow-with-control.cwl)
* [PE - Broad](ChIP-seq_pipeline/pipeline-pe-broad.cwl)
* [PE - Broad - w/control](ChIP-seq_pipeline/pipeline-pe-broad-with-control.cwl)

#### Steps
* 01 - Fastq QC step:
    * [Fastq QC step - SE](ChIP-seq_pipeline/01-qc-se.cwl)
    * [Fastq QC step - PE](ChIP-seq_pipeline/01-qc-pe.cwl)
* 02 - Trimming reads step:
    * [Trimming step - SE](ChIP-seq_pipeline/02-trim-se.cwl)
    * [Trimming step - PE](ChIP-seq_pipeline/02-trim-pe.cwl)
* 03 - Mapping step:
    * [Mapping step - SE](ChIP-seq_pipeline/03-map-se.cwl)
    * [Mapping step - PE](ChIP-seq_pipeline/03-map-pe.cwl)
* 04 - Peak calling step:
    * [Peak calling step - narrow](ChIP-seq_pipeline/04-peakcall-narrow.cwl)
    * [Peak calling step - narrow with control](ChIP-seq_pipeline/04-peakcall-narrow-with-control.cwl)
    * [Peak calling step - broad](ChIP-seq_pipeline/04-peakcall-broad.cwl)
    * [Peak calling step - broad with control](ChIP-seq_pipeline/04-peakcall-broad-with-control.cwl)
* 05 - [Quantification step](ChIP-seq_pipeline/05-quantification.cwl)


### [DNase-seq](DNase-seq_pipeline):

#### Pipelines
* [SE](DNase-seq_pipeline/pipeline-se.cwl)

#### Steps
* 01 - Mapping step:
    * 01 - [Mapping step - SE](DNase-seq_pipeline/01-map-se.cwl)
* 02 - Peak calling step:
    * 02 - [Peak calling step](DNase-seq_pipeline/02-peakcall.cwl)
* 03 - Quantification step:
    * 03 - [Quantification step](DNase-seq_pipeline/03-quantification.cwl)


### [RNA-seq](RNA-seq_pipeline):

#### Pipelines
[PE](RNA-seq_pipeline/pipeline-pe.cwl)

#### Steps
* 00 - Genome files generation for STAR and RSEM:
    * 00 - [Preprocessing step](RNA-seq_pipeline/00-preprocessing.cwl)
* 01 - Fastq QC step:
    * 01 - [Fastq QC step - PE](RNA-seq_pipeline/01-qc-pe.cwl)
* 02 - Trimming reads step:
    * 02 - [Trimming step - PE](RNA-seq_pipeline/02-trim-pe.cwl)
* 03 - Mapping step:
    * 03 - [Mapping step - PE](RNA-seq_pipeline/03-map-pe.cwl)
* 04 - Quantification step:
    * 04 - [Quantification step - PE](RNA-seq_pipeline/04-quantification-pe.cwl)

##### Workflow differences legend 
Depending on the experiments, there might be small differences in the workflows which will be determined by:

- Type of read:
    - SE: Single End reads
    - PE: Paired-End reads
- Type of region targeted:
    - Narrow: Narrow (also known as Point-Source) peaks. Limited region bound (e.g. TFs).
    - Broad: Broad peaks. Wide region bound (e.g. Histone modifications)
- If a control sample is available (with control when applicable).
