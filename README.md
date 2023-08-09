## NanoTax-Dorado: Next-Generation 16S Metabarcoding

Overview: 16S Metabarcoding is a transformative technique that allows identification of microbial communities within a given sample. The NanoTax-Dorado pipeline is specifically designed to streamline this process, turning raw sequencing data into a comprehensive microbial community profile.
At its core, NanoTax-Dorado employs the Dorado basecaller, ONT's latest software, ensuring accurate and efficient base-calling for high-throughput sequencing data. The pipeline encompasses various stages, from sorting and de-barcoding to species-level taxonomic abundance estimation using Emu.

## Key Features

-	Latest ONT: Utilizes the new ONT technologies, including Dorado.

-	Emu taxonomic abundance calculator: Emu quickly transforms raw sequence data into abundance profilesfor microbial community composition analysis.

-	Next Gen V14 Chemistry: Assures top-tier quality of base-calling and identification. Improvement upon previous chemistry ensuring Q20+.

-	Comprehensive Analysis: Offers an end-to-end solution for 16S Metabarcoding, from DNA extraction to data interpretation.

## Prerequisites 

This pipeline utilises snakemake to handle all the data analysis. This pipeline makes use of several dependencies including snakemake. To easily handle this, a base environment base_environment.yml has been provided. To create this, run the following command:
conda env create -f base_environment.yml
This will create an environment snakemake which should have everything you need installed. It is automatically activated in the run_snakemake.sh script. This pipeline was designed to run in a SLURM environment. To allow snakemake to interact with the SLURM job manager to submit jobs, you'll need to use cookiecutter. This will allow you to build a job template which snakemake will use to wrap around each rule allowing it to be submitted as a SLURM job. To build a profile suitable for SLURM, run the following commands:

'''
Create a snakemake directory in user config
mkdir -p ~/.config/snakemake

cd ~/.config/snakemake

This will run the setup for the profile - the default settings should be fine, they can always be changed later if necessary!
cookiecutter https://github.com/Snakemake-Profiles/slurm.git
'''

## Power, Memory, and Cluster requirements: 
This pipeline involves processing extensive amounts of data, complex computations, and high memory usage, making it unsuitable for execution on personal or low-resource devices. Here’s why the use of a specialized cluster, such as the UK Crop Diversity cluster, is recommended:

1. High Memory Usage
The pipeline's steps, including base calling with Dorado, sorting BAM files, and taxonomic assignment with Emu, require significant amounts of RAM. Personal computers and standard servers may not be equipped to handle such requirements, leading to slow performance or even failure to execute the pipeline.

2. GPU Requirements
Some steps in the pipeline, like base calling with Dorado, are optimized to run on Graphics Processing Units (GPUs). GPUs can significantly speed up the processing time for these specific tasks. Most personal devices do not have the necessary GPU capabilities, making the use of a specialized cluster with dedicated GPU resources vital.

3. Cost Efficiency
Accessing the required computational resources through commercial vendors can be prohibitively expensive. Utilizing the UK crop diversity cluster offers a more cost-effective solution by providing access to the necessary hardware and computational resources at a fraction of the commercial cost.

4. Parallel Processing
The pipeline's design allows for parallel processing, where multiple tasks can be executed simultaneously. This parallelization can be efficiently managed on a cluster environment, further reducing the processing time and ensuring optimal use of resources.

5. Scalability
The UK crop diversity cluster provides the flexibility to scale the resources according to the complexity and size of the data. This scalability ensures that the pipeline can handle different project sizes without the need to change the underlying infrastructure.

Given the above considerations, it is strongly advised not to run this pipeline on personal devices. 

For detailed guidance on how to access and use the UK crop diversity cluster for this pipeline, refer to the help page: https://help.cropdiversity.ac.uk/index.html

## Pipeline Rules Expounded

1.	dorado_basecall: Base Calling with Dorado

    Description:
    Base calling is the process of translating the raw signal data produced by the sequencer into nucleotide sequences (A, T, C, G). This rule utilizes Dorado, the latest basecalling software developed specifically for Oxford Nanopore data. It succeeds Guppy as the primary basecaller.
 
    Output:
    A BAM file, which is a binary version of SAM (Sequence Alignment/Map) file. This file type stores nucleotide sequence data along with their qualities.

