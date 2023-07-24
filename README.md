# Metagenomics analysis

Hello!

This repository contains all the code and stuff used during the 16s metagenomics analysis.

## Prerequisites

This pipeline utilises [snakemake](snakemake.readthedocs.io) to handle all the data analysis.
This pipeline makes use of several dependencies including snakemake.
To easily handle this, a base environment `base_environment.yml` has been provided.
To create this, run the following command:

```
conda env create -f base_environment.yml
```

This will create an environment `snakemake` which should have everything you need installed.
It is automatically activated in the `run_snakemake.sh` script.
This pipeline was designed to run in a SLURM environment.
To allow snakemake to interact with the SLURM job manager to submit jobs, you'll need to use [cookiecutter](https://pypi.org/project/cookiecutter/):
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
