#!/bin/bash
#SBATCH --job-name=transcribe
#SBATCH --partition=cpu-single
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --time=03:00:00
#SBATCH --mem=10gb
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=lukas.erhard@sowi.uni-stuttgart.de

~/nix-portable nix develop --impure --command uv run pipeline/03-tokenize_transcripts.py
