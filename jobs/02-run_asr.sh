#!/bin/bash
#SBATCH --job-name=run_asr
#SBATCH --partition=gpu-single
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=3
#SBATCH --gres=gpu:1
#SBATCH --time=12:00:00
#SBATCH --mem=15gb
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=lukas.erhard@sowi.uni-stuttgart.de

cd /home/st/st_st/st_ac138201/workspaces/gpfs/st_ac138201-ytpop/ytpop

~/nix-portable nix develop --impure --command nixglhost python pipeline/02-run_asr.py
