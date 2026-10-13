#!/usr/bin/env python

from typer import Typer
import mrich
from rich import print
import pandas as pd
from pathlib import Path

app = Typer()


@app.command()
def create_bulkdock_inputs(dir: str):

    dir = Path(dir)
    assert dir.exists()

    key = dir.name

    fstein_df = pd.read_csv(dir / "output.csv")

    data = []

    for i, row in fstein_df.iterrows():

        smiles = row.smiles
        inspirations = (
            row.regarded.removeprefix("['")
            .removesuffix("']")
            .replace("'", "")
            .split(",")
        )

        if not isinstance(smiles, str):
            continue

        d = dict(smiles=smiles)

        for i, inspiration in enumerate(inspirations):
            d[f"hit{i}"] = inspiration.strip()

        data.append(d)

    mrich.var("#merges", len(data))

    df = pd.DataFrame(data)

    outfile = dir / f"fragmenstein_bulkdock_input.csv"
    mrich.writing(outfile)
    df.to_csv(outfile, index=False)


if __name__ == "__main__":
    app()

# python fragmenstein_to_bulkdock.py fragmenstein_dir
