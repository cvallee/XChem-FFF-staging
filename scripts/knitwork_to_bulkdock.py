#!/usr/bin/env python

from typer import Typer
import mrich
from rich import print
import pandas as pd
from pathlib import Path
import json
from rdkit import Chem

app = Typer()


@app.command()
def create_bulkdock_inputs(dir: str):

    dir = Path(dir)
    assert dir.exists()

    key = dir.name

    dir_suffix_pure_triples = [
        (dir / "knitwork_pure_output", "_pure_merges.sdf", True),
        (dir / "knitwork_impure_output", "_impure_merges.sdf", False),
    ]

    for out_dir, suffix, pure in dir_suffix_pure_triples:
        
        all_merges = []

        for sdf in Path(out_dir).glob(f"*{suffix}"):

            with Chem.SDMolSupplier(sdf) as supl:
                for mol in supl:
                    if mol is None:
                        continue

                    smiles = mol.GetProp("merge_smiles")
                    id_a = mol.GetProp("ID_A")
                    id_b = mol.GetProp("ID_B")

                    merge = {
                        "smiles": smiles,
                        "ID_A": id_a,
                        "ID_B": id_b,
                    }

                    if mol.HasProp("ID_C"):
                        merge["ID_C"] = mol.GetProp("ID_C")

                    if mol.HasProp("ID_D"):
                        merge["ID_D"] = mol.GetProp("ID_D")

                    all_merges.append(merge)

        df = pd.DataFrame(all_merges)

        mrich.success(f"{len(df)} total merges")

        if pure:
            output = dir / f"{out_dir}/knitwork_pure_bulkdock_input.csv"
            mrich.writing(output)
            df.to_csv(output, index=False)
        else:
            output = dir / f"{out_dir}/knitwork_impure_bulkdock_input.csv"
            mrich.writing(output)
            df.to_csv(output, index=False)


if __name__ == "__main__":
    app()

# python knitwork_to_bulkdock.py knitwork_dir
