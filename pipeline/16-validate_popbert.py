import marimo

__generated_with = "0.17.8"
app = marimo.App(width="full")


@app.cell
def _():
    from pathlib import Path

    from ibis import _
    import pandas as pd
    from sklearn.metrics import classification_report
    from sklearn.metrics import multilabel_confusion_matrix

    import src
    from src.load import DataLoader
    return DataLoader, classification_report, pd, src


@app.cell
def _(DataLoader):
    dl = DataLoader()
    return


@app.cell
def _(pd, src):
    df = pd.read_csv(src.PATH / "data/validation/popbert/erhard.csv")
    return (df,)


@app.cell
def _(df):
    df["label_elite"] = df["label"].str.contains("Anti-Elitism", na=False)
    df["label_pplcentr"] = df["label"].str.contains("People-Centrism", na=False)
    df["elite"] = df["elite"].astype(bool)
    df["pplcentr"] = df["pplcentr"].astype(bool)

    y_pred = list(zip(df.elite, df.pplcentr, strict=False))
    y_true = list(zip(df.label_elite, df.label_pplcentr, strict=False))
    return y_pred, y_true


@app.cell
def _(classification_report, y_pred, y_true):
    print(
        classification_report(
            y_pred=y_pred,
            y_true=y_true,
            target_names=["Anti-Elitism", "People-Centrism"],
            zero_division=0,
        )
    )
    return


@app.cell
def _(classification_report, pd, y_pred, y_true):
    report = classification_report(
        y_pred=y_pred,
        y_true=y_true,
        target_names=["Anti-Elitism", "People-Centrism"],
        zero_division=0,
        output_dict=True,
    )
    out = pd.DataFrame(report).transpose()
    out = out[["precision", "recall", "f1-score", "support"]]
    out.index.name = "class"
    out.reset_index(inplace=True)
    out = out.iloc[:2, :]
    return (out,)


@app.cell
def _(out):
    latex_table = out.to_latex(
        index=False,
        float_format="%.3f",
        column_format="lrrrr",
    )
    return (latex_table,)


@app.cell
def _(latex_table, src):
    (src.PATH / "overleaf/tables/popbert_classificaton_report.tex").write_text(latex_table)
    return


@app.cell
def _():
    return


if __name__ == "__main__":
    app.run()
