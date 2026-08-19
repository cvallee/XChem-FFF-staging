#!/bin/bash

#SBATCH --job-name=notebook

# default
CONDA_ENV='base'
CONDA_DIR='conda'
JUPYTER_CONFIG_DIR='jupyter'
PORT=9500
ARGS=$@

# CLI
while test $# -gt 0; do
    case "$1" in
        -h|--help)
            echo -e "Usage for notebook.sh:"
            echo -e "-h | --help => Show this help screen"
            echo -e "-p | --port [PORT] => Specify the port for SSH forwarding"
            echo -e "-d | --dir [DIR] => Specify the data directory (relative to /opt/xchem-fragalysis-2)"
            echo -e "-cd | --conda-dir [DIR] => Specify the conda root (relative to --dir)"
            echo -e "-ce | --conda-env [ENV='base'] => Specify the conda environment"
            echo -e "-jc | --jupyter-config [DIR] => Specify the jupyter config directory (relative to --dir)"
            echo -e "-js | --jupyter-setup [PASSWORD] => Configure jupyter with the given password"
            exit 1
            ;;
        -p|--port)
            shift
            JUPYTER_PORT=$1
            shift
            ;;
        -d|--dir)
            shift
            ROOT=$1
            shift
            ;;
        -cd|--conda-dir)
            shift
            CONDA_DIR=$1
            shift
            ;;
        -ce|--conda-env)
            shift
            CONDA_ENV=$1
            shift
            ;;
        -jc|--jupyter-config)
            shift
            JUPYTER_CONFIG_DIR=$1
            shift
            ;;
        -js|--jupyter-setup)
            shift
            JUPYTER_SETUP=1
            ;;
        -ajc|--absolute-jupyter-config)
            shift
            ABSOLUTE_JUPYTER_CONFIG=1
            ;;
        *)
            echo "Unknown command line option: $1"
            echo "See notebook.sh --help for usage."
            exit 2
            ;;
    esac
done

# if [ -z "$JUPYTER_PORT" ]; then
#     if [ -z "$JUPYTER_SETUP" ]; then
#         echo "--port not specified";
#         exit 3;
#     fi
# fi

if [ -z "$ROOT" ]; then echo "--dir not specified"; exit 3; fi
# if [ -z "$CONDA_DIR" ]; then echo "--conda-dir not specified"; exit 3; fi
# if [ -z "$JUPYTER_CONFIG_DIR" ]; then echo "--jupyter-config not specified"; exit 3; fi

# setup root directories
export DATA=/opt/xchem-fragalysis-2
export HOME=/opt/xchem-fragalysis-2/$ROOT
export HOME2=/opt/xchem-fragalysis-2/$ROOT

if [ -n "$ABSOLUTE_JUPYTER_CONFIG" ] ; then
    export JUPYTER_CONFIG_DIR=$JUPYTER_CONFIG_DIR
    export IPYTHONDIR="$(dirname $JUPYTER_CONFIG_DIR)/.ipython"
    export JUPYTER_DATA_DIR="$(dirname $JUPYTER_CONFIG_DIR)/.jupyter"
else
    export JUPYTER_CONFIG_DIR=$HOME2/$JUPYTER_CONFIG_DIR
fi

export CONDA_PREFIX=$HOME2/$CONDA_DIR

# setup environment
export PYTHONUSERBASE=$CONDA_PREFIX
export PYTHONPATH=$
export CONDA_ENVS_PATH=$CONDA_PREFIX/envs
export CONDA_PKGS_DIRS=$CONDA_PREFIX/pkgs
export MAMBA_ALWAYS_YES=yes
export LD_LIBRARY_PATH=/usr/local/cuda/compat:$CONDA_PREFIX/lib:$LD_LIBRARY_PATH;

# splashscreen
echo "************************************************************************"
echo "script         = $0"
echo "whoami         = $(whoami)"
echo "hostname       = $(hostname)"
echo "ip-address     = $(ifconfig | grep -A1 eth0 | grep inet | awk '{print $2}')"
echo "port           = $JUPYTER_PORT"
echo "dir            = $HOME2"
echo "jupyter-config = $JUPYTER_CONFIG_DIR"
echo "IPYTHONDIR     = $IPYTHONDIR"
echo "conda-dir      = $CONDA_PREFIX"
echo "conda-env      = $CONDA_ENV"
echo "arguments      = $ARGS"
echo "************************************************************************"

export CONDA_SHLVL=0

# setup conda
echo 'Activating conda...'
source $CONDA_PREFIX/etc/profile.d/conda.sh
conda activate $CONDA_ENV

conda info

# if --jupyter-setup
if [ -n "$JUPYTER_SETUP" ] ; then
    echo 'Configuring notebook...'
    jupyter notebook --generate-config
    # yes $PASSWORD | jupyter server password
    jupyter server password
    echo 'Notebook configured, please re-run job without --jupyter-setup'

else

    # run notebook
    while true
    do
        echo 'Launching notebook...'
        jupyter lab --ip="0.0.0.0" --no-browser --NotebookNotary.db_file=':memory:' --port=$JUPYTER_PORT
    done

fi