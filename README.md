# AIV Pipeline IRMA Assembly Module
---

Module to take high quality reads from the preprocessing module and assemble influenza genomes using IRMA

[IRMA](https://wonder.cdc.gov/amd/flu/irma/): Iterative Refinement Meta-Assembler

##### Input:
* Trimmed high-quality fastq reads from the preprocessing module

##### Output:
Assembled influenza genome as individual segments.  Each segment represented with the following files:
* Sequence in Fasta format
* BAM formatted alignment file
* VCF file

```
irma_output/
├── A_HA_H5.bam
├── A_HA_H5.bam.bai
├── A_HA_H5.fasta
├── A_HA_H5.vcf
├── A_MP.bam
├── A_MP.bam.bai
├── A_MP.fasta
├── A_MP.vcf
├── A_NA_N3.bam
...
```
---
### Running example data from Introduction repository

Command line:
```bash
> snakemake --cores=2 --snakefile=rules/irma_assembly.smk --configfile=irmascan_config.yaml
```
The snakemake and config files combine to provide the working directory which includes the raw data sets and the outputs per IRMA module (configuration).

In the example case:
```
datasets/
├── 21-02023-0001/
│ └── raw_reads/
|     ├── 21-02023-01_S4_L001_R1_001.fastq.gz
│     └── 21-02023-01_S4_L001_R2_001.fastq.gz
|
│ └── FLU-avian-acdp/   <- IRMA Module name
│   └── irma_output/
|       ├── A_HA_H7.bam
|       ├── A_HA_H7.bam.bai
|       ├── A_HA_H7.bam
|       ├── A_HA_H7.fasta
|       ├── A_HA_H7.vcf
|       ...
|
├── 21-02023-0003/
│ └── raw_reads/
...
```
---
### Results of test data sets

<!--
###### 21-02023-0001 - Complete Genome
The IRMA results were an exact match with the example set.  
The full results are buried at [datasets/21-02023-0001/FLU-avian-acdp/irma_output/](datasets/21-02023-0001/FLU-avian-acdp/irma_output/)
-->

###### 21-02023-0003 - Incomplete Genome
The five segments provided in the incomplete example set were once again matched exactly with the results from the IRMA run.  IRMA also detected the remaining 3 segments,  which all had 94% or greater identity when Blasted on NCBI.  

That said,  these were derived from very low coverage and therefore are not considered reliable.
Once again the full results can be viewed at [datasets/21-02023-0003/FLU-avian-acdp/irma_output/](datasets/21-02023-0003/FLU-avian-acdp/irma_output/)
