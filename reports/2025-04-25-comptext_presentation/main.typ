#import "@preview/touying:0.6.1": *
#import "stuttgart.typ": *

#show list: e => {
  show par: p => {
    p
    v(1.0em, weak: true)
  }
  e
}

#show: stuttgart-theme.with(
  config-colors(
    primary: uniBlue,
    primary-light: uniLightBlue,
    secondary: uniBlue,
  ),
  config-info(
    title: [Populism on YouTube],
    subtitle: [How German Parties Utilize New Social Media Platforms],
    author: [Lukas Erhard],
    date: [April 25#super[th], 2025],
    institution: [
      University of Stuttgart, Department for Computational Social Sciences#linebreak()
      Interchange Forum for Reflecting on Intelligent Systems (SRF IRIS)
    ],
    logo: image("img/logos/youtube_logo.svg", height: 13%)
  ),
  config-common(
    new-section-slide-fn: none,
    // show-bibliography-as-footnote: bibliography("references.bib")
  )
)
#title-slide()

#let convert-to-float(val) = {
  let check = val.find(regex("^\d+[\.,]?\d*$"))
  if check != none {
    str(calc.round(float(val), digits: 2))
  } else {
    val
  }
}

#let highlight-max(row) = {
  let numeric-part = row.slice(1).map(v => float(v))
  let row-max = calc.max(..numeric-part)

  let make-bold(item) = {

    let check = item.find(regex("^\d+[\.,]?\d*$"))
    if check == none {
      item
    } else {
      let num-item = float(item)
      if num-item == row-max {
        set text(weight: "bold")
        convert-to-float(item)
      } else {
        convert-to-float(item)
      }
    }
  }
  row.map(make-bold)
}

#let highlight-rect(x, y, width, height) = {
  place(
    top + left,
    dy: y,
    dx: x,
    rect(
      fill: none,
      stroke: 4pt + red,
      height: height,
      width: width,
      radius: 7pt,
    ),
  )
}

= Theory

== Goal of this study

#miniheader[Overview]

- investigating populist content on *YouTube*
- YouTube meaning: the official *party channels* of all parties in the (last) German Bundestag
- Dataset:
  - Channels: \@FDP, \@DieGruenen, \@spdde, \@cdutv, \@csumedia, \@AfDTV, \@AfDFraktionimBundestag, \@DIELINKE
  - all videos between
    - December 6, 2017 (final channel's inaugural video)
    - February 24, 2025 (day of the Bundestagswahl 2025)
  - Total:
    - 12,178 videos
    - 1,659.2 hours containing 908,222 sentences


== Populism

#miniheader[What is Populism?]

- Defined as the struggle between the "corrupt elite" and the "virtuous" people @muddePopulistZeitgeist2004
  - focusing on *anti-elitism* and *people-centrism*
- Treated as gradational concept ("more or less populism") rather than binary attribute
- In German context, *AfD* and *The Left* are considered populist parties @schurmannYellingSidelinesHow2022


== YouTube

#miniheader[YouTube as a research platform]

- Second most important information source for young Germans after Google @allgaierRezoGermanClimate2020
- Enables measuring direct user engagement through *views* and *likes*

= Dataset

== Dataset

#let table_array = csv("../tables/dataset_summary.csv", row-type: array)
#let header = table_array.first()
#let table_content = table_array.slice(1).map(row => highlight-max(row))

#figure(
  kind: table,
  context [
    #set text(size: 0.89em)
    #table(
      columns: (4.5cm, ..(auto,) * (header.len() - 1)),
      align: (left, ..(right,) * (header.len() - 1)),
      inset: 8pt,
      stroke: none,
      table.hline(),
      table.header(..header),
      table.vline(x: 1, start: 1, end: table_content.len() + 1),
      table.hline(),
      ..table_content.flatten(),
      table.hline(),
    )
  ],
)

#only("2")[
#highlight-rect(130pt, 30pt,160pt, 330pt)
]

#only("3")[
#highlight-rect(475pt, 165pt,60pt, 30pt)
]

== View and Like counts

#figure(
  placement: none,
  image("../figures/view_count.svg", height: 100%),
)

== Whisper

#miniheader[Speech-to-Text ]
- Used OpenAI's *whisper-large-v3-turbo* model @radfordRobustSpeechRecognition2022 to transcribe video content
- Combined with *Silero voice activity detector* @silerovad2024 to reduce hallucinations
    - Isolates segments containing actual speech
    - Passes only speech segments to Whisper transcription model

#infobox[But why?][
- Produces higher quality transcripts than YouTube's auto-generated captions
  - Preserves word case (especially important in German)
  - Maintains punctuation marks necessary for accurate analysis
]

== PopBERT

#miniheader[Detection of Populism]

- BERT-based transformer model specifically fine-tuned to detect populism in German political speech @erhardPopBERTDetectingPopulism2024
- Detected on the sentence-level: *anti-elitism* and *people-centrism*
- aggregated to the video-level by calculating the ratio

= Results


== Populism by channel

#figure(
  placement: none,
  image("../figures/populism_per_party.svg", height: 100%),
)

== Explanation regression models

#slide[
#miniheader[Regression models]

- DV: `log(view count)`
- IVs:
  - `log(n_sents)`
  - `released_year`
  - `is_short` (< 180sec)
  - `elite/pplcentr`
  - `is_short * elite/pplcentr` (interaction)
][
- Linear regressions, 1 per populist dimension per channel
- Results displayed as Average Marginal Effects (*AME*)
- Range x-axis: `[0, +2sd]`
]

== Effect of Anti-Elitism

#figure(
  placement: none,
  image("../figures/reg_ame_views_elite.svg", height: 110%),
)


== Effect of People-Centrism

#figure(
  placement: none,
  image("../figures/reg_ame_views_pplcentr.svg", height: 110%),
)

= Conclusion

==
#miniheader[Conclusion]

- German populist parties are fare more successful that non-populist parties on YouTube
- The use of populist language differs across populist parties:
  - *AfD* emphasizes *anti-elitist* messages
  - the *Left* uses *people-centric* appeals more often
- Positive relationship between user engagement and populist content is clearest for the populist parties but can also be found in some other channels

#show: appendix

= References

==
#set text(size: 15pt)
#bibliography("library/references.bib", style: "library/custom.csl", title: none)
#v(1fr)


#figure(
  placement: none,
  image("../figures/reg_ame_likes_elite.svg", height: 110%),
)

#figure(
  placement: none,
  image("../figures/reg_ame_likes_pplcentr.svg", height: 110%),
)
