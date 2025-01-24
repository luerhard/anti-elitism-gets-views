#import "@preview/drafting:0.2.0": *
#import "template.typ": *

// TITLE PAGE
#set text(
  font: "Times New Roman",
  size: 12pt,
  lang: "en"
)

#set page(
  paper: "a4",
  margin: (x: 3cm, y: 3cm)
)

#set par(
  leading: 1.3em,
  justify: true,
  linebreaks: "optimized",
  spacing: 2em
)

#page[
  #set par(leading: 1em, spacing: 1em)
  #show: article.with(
    title: "Populism on YouTube. How German Parties Utilize New Social Media Platforms.",
    authors: (
      "Lukas Erhard": author-meta(
        "UniS", "IRIS",
        email: "lukas.erhard@sowi.uni-stuttgart.de",
        address: "University of Stuttgart, Seidenstraße 36, 70174 Stuttgart, Germany"
      ),
    ),
    affiliations: (
      "UniS": "University of Stuttgart, Institute for Social Sciences, Germany",
      "IRIS": "Research Forum for Reflecting on Intelligent Systems",
    ),
    abstract: [#lorem(100)],
    keywords: ("Populism", "YouTube", "LLM")
  )
]
#counter(page).update(1)
#set page(numbering: "1")

#set heading(numbering: "1.1.1")
#show heading: set block(above: 2em, below: 2em)

#set quote(block: true)

#let inote(body) = {
  set align(center)
  set par(leading: 0.45em, justify: false)
  let mybody = {
    set align(left)
    body
  }
  let default-rect = rect.with(inset: 1em, radius: 0.5em, fill: orange.lighten(70%))
  inline-note(mybody, rect: default-rect)

}

#let mnote(body) = {
  let mybody = {
    set align(left)
    set par(leading: 0.45em, justify: false)
    body
  }
  let default-rect = rect.with(inset: 0.4em, radius: 0.3em, fill: orange.lighten(70%))
  margin-note(mybody, rect: default-rect, side:right)
}

#place(set-page-properties())

/* emergency workaround for filed bug*/
#show cite: it => {
  show "Vreese": "de Vreese"
  it
}
#show bibliography: it => {
  show regex("Vreese, C. H. de"): "de Vreese, C. H."
  it
}


= Introduction <introduction>


Populist parties threaten democratic values and contribute to ideological polarization @robertsPopulismPolarizationComparative2022.
Yet it has been heavily on the rise in Western countries for decades.
Germany had its populist surge with rise of the Alternative for Germany (AfD).
While originally founded as a Euroskeptic response to the problems of the 2008 financial crisis, the party was quickly overtaken by right-wing anti-immigrant sentiment.
A sudden influx of migrants during the summer of 2015 gave the AfD's numbers and additional boost.
Despite mostly lacking a substantial agenda other than harsh criticism of the established and governing parties, they gained traction across all voter demographics.
Some attribute part of this success to social media, which is used far more by populist actors than non-populist ones (CITE?).
Although there exist research on populism on other social media platforms, such as TikTok @gonzalez-aguilarPopulistRightParties2023, Twitter @ernstExtremePartiesPopulism2017, Instagram @oloflarssonRiseInstagramTool2023, or Facebook @schurmannYellingSidelinesHow2022, research on YouTube is still lacking.
While in previous years TV was "considered to be the most important advertising medium and televised political advertising a leading way of communication between candidates voters" @vesnic-alujevicYouTubePoliticalAdvertising2014[199] and it probably still is, its place at the top is being fiercely contested by emerging players on the web.
Social media, especially YouTube as one of the largest platforms, is an important but understudied place where populism is being spread.

/*
Populism, seen as a thin ideology, describes a worldview that is characterized above all by the antagonistic relationship between the virtuous people and the corrupt elite, which is linked to a thick ideology @muddePopulistZeitgeist2004.
Understanding populist rhetoric and claims that support this antagonism is thereby key to explaining their electoral success @devreesePopulismExpressionPolitical2018.

  2. Arguments from "rise of insta" paper on how insta is not research as much, but video and audio is superimportant.
*/


