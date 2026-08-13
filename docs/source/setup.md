# Setup

This GitHub repository documents deployment of the Fast Forward Fragments (FFF) design pipeline (Version 1.0) at the Centre for Medicines Discovery (CMD) at the University of Oxford.

## Prerequisites 

Version 1.0 of the FFF design pipeline is intended for use on the IRIS compute cluster at Diamond Light Source (DLS).
Users should have an active DLS FedID and have setup SSH access to IRIS following the onboarding instructions provided by DLS/Openbind. 
For access to these instructions, please contact Ben Emery (ben.emery@cmd.ox.ac.uk) or Cedric Vallee (cedric.vallee@diamond.ac.uk). 

```bash
git clone https://github.com/xchem/XChem-FFF.git
git clone https://github.com/xchem/BulkDock.git
git clone https://github.com/Jnelen/openbind-rescore.git
```

## Configure Bulkdock

`cd Bulkdock`

```bash
python -m bulkdock configure DIR_SLURM_LOGS $HOME2/logs
python -m bulkdock configure FRAGALYSIS_EXPORT_SUBMITTER_NAME "YOUR NAME"
python -m bulkdock configure FRAGALYSIS_EXPORT_SUBMITTER_EMAIL "YOUR EMAIL"
python -m bulkdock configure FRAGALYSIS_EXPORT_SUBMITTER_INSTITUTION "YOUR INSTITUTION"
python -m bulkdock configure SLURM_PYTHON_SCRIPT $HOME2/slurm/run_python.sh
python -m bulkdock configure EMAIL_ADDRESS "YOUR EMAIL"
python -m bulkdock create-directories
```

## Configure Conda Environments

```bash
cd XChem-FFF
conda create -f xchem-fff_environment.yml
conda create -f xchem-fragmenstein_environment.yml
```

## Configure Gnina 

```bash
cd openbind-rescore/gnina/
wget https://github.com/gnina/gnina/releases/download/v1.3.1/gnina1.3.1
mv gnina1.3.1 gnina
chmod +x gnina
singularity pull --disable-cache gnina_singularity.sif oras://ghcr.io/jnelen/gnina_singularity:v1
cd ..
python gnina_rescore.py --help
```

