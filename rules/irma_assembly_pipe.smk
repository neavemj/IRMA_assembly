import textwrap
from pathlib import Path


rule irma_all:
    input: expand("02_irma_assembly/{sample}/IRMA_COMPLETE", sample=config["samples"])


# need a function here to differentiate MiSeq from MinION dataset
# will use the IRMA module config parameter for now
def get_reads(wildcards):
    if config["irma_module"] == "FLU-avian":
        return([
            "01_preprocessing/{sample}_1P.fastq.gz",
            "01_preprocessing/{sample}_2P.fastq.gz"
            ])
    elif config["irma_module"] == "FLU-minion":
        return([      
            "01_preprocessing/{sample}.porechop.nanofilt.fastq"
            ])   

# made this a checkpoint so that the DAG is re-evaluated
# depending on subtype assembled
# important for the phylogenetic rules
checkpoint irma_scan:
    message: textwrap.dedent(f"""
        Run given dataset through CDCs IRMA pipeline
        IRMA Module: {config["irma_module"]}
        """).rstrip()
    input:
        # will return either cleaned MiSeq or MinION reads as above
        get_reads
    output:
        # be very careful that the output doesn't include a file in
        # the folder created by IRMA below
        # otherwise, snakemake creates the folder, IRMA sees it's already
        # there and appends a V2 onto the output folder
        # Then snakemake can't see any output getting created
        dir = directory("02_irma_assembly/{sample}/irma_output/"),
        dummy_file = "02_irma_assembly/{sample}/IRMA_COMPLETE",
        #counts = "02_irma_assembly/{sample}/irma_output/tables/READ_COUNTS.txt"
    params:
        irma_module = config["irma_module"]
    shell:
        """
            # Run IRMA
            IRMA \
                {params.irma_module} \
                {input} \
                02_irma_assembly/{wildcards.sample}/irma_output

            if [ "$?" == "0" ]; then
                touch 02_irma_assembly/{wildcards.sample}/IRMA_COMPLETE
            fi
        """



# def fasta_list(wildcards):
#     """Enumerate all fasta files in directory"""
#     files = list((Path(wildcards.dataset) / "irma_output").glob("*.fasta"))
#     return [str(x) for x in files]



# rule svg_plots:
#     message: textwrap.dedent("""
#         Run a hack of the simpleCoverageDiagram.R to generate SVG
#         formatted coverage diagrams
#         """).rstrip()
#
#     input: "{dataset}/IRMA_COMPLETE",
#            fasta_list
#
#     output: "{dataset}/SVG_COVERAGE"
#
#     threads: 1
#
#     shell:
#         """
#             COVER_SCRIPT=$HOME/bin/simpleCoverageDiagram_svg.R
#             BASE="{wildcards.dataset}/irma_output"
#
#             # Generage SVG coverage plots
#             for CONTIG in {input}
#             do
#                 KEY=$(basename ${{CONTIG%.fasta}})
#                 if [ "$KEY" != "IRMA_COMPLETE" ]; then
#                     GENE=$(echo $KEY | cut -d_ -f 2)
#                     Rscript \
#                         $COVER_SCRIPT \
#                         {wildcards.dataset} \
#                         $GENE \
#                         $BASE/tables/$KEY-coverage.txt \
#                         $BASE/figures/$KEY-coverage.svg \
#                         > /dev/null
#                 fi
#             done
#
#             touch {wildcards.dataset}/SVG_COVERAGE
#         """
