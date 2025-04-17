#import "@preview/drafting:0.2.2": *
#import "template.typ": *
#import "@preview/wordometer:0.1.4": word-count, total-words

// TITLE PAGE
#set text(
  font: "Times New Roman",
  size: 12pt,
  lang: "en"
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

// Table highlight / format functions
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

#set page(
  paper: "a4",
  margin: (left: 2cm, right: 4cm)
)

#set-page-properties(margin-left: 2cm, margin-right: 4cm)

#show figure: it => {
	align(center)[#it.body]
  set text(size: 0.93em)
	set align(left)
	set par(hanging-indent: 0cm, justify: true, leading: 0.4em)
	pad(x: 0.4cm)[#it.caption]
}

/* emergency workaround for filed bug*/
#show cite: it => {
  show "Vreese": "de Vreese"
  it
}
#show bibliography: it => {
  show regex("Vreese, C. H. de"): "de Vreese, C. H."
  it
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

#let float-note(body) = {
  let mybody = {
    set align(left)
    set par(leading: 0.45em, justify: false)
    body
  }
  let default-rect = rect.with(inset: 0.4em, radius: 0.3em, fill: orange.lighten(70%))
  margin-note(mybody, rect: default-rect, stroke:none, side:right, fill: orange.lighten(80%))
}


#word-count(total => [

= Introduction <introduction>

Populist parties threaten democratic values and contribute to ideological polarization @robertsPopulismPolarizationComparative2022.
#[]<start>#float-note[Word-Count: #total.words]
Yet it has been heavily on the rise in Western countries for decades.
Germany had its populist surge with rise of the Alternative for Germany (AfD).
While originally founded as a Euroskeptic response to the problems of the 2008 financial crisis, the party was quickly overtaken by right-wing anti-immigrant sentiment.
A sudden influx of migrants during the summer of 2015 gave the AfD's numbers and additional boost.
Despite mostly lacking a substantial agenda other than harsh criticism of the established and governing parties, they gained traction across all voter demographics.
Some attribute part of this success to social media, which is used far more by populist actors than non-populist ones (CITE?).
Although there exist research on populism on other social media platforms, such as TikTok @gonzalez-aguilarPopulistRightParties2023, Twitter @ernstExtremePartiesPopulism2017, Instagram @oloflarssonRiseInstagramTool2023, or Facebook @schurmannYellingSidelinesHow2022, research on YouTube is still lacking @mungerPressingPlayPolitics2025.
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

Even without the direct interaction between content creators and viewers, this platform provides an easy way for almost everyone to create and share content.
Of course, the German parties are also taking the opportunity to be represented on the platform, albeit with varying degrees of success.
While the audience is behind some of the more influential accounts on this platform, an examination of the content shared on YouTube allows us to examine the parties' self-representation in more detail.
#footnote[There are some successful channels of German politicians like Sarah Wagenknecht (with 673,000 followers) or Alice Weidel (with 292,000 followers) with personal channels (checked on February 26, 2025).
Nevertheless, in this study we focus on the party channels.]
This research aims to take a closer look at the use and spread of populism on YouTube by German political parties.

#quote(block: true)[
    #strong[Research Question:]
    How do German political parties utilize YouTube and to what extent does populism influence the popularity of their content?
]

= Theory

== YouTube as a Research Platform <youtube-as-a-research-platform>

YouTube is very popular in Germany @allgaierRezoGermanClimate2020.
A fairly recent representative study among young Germans reports that 60% used the site daily or at least several times a week @feierabendJIMstudie2018Jugend2018.
The study also shows that YouTube is the second most important site for respondents to obtain news and information, trailing only Google.
While the YouTube is still dramatically understudied compared to other social media platforms @mungerPressingPlayPolitics2025, increasing effort is undertaken to systematically analyze content on YouTube in general and the _political_ YouTube in particular @bartlYouTubeChannelsUploads2018 @mungerPressingPlayPolitics2025.

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
In contrast to, for example, TV, however, it is possible to measure user engagement with content on YouTube in a number of ways.
The two that we will focus on in this study are:
1) ViewCount.
The number of times a video was watched.
While this is a rather naive metric, it is comparably insensitive to different interpretations.
2) LikeCount.
The number of times a video is liked.
It measures a deeper engagement with a video but also can have some shortcomings.
While some users just might never like a video, others might just like all videos or like videos that they want to save for later in ther "Liked Videos" tab on the website.

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
Secondly, we see populism less as an attribute of political actors but rather see it as a practice that political actors consciously choose to employ to convey an ideology to the audience. Assuming that parties behave similarly on YouTube as they do elsewhere in the political landscape, we can state:

