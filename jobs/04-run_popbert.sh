#!/bin/bash
#SBATCH --job-name=transcribe
#SBATCH --partition=single
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --gres=gpu:1
#SBATCH --time=08:00:00
#SBATCH --mem=10gb
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=lukas.erhard@sowi.uni-stuttgart.de

module load devel/cuda/12.1

cd /home/st/st_st/st_ac138201/ws_ytpop/ytpop

poetry install
poetry run python pipeline/04-run_popbert.py
