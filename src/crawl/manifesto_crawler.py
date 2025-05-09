import json

import pandas as pd
import requests

from src import config


class ManifestoAPI:
    def __init__(self) -> None:
        self.key = config["manifesto"]["api_key"]
        self.metadata_version = config["manifesto"]["metadata_version"]
        self.core_version = config["manifesto"]["core_version"]
        self.election_date = config["manifesto"]["election_date"]
        self.base_url = "https://manifesto-project.wzb.eu/api/v1"
        self.parties = ["AfD", "CDU/CSU", "CDU", "CSU", "FDP", "90/Greens", "SPD", "LINKE"]

    @staticmethod
    def _request(url):
        req = requests.get(url)
        if not req.status_code == 200:
            msg = f"HTTP Request Status Code not 200, but: {req.status_code}"
            raise Exception(msg)
        text = req.content
        content = json.loads(text)
        return content

    def list_core_versions(self):
        url = f"{self.base_url}/list_core_versions?api_key={self.key}"
        return self._request(url)

    def list_metadata_versions(self):
        url = f"{self.base_url}/list_metadata_versions?api_key={self.key}"
        return self._request(url)

    def get_german_parties(self):
        url = f"{self.base_url}/get_core?api_key={self.key}&key={self.core_version}"
        data = self._request(url)
        df = pd.DataFrame(data[1:], columns=data[0])
        df = df[df.countryname == "Germany"]
        df = df[df.partyabbrev.isin(self.parties)]
        df = df[df.edate == self.election_date]
        df["party_key"] = df["party"] + "_" + df["date"]
        return df.to_dict(orient="records")

    def get_metadata(self, party_key):
        url = f"{self.base_url}/metadata?api_key={self.key}&keys[]={party_key}&version={self.metadata_version}" # noqa: E501
        data = self._request(url)
        return data

    def get_text_annotations(self, party_key):
        url = f"{self.base_url}/texts_and_annotations?api_key={self.key}&keys[]={party_key}&version={self.metadata_version}" # noqa: E501

        data = self._request(url)
        return data
