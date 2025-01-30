import Levenshtein
import pytest
from pytest_cases import parametrize_with_cases

import src
from src.processing.whisper_pipeline import WhisperPipeline


class LoadWrapper:
    data = src.PATH / "tests/testdata"

    @staticmethod
    def _load_transcript(folder):
        transcript = (folder / "transcript.txt").read_text(encoding="utf-8")
        transcript = transcript.strip()
        return transcript


class Cases(LoadWrapper):
    def case_simple_short(self):
        folder = self.data / "1FTQwFurM3I"
        file = folder / "140.m4a"
        transcript = self._load_transcript(folder)
        allowed_distance = 12
        return file, transcript, allowed_distance

    def case_bavarian(self):
        folder = self.data / "VMJVN9Z9i_8"
        file = folder / "140.m4a"
        transcript = self._load_transcript(folder)
        allowed_distance = 93
        return file, transcript, allowed_distance


class MusicCase(LoadWrapper):
    def case_only_music(self):
        folder = self.data / "UM5cswiM-sU"
        file = folder / "140.m4a"
        self._load_transcript(folder)
        return file


@pytest.mark.slow
@parametrize_with_cases("file, exp, max_distance", cases=Cases)
def test_transcribe(file, exp, max_distance):
    model = WhisperPipeline(model_type="small")

    out = model.transcribe(speech_file=file)

    distance = Levenshtein.distance(out, exp)

    assert distance <= max_distance, out


@pytest.mark.slow
@parametrize_with_cases("file", cases=MusicCase)
def test_transcribe_music(file):
    model = WhisperPipeline(model_type="small")

    out = model.transcribe(speech_file=file)
    out = out.strip()
    assert out.startswith("Musik")
    assert len(out) < 25