#quote(block: true)[
    #strong[H1:]
    _Populist parties convey more populist content on YouTube than non-populist parties._
]


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

A notable aspect of analyzing populist communication on Social Media is that we are able to analyze direct feedback in terms of views, likes and comments on very specific bits of populist communication.
According to #cite(<keffordPopulistAttitudesBringing2022>, form: "prose") they are the first to try to bridge this gap and try link populist communcation can populist attitudes in terms of voting behavior.
From a theoretical perspective, they achieve this by combining the ideational approach and the discursive-perfomative approach.
We follow their tradition loosely and believe we can at least get a rough grasp of how people react to populist communication, how their attitudes towards populist communcation is, or in other words: what they do or do not 'like'.

This highlights a major advantage of analyzing populist communication on social media platforms, namely the ability to gauge public responses to populist messaging.
This process not only involves detecting populist content published by political actors but also measuring audience reactions through various platform-specific metrics such as likes, dislikes, views, or shares.
While the audiences on these platforms are often partisan and vary across different channels, comparing how distinct publics (i.e. viewers, followers, or subscribers) engage with content---whether it leans towards populism or not---offers valuable insights into broader public sentiment and interaction patterns.

Given this premise, we expect populist parties as well as populist content to be popular among people with populist attitudes.
We also hypothesize the opposite to be true: populist parties as well as populist content will not be especially popular among people with less populist attitudes.
We can formulate the following hypotheses:

#quote(block: true)[
    #strong[H2a:]
    _On channels of populist parties, we expect a positive relationship between a videos' amount of contained populism and it's user engagment._

    #strong[H2b:]
    _On non-populist channels, we expect no positive relationship between a videos' amount of populism and user engagement._
]


// == Populism in the German Bundestag <sec:pop_in_bundestag>


// // Populism can be defined in a lot of different ways, with the two main approaches being "actor-centered" and "communication-centered" (larsson et al, the rise of instagram).
// // While the former approach sees populism as a property of some political entity, be it a politician or a party, the latter considers populism as a style of communication (e.g. Jacobs et al or Stanyer et al.-- see larson).
// // We combine both approaches in classifying the parties, based on a actor-centered approach (using PopuList) and identifying populist dimensions in the commnunication that is shared on the parties' YouTube channel.

// Despite debates on the role of moralistic language in populism, recent scholarship suggests that combining moral, anti-elitist, and people-centric elements is essential to classify a statement as populist (Stavrakakis and Jäger 2018; Dai and Kustov 2022). Thus, populism is characterized by these three intertwined attributes.

// There are currently two parties in the German Bundestag that are considered populist, the AfD and the Left @rooduijnPopuListDatabasePopulist2023.



= Data & Methods <data-methods>

Our research methodology begins by retrieving the audio material from all the videos under investigation.
A speech-to-text tool is then employed to extract the transcripts from these videos, effectively converting the auditory data into analyzable text.
Finally, an LLM model is applied to the transcripts to detect populism, providing a systematic and automated approach to identifying populist language in the content.
All steps are described in the following in more detail.

== YouTube Data

