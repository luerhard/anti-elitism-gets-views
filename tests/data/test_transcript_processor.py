from pytest_cases import parametrize_with_cases
from sqlalchemy import create_engine
from sqlalchemy.orm import Session

import src
from src.data.models import Transcript
from src.data.transcript_processor import PopBERTPredictor
from src.data.transcript_processor import TranscriptCleaner

class Cases:
    def case_first(self):
        text = (
            "Das Ponyreiten auf der Wiesn soll verboten werden. Liebe Freundinnen und "
            "Freunde, nein, nein, nein. Verbot, Verbot, Verbot. 90 Joints pro Monat soll jetzt "
            "das Ziel sein. 90 Joints. Drei am Tag. Natürlich hat das grün-rote München sofort "
            "geäußert, ja wir wollen auch Drogenregion werden. Wir werden, soweit "
            "wir es irgendwie können, das nicht erlauben.  "
            "Dafür steht die CSU. Wenn geht's Bayern, auf geht's CSU in den Wahlkampf, "
            "liebe Freunde! "
            "Einstimmig Dr. Markus Söder zum Spitzenkandidaten! Dann darf ich feststellen, "
            "dass wir heute auf diesem Parteitag einstimmig unser neues CSU-Grundsatzprogramm "
            "beschlossen haben."
        )
        exp = [
            [
                "Das",
                "Ponyreiten",
                "auf",
                "der",
                "Wiesn",
                "soll",
                "verboten",
                "werden",
                ".",
            ],
            [
                "Liebe",
                "Freundinnen",
                "und",
                "Freunde",
                ",",
                "nein",
                ",",
                "nein",
                ",",
                "nein",
                ".",
            ],
            ["Verbot", ",", "Verbot", ",", "Verbot", "."],
            [
                "90",
                "Joints",
                "pro",
                "Monat",
                "soll",
                "jetzt",
                "das",
                "Ziel",
                "sein",
                ".",
            ],
            ["90", "Joints", "."],
            ["Drei", "am", "Tag", "."],
            [
                "Natürlich",
                "hat",
                "das",
                "grün-rote",
                "München",
                "sofort",
                "geäußert",
                ",",
                "ja",
                "wir",
                "wollen",
                "auch",
                "Drogenregion",
                "werden",
                ".",
            ],
            [
                "Wir",
                "werden",
                ",",
                "soweit",
                "wir",
                "es",
                "irgendwie",
                "können",
                ",",
                "das",
                "nicht",
                "erlauben",
                ".",
            ],
            ["Dafür", "steht", "die", "CSU", "."],
            [
                "Wenn",
                "geht's",
                "Bayern",
                ",",
                "auf",
                "geht's",
                "CSU",
                "in",
                "den",
                "Wahlkampf",
                ",",
                "liebe",
                "Freunde",
                "!",
            ],
            ["Einstimmig", "Dr.", "Markus", "Söder", "zum", "Spitzenkandidaten", "!"],
            [
                "Dann",
                "darf",
                "ich",
                "feststellen",
                ",",
                "dass",
                "wir",
                "heute",
                "auf",
                "diesem",
                "Parteitag",
                "einstimmig",
                "unser",
                "neues",
                "CSU-Grundsatzprogramm",
                "beschlossen",
                "haben",
                ".",
            ],
        ]
        return {"text": text, "tokens": exp, "sum_of_preds": 0}

    def case_populist(self):
        text = (
            "Das ist Klassenkampf von oben, das ist Klassenkampf im Interesse von "
            "Vermögenden und Besitzenden gegen die Mehrheit der Steuerzahlerinnen und "
            "Steuerzahler auf dieser Erde."
        )
        exp = [
            [
                "Das",
                "ist",
                "Klassenkampf",
                "von",
                "oben",
                ",",
                "das",
                "ist",
                "Klassenkampf",
                "im",
                "Interesse",
                "von",
                "Vermögenden",
                "und",
                "Besitzenden",
                "gegen",
                "die",
                "Mehrheit",
                "der",
                "Steuerzahlerinnen",
                "und",
                "Steuerzahler",
                "auf",
                "dieser",
                "Erde",
                ".",
            ],
        ]
        return {"text": text, "tokens": exp, "sum_of_preds": 3}

    def case_music1(self):
        text = "Musik Musik Musik Bis zum nächsten Mal."
        exp = [["Bis", "zum", "nächsten", "Mal", "."]]
        return {"text": text, "tokens": exp, "sum_of_preds": 0}

    def case_music2(self):
        text = (
            "Musik Applaus Ja, liebe Freunde, das ist das i-Tüpfelchen der Arbeit der letzten "
            "Jahre. So viele neue Gesichter, so viele neue Namen."
        )
        exp = [
            [
                "Applaus",
                "Ja",
                ",",
                "liebe",
                "Freunde",
                ",",
                "das",
                "ist",
                "das",
                "i-Tüpfelchen",
                "der",
                "Arbeit",
                "der",
                "letzten",
                "Jahre",
                ".",
            ],
            [
                "So",
                "viele",
                "neue",
                "Gesichter",
                ",",
                "so",
                "viele",
                "neue",
                "Namen",
                ".",
            ],
        ]

        return {"text": text, "tokens": exp, "sum_of_preds": 0}

    def case_music3(self):
        text = "Musik "
        exp = [[]]
        return {"text": text, "tokens": exp, "sum_of_preds": 0}


@parametrize_with_cases("data", cases=Cases)
def test_cleaner(data):
    cleaner = TranscriptCleaner()
    sentences = cleaner.tokenize(data["text"])
    assert sentences == data["tokens"]


@parametrize_with_cases("data", cases=Cases)
def test_predictions(data):
    popbert = PopBERTPredictor()
    pred = popbert.predict(data["tokens"], chunksize=32)
    assert sum(p.sum() for p in pred) == data["sum_of_preds"]


def test_repitition_counter():
    text = [
        "Wir",
        "haben",
        "über",
        "ein",
        "über",
        "ein",
        "über",
        "ein",
        "Format",
        "verhandelt",
        ".",
    ]

    ngram, count = TranscriptCleaner._count_duplicate_ngrams(text)
    assert (ngram, count) == (("über", "ein"), 3)


def test_in_der_zukunft():
    engine = create_engine(src.PS_ENGINE)
    with Session(engine) as s:
        transcript = s.query(Transcript).filter(Transcript.id == "QgOHFPNlef0").one()
        text = transcript.text
        cleaner = TranscriptCleaner()
        sentences = cleaner.tokenize(text)
        assert max(len(sent) for sent in sentences) < 500


def test_uber_repetition():
    engine = create_engine(src.PS_ENGINE)
    with Session(engine) as s:
        transcript = s.query(Transcript).filter(Transcript.id == "9ch4oU-cClo").one()
        text = transcript.text
        cleaner = TranscriptCleaner()
        sentences = cleaner.tokenize(text)
        assert max(len(sent) for sent in sentences) < 500
