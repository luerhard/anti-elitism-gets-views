import pandas as pd

import src
from src.crawl.manifesto_crawler import ManifestoAPI
from src.logging import logger as log

OUT_DIR = src.DATA / "raw/manifestos"
OUT_DIR.mkdir(exist_ok=True, parents=True)


def main():
    api = ManifestoAPI()
    log.info("Getting parties")
    parties = api.get_german_parties()
    log.info("Number of parties found: %d", len(parties))
    for party in parties:
        filename = party["partyabbrev"].replace("/", "_").lower()
        log.info("Crawling data for %s", filename)
        req_annotations = api.get_text_annotations(party["party_key"])
        annotations = req_annotations["items"][0]["items"]
        df = pd.DataFrame(annotations)
        df.to_parquet(OUT_DIR / f"{filename}.parquet.gzip")
        log.info("Saved data for %s", filename)


if __name__ == "__main__":
    main()
