import textwrap
from pathlib import Path


rule one:
    message: "The one rule"
    input: f"datasets/{config['dataset_name']}/{config['irma_module']}/IRMA_COMPLETE"




rule irma_scan:
    message: textwrap.dedent(f"""
        Run given dataset through CDCs IRMA pipeline
        IRMA Version: {config["irma_version"]}
        IRMA Module: {config["irma_module"]}
        """).rstrip()

    input:
        forward_reads = "datasets/{dataset}/raw_reads/" + config["forward_reads"],
        reverse_reads = "datasets/{dataset}/raw_reads/" + config["reverse_reads"]

    output: "datasets/{dataset}/" + config['irma_module'] + "/IRMA_COMPLETE"

    params:
        irma_module = config["irma_module"],
        irma_version = config["irma_version"]

    shell:
        """
            # Run IRMA
            $HOME/bin/flu-amd_{params.irma_version}/IRMA \
                {params.irma_module} \
                {input.forward_reads} \
                {input.reverse_reads} \
                datasets/{wildcards.dataset}/{params.irma_module}/irma_output


            if [ "$?" == "0" ]; then
                touch datasets/{wildcards.dataset}/{params.irma_module}/IRMA_COMPLETE
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
