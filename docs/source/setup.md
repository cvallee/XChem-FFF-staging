# Setup

This page describes how to set up the XChem-FFF pipeline tools.

## Prerequisites

Version 1.0 of the XChem-FFF design pipeline is intended for use on the IRIS compute cluster at DLS and on Squonk.

Before continuing, make sure that you followed the [Onboarding](onboarding.md) instructions and have:

- an active DLS FedID;
- configured SSH access to IRIS;
- set up your IRIS profile; and
- got access to Squonk

## Step 1 - Installing and setting up conda

### 1a. Install Miniconda

Set the conda installation prefix to your working directory to avoid filling your home quota:

```bash
export CONDA_PREFIX=$HOME2/<WORKDIR>/conda

curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
bash Miniforge3-Linux-x86_64.sh -p $CONDA_PREFIX -b
source $CONDA_PREFIX/etc/profile.d/conda.sh

conda info   # confirm base environment is active
```

### 1b. Create the xchem-fff environment

Create a conda environment (execute each line at a time)

```{note}
When running the `pip cache dir` command, please make sure that the output look like `/opt/xchem-fragalysis-2/<WORKDIR>/.cache/pip`. If it doesn't, you might run into an error when running `pip install --no-deps -r $XCHEM_FFF/xchem-fff_requirements.txt`. If that is the case, please contact your FFF coordinator.
```

```bash
cd $HOME2
conda create -f $XCHEM_FFF/xchem-fff_environment.yml
conda activate xchem-fff
pip cache dir
pip install --no-deps -r $XCHEM_FFF/xchem-fff_requirements.txt
```

```{important}
You only need to do this step once. If the `xchem-fff` environment already exists (you can check by running `conda env list`) you don't need to repeat this step, you can activate the environment by running `conda activate xchem-fff`.
```

### 1c. Update your login profile

If you followed the onboarding instructions, your `.bashrc_local` file should contain the following lines:

```bash
if [ $(hostname) == 'cs05r-sc-cloud-30.diamond.ac.uk' ] ; then
    export DATA=/opt/xchem-fragalysis-2
    export HOME2=$DATA/<WORKDIR>
    export XCHEM_FFF=$DATA/XChem-FFF
    export LOGS=$HOME2/logs
    export PIP_CACHE_DIR=$HOME2/.cache/pip
fi
```

Edit `.bashrc_local` to match the following:

```bash
if [ $(hostname) == 'cs05r-sc-cloud-30.diamond.ac.uk' ] ; then
    export DATA=/opt/xchem-fragalysis-2
    export HOME2=$DATA/<WORKDIR>
    export XCHEM_FFF=$DATA/XChem-FFF
    export LOGS=$HOME2/logs
    export PIP_CACHE_DIR=$HOME2/.cache/pip
    export BULK=$HOME2/src/xchem-bulkdock

    # Activate conda
    export CONDA_PREFIX=$HOME2/conda
    source $CONDA_PREFIX/etc/profile.d/conda.sh
    conda activate xchem-fff
fi
```

Now the `xchem-fff` environment will automatically be activated everytime you log into IRIS (you should see something like `(xchem-fff)[<yourfedid>@cs05r-sc-cloud-30 <WORKDIR>]` on the terminal).

```{important}
As explained in the onboarding instructions: this edit must be done on a **Diamond machine** (e.g. a DLS Linux desktop or login node), not on IRIS. `nano` is not installed on IRIS. Because your home directory is shared across Diamond systems, the change will take effect when you next log in to IRIS.
```

Load the changes in your current session:

```bash
source ~/.bashrc_local
```

(setup-step2)=

## Step 2 — Start a Jupyter notebook job

The XChem-FFF workflow can be run from a Jupyter notebook on an IRIS compute node. The following steps configure and submit a Jupyter notebook job using SLURM.

### 2a. Configure Jupyter

Create a `slurm` directory in your working directory:

```bash
cd "$HOME2"
mkdir slurm
```

Configure Jupyter. Replace `<WORKDIR>` with the name of your working directory.

```bash
cp $XCHEM_FFF/scripts/notebook.sh $HOME2/slurm/
bash "$HOME2/slurm/notebook.sh" -p 9500 -d <WORKDIR> -cd conda -jc "$HOME2/jupyter_slurm" -ce xchem-fff -ajc -js
```
```{note}
This should ask you to set up a password for your notebook (this is optional, if you don't want a password, press RETURN twice)
```

### 2b. Submit the notebook job

Submit the Jupyter notebook job to SLURM:

```bash
sbatch --job-name notebook --exclusive --partition main "$HOME2/slurm/notebook.sh" -p 9500 -d <WORKDIR> -cd conda -jc "$HOME2/jupyter_slurm" -ce xchem-fff -ajc
```

### 2c. Find the `NODELIST`

Check the SLURM queue for your FedID:

```bash
squeue -u <yourfedid>
```

You should see output similar to the following:

```text
JOBID PARTITION NAME USER ST TIME NODES NODELIST(REASON)
1240588 main notebook <yourfedid> R 0-00:01:50 1 host-192-168-222-102
```

Make a note of the host shown under `NODELIST`. You will need its IP address to connect to the notebook.

### 2d. Connect to the notebook

From a new terminal on your local machine, create an SSH connection to the compute node. Replace `<yourfedid>` with your DLS FedID and `<NODE_IP>` with the IP address from the `NODELIST` output above.

```bash
ssh -L 9500:<NODE_IP>:9500 -J <yourfedid>@ssh.diamond.ac.uk <yourfedid>@cepheus-slurm.diamond.ac.uk
```

For example, if the node is `host-192-168-222-102`, then `<NODE_IP>` is `192.168.222.102`.

```{note}
If you are already connected to a Diamond machine (e.g. using NoMachine) you do not need to do a proxy jump. Run the following command instead: `ssh -L 9500:<NODE_IP>:9500 <yourfedid>@cepheus-slurm.diamond.ac.uk`
```

### 2e. Open Jupyter

On your local machine's browser, open a window and go to:

```text
http://localhost:9500
```

## Step 3 — Configure BulkDock

Configure BulkDock with your working directory and Fragalysis submission details. Replace `<WORKDIR>` with the name of your working directory and the values in quotation marks with your own details.

```bash
cd $HOME2
cp $XCHEM_FFF/scripts/run_python.sh $HOME2/slurm/
sed -i 's/__YOUR_WORKDIR__/<WORKDIR>/g' $HOME2/slurm/run_python.sh

python -m bulkdock configure DIR_SLURM_LOGS "$HOME2/logs"
python -m bulkdock configure FRAGALYSIS_EXPORT_SUBMITTER_NAME "YOUR NAME"
python -m bulkdock configure FRAGALYSIS_EXPORT_SUBMITTER_EMAIL "YOUR EMAIL"
python -m bulkdock configure FRAGALYSIS_EXPORT_SUBMITTER_INSTITUTION "YOUR INSTITUTION"
python -m bulkdock configure SLURM_PYTHON_SCRIPT "$HOME2/slurm/run_python.sh"
python -m bulkdock configure EMAIL_ADDRESS "YOUR EMAIL"
python -m bulkdock create-directories
```

## Step 4 - Configure a Squonk project

Place holder for configuring a Squonk project

## Next steps

You are now ready to start your first FFF project. Continue to the [Design](design.md) page.