With the rise of YouTube as one of the most important social media networks on the Internet, it still lacks a thorough investigation @rauchfleischGermanFarrightYouTube2020.
This article aims to take a closer look at the usage patterns YouTube by German political parties.
A glance at the number of likes and followers for the parties' channels shows that the populist Alternative for Germany (AfD) has a massively larger followership on this platform than any other party.

// But YouTube is not "just" a social media platform.
// Im Gegensatz zu vielen anderen social media Plattformen, ist die Interaktivität hier stark eingeschränkt.

Even without the direct interaction between content creators and viewers, this platform provieds an easy way for almost everyone to create and share content.
Of course, the German parties are also taking the opportunity to be represented on the platform, albeit with varying degrees of success.
While the audience is behind some of the more influential accounts on this platform, an examination of the content shared on YouTube allows us to examine the parties' self-representation in more detail.
#footnote[There are some successful channels of German politicians like Sarah Wagenknecht (with 664,000 followers) or Alice Weidel (with 189,000 followers) with personal channels.
Nevertheless, in this study we focus on the party channels.]
This research aims to take a closer look at the use and spread of populism on YouTube by German political parties.

#quote(block: true)[
    #strong[Research Question:]
    How do German political parties utilize YouTube and to what extent does populism influence the popularity of their content?
]

= Theory

== Populism

There are several key approaches in the literature on populism, the ideational, the strategic, and the discursive-performative approach @moffittPopulism2020, or as a style of communication @jagersPopulismPoliticalCommunication2007.
Although scholars have had a lively discussion about what the "correct" definition is @aslanidisPopulismIdeologyRefutation2016, we will follow #cite(<engesserPopulistOnlineCommunication2017>, form: "prose") and see these approaches not as mutually exclusive, but argue that all definitions shed light on different aspects of populism @engesserPopulismSocialMedia2017[p.~1280].
Another scholar puts this aspect of the scholarly discussion as:

#quote()[
  There is actually a fair degree of agreement among academics: most specialists are of the view that populism revolves around a central division between "the people" and "the elite".
  In other words, there is considerable consensus about the core features of populism. @moffittPopulism2020
]

// What all approaches on populism share, is a common understanding that at its core, populism is about a

The most popular definition of populism in the empirical literature is given by Cas #cite(<muddePopulistZeitgeist2004>, form: "prose").
This approach frames populism pimarily as a conflict between the corrupt elite and the virtuous people and therefore focuses on two key notions: anti-elitism and people-centrism.
Populism in this context emphasizes the homogeneous nature of the people, often depicted as a cultural or economic entity, and defines the elite variably depending on context @muddeStudyingPopulismComparative2018.
It is seen as a "thin-centered ideology" with a narrow scope compared to broader ideologies like nativism or socialism, which it can accompany @muddePopulistZeitgeist2004 @hawkinsIdeationalApproachPopulism2019.
Populism, seen as a thin ideology, describes a worldview that is characterized above all by the antagonistic relationship between the virtuous people and the corrupt elite, which is linked to a thick ideology @muddePopulistZeitgeist2004.
Understanding populist rhetoric and claims that support this antagonism is thereby key to explaining their electoral success @devreesePopulismExpressionPolitical2018.

Another notable perspective on populism is the discursive-performative approach.
Rooted in the work of Ernesto Laclau, it is by far the most common approach by political theorists @moffittPopulism2020.// (S. ~60 von 360, Beginn "The Discursive-Performative Approach")
Although this approach is less prevalent in the empirical literature, as it is considered "extremely abstract" and faces "serious problems when it comes to analysing populism in more concrete terms" #cite(<muddePopulismEuropeAmericas2012>, supplement: "p. 6"), it offers several valuable features that are applied in the in this work.
While #cite(<moffittPopulism2020>, form: "prose", supplement: "Table 2.1") makes a clear distinction in that the ideational approach views populism as a purely binary attribute of political actors, Mudde recognizes a gradual "more or less populism" and merely qualifies that it makes little sense to speak of "weak populists" in the case of non-populist actors who use some populist phrases @muddePopulismIdeatioalApproach2017.

