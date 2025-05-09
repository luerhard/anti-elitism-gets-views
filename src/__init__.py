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

_channel_names = {
    "@AfDFraktionimBundestag": ("BT", "AfD"),
    "@AfDTV": ("DE", "AfD"),
    "@cducsu": ("BT", "CDU/CSU"),
    "@cdutv": ("DE", "CDU/CSU"),
    "@csuimbundestag9622": ("BT", "CDU/CSU"),
    "@csumedia": ("DE", "CDU/CSU"),
    "@DieGruenen": ("DE", "Greens"),
    "@gruenebundestag": ("BT", "Greens"),
    "@DIELINKE": ("DE", "Left"),
    "@linksfraktion": ("BT", "Left", "old"),
    "@dielinkebt": ("BT", "Left", "new"),
    "@FDP": ("DE", "FDP"),
    "@fdpbt": ("BT", "FDP"),
    "@spdde": ("DE", "SPD"),
    "@spdbt": ("BT", "SPD"),
}


def format_name(items):
    if len(items) == 2:
        return " ".join((items[1], items[0]))
    else:
        return " ".join((items[1], items[0], items[2]))


channel_id2name = {k: format_name(v) for k, v in _channel_names.items()}
channel_id2party = {k: v[1] for k, v in _channel_names.items()}

cmaps_party2color = {
    "CDU": "#000000",
    "CSU": "#000000",
    "CDU/CSU": "#000000",
    "Greens": "#1AA037",
    "Left": "#8B008B",  # SPD complementary for visual disambiguation
    "FDP": "#FFEF00",
    "AfD": "#0489DB",
    "SPD": "#E3000F",
}

cmaps_channel2color = {k: cmaps_party2color[v] for k, v in channel_id2party.items()}
cmaps_name2color = {
    channel_id2name[k]: cmaps_party2color[channel_id2party[k]] for k in channel_id2name.keys()
}

r_colormap_id = pd.DataFrame(cmaps_channel2color.items(), columns=["channel", "color"])
r_colormap_name = pd.DataFrame(cmaps_name2color.items(), columns=["channel", "color"])
r_colormap_party = pd.DataFrame(cmaps_party2color.items(), columns=["party", "color"])


mynewvar = "TEST"
