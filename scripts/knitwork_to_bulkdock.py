#!/usr/bin/env python

from typer import Typer
import mrich
from rich import print
import pandas as pd
from pathlib import Path
import json

app = Typer()


@app.command()
def create_bulkdock_inputs(subdir: str):

    subdir = Path(subdir)
    assert subdir.exists()

    key = subdir.name

    dir_suffix_pure_triples = [
        (subdir / "knitwork_pure_output", "_pure_merge.json", True),
        (subdir / "knitwork_impure_output", "_prop_pharmfp_impure_merge.json", False),
    ]

    for out_dir, suffix, pure in dir_suffix_pure_triples:

        all_merges = []

        for json_file in Path(out_dir).glob(f"*{suffix}"):

            merge_name = json_file.name.removesuffix(suffix)

            hit_names = merge_name.split("-")

            if len(hit_names) == 2:
                pass

            elif len(hit_names) == 4:
                hit_names = [f"{hit_names[0]}-{hit_names[1]}", f"{hit_names[2]}-{hit_names[3]}"]
            elif len(hit_names) == 3:
                if len(hit_names[2]) == 1:
                    hit_names = [hit_names[0], f"{hit_names[1]}-{hit_names[2]}"]
                elif len(hit_names[1]) == 1:
                    hit_names = [f"{hit_names[0]}-{hit_names[1]}", hit_names[2]]
                else:
                    raise NotImplementedError(f"Wrong number of dashes in merge name: {merge_name}")
            else:
                raise NotImplementedError(f"Wrong number of dashes in merge name: {merge_name}")


            data = json.load(open(json_file, "rt"))

            for series in data.values():

                mrich.var(f"{merge_name} #expansions:", len(series["expansions"]))

                for i, (smiles, cmpd_ids) in enumerate(
                    zip(series["expansions"], series["cmpd_ids"])
                ):

                    merge = dict(smiles=smiles)

                    for j, hit in enumerate(hit_names):
                        merge[j] = hit

                    all_merges.append(merge)

        df = pd.DataFrame(all_merges)

        mrich.success(f"{len(df)} total merges")

        if pure:
            mrich.writing(f"{key}_knitwork_pure.csv")
            df.to_csv(f"{key}_knitwork_pure.csv", index=False)
        else:
            mrich.writing(f"{key}_knitwork_impure.csv")
            df.to_csv(f"{key}_knitwork_impure.csv", index=False)


if __name__ == "__main__":
    app()

# python to_bulkdock.py iter1_frags
