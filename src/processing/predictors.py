from abc import ABCMeta
from abc import abstractmethod
from abc import abstractproperty

import numpy as np
import torch
from transformers import AutoModelForSequenceClassification
from transformers import AutoTokenizer

import src
from src.logging import logger as log
from src.utils.iterate import chunks
from src.utils.iterate import flatten_list

class TransformerPredictor(metaclass=ABCMeta):
    device = "cuda" if torch.cuda.is_available() else "cpu"

    @abstractmethod
    def __init__(self) -> None: ...

    @abstractproperty
    @property
    def model(self): ...

    @abstractproperty
    @property
    def tokenizer(self): ...

    @abstractmethod
    def tokenize(self): ...

    @abstractmethod
    def _get_probas(self, out): ...

    @abstractmethod
    def predict(self): ...


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

    def tokenize(self, batch):
        encodings = self.tokenizer(
            batch,
            is_split_into_words=True,
            truncation=True,
            padding=True,
            return_tensors="pt",
            max_length=512,
        )
        return encodings

    def _get_probas(self, out):
        probs = torch.nn.functional.sigmoid(out.logits)
        probs = probs.detach().cpu().numpy()
        labels = np.where(probs > self.thresholds, 1, 0)
        return labels

    def predict(self, tokens: list[str] | list[list[str]], chunksize=32):
        """Predict populism dimensions of an already tokenized sentence."""
        # ensure correct tokens-batch format
        if len(tokens) < 1:
            # if tokens is empty, raise Error
            tokens = [[]]
        elif isinstance(tokens, list) and isinstance(tokens[0], str):
            # if tokens is a single sentence wrap in in batch
            tokens = [tokens]

        results = []
        for batch in chunks(tokens, chunksize=chunksize):
            encodings = self.tokenize(batch)
            encodings = encodings.to(self.device)

            with torch.inference_mode():
                out = self.model(**encodings)

            probas = self._get_probas(out)
            results.extend(probas)

        return results


class ManifestorPredictor(TransformerPredictor):
    def __init__(self) -> None:
        self._tokenizer = None
        self._model = None
        self._max_length = None
        self._label = None

    @property
    def tokenizer(self):
        if not self._tokenizer:
            self._tokenizer = AutoTokenizer.from_pretrained("xlm-roberta-large")
            log.info("Manifesto Tokenizer loaded.")
        return self._tokenizer

    @property
    def model(self):
        if not self._model:
            self._model = AutoModelForSequenceClassification.from_pretrained(
                "manifesto-project/manifestoberta-xlm-roberta-56policy-topics-context-2023-1-1",
                trust_remote_code=True,
            ).to(self.device)
            self._labels = self._model.config.id2label
            log.info("Manifesto Classifier loaded.")

        return self._model

    def tokenize(self, tokens, context):
        encodings = self.tokenizer(
            tokens,
            context,
            is_split_into_words=True,
            truncation=True,
            padding="max_length",
            return_tensors="pt",
            max_length=300,
        )
        return encodings

    def _get_probas(self, out):
        probs = torch.softmax(out.logits, dim=1).detach().cpu().numpy()
        preds = np.argmax(probs, axis=1)
        confidences = probs.max(axis=1)
        labels = [self._labels[i] for i in preds]
        return list(zip(labels, confidences, strict=True))

    def predict(
        self,
        tokens: list[str] | list[list[str]],
        context: list[str] | list[list[str]] | None = None,
        chunksize=32,
    ):
        """Predict populism dimensions of an already tokenized sentence."""
        # ensure correct tokens-batch format
        if len(tokens) < 1:
            # if tokens is empty, raise Error
            tokens = [[]]
        elif isinstance(tokens, list) and isinstance(tokens[0], str):
            # if tokens is a single sentence wrap in in batch
            tokens = [tokens]

        # ensure correct context-batch format
        if not context:
            context = tokens
        if len(context) < 1:
            # if tokens is empty, raise Error
            context = [[]]
        elif isinstance(context, list) and isinstance(context[0], str):
            # if tokens is a single sentence wrap in in batch
            context = [context]
            context = [flatten_list(cxt) for cxt in context]
        else:
            context = [flatten_list(cxt) for cxt in context]

        results = []
        token_chunks = chunks(tokens, chunksize=chunksize)
        context_chunks = chunks(context, chunksize=chunksize)
        for toks, cxts in zip(token_chunks, context_chunks, strict=True):
            encodings = self.tokenize(toks, cxts)
            encodings = encodings.to(self.device)

            with torch.inference_mode():
                out = self.model(**encodings)

            probas = self._get_probas(out)
            results.extend(probas)

        return results
