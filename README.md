# Next-Generation 16S Metabarcoding

16S metabarcoding is a method which can determine the composition of microbial communities within a given sample.
This pipeline is specifically designed to streamline this process, turning raw sequencing data into a microbial community profile compatible with downstream analysis tools.
At its core, the pipeline employs ONT's Dorado basecaller, ensuring rapid and accurate basecalling for the latest nanopore chemistry.
Taxonomic assignments are handled via [Emu](https://gitlab.com/treangenlab/emu).

## A note on conda

It is highly recommend you install [mamba](https://github.com/conda-forge/miniforge#mambaforge) rather than relying on conda.
It's a lot faster than mamba.
Follow the instructions in the link to get started.

## Prerequisites 

This pipeline utilises [snakemake](https://snakemake.readthedocs.io/en/stable/) to handle all the data analysis.
To easily handle this, a base environment `base_environment.yml` has been provided with all required dependencies.
To create this, run the following command:

```
mamba env create -f base_environment.yml
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

All results will be available under the `results/` directory.
Results include rudimentary richness and rarefaction curve plots, as well as top 10 genera.
A phyloseq object is also created and saved as an `.rds` object for easy integration into downstream analysis.

A Sainsbury's Fellowship and Root2Res funded project

![jhi](resources/jhi_adjusted.png)
![gatsby](resource/../resources/logo-v.png)
