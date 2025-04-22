// This theme is inspired by https://github.com/zbowang/BeamerTheme
// The typst version was written by https://github.com/OrangeX4

#import "@preview/touying:0.6.1": *
#import themes.metropolis: *
#import "@preview/showybox:2.0.4": showybox

#let uniBlue = rgb("#004191")
#let uniLightBlue = rgb("#00BEFF")
#let uniGray = rgb("#3E444C")
#let uniYellow = rgb("#FFD500")

#let miniheader(content, text-color: uniBlue, size: 25pt) = {
  set text(weight: "bold", fill: text-color, size: size)
  content
  v(1pt)
}

#let infobox(..args) = {
  let title = ""
  let body = ""
  if args.pos().len() > 1 {
    title = args.pos().at(0)
    body = args.pos().slice(1)
  } else {
    body = args.pos()
  }
  showybox(
    frame: (
      border-color: uniBlue.darken(10%),
      title-color: uniBlue,
      body-color: uniBlue.lighten(80%),
    ),
    title-style: (
      color: white,
      weight: "bold",
      align: center
    ),
    body-style: (
      color: black
    ),
    shadow: (
      offset: 0pt,
    ),
    title: title,
    ..body
  )
}

// This theme is inspired by https://github.com/matze/mtheme
// The origin code was written by https://github.com/Enivex


/// Default slide function for the presentation.
///
/// - title (string): The title of the slide. Default is `auto`.
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - repeat (int, string): The number of subslides. Default is `auto`, which means touying will automatically calculate the number of subslides.
///
///   The `repeat` argument is necessary when you use `#slide(repeat: 3, self => [ .. ])` style code to create a slide. The callback-style `uncover` and `only` cannot be detected by touying automatically.
///
/// - setting (function): The setting of the slide. You can use it to add some set/show rules for the slide.
///
/// - composer (function, array): The composer of the slide. You can use it to set the layout of the slide.
///
///   For example, `#slide(composer: (1fr, 2fr, 1fr))[A][B][C]` to split the slide into three parts. The first and the last parts will take 1/4 of the slide, and the second part will take 1/2 of the slide.
///
///   If you pass a non-function value like `(1fr, 2fr, 1fr)`, it will be assumed to be the first argument of the `components.side-by-side` function.
///
///   The `components.side-by-side` function is a simple wrapper of the `grid` function. It means you can use the `grid.cell(colspan: 2, ..)` to make the cell take 2 columns.
///
///   For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]]` will make the `Footer` cell take 2 columns.
///
///   If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.
///
/// - bodies (array): The contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.

#let header(self) = {
    let mini-slides = (
        height: 1em,
        x: 2em,
        display-section: false,
        display-subsection: true,
        linebreaks: false,
        short-heading: true,
      )

    let mini-slide-obj = components.mini-slides(
      self: self,
      fill: white,
      alpha: 70%,
      display-section: mini-slides.at("display-section", default: true),
      display-subsection: mini-slides.at("display-subsection", default: false),
      linebreaks: mini-slides.at("linebreaks", default: true),
      short-heading: mini-slides.at("short-heading", default: true),
    )

    set text(size: 0.8em)
    place(
center + top,
      dy: .1em,
rect(
        width: 99%,
        fill: self.colors.primary,
        radius: 12pt
    ))
    place(
center + top,
      dy: .1em,
      utils.call-or-display(self, mini-slide-obj)
)

}

#let footer(self) = {
  set align(bottom)
  set text(size: 0.5em)
  show: pad.with(.5em)
  components.left-and-right(
    text(fill: self.colors.neutral-darkest.lighten(40%), utils.call-or-display(self, self.store.footer)),
    text(fill: self.colors.neutral-darkest.lighten(20%), utils.call-or-display(self, self.store.footer-right)),
  )
}

// #let footer(self) = {
// set std.align(bottom)
//   set text(size: 0.8em)
//   pad(
//     .5em,
//     components.left-and-right(
//       text(fill: self.colors.neutral-darkest.lighten(40%), utils.call-or-display(self, self.store.footer)),
//       text(fill: self.colors.neutral-darkest, utils.call-or-display(self, self.store.footer-right)),
//     ),
//   )
//   if self.store.footer-progress {
//     place(bottom, components.progress-bar(height: 2pt, self.colors.primary, self.colors.primary-light))
//   }
// }

#let slide(
  title: auto,
  align: auto,
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  if align != auto {
    self.store.align = align
  }
  let self = utils.merge-dicts(
    self,
    config-page(
      fill: self.colors.neutral-lightest,
      header: header,
      footer: footer,
    ),
  )
  let new-setting = body => {
    show: std.align.with(self.store.align)
    set text(fill: self.colors.neutral-darkest)
    show: setting
    body
  }
  touying-slide(self: self, config: config, repeat: repeat, setting: new-setting, composer: composer, ..bodies)
})


