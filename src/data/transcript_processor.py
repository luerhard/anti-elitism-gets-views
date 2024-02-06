"""Processes transcripts. Tokenizes them and uses PopBERT to predict populism dimensions."""

from abc import ABCMeta
from abc import abstractmethod
from abc import abstractproperty

import numpy as np
from somajo import SoMaJo
import torch
from transformers import AutoModelForSequenceClassification
from transformers import AutoTokenizer

import src
from src.utils.iterate import chunks

class TransformerPredictor(metaclass=ABCMeta):
    device = "cuda" if torch.cuda.is_available() else "cpu"

    @abstractmethod
    def __init__(self) -> None:
        raise NotImplementedError

    @abstractproperty
    @property
    def model(self): ...

    @abstractproperty
    @property
    def tokenizer(self): ...

    @abstractproperty
    @property
    def max_length(self): ...

    @abstractmethod
    def _get_probas(self, out):
        raise NotImplementedError

    def predict(self, tokens: list[str] | list[list[str]], chunksize=32):
        """Predict populism dimensions of an already tokenized sentence."""
        # ensure correct batch format
        if len(tokens) < 1:
            # if tokens is empty, raise Error
            tokens = [[]]
        elif isinstance(tokens, list) and isinstance(tokens[0], str):
            # if tokens is a single sentence wrap in in batch
            tokens = [tokens]

        results = []
        for batch in chunks(tokens, chunksize=chunksize):
            encodings = self.tokenizer(
                batch,
                is_split_into_words=True,
                truncation=True,
                padding=True,
                return_tensors="pt",
                max_length=self.max_length,
            )
            encodings = encodings.to(self.device)

            with torch.inference_mode():
                out = self.model(**encodings)

            probas = self._get_probas(out)
            results.extend(probas)

        return results


class PopBERTPredictor(TransformerPredictor):

    def __init__(self) -> None:
        self._tokenizer = None
        self._model = None
        self._max_length = None
        self.elite_thresh = float(src.config["THRESHOLD"]["elite"])
        self.pplcentr_thresh = float(src.config["THRESHOLD"]["pplcentr"])
        self.left_thresh = float(src.config["THRESHOLD"]["left"])
        self.right_thresh = float(src.config["THRESHOLD"]["right"])

        self.thresholds = (
            self.elite_thresh,
            self.pplcentr_thresh,
            self.left_thresh,
            self.right_thresh,
        )

    @property
    def tokenizer(self):
        if not self._tokenizer:
            self._tokenizer = AutoTokenizer.from_pretrained("luerhard/PopBERT")
        return self._tokenizer

    @property
    def model(self):
        if not self._model:
            self._model = AutoModelForSequenceClassification.from_pretrained("luerhard/PopBERT").to(
                self.device,
            )
        return self._model

    @property
    def max_length(self):
        return 512

    def _get_probas(self, out):
        probs = torch.nn.functional.sigmoid(out.logits)
        probs = probs.detach().cpu().numpy()
        labels = np.where(probs > self.thresholds, 1, 0)
        return labels


class TranscriptCleaner:
    """Processes transcripts. Tokenizes them and uses PopBERT to predict populism dimensions."""

    def __init__(self) -> None:
        self.sentence_splitter = SoMaJo("de_CMC", split_sentences=True)

    def _clean_sentence(self, sentence) -> list[str]:
        sentence = [tok for tok in sentence if tok != "Musik"]
        return sentence

    def tokenize(self, text: str) -> list[str]:
        """Use SoMaJo to tokenize and sentence-split text."""
        sentence_iterator = self.sentence_splitter.tokenize_text([text])
        sentences = []
        for sentence in sentence_iterator:
            tokens = [tok.text for tok in sentence]
            sentence = self._clean_sentence(tokens)
            sentences.append(sentence)
        return sentences