Using their official channels, we collected a dataset comprising YouTube videos from all six political parties within the German Bundestag.
The FDP (Free Democratic Party) with \@FDP, the Greens with \@DieGruenen, the SPD (Social Democratic Party) with \@spdde and the Left with \@DIELINKE have easily identifiable main official party channels.
The CDU (Christian Democratic Union) and CSU (Christian Social Union) are two separate political parties in Germany that operate as sister parties.
The CDU is active in all German states except Bavaria, where the CSU operates exclusively.
For this reason, both parties also maintain separate YouTube channels with \@cdutv and \@csumedia, although they are regarded as a single party within the Bundestag.
Conversely, the AfD's (Alternative for Germany) official channel (\@AfDTV) is distinct from the parliamentary group's channel (\@AfDFraktionimBundestag).
Both channels, exhibiting comparable follower counts, were incorporated into our analysis.
Consequently, our dataset encompasses a total of eight channels.
The dataset is restricted to the period from December 6, 2017 (the final channel's inaugural video publication) to February 24, 2025, the day of the Bundestagswahl 2025.

During the period of investigation, YouTube has updated its rules on Shorts.
These are a separate video stream for short videos.
Its implementation is comparable to TikTok.
Since October 15, 2024, every video up to three minutes of length and with a square or vertical aspect ratio will automatically categorized as a Short @youtube2025-shorts.
Although we have explicitly not included Shorts during data collection, we there possibly have content that is not solely published as long-form video on YouTube in our data.
To handle that and homogenize the data anlysis, we create a variable in the data "is_short".
It indicates whether a videos is up to 180 seconds in length.

== Video transcripts

The analysis of video material is very challenging, we therefore follow #cite(<schwemmerSocialMediaSellout2018>, form: "prose") and focus our analysis on the audio material.
In order to do that, audio data of all videos and their accompanying metadata were downloaded using _yt-dlp_.
In contrast to the abovementioned article, who use the pre-generated transcripts provided by YouTube, we use a state-of-the-art speech-to-text model to transcribe the audio material ourselves.
While there exist professional captions on some of the videos, many of the videos in our corpus do not have such manually created captions.
The quality of the automatically generated subtitles on YouTube is not sufficient for our purposes.
Although they are sufficient to understand the content of the video without sound, they usually lack word case (a significantly bigger problem in German than in English) and almost all punctuation marks.
While this is only a minor problem for simple text analysis approaches, such as bag-of-words, we assume that such differences between the training material and the data to be analyzed can have unpredictable effects on the predictive power of more complex LLMs, such as the BERT model used below to detect populism.
We therefore try to achieve the highest possible quality of the automated transcripts.

The content of the videos was transcribed using OpenAI's advanced speech-to-text model, whisper-large-v3-turbo @radfordRobustSpeechRecognition2022.
This model provides significantly faster transcription compared to whisper-large-v3 while maintaining comparable accuracy.
However, Whisper models tend to produce erroneous transcriptions, known as hallucinations, particularly when the audio includes extended periods without speech, a common occurrence in YouTube videos.
To address this issue, we employed the Silero voice activity detector @silerovad2024, isolating segments containing actual speech and passing only these segments to the Whisper transcription model.

#let faulty_transcripts = read("inlines/n_broken.txt")
Although this approach effectively reduced the number of hallucinations, #faulty_transcripts videos had to be excluded from the analysis due to faulty transcripts.
Faulty transcripts were identified by generating all n-grams for values of n between 2 and 10, and determining whether any n-gram appeared more than nine consecutive times within a transcript.
Subsequently, the transcriptions were tokenized and segmented into sentences using the current version of the SoMaJo tokenizer and sentence-splitter @proislSoMaJoStateoftheartTokenization2016.
#let hour_duration = read("inlines/sum_duration.txt")
#let n_videos = read("inlines/n_videos.txt")
#let n_sents = read("inlines/n_sents.txt")
After removing sentences with less than 3 tokens and videos with less than 5 sentences (mostly music-only videos with written text on screen), our clean dataset comprises #n_videos videos, totaling #hour_duration hours of playtime and containing #n_sents sentences.

== Detecting Populism <detection-of-populism>

To detect populism in transcripts of YouTube videos from the official channels of the German parties in the Bundestag, we apply PopBERT, a BERT-based transformer model, fine-tuned to specifically detect anti-elitism and people-centrism in German political speech @erhardPopBERTDetectingPopulism2024.
Although PopBERT was trained on transcripts of parliamentary speeches, we consider its application to videos from official party channels feasible.
There is a high degree of similarity in tone, vocabulary, and rhetorical style between these two contexts.
Additionally, there is substantial overlap in the speakers themselves, and the videos originate predominantly from the same time period as the training data.
Therefore, we expect the model to reliably generalize to this closely related domain.

To detect populism in the videos, we use the two core categories defined by PopBERT: anti-elitism and people-centrism.
Analogous to the procedure in the associated article, the transcripts are divided into sentences and each sentence is fed into the model independently of the others and classified using the proposed thresholds.
To obtain a value at the video level, the relative proportion of sentences classified as anti-elitist or people-centric is then calculated for each video.
Since there are various possibilities in the literature for combining these dimensions, we examine both dimensions separately and refrain from combining them into a single populism score.

= Results <results>

The analysis begins with an examination of the descriptive statistics across all channels.
Subsequently, the focus shifts to exploring the relationship between populism and the popularity of videos.

== German Parties on YouTube

Summary statistics per channel are presented in @tab:descriptives.
Notably, each of the two AfD channels---\@AfDFraktionimBundestag (521,000 followers), hereafter referred to as AfD BT, and \@AfDTV (334,000 followers)---individually has more followers than all other analyzed channels combined (252,410 followers).
While the CDU, FDP, Greens, and SPD channels have comparable follower counts around 30,000 each, the CSU, the smaller "sister party" of the CDU limited to Bavaria, has only 6,610 followers.
In contrast, the Left party, another populist party represented in the Bundestag alongside the AfD, has a substantially higher follower count of 117,000, highlighting the greater popularity of populist parties compared to their non-populist counterparts.

#let table_array = csv("tables/table_1.csv", row-type: array)
#let header = table_array.first()
#let table_content = table_array.slice(1).map(row => highlight-max(row))
#show figure: set block(breakable: false)

#figure(
  kind: table,
  context [
    #set text(size: 0.85em)
    #table(
      columns: (2.5cm, ..(auto,) * (header.len() - 1)),
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
  ],
  caption: [
    Summary statistics of the dataset.
    All data is current as of February 25, 2025, the day after the federal election.
    *chFollowers* corresponds to the number of followers that are shown given in the channel description; this number is most probably rounded to some degree by YouTube.
    *meanVideoLen* is shown in seconds.
    *nLikesNA* corresponds to the number of returned missings for the like_count from the API, indicating that the like functionality is disabled for a particular video.
    *nSentences* corresponds to the number of sentences extracted from all valid videos per channel.
  ]
) <tab:descriptives>

