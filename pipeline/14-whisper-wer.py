import marimo

__generated_with = "0.17.8"
app = marimo.App(width="full")


@app.cell
def _():
    import ibis
    from ibis import _
    from ibis import selectors as s
    import jiwer

    import src
    from src.load import DataLoader
    return ibis, jiwer, src


@app.cell
def _(ibis, src):
    con = ibis.duckdb.connect()
    transcripts = con.read_parquet(src.PATH / "data/interim/transcripts/v3_large_turbo.parquet")
    return (transcripts,)


@app.cell
def _(transcripts):
    def load_test_data(video_ids):
        out = {}
        for video_id in video_ids:
            video_df = transcripts.filter(_.video_id == video_id).execute()
            assert len(video_df) == 1
            out[video_id] = video_df.text[0]
        return out
    return (load_test_data,)


@app.cell
def _(src):
    def load_validation_data():
        manual_folder = src.PATH / "data/validation/whisper/"

        out = {}
        for file in manual_folder.iterdir():
            key = file.stem
            content = file.read_text().replace("\n", " ")
            out[key] = content

        return out
    return (load_validation_data,)


@app.cell
def _(load_validation_data):
    val = load_validation_data()
    return (val,)


@app.cell
def _(load_test_data, val):
    test = load_test_data(val.keys())
    return (test,)


@app.cell
def _(test, val):
    assert val.keys() == test.keys()
    return


@app.cell
def _(test, val):
    reference = []
    hypothesis = []
    for key in list(val.keys()):
        reference.append(val[key])
        hypothesis.append(test[key])
    return hypothesis, reference


@app.cell
def _(hypothesis, jiwer, reference):
    tr = jiwer.Compose(
        [
            jiwer.RemoveMultipleSpaces(),
            jiwer.Strip(),
            jiwer.ReduceToListOfListOfWords(),
        ]
    )

    ref = jiwer.RemovePunctuation()(reference)
    ref_lower = jiwer.ToLowerCase()(ref)
    hypo = jiwer.RemovePunctuation()(hypothesis)
    hypo_lower = jiwer.ToLowerCase()(hypo)

    out = jiwer.process_words(reference, hypothesis, hypothesis_transform=tr, reference_transform=tr)
    print(jiwer.visualize_alignment(out))
    return hypo, hypo_lower, ref, ref_lower, tr


@app.cell
def _(hypothesis, jiwer, reference, tr):
    print(
        jiwer.wer(
            hypothesis=hypothesis,
            reference=reference,
            reference_transform=tr,
            hypothesis_transform=tr,
        )
    )
    return


@app.cell
def _(hypo, jiwer, ref, tr):
    print(
        jiwer.wer(
            hypothesis=hypo,
            reference=ref,
            reference_transform=tr,
            hypothesis_transform=tr,
        )
    )
    return


@app.cell
def _(hypo_lower, jiwer, ref_lower, tr):
    print(
        jiwer.wer(
            hypothesis=hypo_lower,
            reference=ref_lower,
            reference_transform=tr,
            hypothesis_transform=tr,
        )
    )
    return


if __name__ == "__main__":
    app.run()
