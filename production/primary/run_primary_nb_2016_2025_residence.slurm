#!/bin/bash
#SBATCH --job-name=chik_nb_residence
#SBATCH --output=logs/chik_nb_residence_2016_2025_%j.out
#SBATCH --error=logs/chik_nb_residence_2016_2025_%j.err
#SBATCH --partition=cac_cpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --time=24:00:00

echo "Job ID: $SLURM_JOB_ID"
echo "Node: $(hostname)"
echo "Start: $(date)"
echo "Working directory: $(pwd)"

module load anaconda3/2025.06
source /opt/ohpc/pub/software/anaconda3/etc/profile.d/conda.sh
conda activate inla_geo

export R_LIBS_USER=$HOME/R/4.6.0
export LD_LIBRARY_PATH="$HOME/local/flexiblas/lib64:$HOME/local/flexiblas/lib64/flexiblas:$CONDA_PREFIX/lib:$HOME/local/R-4.6.0/lib64/R/lib:$HOME/local/expat/lib:$HOME/local/udunits2/lib:$LD_LIBRARY_PATH"

mkdir -p logs results

$HOME/local/R-4.6.0/bin/Rscript 02_fit_primary_nb_2016_2025_residence.R

echo "End: $(date)"
