# Metagenomics analysis

Hello!

This repository contains all the code and stuff used during the 16s metagenomics analysis.

## Prerequisites

This pipeline utilises [snakemake](snakemake.readthedocs.io) to handle all the data analysis.
To run snakemake, we first need to install snakemake.
If using conda, run the command:

```
conda install -c bioconda snakemake
```

This will install snakemake into your base conda environment (assuming you already have it installed!).
This pipeline was designed to run in a SLURM environment.
To allow snakemake to interact with the SLURM job manager to submit jobs, you'll first need to install [cookiecutter](https://pypi.org/project/cookiecutter/):

```
conda install -c conda-forge cookiecutter
```

This will allow you to build a job template which snakemake will use to wrap around each rule allowing it to be submitted as a SLURM job. To build a profile suitable for SLURM, run the following commands:

```
# Create a snakemake directory in user config
mkdir -p ~/.config/snakemake

cd ~/.config/snakemake

# This will run the setup for the profile - the default settings should be fine, they can always be changed later if necessary!
cookiecutter https://github.com/Snakemake-Profiles/slurm.git
```

## Project Focus

Rhizosphere to Root Exudate interaction and phylogenetic analysis comparing Illumina Mysiq short read vs ONT MinION long read sequences.

A Sainsbury's Undergraduate Studentship funded by the Gatsby Foundation