#import "@preview/zero:0.3.3": ztable

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

= Appendix <appendix>


#counter(heading).update(0)
#counter(page).update(1)
#counter(figure).update(0)

#set heading(numbering: "A1", supplement: [Appendix])
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

= Dataset <ap:dataset>

== Channels

#let table_array = csv("../tables/channel_descriptives.csv", row-type: array)
#let header = table_array.first()
#let table_content = table_array.slice(1)


// #show figure: set block(breakable: false)

#figure(
  kind: table,
  context [
    #set text(size: 0.85em)
    #table(
      columns: (3cm, 5cm, 3cm),
      align: (left, left, right),
      inset: 4pt,
      stroke: none,
      table.hline(),
      table.header(..header),
      table.hline(),
      table.vline(x: 1, start: 1, end: table_content.len() + 1),
      ..table_content.flatten(),
      table.hline(),
    )
  ],
  caption: [Followers per channel.],
)


== Videos per channel

#let table_array = csv("../tables/videos_per_channel.csv", row-type: array)
#let header = table_array.first()
#let table_content = table_array.slice(1)

#figure(
  kind: table,
  context [
    #set text(size: 0.85em)
    #ztable(
      format: (none, ..(auto,) * (header.len() - 2), (digits: 3)),
      columns: (2.5cm, ..(auto,) * (header.len() - 1)),
      align: (left, ..(right,) * (header.len() - 1)),
      inset: 4pt,
      stroke: none,
      table.hline(),
      table.header(..header),
      table.hline(),
      table.vline(x: 1, start: 1, end: table_content.len() + 1),
      ..table_content.flatten(),
      table.hline(),
    )
  ],
  caption: [Number of Videos per channel.],
)

== Descriptives per channel

#let table_array = csv("../tables/video_descriptives_per_channel.csv", row-type: array)
#let header = table_array.first()
#let table_content = table_array.slice(1)
// #show figure: set block(breakable: false)

#figure(
  kind: table,
  context [
    #set text(size: 0.85em)
    #ztable(
      format: (none, (digits: 3), (digits: 0), (digits: 3), (digits: 0), auto),
      columns: (2.5cm, ..(auto,) * (header.len() - 1)),
      align: (left, ..(right,) * (header.len() - 1)),
      inset: 4pt,
      stroke: none,
      table.hline(),
      table.header(..header),
      table.vline(x: 1, start: 1, end: table_content.len() + 1),
      table.hline(),
      ..table_content.flatten(),
      table.hline(),
    )
  ],
  caption: [Engagement metrics per channel.],
)


= Regressions Results on Number of Likes <ap:reg_on_likes>

#figure(
  image("../figures/reg_likes_elite.svg", width: 100%),
  // placement: auto,
  caption: [
    Regression of Anti-Elitism on Number of Likes per video. A separate regression is run for each channel.
  ],
) <fig:likes_elite>

#figure(
  image("../figures/reg_likes_pplcentr.svg", width: 100%),
  // placement: auto,
  caption: [
    Regression of People-Centrism on Number of Likes per video. A separate regression is run for each channel.
  ],
) <fig:likes_pplcentr>

= Simulation study Bayesian $R^2$ <ap:sim_bayes_r2>

TODO: DESCRIBE SIMULATION IN MORE DETAIL

#let table_array = csv("../tables/synthetic_correlation_matrix.csv", row-type: array)
#let header = table_array.first()
#let table_content = table_array.slice(1)

#figure(
  kind: table,
  context [
    #set text(size: 0.85em)
    #table(
      columns: (2.5cm, 2.5cm, 2.5cm, 2.5cm, 2.5cm),
      // align: (left, right, right, right, right),
      inset: 4pt,
      stroke: none,
      table.hline(),
      table.header(..header),
      table.hline(),
      ..table_content.flatten(),
      table.hline(),
    )
  ],
  caption: [Correlation matrix for variables underlying the simulation study.],
)<tbl:bayes_r2_cor_mat>

#figure(
  image("../figures/bayes_r2_synthetic_coefficients.svg", width: 80%),
  // placement: auto,
  caption: [
    Coefficients of quantile regressions with synthetic data.
  ],
) <fig:bayes_r2_coefficients>

#figure(
  image("../figures/bayes_r2_synthetic.svg", width: 80%),
  // placement: auto,
  caption: [
    Bayesian $R^2$ for quantile regressions with synthetic data.
  ],
) <fig:bayes_r2>

= Top 10 most viewed video per channel <ap:most_viewed>

#let table_array = csv("../tables/most_viewed_videos_per_channel.csv", row-type: array)
#let header = ([Channel], [N Likes], [N Views], [Title])
#let table_content = table_array.slice(1)

#figure(
  align(center)[
    #set par(leading: 0.65em, justify: false)
    #set text(size: 10.2pt)
    #table(
      columns: (auto, ..(auto,) * (header.len() - 1)),
      align: (left, ..(right,) * (header.len() - 2), left),
      inset: 4pt,
      stroke: (x, y) => (
        top: if calc.rem(y - 1, 10) == 0 { 1pt },
      ),
      table.hline(),
      table.header(..header),
      table.vline(x: 1, start: 1, end: table_content.len() + 1),
      table.hline(),
      ..table_content.flatten(),
      table.hline(),
    )
  ],
  caption: [Most successful videos. Shown are the top 10 videos ordered by video_likes. The FDP is excluded due to their videos having basically no likes.],
  kind: table,
) <ap:tab:most_viewed_videos>

= Top 10 most liked videos per channel <ap:most_liked>

#let table_array = csv("../tables/most_liked_videos_per_channel.csv", row-type: array)
#let header = ([Channel], [N Likes], [N Views], [Title])
#let table_content = table_array.slice(1)

#show figure: set block(breakable: true)
#figure(
  align(center)[
    #set par(leading: 0.65em, justify: false)
    #set text(size: 10.2pt)
    #block(breakable: true, table(
      columns: (auto, ..(auto,) * (header.len() - 1)),
      align: (left, ..(right,) * (header.len() - 2), left),
      inset: 4pt,
      stroke: (x, y) => (
        top: if calc.rem(y - 1, 10) == 0 { 1pt },
      ),
      table.hline(),
      table.header(..header),
      table.vline(x: 1, start: 1, end: table_content.len() + 1),
      table.hline(),
      ..table_content.flatten(),
      table.hline(),
    ))
  ],
  caption: [Most successful videos. Shown are the top 10 videos ordered by video_likes. The FDP is excluded due to their videos having basically no likes.],
) <ap:tab:most_liked_videos>

= Top 10 most anti-elitist videos per channel <ap:most_elite>

#let table_array = csv("../tables/most_antielitism_videos_per_channel.csv", row-type: array)
#let header = ([Channel], [Sents], [Anti-Elite], [Title])
#let table_content = table_array.slice(1)

#figure(
  align(center)[
    #set par(leading: 0.65em, justify: false)
    #set text(size: 10.2pt)
    #table(
      columns: (auto, ..(auto,) * (header.len() - 1)),
      align: (left, ..(right,) * (header.len() - 2), left),
      inset: 4pt,
      stroke: (x, y) => (top: if calc.rem(y - 1, 10) == 0 { 1pt }),
      table.hline(),
      table.header(..header),
      table.vline(x: 1, start: 1, end: table_content.len() + 1),
      table.hline(),
      ..table_content.flatten(),
      table.hline(),
    ),
  ],
  caption: [This table shows the top 10 most anti-elitist videos per channel. Anti-Elite shows the fraction of sentences that are classified as anti-elitist in each video.],
  kind: table,
  placement: bottom,
) <ap:tab:most_elite_videos>
