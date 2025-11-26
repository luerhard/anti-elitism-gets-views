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

~/nix-portable nix develop --impure --command uv run pipeline/04-run_popbert.py
