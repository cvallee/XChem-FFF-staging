# Pose Generation

Now we have our 2D designs, we must generate the 3D poses for scoring. In this version of the XChem-FFF pipeline, we will generate 3D poses using Fragmenstein's Wictor placement function, then minimise these poses in place using GNINA. 

## Prerequisites

Before continuing, make sure that you have:

- completed the [design](design.md) page;
- a running Jupyter notebook session on IRIS (see [Setup - Step 2](setup.md));
- a copy of `Pose_Generation_Template.ipynb` open in that session.

```{note}
Make a copy of `Pose_Generation_Template.ipynb` for each target (for example, `<target_name>_pose_generation_workflow.ipynb`). Keep the template unchanged so it is available for the next target.
```

To copy the template, run the following command on your IRIS terminal:
```bash
cd $HOME2
cp $XCHEM_FFF/templates/Pose_Generation_Template.ipynb $HOME2/XChem-FFF/pose_generation_workflow.ipynb
```

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

## 3. Run GNINA minimisation and scoring.

Following the cells in the pose_generation notebook, you can inspect the existing tags associated with poses and export them to the relevant GNINA directories using the animal.poses.to_fragalysis function. 

Now we have compatible file formats, we can run GNINA minimisation and scoring for each method. 

The sbatch scripts can be ran directly from the pose_generation notebook and should be configured to use the outputs you have just generated from HIPPO.

## 4. Import GNINA minimised poses to HIPPO for visualisation.

Finally, the newly minimised poses can be imported into HIPPO for easy visualisation, triaging and further analysis.

Complete the last notebook cells using the animal.load_sdf function to import the poses.