/// Title slide for the presentation. You should update the information in the `config-info` function. You can also pass the information directly to the `title-slide` function.
///
/// Example:
///
/// ```typst
/// #show: metropolis-theme.with(
///   config-info(
///     title: [Title],
///     logo: emoji.city,
///   ),
/// )
///
/// #title-slide(subtitle: [Subtitle], extra: [Extra information])
/// ```
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - extra (string, none): The extra information you want to display on the title slide.
#let title-slide(
  config: (:),
  extra: none,
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(fill: self.colors.neutral-lightest),
  )
  let info = self.info + args.named()
  let body = {
    set text(fill: self.colors.neutral-darkest)
    set std.align(horizon)
    place(image("img/logos/logo_us.png", width: 30%), top + left, dy:-15pt)
    place(image("img/logos/logo_iris.png", width: 20%), top + right, dy:-15pt)
    place(image("img/logos/logo_s7_bg_none.png", width: 15%), bottom + right, dy:15pt)
    block(
      width: 100%,
      inset: 2em,
      {
        components.left-and-right(
          {
            text(size: 1.6em, text(weight: "medium", info.title))
            if info.subtitle != none {
              linebreak()
              v(0.1cm)
              text(size: 0.9em, info.subtitle)
            }
          },
          text(2em, utils.call-or-display(self, info.logo)),
        )
        line(length: 100%, stroke: .05em + self.colors.primary)
        set text(size: .9em)
        if info.author != none {
          block(spacing: 1em, info.author)
        }
        if info.date != none {
          block(spacing: 1em, utils.display-info-date(self))
        }
        set text(size: .8em)
        if info.institution != none {
          block(spacing: 1em, info.institution)
        }
        if extra != none {
          block(spacing: 1em, extra)
        }
      },
    )
  }
  touying-slide(self: self, body)
})


/// New section slide for the presentation. You can update it by updating the `new-section-slide-fn` argument for `config-common` function.
///
/// Example: `config-common(new-section-slide-fn: new-section-slide.with(numbered: false))`
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - level (int): The level of the heading.
///
/// - numbered (boolean): Indicates whether the heading is numbered.
///
/// - body (auto): The body of the section. It will be passed by touying automatically.
#let new-section-slide(config: (:), level: 1, numbered: true, body) = touying-slide-wrapper(self => {
  let slide-body = {
    set std.align(horizon)
    show: pad.with(20%)
    set text(size: 1.5em)
    stack(
      dir: ttb,
      spacing: 1em,
      text(self.colors.neutral-darkest, utils.display-current-heading(level: level, numbered: numbered, style: none)),
      block(
        height: 2pt,
        width: 100%,
        spacing: 0pt,
        components.progress-bar(height: 2pt, self.colors.primary, self.colors.primary-light),
      ),
    )
    text(self.colors.neutral-dark, body)
  }
  self = utils.merge-dicts(
    self,
    config-page(fill: self.colors.neutral-lightest),
  )
  touying-slide(self: self, config: config, slide-body)
})


/// Focus on some content.
///
/// Example: `#focus-slide[Wake up!]`
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - align (alignment): The alignment of the content. Default is `horizon + center`.
#let focus-slide(config: (:), align: horizon + center, body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: self.colors.neutral-dark, margin: 2em),
  )
  set text(fill: self.colors.neutral-lightest, size: 1.5em)
  touying-slide(self: self, config: config, std.align(align, body))
})


/// Touying metropolis theme.
///
/// Example:
///
/// ```typst
/// #show: metropolis-theme.with(aspect-ratio: "16-9", config-colors(primary: blue))`
/// ```
///
/// Consider using:
///
/// ```typst
/// #set text(font: "Fira Sans", weight: "light", size: 20pt)`
/// #show math.equation: set text(font: "Fira Math")
/// #set strong(delta: 100)
/// #set par(justify: true)
/// ```
///
/// The default colors:
///
/// ```typ
/// config-colors(
///   primary: rgb("#eb811b"),
///   primary-light: rgb("#d6c6b7"),
///   secondary: rgb("#23373b"),
///   neutral-lightest: rgb("#fafafa"),
///   neutral-dark: rgb("#23373b"),
///   neutral-darkest: rgb("#23373b"),
/// )
/// ```
///
/// - aspect-ratio (string): The aspect ratio of the slides. Default is `16-9`.
///
/// - align (alignment): The alignment of the content. Default is `horizon`.
///
/// - header (content, function): The header of the slide. Default is `self => utils.display-current-heading(setting: utils.fit-to-width.with(grow: false, 100%), depth: self.slide-level)`.
///
/// - header-right (content, function): The right part of the header. Default is `self => self.info.logo`.
///
/// - footer (content, function): The footer of the slide. Default is `none`.
///
/// - footer-right (content, function): The right part of the footer. Default is `context utils.slide-counter.display() + " / " + utils.last-slide-number`.
///
/// - footer-progress (boolean): Whether to show the progress bar in the footer. Default is `true`.
#let stuttgart-theme(
  aspect-ratio: "16-9",
  align: horizon,
  header: self => utils.display-current-heading(
    setting: utils.fit-to-width.with(grow: false, 100%),
    depth: self.slide-level,
  ),
  header-right: self => self.info.logo,
  footer: none,
  footer-right: context utils.slide-counter.display() + " / " + utils.last-slide-number,
  footer-progress: true,
  ..args,
  body,
) = {

  set text(font: "Inter", size: 18pt)
  set list(tight: false, marker: ([•], [•]), spacing: 18pt)
  set enum(number-align: end + bottom, spacing: 18pt)
  show footnote.entry: set text(size: 13pt)
  set footnote.entry(gap: 5pt, clearance: 0.5em, indent: 0.1em)

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      header-ascent: 30%,
      footer-descent: 30%,
      margin: (top: 3em, bottom: 1.5em, x: 2em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
      // show-bibliography-as-footnote: false,
    ),
    config-methods(
        init: (self: none, body) => {
        show heading.where(level: 3): set text(fill: self.colors.primary)
        show heading.where(level: 4): set text(fill: self.colors.primary)

        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      primary: rgb("#eb811b"),
      primary-light: rgb("#d6c6b7"),
      secondary: rgb("#23373b"),
      neutral-lightest: rgb("#fafafa"),
      neutral-dark: rgb("#23373b"),
      neutral-darkest: rgb("#23373b"),
    ),
    // save the variables for later use
    config-store(
      align: align,
      header: header,
      header-right: header-right,
      footer: footer,
      footer-right: footer-right,
      footer-progress: footer-progress,
    ),
    ..args,
  )

  body
}
