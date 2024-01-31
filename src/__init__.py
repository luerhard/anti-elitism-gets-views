"""Analysis on populism on YouTube based on PopBERT."""

from configparser import ConfigParser
from pathlib import Path

PATH = Path(__file__).parent.parent

config = ConfigParser()
config.read(PATH / "config.ini")

credentials = f"{config['DB']['username']}:{config['DB']['password']}"
db = f"{config['DB']['ip']}:{config['DB']['port']}/{config['DB']['database']}"
PS_ENGINE = f"postgresql+psycopg://{credentials}@{db}"
