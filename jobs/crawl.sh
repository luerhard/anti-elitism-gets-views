#!/bin/bash
#SBATCH --job-name=crawl
#SBATCH --partition=cpu-single
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=3
#SBATCH --time=15:00:00
#SBATCH --mem=10gb
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=lukas.erhard@sowi.uni-stuttgart.de

~/nix-portable nix develop --impure --command python scripts/crawler/01-crawl_channels.py