// First, we follow the discursive-perfomative approach in that we define populism as a gradational concept, in contrast to a binary approach which is commonly used in research using the ideational defintion. (CITE) // (CITE Moffit 2020, Table 2.1 -- roughly)
This allows us to detect 'more or less' populism in specific texts.
Secondly, we see populism less as an attribute of political actors but rather see it as a practice that political actors consciously choose to employ to convey an ideology to the audience.

// === What are "The People"? (or People-Centrism)

// // people centrism
// The concept of "the people" plays an uncontested central role in all theoretical strands of populism, yet there is no complete consensus on how this term is defined.
// Proponents of the ideological approach assume that "the people" is perceived as "pure" and "homogeneous", while scholars self-identifying as "post-Laclauian" #cite(<ostiguyIntroduction2021>, supplement: [p.~2]) contend that '"[t]he people", as a unified (but not necessarily "pure" or homogeneous) #cite(<muddePopulismLiberalDemocracy2012>, supplement: [p.~8]) political agent, is the outcome of particular political appeals and not a pre-existing social category" #cite(<panizzaPopulismHegemonyPolitical2021>, supplement: [p.~26]).
// We argue that these two stands are not contradictory but can exist side-by-side.
// Populists use Social Media to engage with specific segments of the population in a way, that almost everyone can find appeals they can identify with.
// By spreading these appeals very widely and addressing many different subgroups, they create a sense of belonging with which a broad mass can identify.
// In this way, they create the feeling of a unified people.
// This argument, originally stated by Laclau as the fact that "the people" is an "empty signifier" is a construction, nowadays also appears to be shared by Mudde and Rovira Kaltwasser @muddePopulismVeryShort2017. They state that, 'given that populism has the capacity to frame "the people" in a way that appeals to different constitutencies and articulate their demands, it can generate a shared identity between different groups and facilitate their support for a common cause' (p.~9).


// === The Elite (or Anti-Elitism)

== Populist attitudes

Populism reasearch is mostly divided into to different parts.
There is one strain that detects populism in political actors or parts of discourse like speeches.
And there is another strain that is concerned with measuring populist attitudes among populations @akkermanHowPopulistAre2014 @hawkinsActivationPopulistAttitudes2020.

A notable aspect of analysing populist communication on Social Media is that we are able to analyze direct feedback in terms of views, likes and comments on very specific bits of populist communication.
According to #cite(<keffordPopulistAttitudesBringing2022>) they are the first to try to bridge this gap and try link populist communcation can populist attitudes in terms of voting behavior.
From a theoretical perspective, they achieve this by combining the ideational approach and the discursive-perfomative approach.
We follow their tradition loosely and believe we can at least get a rough grasp of how people react to populist communication, how their attitudes towards populist communcation is, or in other words: what they do or do not "like".

This highlights a major advantage of analyzing populist communication on social media platforms, namely the ability to gauge public responses to populist messaging.
This process not only involves detecting populist content published by political actors but also measuring audience reactions through various platform-specific metrics such as likes, dislikes, views, or shares.
While the audiences on these platforms are often partisan and vary across different channels, comparing how distinct publics (i.e. viewers, followers, or subscribers) engage with content---whether it leans towards populism or not---offers valuable insights into broader public sentiment and interaction patterns.


// == Populism in the German Bundestag <sec:pop_in_bundestag>


// // Populism can be defined in a lot of different ways, with the two main approaches being "actor-centered" and "communication-centered" (larsson et al, the rise of instagram).
// // While the former approach sees populism as a property of some political entity, be it a politician or a party, the latter considers populism as a style of communication (e.g. Jacobs et al or Stanyer et al.-- see larson).
// // We combine both approaches in classifying the parties, based on a actor-centered approach (using PopuList) and identifying populist dimensions in the commnunication that is shared on the parties' YouTube channel.

// Despite debates on the role of moralistic language in populism, recent scholarship suggests that combining moral, anti-elitist, and people-centric elements is essential to classify a statement as populist (Stavrakakis and Jäger 2018; Dai and Kustov 2022). Thus, populism is characterized by these three intertwined attributes.

