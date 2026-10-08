# Scaffold Elaboration

This page describes the general XChem-FFF scaffold-elaboration workflow implemented in `Elaboration_Template.ipynb`. For each target, create directories and perform each elaboration iteration in a numbered cycle. The notebook uses the target and cycle variables to derive every path, tag, and output name so that the same workflow can be repeated for another target or cycle without editing hard-coded paths. Please follow the instructions below and run the cell one by one in order to complete the workflow. If you run into any kind of issues, please contact your FFF coordinator.

By the end of a cycle, you will have generated and placed elaborated candidates with [Syndirella](https://syndirella.readthedocs.io/en/latest/), minimised them with [GNINA](https://github.com/gnina/gnina) from [OpenBind rescore](https://github.com/xchem/openbind-rescore) and uploaded them into [HIPPO](https://github.com/xchem/HIPPO). You will also be ready to start the review process of your elaborations on [Fragalysis](https://updated-fragalysis-docs.readthedocs.io/en/docs-md-only/index.html).

## Prerequisites

Before continuing, make sure that you have:

- completed the [Scaffold Design](design.md) and [Pose Generation](pose_generation.md) workflow (if currently working on cycle02);
- OR already completed a Scaffold Elaboration cycle (if currently working on cycle03 onwards);
- a running Jupyter notebook session on IRIS (see {ref}`Start a Jupyter notebook job on IRIS <setup-step2>`);
- a copy of `Elaboration_Template.ipynb` open in that session.

```{important}
Make a copy of `Elaboration_Template.ipynb`, do not edit the template inside the `$XCHEM_FFF` shared directory! It is important to keep the template unchanged so it is available for other users.
```

To copy the template, run the following command on your IRIS terminal:
```bash
cd $HOME2
mkdir XChem-FFF # Only needed if the directory XChem-FFF doesn't exist already
cp $XCHEM_FFF/templates/Elaboration_Template.ipynb $HOME2/XChem-FFF/elaboration_workflow.ipynb
```

```{note}
Target name and cycle IDs can be changed inside the notebook, but you are free to choose to make a copy of `Elaboration_Template.ipynb` for each target (for example, `<target_name>_elaboration_workflow.ipynb`) instead of editing the same notebook for each target you are working on.
```

## Key concepts

An elaboration cycle takes either:
- Scaffolds from cycle01
- Previous elaboration from previous cylces

Elaborations are generated using [Syndirella](https://syndirella.readthedocs.io/en/latest/). Syndirella can automatically place the elaborations using [Fragmenstein](https://fragmenstein.readthedocs.io/en/latest/). [HIPPO](https://hippo-docs.winokan.com/en/stable/) is used to store the data and export it for review in [Fragalysis](https://updated-fragalysis-docs.readthedocs.io/en/docs-md-only/index.html).

## 1. Extract and elaborate poses

The first step is to extract the poses that you want to elaborate from your HIPPO database. You can always elaborate everything, but the chemical space grows exponentially between scaffold design and elaborations, so you might want to limit that space by elaboration only a subselection of the "best" scaffolds. To extract poses from HIPPO, use the `get_by_tag()` function (make sure you tagged your subset in previous step e.g. `"c0X_selected"` with X being the cycle ID of the previous cycle).

Once you have your subselection ready, you can prepare the inputs using HIPPO's `to_syndirella()` function. This will create all the `.csv` files Syndirella needs for the elaboration.

Next, there are some configuration to do to be able to submit all the elaboration jobs at scale on the IRIS cluster. Follow the cells in the Jupyter Notebook and submit your jobs. You should be able to see all your job using the `squeue -u $USER` command.

Once all your jobs are completed, load the outputs into HIPPO using the `add_syndirella_elabs()` function. It is better to wait that all jobs are completed before running this cell from the Jupyter Notebook. By default, `add_syndirella_elabs()` assign a `"syndirella_place"` pose_tag to the data. This is useful to use for the next step.

## 2. Minimised elaborated poses

Syndirella, by default, uses Fragmenstein to place the elaborated compounds. Once all your jobs are completed and all the elaborations are loaded into HIPPO, you can proceed with a GNINA minimisation and rescore. From there onwards, we follow the exact same procedure as describe in [Pose Generation](pose_generation.md) from {ref}`GNINA minimisation and scoring <pose-GNINA>` onwards. Please refer to this part of the documentation for the rest of the elaboration.

## Next steps

If you followed all the final steps explained in [Pose Generation](pose_generation.md), and completed the sanity check and review on Fragalysis. You are ready for the next steps which are: ordering, synthesis or further elaborations.