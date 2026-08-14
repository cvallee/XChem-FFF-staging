#!/bin/bash

#SBATCH --job-name=bash_w_conda

# default
ROOT=<YOUR_ROOT_DIRECTORY>
CONDA_ENV='xchem-fff'
ARGS=$@
CONDA_DIR='conda'

# setup root directories
export DATA=/opt/xchem-fragalysis-2
export HOME=/opt/xchem-fragalysis-2/$ROOT
export HOME2=/opt/xchem-fragalysis-2/$ROOT
export CONDA_PREFIX=$HOME2/$CONDA_DIR

echo $CONDA_PREFIX

# setup environment
export PYTHONUSERBASE=$CONDA_PREFIX
export CONDA_ENVS_PATH=$CONDA_PREFIX/envs
export CONDA_PKGS_DIRS=$CONDA_PREFIX/pkgs
export MAMBA_ALWAYS_YES=yes
export LD_LIBRARY_PATH=/usr/local/cuda/compat:$CONDA_PREFIX/lib:$LD_LIBRARY_PATH;

export PYTHONPATH=$PYTHONPATH:$HOME2/MolParse:$HOME2/HIPPO:$HOME2:$HOME2/syndirella

# splashscreen
echo "************************************************************************"
echo "script         = $0"
echo "whoami         = $(whoami)"
echo "hostname       = $(hostname)"
echo "ip-address     = $(ifconfig | grep -A1 eth0 | grep inet | awk '{print $2}')"
echo "conda-dir      = $CONDA_PREFIX"
echo "conda-env      = $CONDA_ENV"
echo "arguments      = $ARGS"
echo "************************************************************************"

# setup conda
echo 'Activating conda...'
source $CONDA_PREFIX/etc/profile.d/conda.sh
conda activate $CONDA_ENV

echo 'conda info...'
conda info

echo 'python location...'
which python

echo 'running python...'
bash $ARGS

exit $?
