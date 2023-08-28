
from levenshtein_distance import Levenshtein
import pytest
from pytest_cases import parametrize_with_cases

import src
from src.tts import WhisperPipeline

class Cases:

    data = src.PATH / "tests/testdata"

    @staticmethod
    def _load_transcript(folder):
        transcript = (folder / "transcript.txt").read_text()
        transcript = transcript.strip()
        return transcript

    def case_simple_short(self):
        folder = self.data / "1FTQwFurM3I"
        file = folder / "140.m4a"
        transcript = self._load_transcript(folder)
        allowed_distance = 10
        return file, transcript, allowed_distance

    def case_only_music(self):
        folder = self.data / "UM5cswiM-sU"
        file = folder / "140.m4a"
        transcript = self._load_transcript(folder)
        allowed_distance = 0
        return file, transcript, allowed_distance


@pytest.mark.slow()
@parametrize_with_cases("file, exp, max_distance", cases=Cases)
def test_transcribe(file, exp, max_distance):
    model = WhisperPipeline(model_type = "small")

    out = model.transcribe(speech_file=file)

    levenshtein = Levenshtein(out, exp)
    distance = levenshtein.distance()

    assert distance <= max_distance
