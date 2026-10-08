# Pose Generation

Now we have our 2D designs, we must generate the 3D poses for scoring. In this version of the XChem-FFF pipeline, we will generate 3D poses using Fragmenstein's Wictor placement function, then minimise these poses in place using GNINA. 

## Prerequisites

Before continuing, make sure that you have:

- completed the [design](design.md) page;
- a running Jupyter notebook session on IRIS (see [Setup - Step 2](setup.md));
- a copy of `Pose_Generation_Template.ipynb` open in that session.

```{important}
Make a copy of `Pose_Generation_Template.ipynb`, do not edit the template inside the `$XCHEM_FFF` shared directory! It is important to keep the template unchanged so it is available for other users.
```

To copy the template, run the following command on your IRIS terminal:
```bash
cd $HOME2
cp $XCHEM_FFF/templates/Pose_Generation_Template.ipynb $HOME2/XChem-FFF/pose_generation_workflow.ipynb
```

```{note}
Target name and cycle IDs can be changed inside the notebook, but you are free to choose to make a copy of `Pose_Generation_Template.ipynb` for each target (for example, `<target_name>_pose_generation_workflow.ipynb`) instead of editing the same notebook for each target you are working on.
```

## Key concepts

To evaluate if the designed compounds from the previous steps are good candidates, they will be placed with the protein structure of one of their original inspirations and scored. Contrary to standard docking procedure, the following placement workflow tries to recapitalutes as much as possible the original pose of the inspirations using restrained protein-ligand methodology. First, the new designs are place using [BulkDock](https://github.com/xchem/BulkDock) (a job manager package for HPC submission of [Fragmenstein](https://github.com/xchem/Fragmenstein) placement jobs, and for loading the poses into [HIPPO](https://github.com/xchem/HIPPO)), and are then minimised and rescored using [GNINA](https://github.com/gnina/gnina) from [OpenBind rescore](https://github.com/xchem/openbind-rescore).

Here is a summary of the scores attributed by each software:

### Fragmenstein placement

- **`energy_score`** — an estimate of binding affinity. More negative/lower values indicate a stronger predicted binder. 
- **`distance_score`** — the deviation between the placed pose of a scaffold compare to its inspirations. Small values mean the scaffold was placed in proximity with the inspirations original position; large values suggest the scaffold placement poorly reflect the original positions of the inspirations.

### GNINA rescore

- **`CNNscore`** — a score value between 0 and 1 that gives the probability of a pose to be "correct", i.e. within 2 Å RMSD of the true binding mode. Higher is better.
- **`CNNaffinity`** — a continuous prediction of binding affinity (a pK-like value, e.g. analogous to pKd/pKi). Higher is better.
- **`CNN_VS`** — `CNNscore × CNNaffinity`. Because it multiplies pose-confidence by predicted affinity, it favours poses that are both geometrically plausible **and** predicted to bind strongly, and is a convenient single metric for ranking.

## 1. Generate Bulkdock compatible inputs for placement jobs.

We must first convert the outputs from Fragmenstein and Knitwork into BulkDock CSV inputs. Run all the cells in the Jupyter Notebook in order, it will:
- Generates the input for the Fragmenstein scaffolds
- Copy them into the correct BulkDock input directory
- Generates the inputs for the Knitwork scaffolds (both pure and impure merges)
- Copy them into the correct BulkDock input directory

## 2. Run Bulkdock placement jobs.

Now we are ready to run the three BulkDock placement commands, these can be ran directly from your pose_generation notebook, or from the terminal:

```bash
python -m bulkdock place <target_name> <target_name>_fragmenstein.csv --split 2000
python -m bulkdock place <target_name> <target_name>_pure_knitwork.csv --split 2000
python -m bulkdock place <target_name> <target_name>_impure_knitwork.csv --split 2000
```

Bulkdock automatically uploads the placed poses to your HIPPO animal and tags them with a new tag in the format '<target_name>_method' e.g. a71ev2az_fragmenstein. These poses must be exported from HIPPO in a format compatible with the Openbind-Rescore workflow for GNINA minimisation and scoring.


(pose-GNINA)=

## 3. Run GNINA minimisation and scoring.

Following the cells in the pose_generation notebook, you can inspect the existing tags associated with poses and export them to the relevant GNINA directories using the animal.poses.to_fragalysis function. 

Now we have compatible file formats, we can run GNINA minimisation and scoring for each method. 

The sbatch scripts can be ran directly from the pose_generation notebook and should be configured to use the outputs you have just generated from HIPPO.

## 4. Import GNINA minimised poses to HIPPO for visualisation.

Finally, the newly minimised poses can be imported into HIPPO for easy visualisation, triaging and further analysis.

Complete the last notebook cells using the animal.load_sdf function to import the poses.

## 5. Sanity check and review

Designed scaffolds can be reviewed in Fragalysis' right hand side. Extract and tag a sensible subset of the `PoseSet` you have just generated (e.g. 20% of the poses with the best `CNN_VS` score from GNINA minimisation and rescoring tagged `"c01_selected"`) and contact your FFF coordinator to have them loaded into Fragalysis. Sanity check that your scaffolds recapitulate their inspiration, and if you are happy with them, continue with the next steps: ordering, synthesis or elaborations. 