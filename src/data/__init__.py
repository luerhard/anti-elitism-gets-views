"""Handle all data import and export."""

import sqlalchemy

import src

def create_engine():
    """Create a sqlite DB engine."""
    db_path = f"sqlite:///{src.PATH}/data/db/sqlite.db"
    engine = sqlalchemy.create_engine(db_path)
    return engine

__all__ = ["create_engine"]
