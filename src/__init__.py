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

_channel_names = {
    "@AfDFraktionimBundestag": ("BT", "AfD"),
    "@AfDTV": ("DE", "AfD"),
    "@cducsu": ("BT", "CDU/CSU"),
    "@cdutv": ("DE", "CDU"),
    "@csuimbundestag9622": ("BT", "CSU"),
    "@csumedia": ("DE", "CSU"),
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


_channel_party_joined = {
    "@AfDFraktionimBundestag": "AfD",
    "@AfDTV": "AfD",
    "@cducsu": "CDU/CSU",
    "@cdutv": "CDU/CSU",
    "@csuimbundestag9622": "CDU/CSU",
    "@csumedia": "CDU/CSU",
    "@DieGruenen": "Greens",
    "@gruenebundestag": "Greens",
    "@DIELINKE": "Left",
    "@linksfraktion": "Left",
    "@dielinkebt": "Left",
    "@FDP": "FDP",
    "@fdpbt": "FDP",
    "@spdde": "SPD",
    "@spdbt": "SPD",
}


def format_name(items):
    if len(items) == 2:
        return " ".join((items[1], items[0]))
    else:
        return " ".join((items[1], items[0], items[2]))


channel_id2name = {k: format_name(v) for k, v in _channel_names.items()}
channel_id2party = dict(_channel_party_joined.items())

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
