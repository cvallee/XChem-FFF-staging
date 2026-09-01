# Scaffold Design

This page describes the general XChem-FFF scaffold-design workflow implemented in `Design_Template.ipynb`. For each target, create a target directory and perform each design iteration in a numbered cycle directory. The notebook uses the target and cycle variables to derive every path, tag, and output name so that the same workflow can be repeated for another target or cycle without editing hard-coded paths.

By the end of a cycle, you will have generated scaffold candidates with [Fragmenstein](https://fragmenstein.readthedocs.io/en/latest/) and/or [Knitwork](https://github.com/xchem/Knitwork), placed them with BulkDock, and loaded the BulkDock poses into HIPPO.

## Prerequisites

Before continuing, make sure that you have:

- completed the [Onboarding](onboarding.md) and [Setup](setup.md) pages;
- a running Jupyter notebook session on IRIS (see {ref}`Start a Jupyter notebook job on IRIS <setup-step2>`);
- a copy of `Design_Template.ipynb` open in that session.
- a running Jupyter notebook job on Squonk (see {ref}`Start a Jupyter notebook job on Squonk <setup-step2>`);

```{note}
Make a copy of `Design_Template.ipynb` for each target (for example, `<target_name>_design_workflow.ipynb`). Keep the template unchanged so it is available for the next target.
```

To copy the template, run the following command on your IRIS terminal (change `<target_name>` to the corresponding Fragalysis target you are working on):
```bash
cp $XCHEM_FFF/templates/Design_Template.ipynb $HOME2/XChem-FFF/<target_name>/<target_name>_design_workflow.ipynb
```

## Key concepts

A design cycle takes experimentally observed fragment hits and creates larger candidate scaffolds predicted to bind in the same pocket.

- **[Fragalysis](https://updated-fragalysis-docs.readthedocs.io/en/docs-md-only/index.html)** stores experimental fragment hits. Use curator tags to identify the poses to merge.
- **[HIPPO](https://hippo-docs.winokan.com/en/stable/)** records the target's compounds, poses, and reactions in a SQLite database. In the notebook, this database is represented by the `animal` object.
- **[Fragmenstein](https://fragmenstein.readthedocs.io/en/latest/)** merges overlapping fragment-hit poses and energy-minimises the resulting scaffold in the protein pocket.
- **[Knitwork](https://github.com/xchem/Knitwork)** generates complementary pure and impure scaffold merges from the same set of fragment hits.

## 1. Download and initialise a target

In the first notebook cells, run the Fragalysis download widget and download the aligned files to `$BULK/TARGETS`. Set the following values in the configuration cell:

```python
target_name = "Target name"
cycle_number = 1
```

`target_name` must exactly match the directory name created by the Fragalysis download. 

Run the directory-creation cells next. They create the cycle directory and its required subdirectories, then copy `aligned_files` from `$BULK/TARGETS/<target_name>` to `$HOME2/XChem-FFF/<target_name lowercase>`.

## Directory layout

All design work is kept below `$HOME2/XChem-FFF`. The notebook creates the following directory tree after you set `target_name` and `cycle_number`:

```text
$HOME2/XChem-FFF/
└── <target_name lowercase>/
	├── <target_name>_design_workflow.ipynb
	├── aligned_files/
	└── cycle_01/
		├── hits.sdf
		├── fragmenstein/
		├── knitwork/
		│   ├── knitwork_pure_output/
		│   └── knitwork_impure_output/
		├── gnina/
		│   ├── inputs/
		│   │   ├── fragmenstein/
		│   │   ├── knitwork_pure/
		│   │   └── knitwork_impure/
		│   └── outputs/
		│       ├── fragmenstein/
		│       ├── knitwork_pure/
		│       └── knitwork_impure/
		└── moccassin_outputs/
```

For a later design round for the same target, increment `cycle_number`; the notebook will create `cycle_02`, `cycle_03`, and so on. Do not use the BulkDock target directory as the cycle working directory: it stores the downloaded target files and HIPPO database, while `$HOME2/XChem-FFF` stores your design-cycle results.


## 2. Set up BulkDock and HIPPO

BulkDock creates the HIPPO database once per target. In a terminal, run:

```bash
conda activate xchem-fff    ### xchem-fff environment will be used throughout this work
cd "$BULK"
python -m bulkdock setup <target_name>
```

This creates `$BULK/TARGETS/<target_name>/<target_name>.sqlite`. Back in the notebook, run the HIPPO setup cells. They deliberately use `bulk_target_dir` for this database, leaving `target_dir` reserved for the cycle work under `$HOME2/XChem-FFF`.

## 3. Select fragment hits and prepare inputs

In Fragalysis, tag the fragment-hit poses you want to merge. In the notebook:

1. Run `animal.tags` to list available tags.
2. Set `merge_tag` to the selected Fragalysis tag.
3. Run the fragment-input cells to write `hits.sdf` to the cycle directory.
4. Run the reference-pose cell to copy a ligand-stripped reference protein into `fragmenstein_dir`.

The same `hits.sdf` is used by both Fragmenstein and Knitwork.

## 4. Generate candidate scaffolds

### Fragmenstein

Run the path-printing notebook cell and use the reported `fragmenstein_dir` in a terminal:

```bash
cd <fragmenstein_dir>
sbatch --job-name "fragmenstein" --mem 16000 "$HOME2/slurm/run_bash_with_xchem-fragmenstein_conda.sh" "$HOME2/slurm/run_fragmenstein.sh"
```

Fragmenstein produces merged scaffolds using the fragment hits and reference protein placed in this directory.

### Knitwork

First you need to import `hits.sdf` to Squonk. Copy the file from IRIS to your local machine using the following command on your local terminal:
```bash
scp -J <yourfedid>@ssh.diamond.ac.uk <yourfedid>@cepheus-slurm.diamond.ac.uk:/<path_to_hits_file>/hits.sdf /<local_path>/
```
Change `<yourfedid>`, `<path_to_hits_file>`, and `<local_path>` to your FedID, the full path where `hits.sdf` can be found (you can use `pwd` in the directory where `hits.sdf` is) and the local path on your machine where you want the file to be copied to, respectively.

In your Squonk Project, go to the `Project Data` tab. Create a new directory corresponding to your current target by clicking on the folder icon with a + sign (next to the Search box). The new folder should appear, click on it. Then, upload your `hits.sdf` using the Upload icon (a cloud with an arrow, next to the create directory icon).

Then, go to the `Results` tab and open your JupyterNotebook app. Make sure you have {ref}`set up Knitwork <setup-knitwork>` before continuing.

Open a new Terminal, and make sure knitwork installation is still available:
```bash
pip freeze | grep Knitwork
```
You should see something starting like that
```bash
-e git+https://github.com/xchem/Knitwork.git
```
If you don't see the above line as an output of the `pip freeze | grep Knitwork` you will need to reinstall Knitwork:
```bash
cd Knitwork
pip install -e .
cd ../
```
```{note}
If you have properly set up Knitwork, you do not need to reset it up again after the second pip install. Your configuration is saved into the config.json file
```

Now you should be able to run Knitwork. First, you need to create fragment pairs (change `<path_to_hits_file>` to the actual path where the hits.sdf is located):
```bash
cd <path_to_hits_file>
python -m knitwork fragment hits.sdf
```
This will create a `fragment_output` subdirectory. The output from `knitwork fragment` will directly be used for merges.
Now, run the following commands:
```bash
python -m knitwork pure-merge
python -m knitwork impure-merge
```

Pure merges retain the fragment cores; impure merges allow small core changes based on similarity. Download the `.sdf` files from the resulting `knitwork_pure_output` and `knitwork_impure_output` directories (using the Download icon under Actions in Project Data where the files are stored) and copy them into the current cycle's `knitwork` directory on IRIS using `scp`.

## Next steps

For another design iteration on the same target, increment `cycle_number`, repeat this workflow, and keep the earlier cycle directory unchanged. For the next step, continue to the [Pose generation](pose_generation.md) page.
