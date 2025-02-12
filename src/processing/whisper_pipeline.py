"""The actual Speech to text pipeline."""

from pathlib import Path
from typing import Literal
import warnings

import Levenshtein
import librosa
from silero_vad import get_speech_timestamps
from silero_vad import load_silero_vad
import torch
from transformers import WhisperForConditionalGeneration
from transformers import WhisperProcessor

from src.logging import logger as log

WHISPER_MODELS = Literal[
    "tiny",
    "small",
    "medium",
    "large",
    "large-v2",
    "large-v3",
    "large-v3-turbo",
]

warnings.filterwarnings(
    "ignore",
    category=UserWarning,
    message="PySoundFile failed*",
)

warnings.filterwarnings("ignore", category=FutureWarning)


class WhisperPipeline:
    """Simple Whisper Pipeline to transcribe audio files."""

    SAMPLING_RATE = 16_000
    MAX_CHUNK_LEN = 30 * SAMPLING_RATE

    def __init__(
        self,
        model_type: WHISPER_MODELS = "small",
        stride_len_s: int = 2,
        device: str | None = None,
    ) -> None:
        """Load the model.

        Args:
            model_type (["tiny", "small", "medium", "large", "large-v2"], optional): Specify the
                type of model. Defaults to "small".
                See https://huggingface.co/openai/whisper-large-v2 for more details on the models.
            device: Can be set to force the device. Otherwise gpu will be used if available.
        """
        self.stride_len = stride_len_s * self.SAMPLING_RATE

        if not device:
            self.device = "cuda" if torch.cuda.is_available() else "cpu"
        else:
            self.device = device
        log.warning("Running pipeline on: %s", self.device)
        self.speech_rec_model = load_silero_vad()
        log.info("Loaded Silero Speech Model")
        self.model_type = model_type
        self.model_name = f"openai/whisper-{self.model_type}"
        log.info("Load transformers pipeline")
        self.model = WhisperForConditionalGeneration.from_pretrained(self.model_name).to(
            self.device,
        )
        self.processor = WhisperProcessor.from_pretrained(self.model_name)

        # force language to German:
        # self.model.config.forced_decoder_ids[0][1] = 50261

    def _transcribe_segment(self, segment):
        assert segment.shape[0] <= 30 * self.SAMPLING_RATE, "segment too long, will get cut off!"

        inputs = self.processor.feature_extractor(
            segment,
            sampling_rate=self.SAMPLING_RATE,
            return_tensors="pt",
            return_attention_mask=True,
        )

        features = inputs.input_features.to(self.device)
        attention_mask = inputs.attention_mask.to(self.device)

        predicted_ids = self.model.generate(
            features,
            attention_mask=attention_mask,
            language="<|de|>",
            task="transcribe",
        )
        out = self.processor.tokenizer.batch_decode(predicted_ids, skip_special_tokens=True)

        return out[0]

    def _chunk_audio_with_stride(self, audio):
        chunk_len = self.MAX_CHUNK_LEN
        # min_chunk_len = chunk_len // 2

        n_samples = audio.shape[0]

        step = chunk_len - (2 * self.stride_len)

        chunks = []
        for chunk_start_idx in range(0, n_samples, step):
            chunk_end_idx = chunk_start_idx + chunk_len
            chunk_end_idx = n_samples if chunk_end_idx > n_samples else chunk_end_idx
            chunks.append(audio[chunk_start_idx:chunk_end_idx])

        # balance last two chunks if necessary
        # if chunks[-1].shape[0] < min_chunk_len:
        #     combined_last_chunk = np.concatenate(chunks[-2], chunks[-1])
        #     middle = combined_last_chunk.shape[0] // 2
        #     combined_first = combined_last_chunk[:middle]
        #     combined_last = combined_last_chunk[middle:]
        #     merged_chunks = [combined_first, combined_last]

        #     if len(chunks) == 2:
        #         return merged_chunks
        #     else:
        #         return chunks[-2] + merged_chunks
        return chunks

    @staticmethod
    def _concatenate_strides(s1: str, s2: str):
        if not (s1 and s2):
            return s1 + s2
        results = []
        for i in range(1, min(len(s1), len(s2), 250), 1):
            sub1 = s1[-i:]
            sub2 = s2[:i]
            edits = Levenshtein.editops(sub1, sub2)
            case = {"str_len": i, "edits": len(edits), "similarity": i - len(edits)}
            results.append(case)

        best_result = max(results, key=lambda x: x["similarity"])
        return s1 + s2[best_result["str_len"] :]

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

        audio, sampling_rate = librosa.load(speech_file, sr=self.SAMPLING_RATE)

        speech_timestamps = get_speech_timestamps(
            audio,
            self.speech_rec_model,
            sampling_rate=sampling_rate,
            return_seconds=False,
        )
        segments = [audio[ts["start"] : ts["end"]] for ts in speech_timestamps]

        if not segments:
            return ""

        # whisper can listen for up to 30s.
        # if segment is longer, we need to split
        transcript_parts = []
        for segment in segments:
            if segment.shape[0] <= self.MAX_CHUNK_LEN:
                text_segment = self._transcribe_segment(segment)
                transcript_parts.append(text_segment)
            else:
                log.debug("Striding segment")
                sub_segments = self._chunk_audio_with_stride(segment)
                sub_transcript = ""
                for sub_segment in sub_segments:
                    text_segment = self._transcribe_segment(sub_segment)
                    sub_transcript = self._concatenate_strides(sub_transcript, text_segment)
                transcript_parts.append(sub_transcript)

        transcript = "".join(transcript_parts).strip()
        return transcript
