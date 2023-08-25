"""Analysis on populism on YouTube based on PopBERT."""

from configparser import ConfigParser
from pathlib import Path

PATH = Path(__file__).parent.parent

config = ConfigParser()
config.read(PATH / "config.ini")
