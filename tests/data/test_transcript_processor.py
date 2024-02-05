from src.data.transcript_processor import TranscriptProcessor

from pytest_cases import parametrize_with_cases


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
        return text, exp

    def case_music1(self):
        text = "Musik Musik Musik Bis zum nächsten Mal."
        exp = [["Bis", "zum", "nächsten", "Mal", "."]]
        return text, exp

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

        return text, exp

    def case_music3(self):
        text = "Musik "
        exp = [[]]
        return text, exp


@parametrize_with_cases("text,exp", cases=Cases)
def test_cleaner(text, exp):
    cleaner = TranscriptProcessor()
    sentences = cleaner.tokenize(text)
    assert sentences == exp


@parametrize_with_cases("text,exp", cases=Cases)
def test_predictions(text, exp):
    cleaner = TranscriptProcessor()
    sentences = cleaner.tokenize(text)
    pred = cleaner.predict_populism(sentences[0])
    assert sentences == exp