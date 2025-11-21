import marimo

__generated_with = "0.17.8"
app = marimo.App(width="full")


@app.cell
def _():
    from ibis import _
    import pandas as pd

    import src
    from src.load import DataLoader
    return DataLoader, pd, src


@app.cell
def _(DataLoader):
    dl = DataLoader()
    return (dl,)


@app.cell
def _(dl):
    base = (
        dl.sentences(text_fields=True, filtered=True)
        .join(dl.popbert(filtered=False, binarize_predictions=True), "sentence_id")
        .order_by("sentence_id")
        .to_pandas()
    )
    return (base,)


@app.cell
def _(base):
    elite = base[base.elite == 1].sample(n=50, random_state=42)
    return (elite,)


@app.cell
def _(base):
    pplcentr = base[base.pplcentr == 1].sample(n=50, random_state=42)
    return (pplcentr,)


@app.cell
def _(base):
    nothing = base[(base.elite == 0) & (base.pplcentr == 0)].sample(n=100, random_state=42)
    return (nothing,)


@app.cell
def _(elite, nothing, pd, pplcentr):
    df = pd.concat(
        [elite, pplcentr, nothing],
        axis=0,
    )

    df = df[["sentence_id", "video_id", "sentence_no", "tokens", "elite", "pplcentr"]]
    df = df.sample(frac=1, random_state=42)
    df["text"] = df.tokens.apply(lambda x: " ".join(x))
    df.drop("tokens", axis=1, inplace=True)
    return (df,)


@app.cell
def _(df, src):
    df.to_csv(src.PATH / "data/validation/popbert/unlabeled.csv", encoding="utf-8", index=False)
    return


@app.cell
def _(elite, nothing, pd, pplcentr):
    test = pd.concat(
        [
            elite.to_pandas(),
            pplcentr.to_pandas(),
            nothing.to_pandas(),
        ],
        axis=0,
    )
    return (test,)


@app.cell
def _(test):
    test
    return


if __name__ == "__main__":
    app.run()
