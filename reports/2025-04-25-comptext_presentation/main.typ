#import "@preview/touying:0.6.0": *
#import "stuttgart.typ": *

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


== Populism

A slide about populism

== YouTube

A slide about YouTube

// #miniheader[Introduction]

// #v(1fr)
// _In contrast to filter bubbles—which only suggest algorithmic curation will provide users with more ideologically congenial content, compared to an uncurated platform—rabbit holes *additionally imply* that the curation process *serves up content from one’s preferred side* but with *increasing extremity or intensity over time*._ @liuShorttermExposureFilterbubble2025

// #v(1fr)
// #infobox[Research Question][*Does the YouTube recommendation algorithm contribute to the creation of rabbit holes for it's users?* ]

= Data & Methods

== Dataset

#let table_array = csv("../tables/dataset_summary.csv", row-type: array)
#let header = table_array.first()
#let table_content = table_array.slice(1).map(row => highlight-max(row))
#show figure: set block(breakable: false)

#figure(
  kind: table,
  context [
    #set text(size: 0.88em)
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
      table.hline()
    )
  ],
)

#uncover("2")[
  #highlight-rect(130pt, 30pt,160pt, 330pt)
]

#uncover("3")[
#highlight-rect(475pt, 165pt,60pt, 30pt)
]

== Whisper

A slide about Whisper

== PopBERT

A slide about PopBERT




= Results

== View and Like counts

#figure(
  placement: none,
  image("../figures/view_count.svg", height: 100%),
)

== Populism by channel

#figure(
  placement: none,
  image("../figures/populism_per_party.svg", height: 100%),
)

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

What do we learn?


= References

#set text(size: 15pt)
#bibliography("references.bib", style: "chicago-notes", title: none)
#v(1fr)
