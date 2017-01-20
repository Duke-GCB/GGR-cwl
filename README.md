# GGR-cwl

[![Join the chat at https://gitter.im/alexbarrera/GGR-cwl](https://badges.gitter.im/alexbarrera/GGR-cwl.svg)](https://gitter.im/alexbarrera/GGR-cwl?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

CWL tools and workflows associated with the Genomics of Gene Regulation (GGR) project

GGR pipelines created using the [Common Workflow Language](http://www.commonwl.org/) `draft-3` specification. 
The workflows are parametrized with values that best suit the GGR samples, but they can be easily tailored for specific needs.

For a detail User Guide to the CWL workflows, please see the [wiki](https://github.com/Duke-GCB/GGR-cwl/wiki).

## [ChIP-seq](ChIP-seq_pipeline):

### Pipelines
* [SE - Narrow](ChIP-seq_pipeline/pipeline-se-narrow.cwl)
* [SE - Narrow - w/control](ChIP-seq_pipeline/pipeline-se-narrow-with-control.cwl)
* [SE - Broad](ChIP-seq_pipeline/pipeline-se-broad.cwl)
* [SE - Broad - w/control](ChIP-seq_pipeline/pipeline-se-broad-with-control.cwl)
* [PE - Narrow](ChIP-seq_pipeline/pipeline-pe-narrow.cwl)
* [PE - Narrow - w/control](ChIP-seq_pipeline/pipeline-pe-narrow-with-control.cwl)
* [PE - Broad](ChIP-seq_pipeline/pipeline-pe-broad.cwl)
* [PE - Broad - w/control](ChIP-seq_pipeline/pipeline-pe-broad-with-control.cwl)

### Steps
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


## [DNase-seq](DNase-seq_pipeline):

### Pipelines
* [SE](DNase-seq_pipeline/pipeline-se.cwl)

### Steps
* 01 - Mapping step:
    * 01 - [Mapping step - SE](DNase-seq_pipeline/01-map-se.cwl)
* 02 - Peak calling step:
    * 02 - [Peak calling step](DNase-seq_pipeline/02-peakcall.cwl)
* 03 - Quantification step:
    * 03 - [Quantification step](DNase-seq_pipeline/03-quantification.cwl)


## [RNA-seq](RNA-seq_pipeline):

### Pipelines
* [SE - Unstranded](RNA-seq_pipeline/pipeline-se-unstranded.cwl)
* [SE - Unstranded - w/sjdb](RNA-seq_pipeline/pipeline-se-unstranded-with-sjdb.cwl)
* [SE - Stranded](RNA-seq_pipeline/pipeline-se-stranded.cwl)
* [SE - Stranded - w/sjdb](RNA-seq_pipeline/pipeline-se-stranded-with-sjdb.cwl)
* [SE - Revstranded](RNA-seq_pipeline/pipeline-se-revstranded.cwl)
* [SE - Revstranded - w/sjdb](RNA-seq_pipeline/pipeline-se-revstranded-with-sjdb.cwl)
* [PE - Unstranded](RNA-seq_pipeline/pipeline-pe-unstranded.cwl)
* [PE - Unstranded - w/sjdb](RNA-seq_pipeline/pipeline-pe-unstranded-with-sjdb.cwl)
* [PE - Stranded](RNA-seq_pipeline/pipeline-pe-stranded.cwl)
* [PE - Stranded - w/sjdb](RNA-seq_pipeline/pipeline-pe-stranded-with-sjdb.cwl)
* [PE - Revstranded](RNA-seq_pipeline/pipeline-pe-revstranded.cwl)
* [PE - Revstranded - w/sjdb](RNA-seq_pipeline/pipeline-pe-revstranded-with-sjdb.cwl)

### Steps
* 00 - Genome files generation for STAR and RSEM:
    * 00 - [Preprocessing step](RNA-seq_pipeline/00-preprocessing.cwl)
* 01 - Fastq QC step:
    * 01 - [Fastq QC step - SE](RNA-seq_pipeline/01-qc-se.cwl)
    * 01 - [Fastq QC step - PE](RNA-seq_pipeline/01-qc-pe.cwl)
* 02 - Trimming reads step:
    * 02 - [Trimming step - SE](RNA-seq_pipeline/02-trim-se.cwl)
    * 02 - [Trimming step - PE](RNA-seq_pipeline/02-trim-pe.cwl)
* 03 - Mapping step:
    * 03 - [Mapping step - SE](RNA-seq_pipeline/03-map-se.cwl)
    * 03 - [Mapping step - SE - w/sjdb](RNA-seq_pipeline/03-map-se-with-sjdb.cwl)
    * 03 - [Mapping step - PE](RNA-seq_pipeline/03-map-pe.cwl)
    * 03 - [Mapping step - PE - w/sjdb](RNA-seq_pipeline/03-map-pe-with-sjdb.cwl)
* 04 - Quantification step:
    * 04 - [Quantification step - SE - Unstranded](RNA-seq_pipeline/04-quantification-se-unstranded.cwl)
    * 04 - [Quantification step - SE - Stranded](RNA-seq_pipeline/04-quantification-se-stranded.cwl)
    * 04 - [Quantification step - SE - Revstranded](RNA-seq_pipeline/04-quantification-se-revstranded.cwl)
    * 04 - [Quantification step - PE - Unstranded](RNA-seq_pipeline/04-quantification-pe-unstranded.cwl)
    * 04 - [Quantification step - PE - Stranded](RNA-seq_pipeline/04-quantification-pe-stranded.cwl)
    * 04 - [Quantification step - PE - Revstranded](RNA-seq_pipeline/04-quantification-pe-revstranded.cwl)

----------------------------------------------------------------------------------------------------------
##### Workflow differences legend 
Depending on the experiments, there might be small differences in the workflows which will be determined by:

- All
    - Type of read:
        - SE: Single End reads
        - PE: Paired-End reads
- ChIP-seq & DNase-seq
    - Type of region targeted:
        - Narrow: Narrow (also known as Point-Source) peaks. Limited region bound (e.g. TFs).
        - Broad: Broad peaks. Wide region bound (e.g. Histone modifications)
- ChIP-seq only
    - With or without control. If a control sample is available `-with-control` or not.
- RNA-seq only
    - Strand specificity:
        - Unstranded: reads are not strand-specific, is not possible to know from which DNA strand they come.
        - Stranded: reads are strand-specific and can be map to the Watson and Crick strands. 
        - Reverse Stranded: reads come from cDNA, which switches the mapping of the forward and reverse strand. 
    - Custom SJDB: By default the STAR 2-pass mapping strategy is implemented in which a first pass of STAR is run to generate a large pool of novel splice junctions (referred as SJDB). These junctions are used to generate a genome index which is employed in the mapping step. However, this 2-pass strategy can be skipped, using a custom genome index Because typically this genome would be created with a precomputed SJDB, this option is denoted with `-with-sjdb`.
    
