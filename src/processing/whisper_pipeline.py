"""The actual Speech to text pipeline."""

from pathlib import Path
from typing import Literal

import torch
from transformers import pipeline

from src.logging import logger as log

WHISPER_MODELS = Literal["tiny", "small", "medium", "large", "large-v2" "large-v3"]


class WhisperPipeline:
    """Simple Whisper Pipeline to transcribe audio files."""

    def __init__(self, model_type: WHISPER_MODELS = "small", device: str | None = None) -> None:
        """Load the model.

        Args:
            model_type (["tiny", "small", "medium", "large", "large-v2"], optional): Specify the
                type of model. Defaults to "small".
                See https://huggingface.co/openai/whisper-large-v2 for more details on the models.
            device: Can be set to force the device. Otherwise gpu will be used if available.
        """
        if not device:
            self.device = "cuda" if torch.cuda.is_available() else "cpu"
        else:
            self.device = device
        self.model_type = model_type
        self.model_name = f"openai/whisper-{self.model_type}"
        log.debug("Load transformers pipeline")
        self.pipe = pipeline(
            "automatic-speech-recognition",
            model=self.model_name,
            device=self.device,
            framework="pt",
        )

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
            stride_length_s=(6, 0),
            batch_size=8,
            generate_kwargs={
                "task": "transcribe",
                "language": "<|de|>",
            },
        )

        text = out["text"]
        text = text.strip()

        return text
