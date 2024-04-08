"""Processes transcripts. Tokenizes them and uses PopBERT to predict populism dimensions."""

from somajo import SoMaJo

from src.logging import logger as log

class TranscriptCleaner:
    """Processes transcripts. Tokenizes them and uses PopBERT to predict populism dimensions."""

    def __init__(self) -> None:
        self.sentence_splitter = SoMaJo("de_CMC", split_sentences=True)

    @staticmethod
    def _remove_ngram(sentence, remove_ngram):
        """Not used anymore. We just skip faulty sentences completely."""
        n = len(remove_ngram)
        if len(sentence) <= n:
            return sentence
        sent_start = sentence[:n]
        if tuple(sent_start) == remove_ngram:
            in_sequence = True
        else:
            in_sequence = False
        result = [*sent_start]
        cur_index = 1
        while cur_index < len(sentence):
            ngram = tuple(sentence[cur_index : cur_index + n])
            if set(ngram) == set(remove_ngram) and in_sequence:
                cur_index += 1
                continue
            if ngram == remove_ngram:
                in_sequence = True
            else:
                in_sequence = False

            result.append(ngram[-1])
            cur_index += 1
        return result

    @staticmethod
    def _count_duplicate_ngrams(sentence):
        sent_length = len(sentence)
        best_ngram = ()
        best_count = 0
        for gram in (10, 9, 8, 7, 6, 5, 4, 3, 2):
            if not sent_length > gram:
                continue
            cur_index = 0
            while sent_length > ((cur_index + gram) * 2):
                cur_ngram_start = cur_index
                cur_ngram_end = cur_index + gram
                next_ngram_start = cur_ngram_end
                next_ngram_end = next_ngram_start + gram

                cur_count = 0
                cur_ngram = sentence[cur_ngram_start:cur_ngram_end]
                next_ngram = sentence[next_ngram_start:next_ngram_end]
                while (next_ngram_end < sent_length) and (cur_ngram == next_ngram):
                    cur_count += 1
                    next_ngram_start = next_ngram_end
                    next_ngram_end = next_ngram_start + gram
                    next_ngram = sentence[next_ngram_start:next_ngram_end]

                if cur_count > best_count:
                    best_count = cur_count
                    best_ngram = cur_ngram

                cur_index += 1

        return tuple(best_ngram), best_count

    def _remove_duplicate_ngrams(self, sentence) -> list[str]:
        """Not used anymore. We just remove the sentences completely. They don't make much sense
        anyhow.
        """
        common_gram, common_n = self._count_duplicate_ngrams(sentence)
        if common_n > 10:
            log.error("n gram faulty -- occured %d times: %s", common_n, common_gram)
            sentence = self._remove_ngram(sentence, common_gram)
            return self._remove_duplicate_ngrams(sentence)
        return sentence

    def skip_sentence_duplicate_ngrams(self, sentence):
        common_gram, common_n = self._count_duplicate_ngrams(sentence)
        if common_n > 10:
            log.error("n gram faulty -- occured %d times: %s", common_n, common_gram)
            return True
        return False

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
            if not self.skip_sentence_duplicate_ngrams(sentence):
                sentences.append(sentence)
        return sentences
