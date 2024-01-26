#!/bin/bash
#SBATCH --job-name=transribe
#SBATCH --partition=single
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --gres=gpu:1
#SBATCH --time=110:00:00
#SBATCH --mem=60gb

module load devel/cuda/12.1

cd /home/st/st_st/st_ac138201/ws_ytpop/ytpop

poetry install
poetry run pipeline/02-run-asr.py