// There are currently two parties in the German Bundestag that are considered populist, the AfD and the Left @rooduijnPopuListDatabasePopulist2023.


== YouTube as a Research Platform <youtube-as-a-research-platform>

YouTube is very popular in Germany @allgaierRezoGermanClimate2020.
A fairly recent representative study among young Germans reports that 60% used the site daily or at least several times a week @feierabendJIMstudie2018Jugend2018.
The study also shows that YouTube is the second most important site for respondents to obtain news and information, trailing only Google.

YouTube is the only major social media network more popular among right-leaning users @mungerRightWingYouTubeSupply2022.
Additionally, and in contrast to other parties, populists prefer social media over talk shows @ernstPopulistsPreferSocial2019.
As #cite(<engesserPopulismSocialMedia2017>, form: "prose", supplement: [1123]) indicate, the logic of social media platforms gives them more freedom to use strong language when attacking elites or ostracizing others.

// While data on Germany specifically are scarce, a study from 2016 investigating a sample of Americans reported that around 90% of youth and young adults have used YouTube at least once in the past three months @costelloWhoViewsOnline2016[315].
// Motivated by these discoveries, we recognize the importance of examining parties' YouTube videos, particularly emphasizing the effects of populist content.

YouTube can be seen as a social media platform.
Since everybody can publish content on this platform with very few hurdles, and viewers can self-select what content they are willing to watch, it is natural to view YouTube as a social network between people that is centered around sharing video content—in a way like Instagram is a social network centered around images.
Studies that take such an approach might see YouTube from a supply-and-demand perspective, analyzing the side of the content creators and the viewers @mungerRightWingYouTubeSupply2022.
While investigating YouTube through such a lens is a worthwhile endeavor, it might not be suitable to investigate politicians' content.
Many scholars have proposed theories on why politicians, particularly populists, choose social media platforms over traditional hierarchical media.
Nevertheless, populist leaders mostly utilize social media as a supplementary one-way broadcasting system, instead of interacting with citizens as #cite(<jungherrTwitterUseElection2016>, form: "prose") shows in a systematic literature review on twitter use in election campaigns.
They might argue the social media facilitates personal and interactive conversations compared to the more traditional broadcasts through legacy media.
#cite(<waisbordPopulistCommunicationDigital2017>, form: "prose"), for instance, have shown remarkably low interaction between Latin American politicians, populist and non-populist, on Twitter.

This leds to believe, that videos on YouTube are best viewed from content delivery perspective first.

= Data & Methods <data-methods>

== YouTube Data

