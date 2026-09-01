# Contribution

The FFF pipeline at XChem is an open source, we welcolme external contribution to enhance our current workflow from fragments to new designs. If you think that your software could be included in our pipeline please follow the steps below before reaching out to us.

## Step 1 - Onboarding and set up

As the XChem-FFF pipeline has mainly been developped for use on IRIS compute cluster at DLS, please make sure you followed the [Onboarding](onboarding.md) and [Setup](setup.md) steps before continuing.

Once set up, you should be connected to IRIS and you should have your `xchem-fff` environment active.

### 1a. Compatibility with the `xchem-fff` environment

When installing your software, please make sure to do so within the `xchem-fff` environment.

```{note}
Some of the packages installed in `xchem-fff` have clashing dependencies, hence the `--no-deps` flag during the set up.
```

If your software does not install properly within the `xchem-fff` environment, please create a separate conda environment for your tools, export it as a yaml file and share some installation instruction.

### 1b. Working with Squonk

If your software isn't compatible with IRIS or the `xchem-fff` environment, you could also contribute to the pipeline by setting your software jobs on Squonk. Please follow the {ref}`Squonk Onboarding <squonk-access>` steps to get access to Squonk.

Similarly to Knitwork (see documentation [here](design.md)), you can launch a Notebook job to test installing and running your software. It will also be possible to create a specific Squonk job for your software, if you would like to do so, please talk to your FFF coordinator

## Step 2 - Running jobs within the pipeline

For optimal user experience, if you want your software to be included in the pipeline, you would have to make sure it accepts inputs from the pipeline and to make sure it generates outputs readible by the pipeline tools (e.g. if your software merges fragment, the output should be readible by the pose generation tools). If such files aren't produced by default and you are using standalone scripts to convert inputs/outputs into pipeline-ready format, please share the scripts as well.

Ideally, jobs executed with you tools should be included in the Notebook templates. Please provide a new template with a brief explanations on what the software does and how to run it.

If the jobs are requiring a lot of computational resources, they should be launched as SLURM jobs. You can follow the same procedure as submitting SLURM jobs in the Scaffold [Design](design.md) and [Elaboration](elaboration.md) instructions. If you do need to run a SLURM job for your software, please share the SLURM script as well.

## Step 3 - Sharing with the XChem-FFF team

Finally, once you have completed your jobs using your software, contact your FFF coordinator and share all the relevant files mentioned above with them. The XChem-FFF team will review and test your software. If everything run smoothly, a meeting will be organised to discuss including your contribution to the pipeline.
