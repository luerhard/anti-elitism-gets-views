import pandas as pd

import src

def manifestos():
    party_names = {
        "linke": "Left",
        "afd": "AfD",
        "cdu_csu": "CDU/CSU",
        "spd": "SPD",
        "90_greens": "Greens",
        "fdp": "FDP",
    }
    folder = src.DATA / "raw/manifestos"
    dfs = []
    for file in folder.iterdir():
        df = pd.read_parquet(file)
        party = file.parts[-1]
        party = party.split(".", 1)[0]
        df["party"] = party_names[party]
        dfs.append(df)
    df = pd.concat(dfs)
    return df