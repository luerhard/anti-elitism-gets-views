#!/bin/bash
#SBATCH --job-name=popbert
#SBATCH --partition=gpu-single
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --gres=gpu:1
#SBATCH --time=08:00:00
#SBATCH --mem=10gb
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=lukas.erhard@sowi.uni-stuttgart.de

cd /home/st/st_st/st_ac138201/workspaces/gpfs/st_ac138201-ytpop/ytpop

~/nix-portable nix develop --impure --command nixglhost python pipeline/04-run_popbert.py