Using their official channels, we collected a dataset comprising YouTube videos from all six political parties within the German Bundestag.
The FDP (Free Democratic Party) with \@FDP, the Greens with \@DieGruenen, the SPD (Social Democratic Party) with \@spdde and the Left with \@DIELINKE have easily identifiable main official party channels.
The CDU (Christian Democratic Union) and CSU (Christian Social Union) are two separate political parties in Germany that operate as sister parties.
The CDU is active in all German states except Bavaria, where the CSU operates exclusively.
For this reason, both parties also maintain separate YouTube channels with \@cdutv and \@csumedia, although they are regarded as a single party within the Bundestag.
Conversely, the AfD's (Alternative for Germany) official channel (\@AfDTV) is distinct from the parliamentary group's channel (\@AfDFraktionimBundestag).
Both channels, exhibiting comparable follower counts, were incorporated into our analysis.
Consequently, our dataset encompasses a total of eight channels.
The dataset is restricted to the period from December 6, 2017 (the final channel's inaugural video publication) to January 20, 2024 (a week before data collection) to give all videos time to accumulate views and likes.

The analysis of video material is very challenging, we therefore follow #cite(<schwemmerSocialMediaSellout2018>, form: "prose") and focus our analysis on the audio material.
The audio data of all videos and their accompanying metadata were downloaded using _yt-dlp_.
In contrast to the abovementioned article, who use the pre-generated transcripts provided by YouTube, we use a state-of-the-art speech-to-text model to transcribe the audio material ourselves.
This procedure ensures a enhanced quality of the transcripts, including correct punctuation and music recognition.

The videos' content was transcribed using OpenAI's state-of-the-art speech-to-text model, whisper-large-v3 @radfordRobustSpeechRecognition2022.
Subsequently, the transcriptions were tokenized and segmented into sentences using the current version of SoMaJo @proislSoMaJoStateoftheartTokenization2016 tokenizer and sentence-splitter.
After removing sentences with less than 5 tokens and videos with less than 5 sentences (mostly music-only videos with written text on screen), our clean dataset comprises 9,394 videos, totaling 1,485 hours and featuring 708,549 sentences.

== Populism Detection <detection-of-populism>

In a subsequent article, I have applied the PopBERT @erhardPopBERTDetectingPopulism2024, a BERT-based transformer model, initially developed to analyze German parliamentary speeches, to study populism in transcripts of YouTube videos from the official channels of the German parties in the Bundestag.
This adaptation involves using the model to detect populist rhetoric within these videos, identifying patterns of language that align with anti-elitism and people-centrism, and examining how these elements are associated with broader political ideologies.
The analysis focuses on the official communications from these parties, providing insights into how established political entities engage with and propagate populist narratives through online video content.
This approach highlights the versatility of the PopBERT model for examining populist discourse across different media and political contexts.


= Results <results>

The analysis begins with an examination of the descriptive statistics across all channels.
Subsequently, the focus shifts to exploring the relationship between populism and the popularity of videos.

== German Parties on YouTube

Summary statistics per channel are presented in @tab:descriptives.
The most immediately apparent observation is that each of the two AfD channels, \@AfDFraktionimBundestag (388,000 followers), herein after referred to as AfD BT, and \@AfDTV (250,000), has more than twice as many followers as all the other analyzed channels combined (219,670).
The number of videos paints a similar picture.
The two AfD channels are significantly more productive in terms of their video output.
The average length of their videos is comparable to that of the CDU, CSU and FDP.
The Greens, the Left Party and the SPD, on the other hand, tend to produce significantly longer videos than the aforementioned parties.

#let table_array = csv("tables/table_1.csv", row-type: array)
#let header = table_array.first()

#let convert-to-float(val) = {
  let check = val.find(regex("^\d+[\.,]?\d*$"))
  if check != none {
    str(calc.round(float(val), digits: 2))
  } else {
    val
  }
}

#let table_content = table_array.slice(1).map(m => m.map(convert-to-float))

#figure(
  align(center)[
    #set text(size: 10.2pt)
    #table(
      columns: (1fr, ..(auto,) * (header.len() - 1)),
      align: (left, ..(right,) * (header.len() - 1)),
      inset: 4pt,
      stroke: none,
      table.hline(),
      table.header(..header),
      table.vline(x: 1, start: 1, end: table_content.len() + 1),
      table.hline(),
      ..table_content.flatten(),
      table.hline()
    )
  ]
  , caption: [Summary statistics of the dataset.]
  , kind: table
) <tab:descriptives>

It is also evident that the number of comments on FDP and Green Party videos is almost zero.
The FDP also has hardly any likes associated with their videos.
A review of some of these parties' videos on the platform suggests that these functionalities were deactivated by the parties for most of the videos.
Unfortunately, it was not possible to determine whether this was due to a lack of engagement on the part of users or because the corresponding function had been deactivated on the platform at the time the data was collected.
While the number of comments is not relevant to the further course of the investigation, the number of likes per video is, and only the FDP is excluded from these further analyses.

#figure(
  image("figures/figure_1.svg", width: 100%),
  caption: [
    Distribution of likes and views per channel. All values are logged. The box describes the .25, .5 and.75 quantiles. Outliers are represented by dots. Violin plots were superimposed on the boxplot to better visualize the distribution.  ]
) <fig:view_count>