The volume of videos produced follows a similar pattern, with both AfD channels demonstrating significantly higher productivity and engagement measured as median views and likes, followed by the Left.
However, the average like count reported for the FDP may be misleading, as the like functionality has been disabled for all but one video on their channel.
Comparing median and mean values for both likes and views reveals a substantial analytical challenge inherent to YouTube data.
Specifically, the means are substantially higher than the medians for all metrics, indicating a highly skewed distribution driven upward by a few exceptionally successful videos.
@fig:view_count illustrates the distributions of views and likes to examine these disparities more closely. Due to considerable variation in the raw counts, views and likes are displayed on a logarithmic scale.

#figure(
  placement: auto,
  image("figures/figure_1.svg", width: 100%),
  caption: [
    Distribution of likes and views per channel.
    All values are logged.
    The rectangle describes the .25, .5 and.75 quantiles.
    Outliers are represented by dots.
    Violin plots were superimposed on the boxplot to better visualize the distribution.]
) <fig:view_count>

In addition to the above-mentioned differences in median views and likes, we can see in this figure that all parties have some very successful videos in terms of views.
It is evident that all parties produce some successful videos, but the AfD stands out clearly here as well.

// While the median of the views with values between 777 (Greens) and 1,613 (Left Party) is quite similar for the other parties, it is significantly higher for AfD BT with 14,547 and AfD TV with 17,767.
// This picture becomes even clearer when looking at the number of likes.
// While no other party reaches a median like count of 100---the Left achieves the highest count with 86---the AfD reaches 1,808 with AfD BT and as much as 2,233 with AfD TV.

== Populism by German Parties on YouTube

@fig:populism_dimensions shows the relative proportion of sentences classified by PopBERT as anti-elitist and people-centrist by video.
It becomes immediately apparent that both channels of the AfD exhibit a much higher proportion of anti-elitist statements than the channels of any other party.
The second highest amount of anti-elitist statements, though exhibiting substantially lower numbers, is expressed by the Left; the other populist party in the Bundestag.
People-Centrism, on the other hand, draws a different picture.
The Greens, the Left and the SPD all show similar high amounts of this populist dimension, though, in contrast to the anti-elitism dimension, no party surpasses a relative proportion of 5%.