2.	sort_bam: Sorting BAM File

    Description:
    Once the raw data is base called and stored in a BAM file, it's essential to have it sorted. This rule uses SAMtools, a suite of programs for interacting with high-throughput sequencing data, to sort the BAM file.

    Purpose:
    Sorting ensures the alignments in the BAM file are organized by their position in the reference genome. This arrangement is crucial for efficient and accurate downstream analyses.

3.	debarcode: Debarcoding

    Description:
    After base calling, the reads are often mixed with different identifiers called barcodes. Debarcoding segregates these reads based on their barcodes. The pipeline continues to use Guppy for this, which is also known for its demultiplexing capabilities.

    Output:
    A set of fastq files, where each file corresponds to a specific barcode.

4. 	filter_reads: Filtering Reads

    Description:
    It's essential to ensure the quality and reliability of the data being analyzed. This rule filters the reads based on specific parameters, ensuring only the most relevant and high-quality data is used for the subsequent steps.

5.	emu: Taxonomic Assignment with Emu

    Description:
    One of the primary goals of metagenomic analysis is to identify what organisms or taxa are present in a sample. Emu 3.4.5 is a tool that assigns taxonomy to sequence data. In this pipeline, Emu processes the sequence data to output taxonomic graphs, showcasing the diversity and abundance of taxa in the samples.

    Output:
    Taxonomic graphs and tables, giving a detailed view of the microbial composition of the sample.

6. 	emu_subsample: Subsampling and Further Taxonomic Analysis with Emu

    Description:
    For comprehensive analysis or when dealing with vast amounts of data, it might be beneficial to subsample the sequence data. This rule takes a proportion of the original data for further taxonomic investigation with Emu. It ensures that the pipeline's results are consistent even with different data volumes.

7. 	clean_and_plot: Data Visualization

    Description:
    Visualization often makes data interpretation more intuitive. This rule uses R to curate and visualize the taxonomic distribution derived from the samples. Through various plots, researchers can quickly gauge the microbial diversity and prevalence in their samples.

    Output:
    Charts and graphs representing the taxonomic distribution of the analyzed samples.

## Dorado Basecaller

Simplex and Duplex Basecalling: Dorado can not only perform standard simplex basecalling but is also adept at duplex basecalling, a technique that reads both strands of a DNA molecule, enhancing accuracy.

Modifications: It isn’t just about reading the DNA sequence. Dorado can also call DNA modifications, expanding its utility beyond mere sequence determination.

Integrated Duplexing: Unlike previous iterations where duplex pair detection required an external tool, Dorado now has this functionality in-built.

Alignment Capabilities: Dorado doesn't stop at basecalling. It can also align sequences, utilizing the robust Minimap2 algorithm. This alignment can either be post basecalling or directly output during the basecalling process.

Sequencing Summary: For a comprehensive view of the sequencing run, Dorado can generate a detailed summary, providing insights into the quality, quantity, and other metrics of the sequenced data.

For those seeking further details or facing queries regarding Dorado, please refer to the repository: https://github.com/nanoporetech/dorado


## Emu - Taxonomic Abundance Estimator for 16S Sequences

Overview: Emu specializes in estimating relative abundance from 16S genomic sequences. Engineered to handle both full-length and short-read data, Emu quickly transforms raw sequence data into insightful abundance profiles, making it invaluable for microbial community composition analysis.

-   Full-Length & Short Read Compatibility: Emu seamlessly processes a variety of 16S reads, catering to both full-length and short-read datasets.

-   Fast Analysis: Emu swiftly delivers relative abundance data in a structured .tsv file format, ensuring quick insights.

-   Consistent Directory Management: Results are consistently stored in a './results' folder, simplifying data management.

-   Installation & Database: Emu operates using a comprehensive database derived from rrnDB v5.6 and NCBI 16S RefSeq data. This vast repository contains over 49,000 sequences from nearly 17,500 unique bacterial and archaeal species, ensuring precise abundance estimation.
Recommendation: While using Emu, pairing it with minimap2 version >=2.22 is recommended to prevent potential memory issues associated with certain sequences.

For those seeking further details or facing queries regarding Emu, please refer to the repository: https://gitlab.com/treangenlab/emu


A Sainsburys Fellowship and Root2Res funded project

ChatGPT was used in the process of making the run_pipeline.sh and README.md
