from src.asr import WhisperPipeline
import src
import src.data.models as mdm
from sqlalchemy import Session

METADATA_PATH = src.PATH / 'data/yt/metadata.sqlite'
METDATA_DB = create_engine(f"sqlite:///{METADATA_PATH}")

def iter_videos(engine):
    with Session(engine) as s:
        

def main():
    pipeline = WhisperPipeline(model_type="tiny")
    
