import marimo

__generated_with = "0.18.0"
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
    tr = jiwer.Compose([
        jiwer.RemoveMultipleSpaces(),
        jiwer.Strip(),
        jiwer.ReduceToListOfListOfWords(),
    ])

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


@app.cell
def _():
    return


@app.cell
def _():
    sref = "REF: Sind wir jetzt besser auf eine Regierung Donald Trump vorbereitet, Herr Kubicki? Ich weiß nicht, wen Sie mit wir meinen. Wenn Sie die Außenministerin meinen, das Außenministerium, glaube ich das nicht. Wenn Sie jetzt die ******** ** amtierende Bundesregierung meinen, glaube ich das nicht, weil sie erst mal mental ankommen  müssen bei der Realität. Denn ich kann mich daran erinnern, dass alle, die ich  kenne im politischen Berlin, einschließlich der Medien, darauf gesetzt haben, dass Kamala Harris es wird. Anders kann man sich nicht erklären, dass im amerikanischen Wahlkampf das Außenministerium sich offiziell eingemischt hat mit *** Erklärungen gegen Trump. Und ich  glaube die   Amerikaner, Trump, die Administration, haben sich sehr genau gemerkt, wer wann wie sich auch abschätzig über den künftigen amerikanischen Präsidenten geäußert haben. Und wir müssen uns nicht wundern, wenn es darauf Reaktionen gibt. Wir müssen aufpassen Kathrin, dass wir nicht, wir, mit wir meine ich wirklich als Deutsche in der Welt, immer mit erhobenen Zeigefinger rumgehen. Mit Frau Meloni reden wir nicht, weil postfaschistisch, mit den Österreichern ****** *** nichts mehr reden, weil die FPÖ mitregiert. Mit den Ungarn haben wir Riesenprobleme. Mit den Tschechen haben wir jetzt wieder Probleme.       Also irgendwann sind wir ganz alleine mit unserer Moral. Und Außenpolitik muss immer interessengeleitet sein. Wir müssen gucken, welche Interessen hat  Deutschland und das Interesse besteht nicht darin, die gesamte Welt von unserem Modell nicht nur zu überzeugen, sondern zu erklären: Ihr seid böse Menschen, wenn ihr unseren Überlegungen nicht folgt. Das ist unser großes Problem momentan. Dass in Frankreich mittlerweile mehr als die Hälfte der  Franzosen die Deutschen nicht mehr mögen, hat auch was mit dem Auftreten zu tun."
    shyp = "HYP: Sind wir jetzt besser auf eine Regierung Donald Trump vorbereitet, Herr Kubicki? Ich weiß nicht, wen Sie mit wir meinen. Wenn Sie die Außenministerin meinen, das Außenministerium, glaube ich das nicht. Wenn Sie jetzt die Amtieren in        der Bundesregierung meinen, glaube ich das nicht, weil Sie erst mal mental ankommen müssen. Bei der Realität, denn ich kann mich daran erinnern, dass alle, die ich kenne, im politischen Berlin, einschließlich den Medien, darauf gesetzt haben, dass Kamala Harris es wird. Anders kann man sich nicht erklären, dass im amerikanischen Wahlkampf das Außenministerium sich offiziell eingemischt hat mit der     Klärung gegen Trump. Und ich glaube, die Amerikaner... Trump, die Administration, haben sich sehr genau gemerkt, wer wann wie sich auch abschätzig über den künftigen amerikanischen Präsidenten geäußert haben. Wir *** müssen uns nicht wundern, wenn es darauf Reaktionen gibt. *** ****** ********* Kathrin, dass wir  nicht wir, mit wir meine ich wirklich als Deutsche in der  Welt immer mit erhobenen Zeigefinger rumgehen. Mit Frau Meloni reden wir nicht, weil postfaschistisch. Mit den Österreichern werden wir  nicht mehr reden, weil die FPÖ mitregiert. Mit den Ungarn haben wir Riesenprobleme. Mit den Tschechen haben wir jetzt wieder Probleme. Irgendwann ********** sind wir ganz alleine mit unserer Moral. Und Außenpolitik muss immer interessengeleitet sein. Wir müssen gucken, welche Interessen hat Deutschland. Und das Interesse besteht nicht darin, die gesamte Welt von unserem Modell nicht nur zu überzeugen, sondern zu erklären, ihr seid böse Menschen, wenn ihr unseren Überlegungen nicht folgt. Das ist unser großes Problem momentan, dass in Frankreich mittlerweile mehr als die Hälfte der Franzosen, die Deutschen nicht mehr mögen, hat auch was mit dem Auftreten zu tun. "

    err = "                                                                                                                                                                                                                                         I  I          S                                                      S                                S   S             S    S                                                       S                                         S                                                                                                                                                                                           I           S                            S                 S                                                                                                                                                             S   D                                                             D      D         D                        S                                                         S                                                                                                 S   S                        I   I      S                                                                                                                                           S          D                                                                                                                                                   S   S                                                                                                                    S   S                                                                                                     S    S                                                             S                                                                       "
    return err, shyp, sref


@app.cell
def _():
    start = 1800
    end = 1900
    return end, start


@app.cell
def _(end, sref, start):
    print(sref[start:end])
    return


@app.cell
def _(end, shyp, start):
    print(shyp[start:end])
    return


@app.cell
def _(end, err, start):
    print(err[start:end])
    return


@app.cell
def _():
    return


@app.cell
def _():
    return


if __name__ == "__main__":
    app.run()
