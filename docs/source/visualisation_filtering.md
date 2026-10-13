# Visualisation and Filtering

Now that GNINA has minimised and re-scored the placed poses, we review those scores, select the poses worth progressing.

## Prerequisites

Before continuing, make sure that you have:

- completed the [pose generation](pose_generation.md) page and imported the GNINA-minimised poses into HIPPO;
- a running Jupyter notebook session on IRIS (see [Setup - Step 2](setup.md));
- a copy of `Visualisation_Filtering_Template.ipynb` open in that session.

```{important}
Make a copy of `Visualisation_Filtering_Template.ipynb`, do not edit the template inside the `$XCHEM_FFF` shared directory! It is important to keep the template unchanged so it is available for other users.
```

To copy the template, run the following command on your IRIS terminal:
```bash
cd $HOME2
cp $XCHEM_FFF/templates/Visualisation_Filtering_Template.ipynb $HOME2/XChem-FFF/filtering_workflow.ipynb
```

```{note}
Target name and cycle IDs can be changed inside the notebook, but you are free to choose to make a copy of `Visualisation_Filtering_Template.ipynb` for each target (for example, `<target_name>_filtering_workflow.ipynb`) instead of editing the same notebook for each target you are working on.
```

## Key concepts

### HIPPO scores

HIPPO stores score for each pose using the generic score names:

#### Fragmenstein placement

During placement, Fragmenstein assign the following two scores for each poses:

- **`energy_score`** — an estimate of binding affinity. More negative/lower values indicate a stronger predicted binder. 
- **`distance_score`** — the deviation between the placed pose of a scaffold compare to its inspirations. Small values mean the scaffold was placed in proximity with the inspirations original position; large values suggest the scaffold placement poorly reflect the original positions of the inspirations.

#### GNINA rescore

