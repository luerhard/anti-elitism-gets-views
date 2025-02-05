"""The actual Speech to text pipeline."""

from pathlib import Path
from typing import Literal
import warnings

import librosa
import numpy as np
from silero_vad import get_speech_timestamps
from silero_vad import load_silero_vad
import torch
from transformers import pipeline

from src.logging import logger as log

WHISPER_MODELS = Literal["tiny", "small", "medium", "large", "large-v2large-v3"]

warnings.filterwarnings(
    "ignore",
    category=UserWarning,
    message="PySoundFile failed*",
)

warnings.filterwarnings("ignore", category=FutureWarning)


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
        self.speech_rec_model = load_silero_vad()
        log.debug("Loaded Silero Speech Model")
        self.model_type = model_type
        self.model_name = f"openai/whisper-{self.model_type}"
        log.debug("Load transformers pipeline")
        self.pipe = pipeline(
            "automatic-speech-recognition",
            model=self.model_name,
            device=self.device,
            framework="pt",
        )

        # force language to German:
        # self.pipe.model.config.forced_decoder_ids[0][1] = 50261

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

        audio, sr = librosa.load(speech_file, sr=16_000)
        speech_timestamps = get_speech_timestamps(
            audio,
            self.speech_rec_model,
            sampling_rate=16_000,
            return_seconds=False,
        )

        segments = [audio[ts["start"] : ts["end"]] for ts in speech_timestamps]
        only_speech_audio = np.concatenate(segments)

        # inputs = self.processor.feature_extractor(
        #     return_tensors="pt",
        #     sampling_rate=16_000,
        # ).input_features.to(self.device)

        # predicted_ids = self.model.generate(inputs, language="<|de|>", task="transcribe")
        # out = self.processor.tokenizer.batch_decode(predicted_ids, skip_special_tokens=True)
        # return out[0]

        out = self.pipe(
            {"raw": only_speech_audio, "sampling_rate": 16_000},
            return_timestamps=False,
            chunk_length_s=30,
            stride_length_s=(4, 2),
            batch_size=8,
            generate_kwargs={
                "task": "transcribe",
                "language": "<|de|>",
            },
        )

        text = out["text"].strip()
        return text
