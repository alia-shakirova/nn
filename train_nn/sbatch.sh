#!/bin/bash
#SBATCH --account=rrg-yihuang-ad
#SBATCH --nodes=1
#SBATCH --time=10:00:00           # time (DD-HH:MM)
#SBATCH --job-name=nn_train
#SBATCH --mem-per-cpu=20GB

cd  /home/aliia/projects/rrg-yihuang-ad/aliia/nn/train_nn/
module load matlab/2018a
srun matlab -nodisplay -singleCompThread -r "train_arctic_nn_tsr"

