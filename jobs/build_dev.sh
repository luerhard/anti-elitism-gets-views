#!/bin/bash
#SBATCH --job-name=build_dev
#SBATCH --partition=cpu-single
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --time=03:00:00
#SBATCH --mem=10gb
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=lukas.erhard@sowi.uni-stuttgart.de

cd /home/st/st_st/st_ac138201/workspaces/gpfs/st_ac138201-ytpop/ytpop

~/nix-portable nix develop --impure
