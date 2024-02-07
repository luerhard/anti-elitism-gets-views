from sqlalchemy import create_engine

import src
from src.data.models import Base
from src.logging import logger as log
from src.utils.db.sqlalchemy import auto_upgrade_engine

def main():
    engine = create_engine(src.PS_ENGINE)
    Base.metadata.create_all(engine)
    log.warn("Starting upgrade.")
    auto_upgrade_engine(engine, Base.metadata)
    log.warn("Upgrade done.")


if __name__ == "__main__":
    main()