@fig:view_count shows the distribution of views and likes in order to take a closer look at the numbers.
Since these figures differ greatly between the channels, both are shown in logarithmic form.
It is clear that all parties produce some successful videos, but the AfD stands out clearly here as well.
While the median of the views with values between 777 (Greens) and 1,613 (Left Party) is quite similar for the other parties, it is significantly higher for AfD BT with 14,547 and AfD TV with 17,767.
This picture becomes even clearer when looking at the number of likes.
While no other party reaches a median like count of 100---the Left achieves the highest count with 86---the AfD reaches 1,808 with AfD BT and as much as 2,233 with AfD TV.

== Populism by German Parties on YouTube

@fig:populism_dimensions shows the relative proportion of sentences marked by PopBERT as either anti-elitist or people-centred in each video.

// Hier wird unnmittelbar deutlich, dass die Kanäle der AfD


// m


#figure(
  image("figures/figure_2.svg", width: 100%),
  // placement: auto,
  caption: [
    Each case in this figure is a video; the values represent the relative proportion of sentences that are flagged with the respective populst dimension.
  ]
) <fig:populism_dimensions>

== Populism and Popularity <populism-and-popularity>

A key finding here is that only the populist parties (both AfD channels and the Left) show a clear correlation between the number of likes of a video and populist dimensions.
This suggests that people who watch videos from populist parties do so deliberately and in search of anti-elitist content.
This effect is not seen for people-centrism.
As illustrated in @tab:descriptives, the FDP has received an almost negligible number of likes on their videos.
A review of their YouTube content reveals that the FDP has disabled the like feature on nearly all of their videos.
Consequently, we will exclude the FDP from the subsequent analysis.

#figure(
  image("figures/figure_3.svg", width: 100%),
  // placement: auto,
  caption: [
    Negative Binomial Regression on Number of Likes per Video. Anti-elitism is z-transformed by the channel mean. Channel and Anti-Elitism are modeled using an interaction effect. We control for the year of release and video length.
  ]
) <fig:nb_reg_likes>

#figure(
  image("figures/figure_4.svg", width: 100%),
  // placement: auto,
  caption: [
    Negative Binomial Regression on Number of Views per Video. Anti-elitism is z-transformed by the channel mean. Channel and Anti-Elitism are modeled using an interaction effect. We control for the year of release and video length.
  ]
) <fig:nb_reg_views>


= Discussion <discussion>

#pagebreak()
#set par(leading: 1em, spacing: 1.7em)
#bibliography("references.bib", style: "apa")

#set heading(numbering: none)
= Appendix <appendix>

#show heading: it => {
  if it.level == 1 and it.numbering != none {
    [#it.supplement #counter(heading).display():]
  } else if it.numbering != none {
    [#counter(heading).display().]
  }

  h(0.3em)
  it.body
  parbreak()
}

#counter(heading).update(0)
#set heading(numbering: "A.1", supplement: [Appendix])

= Top 10 most liked videos per channel

#let table_array = csv("../tables/most_liked_videos_per_channel.csv", row-type: array)
#let header = ([Channel], [N Likes], [N Views], [Title])
//
#let convert-to-float(val) = {
  let check = val.find(regex("^\d+[\.,]?\d*$"))
  if check != none {
    str(calc.round(float(val), digits: 2))
  } else {
    val
  }
}
//
#let table_content = table_array.slice(1).map(m => m.map(convert-to-float))
//
#show figure: set block(breakable: true)
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
) <tab:top_videos>

= Top 10 most anti-elitist videos per channel

#let table_array = csv("../tables/most_antielitism_videos_per_channel.csv", row-type: array)
#let header = ([Channel], [Total Sents], [Anti-Elite], [Title])
//
#let convert-to-float(val) = {
  let check = val.find(regex("^\d+[\.,]?\d*$"))
  if check != none {
    str(calc.round(float(val), digits: 2))
  } else {
    val
  }
}
//
#let table_content = table_array.slice(1).map(m => m.map(convert-to-float))
//
#show figure: set block(breakable: true)
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
  , caption: [This table shows the top 10 most anti-elitist videos per channel. Anti-Elite shows the fraction of sentences that are classified as anti-elitist in each video.]
  , kind: table
) <tab:top_videos>
