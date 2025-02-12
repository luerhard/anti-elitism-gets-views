#!/bin/bash
#SBATCH --job-name=run_asr
#SBATCH --partition=gpu-single
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=3
#SBATCH --gres=gpu:1
#SBATCH --time=48:00:00
#SBATCH --mem=45gb
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=lukas.erhard@sowi.uni-stuttgart.de

cd /home/st/st_st/st_ac138201/workspaces/gpfs/st_ac138201-ytpop/ytpop

env -u LD_LIBRARY_PATH ~/nix-portable nix develop --command python pipeline/02-run_asr.py