[GNINA](https://github.com/gnina/gnina) rescoring combines a physics-based docking score (from AutoDock Vina/Smina) with a convolutional neural network (CNN) evaluation of the 3D protein-ligand grid. The CNN produces three complementary values:

- **`CNNscore`** — a score value between 0 and 1 that gives the probability of a pose to be "correct", i.e. within 2 Å RMSD of the true binding mode. Higher is better.
- **`CNNaffinity`** — a continuous prediction of binding affinity (a pK-like value, e.g. analogous to pKd/pKi). Higher is better.
- **`CNN_VS`** — `CNNscore × CNNaffinity`. Because it multiplies pose-confidence by predicted affinity, it favours poses that are both geometrically plausible **and** predicted to bind strongly, and is a convenient single metric for ranking.

```{note}
`energy_score` and `distance_score` are the only score fields HIPPO stores in a dedicated, queryable column — `CNNscore`, `CNNaffinity`, and `CNN_VS` are not first-class HIPPO scores. They are, however, preserved on each pose's `metadata` dict (`pose.metadata["CNN_VS"]`) since `animal.load_sdf(...)` carries over every non-name SDF column, so `CNN_VS` remains available for triage alongside the two dedicated scores.
```

### Method tags

Method tags (`fragmenstein`, `pure_knitwork`, `impure_knitwork`) identify which placement/merging approach generated a pose, as described in [Scaffold design](design.md) and [Pose generation](pose_generation.md). Comparing scores across methods helps judge which placement approach is producing the most reliable poses for this target.

### Selection tag

This workflow attributes a dedicated **selection tag** (for example `c01_selected_scaffolds`) to the poses chosen here. This tag and can be used to pull the same poses back out for further scoring/placement/docking/elaboration rounds, to export an SDF for other tools, or to export a SMILES list for compound ordering / synthesis. Downstream steps then simply query `animal.poses.get_by_tag(<selection_tag>)` (or filter `animal.compounds`/`animal.poses` by it).

## 1. Build a score table for the GNINA-minimised poses

The pose generation workflow tags every GNINA-reposed pose with `gnina_repose`. `animal.load_sdf(...)` preserves the placed pose's tags as a comma-separated string in `pose.metadata["tags"]`, so the method can be recovered from there. In the notebook, collect the poses tagged `gnina_repose` with `animal.poses.get_by_tag("gnina_repose")`, derive each pose's method by checking which `<target_name>_<method>` tag appears in `pose.metadata["tags"]`, and build a combined `pandas` table indexed by pose ID recording the `energy_score` and `distance_score` stored on each pose, plus `CNN_VS` pulled from `pose.metadata`, alongside its derived method.

Export this table to `gnina_dir` as a CSV so the full, unfiltered set of scores is kept alongside the target's other cycle outputs.

## 2. Visualise the score distributions

Use the score table to plot the `energy_score` distribution per method (a `plotly` histogram) and the relationship between `energy_score` and `distance_score` (a scatter plot). These plots help you judge whether a method produced a distinct population of strongly-scoring poses, and whether the strongest scores also correspond to small placement/minimisation shifts. The template also plots the `CNN_VS` distribution per method, which is useful if you prefer to triage on GNINA's combined pose-confidence/affinity metric instead of (or alongside) `energy_score`.

## 3. Select the top-scoring poses

Decide on a `score_quantile` cutoff (for example, the top 20% of poses) and apply it per method using `groupby("method")` on the score table. This keeps the selection proportional across methods rather than letting one method's larger output dominate the shortlist.

The template's `score_col` configuration variable controls which column is used for this ranking — `energy_score` by default, but `distance_score` or `cnn_vs` can be used instead. Because `energy_score`/`distance_score` favour smaller values while `CNN_VS` favours larger ones, the template's cutoff logic takes the direction into account automatically based on `score_col`.

```{note}
Check the sign convention of `energy_score` reported by your scoring function before filtering — GNINA affinities are typically more negative for stronger predicted binders, but this should be verified against the scoring output you are using.
```

Use the filtered index to build a `PoseSet` of the top-scoring poses with `animal.poses[...]`.

## 4. Generate pose overlays and images of the top poses

Inspect the shortlisted poses before committing to a selection:

- looping over the poses and calling `pose.draw()` gives a quick 2D depiction of each compound;
- looping over the poses and calling `(pose + pose.inspirations).draw()` overlays each pose with the fragments that inspired it, so you can check how well the pose recapitulates the original fragment binding modes.

Use these to sanity-check the shortlist for chemically sensible structures and consistent binding modes.

## 4b. Interactively accept/reject poses

Scores alone do not capture everything that matters about a pose, so the score-quantile cutoff from step 3 should be treated as a first pass rather than a final answer. The template provides an interactive widget (built with `ipywidgets`) that steps through the top-scoring poses one at a time, drawing each pose alongside its inspirations, and lets you click **Accept** or **Reject** for each. Your decisions are recorded in a `decisions` dictionary (`pose_id -> True/False`) as you go.

Once you have been through all the poses, the accepted subset is collected into `selected_poses` — this, rather than the full `top_poses` set, is what gets tagged and exported in the remaining steps.

```{note}
If you are interrupted partway through review, any unreviewed poses are excluded from `selected_poses` and reported in a warning. Re-run the widget cell to start over, or re-run it to revisit and change any previous decision before moving on.
```

### What to look for when accepting/reject poses

There is no single automatic criterion for this step — use your chemical judgement, informed by the same considerations you would apply when reviewing docked poses manually. Useful things to check for each pose include:

- **Ligand geometry** — does the pose have sensible bond lengths, angles, and torsions? Are there any obvious strain features (eclipsed rotatable bonds, unusually flat or twisted rings, close intramolecular clashes) that suggest an unrealistic conformation, even if the score is favourable?
- **Recapitulation of the inspiration fragments** — does the pose preserve the key interactions and binding mode of the fragment(s) it was built from? Use the `(pose + pose.inspirations).draw()` overlay to check that the atoms inherited from each inspiration fragment sit close to where that fragment was originally observed, rather than drifting away during merging/minimisation.
- **Project-specific criteria** — for example:
  - does the pose maintain a specific hydrogen bond or salt bridge to a residue known to be important for activity;
  - does it avoid clashing with a residue that is known to be sensitive (e.g. from a resistance mutation or a residue lining a selectivity pocket);
  - does it occupy a sub-pocket that your team has prioritised for this target;
- **Synthesisability and physicochemical properties** — is the compound's synthetic route plausible or purchasable, and are its physicochemical properties (molecular weight, logP, number of rotatable bonds, polar surface area, etc.) reasonable for this stage of the project.

Document any project-specific criteria you use (for example, in the notebook itself or in your project's cycle notes) so that the reasoning behind the selection can be revisited later, since — unlike the score-based cutoff — these decisions are not automatically reproducible from the stored scores alone. 


## 5. Tag the selected poses

Once you are satisfied with the shortlist, attribute a selection tag to each pose in `selected_poses` (for example `selected_poses.add_tag("c01_selected_scaffolds")`, or iterate over the poses calling `pose.tag(...)` if a bulk method is not available). Choose a tag name that is specific enough to identify this cycle's shortlist (for example `<target_name>_c01_selected_scaffolds`).

This tag is the general-purpose handle for the shortlist: it is what the downstream workflows (rescoring/placement/docking/elaboration) use to retrieve the exact set of poses selected here via `animal.poses.get_by_tag(<selection_tag>)`. It is also useful for or pulling out their SMILES for compound ordering / recipe generation in CAR.

## 6. Export the tagged poses

Write the filtered score table to a CSV in `gnina_dir`, and export the tagged pose set to a Fragalysis-compatible SDF with `selected_poses.to_fragalysis(...)`, filling in your submitter details. Also export the SMILES of the shortlisted compounds to a CSV which can be handed to CAR for compound ordering or recipe generation. Finally, back up the HIPPO database with `animal.db.backup()` so the scores and tags recorded on the poses are preserved.


## Next steps

Use this shortlist for your next step (e.g. purchase query, synthesis or elaboration workflows). 