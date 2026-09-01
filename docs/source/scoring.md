# Scoring and Visualization

Now that GNINA has minimised and re-scored the placed poses, we must build a combined score table across methods, select the best candidates, and visualise and export them for the next elaboration round.

## Prerequisites

Before continuing, make sure that you have:

- completed the [pose generation](pose_generation.md) page and imported the GNINA-minimised poses into HIPPO;
- a running Jupyter notebook session on IRIS (see [Setup - Step 2](setup.md));
- a copy of `Scoring_Visualisation_Template.ipynb` open in that session.

```{note}
Make a copy of `Scoring_Visualisation_Template.ipynb` for each target (for example, `<target_name>_scoring_workflow.ipynb`). Keep the template unchanged so it is available for the next target.
```

## Key concepts

This page compares poses using the scores that [GNINA](https://github.com/gnina/gnina) records during minimisation and that [HIPPO](https://hippo-docs.winokan.com/en/stable/) stores on each pose. Understanding what each score measures will help you choose a sensible `score_quantile` cutoff before filtering.

- **`energy_score`** is HIPPO's generic name for the pose's predicted binding energy; here it is populated from GNINA's minimised affinity (`minimizedAffinity`), a CNN-based estimate of binding affinity reported in a pK-like unit (see the [GNINA paper](https://doi.org/10.1186/s13321-021-00522-2) and [GNINA docs](https://github.com/gnina/gnina#usage) for details on the underlying convolutional neural network scoring function). More negative/lower values indicate a stronger predicted binder, but always check the sign convention reported by the version of GNINA you are using.
- **`distance_score`** is HIPPO's generic name for a pose's geometric deviation from its reference; here it is populated from GNINA's minimised RMSD (`minimizedRMSD`), the root-mean-square deviation between the placed pose (from Fragmenstein or Knitwork) and the same pose after GNINA's energy minimisation. A small `distance_score` means minimisation made little change to the placement, so the original pose was already close to a low-energy geometry; a large value means minimisation moved the ligand substantially, which can indicate a poor or strained initial placement.
- **Method tags** (for example `fragmenstein`, `pure_knitwork`, `impure_knitwork`) identify which placement/merging method generated a pose, as described in [Scaffold design](design.md) and [Pose generation](pose_generation.md). Comparing `energy_score` and `distance_score` across methods helps you judge which placement approach is producing the most reliable poses for this target.
- **`score_quantile`** is a per-method percentile cutoff (for example, keeping the best-scoring 20% of poses within each method) used in this workflow to shortlist poses. Filtering per method, rather than across the whole table, avoids a single method with many more output poses dominating the shortlist.

## 1. Build a score table for the GNINA-minimised poses

The pose generation workflow tags every GNINA-reposed pose with `gnina_repose` and with a method tag (`fragmenstein`, `pure_knitwork`, or `impure_knitwork`). In the notebook, use `animal.poses.get_by_tag` to collect the poses for each method and build a combined `pandas` table indexed by pose ID, recording the `energy_score` and `distance_score` stored on each pose alongside its method.

Export this table to `gnina_dir` as a CSV so the full, unfiltered set of scores is kept alongside the target's other cycle outputs.

## 2. Visualise the score distributions

Use the score table to plot the `energy_score` distribution per method (a `plotly` histogram) and the relationship between `energy_score` and `distance_score` (a scatter plot). These plots help you judge whether a method produced a distinct population of strongly-scoring poses, and whether the strongest scores also correspond to small placement/minimisation shifts.

## 3. Select the top-scoring poses

Decide on a `score_quantile` cutoff (for example, the top 20% of poses) and apply it per method using `groupby("method")` on the score table. This keeps the selection proportional across methods rather than letting one method's larger output dominate the shortlist.

```{note}
Check the sign convention of `energy_score` reported by your scoring function before filtering — GNINA affinities are typically more negative for stronger predicted binders, but this should be verified against the scoring output you are using.
```

Use the filtered index to build a `PoseSet` of the top-scoring poses with `animal.poses[...]`.

## 4. Generate pose overlays and images of the top poses

Inspect the shortlisted poses before exporting them:

- `top_poses.interactive()` opens a 3D overlay of the top-scoring poses in the binding site;
- looping over the poses and calling `pose.draw()` gives a quick 2D depiction of each compound.

Use these to sanity-check the shortlist for chemically sensible structures and consistent binding modes before committing to the export.

## 5. Export the top-scoring poses

Write the filtered score table to a CSV in `gnina_dir`, and export the corresponding pose set to a Fragalysis-compatible SDF with `top_poses.to_fragalysis(...)`, filling in your submitter details. Finally, back up the HIPPO database with `animal.db.backup()` so the scores and tags recorded on the poses are preserved.

## Next steps

The exported top-scoring poses and CSV are the inputs for the next elaboration round: review them, tag or export any that should be progressed to Fragalysis, and use the recorded scores to decide which scaffolds warrant a further [design](design.md) cycle.
