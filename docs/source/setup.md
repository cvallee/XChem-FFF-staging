# Setup

This page describes how to set up the XChem-FFF pipeline tools on the IRIS compute cluster at Diamond Light Source (DLS).

## Prerequisites

Version 1.0 of the XChem-FFF design pipeline is intended for use on the IRIS compute cluster at DLS.

Before continuing, make sure that you have:

- an active DLS FedID;
- configured SSH access to IRIS; and
- set up your IRIS environment as described in the onboarding instructions.

## Step 1 — Start a Jupyter notebook job

The XChem-FFF workflow can be run from a Jupyter notebook on an IRIS compute node. The following steps configure and submit a Jupyter notebook job using SLURM.

### 1a. Set your working directory

Set the `DATA` and `HOME2` environment variables. Replace `<WORKDIR>` with the name of your own working directory.

```bash
export DATA=/opt/xchem-fragalysis-2
export HOME2=$DATA/<WORKDIR>
```

### 1b. Configure Jupyter

Change to your working directory:

```bash
cd "$HOME2"
```

Configure Jupyter. Replace `<WORKDIR>` with the name of your working directory.

```bash
bash "$HOME2/slurm/notebook.sh" -p 9500 -d <WORKDIR> -cd conda -jc "$HOME2/jupyter_slurm" -ce py310 -ajc -js
```

### 1c. Submit the notebook job

Submit the Jupyter notebook job to SLURM:

```bash
sbatch --job-name notebook --partition main "$HOME2/slurm/notebook.sh" -p 9500 -d WORKDIR -cd conda -jc "$HOME2/jupyter_slurm" -ce py310 -ajc
```

### 1d. Find the `NODELIST`

Check the SLURM queue for your FedID:

```bash
squeue -u <FED_ID>
```

You should see output similar to the following:

```text
JOBID PARTITION NAME USER ST TIME NODES NODELIST(REASON)
1240588 main notebook FED_ID R 9-17:06:50 1 host-192-168-222-102
```

Make a note of the host shown under `NODELIST`. You will need its IP address to connect to the notebook.

### 1e. Connect to the notebook

From a new terminal on your local machine, create an SSH connection to the compute node. Replace `<FED_ID>` with your DLS FedID and `<NODE_IP>` with the IP address from the `NODELIST` output above.

```bash
ssh -L 9500:<NODE_IP>:9500 -J <FED_ID>@ssh.diamond.ac.uk <FED_ID>@cepheus-slurm.diamond.ac.uk
```

For example, if the node is `host-192-168-222-102`, then `<NODE_IP>` is `192.168.222.102`.

### 1f. Open Jupyter

On your local machine's browser, open a window and go to:

```text
http://localhost:9500
```

## Step 2 — Clone the repositories

Change to your working directory:

```bash
cd "$HOME2"
```

Clone the XChem-FFF, BulkDock, Fragmenstein, Fragalysis, OpenBind, HIPPO, and Rescore repositories into your working directory:

```bash
git clone https://github.com/xchem/XChem-FFF.git
git clone https://github.com/xchem/BulkDock.git
git clone https://github.com/xchem/fragalysis
git clone https://github.com/xchem/Fragmenstein.git
git clone https://github.com/xchem/openbind-hippo
git clone https://github.com/Jnelen/openbind-rescore.git
```

## Step 3 — Configure BulkDock

Change to the BulkDock repository:

```bash
cd "$HOME2/BulkDock"
```

Configure BulkDock with your working directory and Fragalysis submission details. Replace the values in quotation marks with your own details.

```bash
python -m bulkdock configure DIR_SLURM_LOGS "$HOME2/logs"
python -m bulkdock configure FRAGALYSIS_EXPORT_SUBMITTER_NAME "YOUR NAME"
python -m bulkdock configure FRAGALYSIS_EXPORT_SUBMITTER_EMAIL "YOUR EMAIL"
python -m bulkdock configure FRAGALYSIS_EXPORT_SUBMITTER_INSTITUTION "YOUR INSTITUTION"
python -m bulkdock configure SLURM_PYTHON_SCRIPT "$HOME2/slurm/run_python.sh"
python -m bulkdock configure EMAIL_ADDRESS "YOUR EMAIL"
python -m bulkdock create-directories
```

It is also useful to set a `BULK` variable now:

```bash
export BULK="$HOME2/BulkDock"
cd "$BULK"
```

## Step 4 — Configure Fragalysis

Change to the Fragalysis repository:

```bash
cd "$HOME2/fragalysis"
```

Install Fragalysis:

```bash
pip install -e . --user
```

## Step 5 — Configure Conda environments

Change to the XChem-FFF repository:

```bash
cd "$HOME2/XChem-FFF"
```

Create the Conda environments required by the pipeline:

```bash
conda env create -f xchem-fff_environment.yml
conda env create -f xchem-fragmenstein_environment.yml
```

## Step 6 — Configure GNINA

Change to the GNINA directory in the OpenBind Rescore repository:

```bash
cd "$HOME2/openbind-rescore/gnina"
```

Download GNINA v1.3.1:

```bash
wget https://github.com/gnina/gnina/releases/download/v1.3.1/gnina1.3.1
mv gnina1.3.1 gnina
chmod +x gnina
```

Pull the GNINA Singularity image:

```bash
singularity pull --disable-cache gnina_singularity.sif oras://ghcr.io/jnelen/gnina_singularity:v1
```

Return to the OpenBind Rescore directory and check that `gnina_rescore.py` can be run:

```bash
cd ..
python gnina_rescore.py --help
```

If the setup has completed successfully, this command should display the available options for `gnina_rescore.py`.

## Next steps

You are now ready to start your first FFF project. Continue to the [Design](design.md) page.