#figure(
  image("figures/figure_2.svg", width: 100%),
  // placement: auto,
  caption: [
    Each case in this figure is a video; the values represent the relative proportion of sentences that are flagged with the respective populist dimension.
  ]
) <fig:populism_dimensions>

Comparing the detected levels of populism across all channels, we find partial support for *H1*, which proposes that populist parties convey more populist content on YouTube than non-populist parties.
This hypothesis is particularly supported in the dimension of anti-elitism: the channels of the AfD and the Left clearly contain more anti-elitist content than those of other parties.
Additionally, the Left's channel proportionally conveys the most people-centric content.
However, the AfD channels display surprisingly limited people-centric appeals.
The AfD TV channel exhibits a similar but somewhat more moderate pattern.
Specifically, the AfD BT channel contains almost no people-centric content and primarily focuses on an exceptionally high volume of anti-elitist messaging.
It is worth noting at this point, that the AfD BT channel's content primarily consists speeches of AfD members of parliament talking in the Bundestag.
A possible explanation of low amount of people-centric messaging on this channel could be that this forum is mostly used to attack the governing parties and much less so to actually appeal to "the people".

== Populism and Popularity <populism-and-popularity>

To analyze the relationship between populism and popularity we use Ordinary Least Squares (OLS) regressions and regress each populism dimensions separately on user engagement.
As mentioned in @youtube-as-a-research-platform, we define user engagement as either like count or view count, assuming that both variables measure a slightly different level of engagement.
#footnote[
The results here are shown for the number of views as the dependent variable, results for the number of likes on the same data are shown in @ap:reg_on_likes.
]

Because the channels have vastly different amounts of contained populism per video, number of videos, views, and likes, we employ separate regressions per channel and compare the effect sizes.
Each regression is thus run on videos from a single channel, and on either the logged number of likes or logged number of views.
To ensure comparability of the effects, we additionally standardize (z-transform) the dependent variable as well as the populist dimension for each regression within each channel.
Although it is important to bear this in mind during the interpretation of the results, we believe that we can achieve a better comparison between the effects.
That way, we are able to investigate if videos that are more populist compared to other content of the same channel accumulates more popularity, again compared to videos of the same channel.
In doing so, we explicitly express the believe that people watch and compare content from within the same channel when deciding about their engagement but not necessarily between channels.

We control for the year of a video's release, the number of sentences in the video's transcript.
Additionally, we control for short vs. long videos and add an interaction effect between the core populist dimension and the is_short variable to allow for different effects in short vs. long videos.
This is especially important since the populist dimension is measured as a _percentage of sentences that contain the populist dimension_ which might express something different in a video with very few sentences vs a video with many sentences.

#figure(
  image("../figures/reg_ame_views_elite.svg", width: 100%),
  // placement: auto,
  caption: [
    Regression of Anti-Elitism on Number of Views per video.
    A separate regression is run for each channel.

  ]
) <fig:views_elite>

@fig:views_elite depicts the average marginal effects of the anti-elitism dimension on the number of likes for each channel.
The range for the x-axis for each channel is bounded by the interval $[-2, 2]$ standard deviations, with impossible values (anti-elitism values that are lower that zero) removed.
The x-axis is then back-transformed to its original values to show the actual percentage values of the populist dimension for each prediction.
The red dashed lines indicates the expected trajectory of the effect if there were no relationship between anti-elitism and view count.
The confidence intervals give an indication on how much data points are available for the respective values with large intervals indicating a few videos actually exhibiting this amount of anti-elitism.

#figure(
  image("../figures/reg_ame_views_pplcentr.svg", width: 100%),
  // placement: auto,
  caption: [
    Regression of People-Centrism on Number of Views per video. A separate regression is run for each channel.

  ]
) <fig:views_pplcentr>

@fig:views_pplcentr illustrates the relationship between people-centric content and view count.
The analysis yields a less clear-cut picture than observed with anti-elitist content.
While a consistent trend is recognizable for long-form content on both AfD channels, and the Left's channel short-form videos on the AfD TV channel do not show the same relationship.
For all channels the x-axis' upper limit which indicates values for +2 standard deviations of the people-centric content, is quite low for all channels, and the large confidence intervals for long form content on CDU and CSU show how sparse and/or varying the data is for values above 5%.

