import torch
from transformers import AutoModelForSequenceClassification
from transformers import AutoTokenizer

from src.utils.iterate import chunks


class PopBERTPredictor:
    def __init__(self) -> None:
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        self._tokenizer = None
        self._model = None
        self._max_length = None

    @property
    def tokenizer(self):
        if not self._tokenizer:
            self._tokenizer = AutoTokenizer.from_pretrained("luerhard/PopBERT")
        return self._tokenizer

    @property
    def model(self):
        if not self._model:
            self._model = AutoModelForSequenceClassification.from_pretrained(
                "luerhard/PopBERT",
            ).to(
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
        return probs

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
