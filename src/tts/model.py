"""The actual Speech to text pipeline."""

from pathlib import Path
from typing import Literal

from transformers import pipeline

WHISPER_MODELS = Literal["tiny", "small", "medium", "large", "large-v2"]


class WhisperPipeline:
    """Simple Whisper Pipeline to transcribe audio files."""

    def __init__(self, model_type: WHISPER_MODELS = "small") -> None:
        """Load the model.

        Args:
            model_type (WHISPER_MODELS, optional): Specify the type of model. Defaults to "small".
                See https://huggingface.co/openai/whisper-large-v2 for more details on the models.
        """
        self.model_name = f"openai/whisper-{model_type}"
        self.pipe = pipeline("automatic-speech-recognition", model=self.model_name)

    def transcribe(self, speech_file: str | Path):
        """Transcribe an audio file.

        Does not contain timestamps.
        Hardcoded to German transcription atm.
        All params are taken without much thought from this tutorial:
        https://colab.research.google.com/drive/1_Clxp5FcEYJVn_w7Q6zm8bX0t1TEg7m_?usp=sharing

        Args:
            speech_file (str | Path): Path the the audio file.

        Returns:
            str: Transcript.
        """
        out = self.pipe(
            str(speech_file),
            return_timestamps=False,
            chunk_length_s=30,
            stride_length_s=[6, 0],
            batch_size=32,
            generate_kwargs={"language": "<|de|>"},
        )

        return out["text"]
