"""Handle all data import and export."""

from sqlalchemy import create_engine

import src

db_path = f"sqlite:///{src.PATH}/data/db/sqlite.db"
engine = create_engine(db_path)

__all__ = ["engine"]