Regarding *H2a* stating that on channels of populist parties, we expect a positive relationship between a videos' amount of contained populism and it's user engagement, we therefore find partial support on both dimensions.
We can observe a clear positive relationship for the video's amount of populism and its view count for the AfD's channels long videos.
Additionally we see an increase in expected view count for the Left but only for long videos.
While the amount populist content in neither dimension seems to have an effect on user engagement for short videos in the Left's channel, the effect for all other types of videos from populists parties' channels is clearly positive.

The analysis of viewer engagement across non-populist party channels (CDU, CSU, FDP, Greens, SPD) provides broad support for *H2b*.
While the regression results show occasional fluctuations in engagement metrics related to populist content, no consistent or significant positive relationship is observed.
In particular, the effect of anti-elitism and people-centrism on views or likes remains weak or absent.
This suggests that audiences of non-populist parties do not reward populist rhetoric with higher engagement, aligning with the hypothesis that populist appeals are less effective or resonant in these political contexts.
Moreover, the large confidence intervals and low prevalence of populist content in non-populist channels further underscore the limited role that populist rhetoric plays in driving engagement outside of explicitly populist party ecosystems.

For the non-populist parties (CDU, CSU, FDP, Greens), Figure 4 reveals no consistent positive relationship between people-centric content and engagement, thus broadly supporting hypothesis H2b. This indicates that populist rhetorical strategies may not universally translate into increased engagement for all parties, reinforcing the notion that populist content effectiveness is contextually bound and audience-specific.


The results indicate a positive relationship of the relative amount of anti-elitism contained in a video and the number of likes it accumulates for the channels AfD BT, AfD TV, CDU, Left, and SPD.
@ap:reg_on_likes shows the same figures computed against the dependent variable of like count.

= Discussion <discussion>

A key methodological strength of this study is its use of advanced speech recognition technology to analyze YouTube content.
By combining OpenAI's whisper-large-v3-turbo with Silero voice activity detection, we produced high-quality transcripts that maintain critical linguistic features often missing from YouTube's native captions.
It further demonstrates that populist parties in Germany—most notably the AfD—are significantly more successful on YouTube than their non-populist counterparts.
They not only attract larger audiences but also disseminate a substantially higher volume of populist content.
This underscores the strategic advantage that populist actors hold on video-based platforms, where emotionally charged and confrontational messaging can gain visibility and engagement.

Importantly, the two core dimensions of populism—anti-elitism and people-centrism—differ both in their prevalence and in their relationship to user engagement.
Anti-elitist content is especially prominent on populist channels and is positively associated with viewer engagement, not only for populist parties but in some cases also for non-populist ones.
This suggests that anti-elitism may tap into broader affective dynamics on social media, such as a preference for polarizing or dramatic content.
Whether this effect reflects genuine user interest in anti-elite narratives or is amplified by platform features like algorithmic curation and clickbait-style presentation remains an open question.

The limited effectiveness of people-centric content, particularly on the AfD TV channel and in short videos on the Left’s channel, raises further questions about the content strategy and thematic focus of short-form video.
Since these formats may differ considerably in tone and purpose—ranging from soundbites to satire—a closer analysis of the content itself is needed to understand these patterns.
It is also possible that limitations in the detection of people-centric language, as observed with the PopBERT model, have contributed to the observed discrepancies.
Still, assuming no systematic bias, the results support the analytical value of examining anti-elitism and people-centrism separately.

Taken together, these findings suggest that anti-elitist rhetoric plays a central role in driving engagement on YouTube, particularly within the context of right-wing populism.
They also highlight the platform’s potential to reinforce populist dynamics through its attention economy.
Future research should expand on this by integrating multimodal analysis, user behavior data, and qualitative assessments of video content, in order to better understand the interplay between message, medium, and audience response.

#[] <end>
])
#pagebreak()
#set par(leading: 1em, spacing: 1.7em)
#bibliography("references.bib", style: "apa")
#pagebreak()

#show figure: set block(breakable: true)
#set heading(numbering: none)

#include "appendix.typ"
