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

~/nix-portable nix develop --impure --command uv run pipeline/02-run_asr.py
