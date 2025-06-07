#!/bin/bash
#SBATCH --job-name=build_dev
#SBATCH --partition=cpu-single
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH --time=72:00:00
#SBATCH --mem=40gb
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=lukas.erhard@sowi.uni-stuttgart.de

~/nix-portable nix develop --impure --command Rscript pipeline/06-run_regressions.R
