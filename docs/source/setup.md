# Setup

This github repository documents deployment of the Fast Forward Fragments (FFF) design pipeline (Version 1.0) at the Centre for Medicines Discovery (CMD) at the University of Oxford.

## Prerequisites 

Version 1.0 of the FFF design pipeline is intended for use on the IRIS compute cluster at Diamond Light Source (DLS).
Users should have an active DLS FedID and have setup SSH access to IRIS following the onboarding instructions provided by DLS/Openbind. 
For access to these instructions, please contact Ben Emery (ben.emery@cmd.ox.ac.uk) or Cedric Vallee (cedric.vallee@diamond.ac.uk). 

`git clone https://github.com/xchem/XChem-FFF.git`
`git clone https://github.com/xchem/BulkDock.git`

## Configure Bulkdock

`cd Bulkdock`

python -m bulkdock configure DIR_SLURM_LOGS $HOME2/logs

python -m bulkdock configure FRAGALYSIS_EXPORT_SUBMITTER_NAME <mark>"YOUR NAME"<mark>

python -m bulkdock configure FRAGALYSIS_EXPORT_SUBMITTER_EMAIL <mark>"YOUR EMAIL"<mark>

python -m bulkdock configure FRAGALYSIS_EXPORT_SUBMITTER_INSTITUTION <mark>"YOUR INSTITUTION"<mark>

python -m bulkdock configure SLURM_PYTHON_SCRIPT $HOME2/slurm/run_python.sh

python -m bulkdock configure EMAIL_ADDRESS <mark>"YOUR EMAIL"<mark>

python -m bulkdock create-directories


## Configure Conda Environments

`cd XChem-FFF` 
`conda create -f xchem-fff_environment.yml`
`conda create -f xchem-fragmenstein_environment.yml`


