# NanoTax-Dorado: Next-Generation 16S Metabarcoding

16S metabarcoding is a method which can determine the composition of microbial communities within a given sample.
This pipeline is specifically designed to streamline this process, turning raw sequencing data into a microbial community profile compatible with downstream analysis tools.
At its core, the pipeline employs ONT's Dorado basecaller, ensuring rapid and accurate basecalling for the latest nanopore chemistry.
Taxonomic assignments are handled via [Emu](https://gitlab.com/treangenlab/emu).

## Prerequisites 

This pipeline utilises [snakemake](https://snakemake.readthedocs.io/en/stable/) to handle all the data analysis.
To easily handle this, a base environment `base_environment.yml` has been provided with all required dependencies.
To create this, run the following command:

```
conda env create -f base_environment.yml
```

This will create an environment `snakemake` which should have everything you need installed.
It is automatically activated in the run_snakemake.sh script.
This pipeline was designed to run in a [SLURM environment](https://slurm.schedmd.com/documentation.html).
To allow snakemake to interact with the SLURM job manager to submit jobs, you'll need to use [cookiecutter](https://github.com/cookiecutter/cookiecutter).
This will allow you to build a job template which snakemake will use to wrap around each rule allowing it to be submitted as a SLURM job. To build a profile suitable for SLURM, run the following commands:

```
# Create a snakemake directory in user config
mkdir -p ~/.config/snakemake

cd ~/.config/snakemake

# This will run the setup for the profile - the default settings should be fine, they can always be changed later if necessary!
cookiecutter https://github.com/Snakemake-Profiles/slurm.git
```

## System requirements

This pipeline involves processing large amounts of data, GPU access, and high memory usage, making it unsuitable for execution on personal or low-resource devices.
This pipeline was developed on the Crop Diversity HPC.
For detailed guidance on how to access and use the UK crop diversity cluster for this pipeline, refer to the [help pages](https://help.cropdiversity.ac.uk/index.html).

## Configuration

All configuration is handled by the `config/config.yaml` file:

| Argument | Value |
| --- | --- |
| raw_data_dir | Path to raw data directory. `pod5` files are collected recursively. |
| dorado_path | Path to local installation of dorado. |
| dorado_model | Path to basecalling model. Can be downloaded with `dorado download` |
| emu_db | [emu, rdp, silva, unite-fungi, unite-all] |

## Output

TBC

## Pipeline Rules

###	dorado_basecall

Base calling is the process of translating the raw signal data produced by the sequencer into nucleotide sequences.
This rule utilizes Dorado, the latest basecalling software developed specifically for Oxford Nanopore data.
 
A BAM file, which is a binary version of SAM (Sequence Alignment/Map) file.
This file type stores nucleotide sequence data along with their qualities.

### sort_bam

    Description:
    Once the raw data is base called and stored in a BAM file, it's essential to have it sorted. This rule uses SAMtools, a suite of programs for interacting with high-throughput sequencing data, to sort the BAM file.

    Purpose:
    Sorting ensures the alignments in the BAM file are organized by their position in the reference genome. This arrangement is crucial for efficient and accurate downstream analyses.

### debarcode: Debarcoding

    Description:
    After base calling, the reads are often mixed with different identifiers called barcodes. Debarcoding segregates these reads based on their barcodes. The pipeline continues to use Guppy for this, which is also known for its demultiplexing capabilities.

    Output:
    A set of fastq files, where each file corresponds to a specific barcode.

### filter_reads: Filtering Reads

    Description:
    It's essential to ensure the quality and reliability of the data being analyzed. This rule filters the reads based on specific parameters, ensuring only the most relevant and high-quality data is used for the subsequent steps.

### emu: Taxonomic Assignment with Emu

    Description:
    One of the primary goals of metagenomic analysis is to identify what organisms or taxa are present in a sample. Emu 3.4.5 is a tool that assigns taxonomy to sequence data. In this pipeline, Emu processes the sequence data to output taxonomic graphs, showcasing the diversity and abundance of taxa in the samples.

    Output:
    Taxonomic graphs and tables, giving a detailed view of the microbial composition of the sample.

### emu_subsample: Subsampling and Further Taxonomic Analysis with Emu

    Description:
    For comprehensive analysis or when dealing with vast amounts of data, it might be beneficial to subsample the sequence data. This rule takes a proportion of the original data for further taxonomic investigation with Emu. It ensures that the pipeline's results are consistent even with different data volumes.

### clean_and_plot: Data Visualization

    Description:
    Visualization often makes data interpretation more intuitive. This rule uses R to curate and visualize the taxonomic distribution derived from the samples. Through various plots, researchers can quickly gauge the microbial diversity and prevalence in their samples.

    Output:
    Charts and graphs representing the taxonomic distribution of the analyzed samples.

A Sainsbury's Fellowship and Root2Res funded project
