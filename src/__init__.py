"""Analysis on populism on YouTube based on PopBERT."""

from configparser import ConfigParser
from pathlib import Path

import pandas as pd

PATH = Path(__file__).parent.parent

DATA = PATH / "data"

OUT = PATH / "reports"
OUT.mkdir(exist_ok=True)
(OUT / "tables").mkdir(exist_ok=True)
(OUT / "figures").mkdir(exist_ok=True)

TMP = PATH / "tmp"
TMP.mkdir(exist_ok=True)

config = ConfigParser()
config.read(PATH / "config.ini")

try:
    credentials = f"{config['DB']['username']}:{config['DB']['password']}"
    db = f"{config['DB']['ip']}:{config['DB']['port']}/{config['DB']['database']}"
    PS_ENGINE = f"postgresql+psycopg://{credentials}@{db}"

    test_db = f"{config['DB']['ip']}:{config['DB']['port']}/test_{config['DB']['database']}"
    PS_TEST_ENGINE = f"postgresql+psycopg://{credentials}@{test_db}"
except KeyError:
    pass

try:
    db_section = config["DB_doccano"]
    db_doccano_credentials = f"{db_section['username']}:{db_section['password']}"
    db = f"{db_section['ip']}:{db_section['port']}/{db_section['database']}"
    DOCCANO_ENGINE = f"postgresql+psycopg://{credentials}@{db}"
except KeyError:
    pass

colormap = {
    "CDU": "#000000",
    "CSU": "#000000",
    "Grüne": "#1AA037",
    "Greens": "#1AA037",
    "DIE LINKE": "#8B008B",  # SPD complementary for visual disambiguation
    "Linke": "#8B008B",  # SPD complementary for visual disambiguation
    "Left": "#8B008B",  # SPD complementary for visual disambiguation
    "FDP": "#FFEF00",
    "AfD TV": "#0489DB",
    "AfD-Fraktion Bundestag": "#0489DB",
    "AfD BT": "#0489DB",
    "SPD": "#E3000F",
}

r_colormap = pd.DataFrame(colormap.items(), columns=["channel", "color"])

party_names = {
    "BÜNDNIS 90/DIE GRÜNEN": "Greens",
    "AfD-Fraktion Bundestag": "AfD BT",
    "DIE LINKE": "Left",
}

channel_to_party = {
    "AfD BT": "AfD",
    "AfD TV": "AfD",
    "CDU": "CDU/CSU",
    "CSU": "CDU/CSU",
    "FDP": "FDP",
    "Greens": "Greens",
    "Left": "Left",
    "SPD": "SPD",
}
