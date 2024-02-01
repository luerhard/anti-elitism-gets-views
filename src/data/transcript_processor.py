from somajo import SoMaJo
import torch
from transformers import AutoTokenizer
from transformers import AutoModelForSequenceClassification


class TranscriptProcessor:
    def __init__(self) -> None:
        self.sentence_splitter = SoMaJo("de_CMC", split_sentences=True)
        self.tokenizer = AutoTokenizer.from_pretrained("luerhard/PopBERT")
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        self.model = AutoModelForSequenceClassification.from_pretrained(
            "luerhard/PopBERT"
        ).to(self.device)

    def _clean_sentence(self, sentence) -> list[str]:
        sentence = [tok for tok in sentence if tok != "Musik"]
        return sentence

    def predict_populism(self, sentence):
        encodings = self.tokenizer(
            [sentence], is_split_into_words=True, return_tensors="pt"
        )
        encodings = encodings.to(self.device)

        with torch.inference_mode():
            out = self.model(**encodings)

        probs = torch.nn.functional.sigmoid(out.logits)
        probs = probs.detach().numpy()
        return probs[0]

    def tokenize(self, text: str) -> list[str]:
        sentence_iterator = self.sentence_splitter.tokenize_text([text])
        sentences = []
        for sentence in sentence_iterator:
            tokens = [tok.text for tok in sentence]
            sentence = self._clean_sentence(tokens)
            sentences.append(sentence)
        return sentences