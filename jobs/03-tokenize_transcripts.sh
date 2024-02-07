#!/bin/bash
#SBATCH --job-name=transcribe
#SBATCH --partition=single
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --time=03:00:00
#SBATCH --mem=10gb
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=lukas.erhard@sowi.uni-stuttgart.de

cd /home/st/st_st/st_ac138201/ws_ytpop/ytpop

poetry install
poetry run python pipeline/03-tokenize_transcripts.py
