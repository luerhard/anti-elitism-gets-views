"""Analysis on populism on YouTube based on PopBERT."""

from configparser import ConfigParser
from pathlib import Path

import pandas as pd

PATH = Path(__file__).parent.parent

config = ConfigParser()
config.read(PATH / "config.ini")

credentials = f"{config['DB']['username']}:{config['DB']['password']}"

db = f"{config['DB']['ip']}:{config['DB']['port']}/{config['DB']['database']}"
PS_ENGINE = f"postgresql+psycopg://{credentials}@{db}"

test_db = f"{config['DB']['ip']}:{config['DB']['port']}/test_{config['DB']['database']}"
PS_TEST_ENGINE = f"postgresql+psycopg://{credentials}@{test_db}"

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
