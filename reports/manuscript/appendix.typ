#let convert-to-float(val) = {
  let check = val.find(regex("^\d+[\.,]?\d*$"))
  if check != none {
    str(calc.round(float(val), digits: 2))
  } else {
    val
  }
}

= Appendix <appendix>


#counter(heading).update(0)
#counter(page).update(1)
#counter(figure).update(0)

#set heading(numbering: "A.1", supplement: [Appendix])
#show heading: it => {
  if it.level == 1 and it.numbering != none {
    [#it.supplement #counter(heading).display():]
  } else if it.numbering != none {
    [#counter(heading).display().]
  }
  counter(figure).update(0)

  h(0.3em)
  it.body
  parbreak()
}

#set figure(numbering: num => {
    let fig_num = counter(figure).get().at(0)
    let section = counter(heading).display()
    str(section) + str(fig_num)
})

= Regressions Results on Number of Likes <ap:reg_on_likes>

#figure(
  image("../figures/reg_ame_likes_elite.svg", width: 100%),
  // placement: auto,
  caption: [
    Regression of Anti-Elitism on Number of Likes per video. A separate regression is run for each channel.
  ]
  ) <fig:likes_elite>

#figure(
  image("../figures/reg_ame_likes_pplcentr.svg", width: 100%),
  // placement: auto,
  caption: [
    Regression of People-Centrism on Number of Likes per video. A separate regression is run for each channel.
  ]
) <fig:likes_pplcentr>

= Top 10 most viewed video per channel <ap:most_viewed>

#let table_array = csv("../tables/most_viewed_videos_per_channel.csv", row-type: array)
#let header = ([Channel], [N Likes], [N Views], [Title])
#let table_content = table_array.slice(1).map(m => m.map(convert-to-float))

#figure(
  align(center)[
    #set par(leading: 0.65em, justify: false)
    #set text(size: 10.2pt)
    #table(
      columns: (auto, ..(auto,) * (header.len() - 1)),
      align: (left, ..(right,) * (header.len() - 2), left),
      inset: 4pt,
      stroke: (x, y) => (
        top: if calc.rem(y - 1, 10) == 0 { 1pt }
      ),
      table.hline(),
      table.header(..header),
      table.vline(x: 1, start: 1, end: table_content.len() + 1),
      table.hline(),
      ..table_content.flatten(),
      table.hline()
    )
  ]
  , caption: [Most successful videos. Shown are the top 10 videos ordered by video_likes. The FDP is excluded due to their videos having basically no likes.]
  , kind: table
) <ap:tab:most_viewed_videos>

= Top 10 most liked videos per channel <ap:most_liked>

#let table_array = csv("../tables/most_liked_videos_per_channel.csv", row-type: array)
#let header = ([Channel], [N Likes], [N Views], [Title])
#let table_content = table_array.slice(1).map(m => m.map(convert-to-float))

#show figure: set block(breakable: true)
#figure(
  align(center)[
    #set par(leading: 0.65em, justify: false)
    #set text(size: 10.2pt)
    #block(
      breakable: true,
      table(
        columns: (auto, ..(auto,) * (header.len() - 1)),
        align: (left, ..(right,) * (header.len() - 2), left),
        inset: 4pt,
        stroke: (x, y) => (
          top: if calc.rem(y - 1, 10) == 0 { 1pt }
        ),
        table.hline(),
        table.header(..header),
        table.vline(x: 1, start: 1, end: table_content.len() + 1),
        table.hline(),
        ..table_content.flatten(),
        table.hline()
      )
    )
  ],
  caption: [Most successful videos. Shown are the top 10 videos ordered by video_likes. The FDP is excluded due to their videos having basically no likes.],
) <ap:tab:most_liked_videos>

= Top 10 most anti-elitist videos per channel <ap:most_elite>

#let table_array = csv("../tables/most_antielitism_videos_per_channel.csv", row-type: array)
#let header = ([Channel],  [Sents], [Anti-Elite], [Title])
#let table_content = table_array.slice(1).map(m => m.map(convert-to-float))

#figure(
  align(center)[
    #set par(leading: 0.65em, justify: false)
    #set text(size: 10.2pt)
    #table(
      columns: (auto, ..(auto,) * (header.len() - 1)),
      align: (left, ..(right,) * (header.len() - 2), left),
      inset: 4pt,
      stroke: (x, y) => (
        top: if calc.rem(y - 1, 10) == 0 { 1pt }
      ),
      table.hline(),
      table.header(..header),
      table.vline(x: 1, start: 1, end: table_content.len() + 1),
      table.hline(),
      ..table_content.flatten(),
      table.hline()
    ),
  ],
  caption: [This table shows the top 10 most anti-elitist videos per channel. Anti-Elite shows the fraction of sentences that are classified as anti-elitist in each video.],
  kind: table,
  placement: bottom,
) <ap:tab:most_elite_videos>
