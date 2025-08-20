#import "@preview/drafting:0.2.2": *
#import "template.typ": *
#import "@preview/wordometer:0.1.4": total-words, word-count

// TITLE PAGE
#set text(
  font: "Times New Roman",
  size: 12pt,
  lang: "en",
)

#set par(
  leading: 1.3em,
  justify: true,
  linebreaks: "optimized",
  spacing: 2em,
)

#page[
  #set par(leading: 1em, spacing: 1em)
  #show: article.with(
    title: "Populism on YouTube. How German Parties Utilize New Social Media Platforms.",
    authors: (
      "Lukas Erhard": author-meta(
        "UniS",
        "IRIS",
        email: "lukas.erhard@sowi.uni-stuttgart.de",
        address: "University of Stuttgart, Seidenstraße 36, 70174 Stuttgart, Germany",
      ),
    ),
    affiliations: (
      "UniS": "University of Stuttgart, Institute for Social Sciences, Germany",
      "IRIS": "Research Forum for Reflecting on Intelligent Systems, University of Stuttgart, Germany",
    ),
    abstract: [
      This paper examines how German political parties utilize YouTube and the relationship between populist content and user engagement.
      We analyze videos from all parties in the German Bundestag using advanced speech-to-text technology and PopBERT, a model detecting populism dimensions in German political speech.
      Our findings show that the populist Alternative for Germany (AfD) significantly outperforms other parties in followers, video production, and engagement.
      Content analysis reveals AfD channels contain substantially higher levels of anti-elitist rhetoric compared to non-populist parties, while people-centrism is more evenly distributed across the political spectrum.
      Regression analyses demonstrate that increased anti-elitist content correlates with higher view counts on populist party channels, particularly for the AfD.
      The study contributes to understanding how populist communication strategies operate on video-sharing platforms, highlighting that different dimensions of populism resonate differently with audiences depending on political alignment.
      These findings underscore the importance of examining platform-specific communication dynamics in digital populism.
    ],
    keywords: ("Populism", "YouTube", "German parties", "Video content analysis"),
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

#set page(paper: "a4", margin: (left: 2cm, right: 4cm))

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
    set text(size: 0.9em)
    body
  }
  let default-rect = rect.with(inset: 0.4em, radius: 0.3em, fill: orange.lighten(70%), stroke: black)
  margin-note(mybody, rect: default-rect, side: right, stroke: blue.lighten(20%))
}

#let float-note(body) = {
  let mybody = {
    set align(left)
    set par(leading: 0.45em, justify: false)
    body
  }
  let default-rect = rect.with(inset: 0.4em, radius: 0.3em, fill: orange.lighten(70%))
  margin-note(mybody, rect: default-rect, stroke: none, side: right, fill: orange.lighten(80%))
}
#word-count(total => [
  = Introduction <introduction>


  Populist parties threaten democratic values and contribute to ideological polarization @robertsPopulismPolarizationComparative2022.
  #float-note[Word-Count: #total.words]
  Yet it has been heavily on the rise in Western countries for decades.
  Germany had its populist surge with the rise of the Alternative for Germany (AfD).
  While originally founded as a Euroskeptic response to the problems of the 2008 financial crisis, the party was quickly overtaken by right-wing anti-immigrant sentiment.

  Some attribute part of this success to social media, which is used far more by populist actors than non-populist ones (CITE?).
  Although there exists research on populism on other social media platforms, such as TikTok @gonzalez-aguilarPopulistRightParties2023, Twitter @ernstExtremePartiesPopulism2017, Instagram @oloflarssonRiseInstagramTool2023, or Facebook @schurmannYellingSidelinesHow2022, research on YouTube is still lacking @mungerPressingPlayPolitics2025.
  While in previous years TV was "considered to be the most important advertising medium and televised political advertising a leading way of communication between candidates voters" @vesnic-alujevicYouTubePoliticalAdvertising2014[199] and it probably still is, its place at the top is being fiercely contested by emerging players on the web.
  Social media, especially YouTube as one of the largest platforms, is an important but understudied place where populism is being spread.

  /*
  Populism, seen as a thin ideology, describes a worldview that is characterized above all by the antagonistic relationship between the virtuous people and the corrupt elite, which is linked to a thick ideology @muddePopulistZeitgeist2004.
  Understanding populist rhetoric and claims that support this antagonism is thereby key to explaining their electoral success @devreesePopulismExpressionPolitical2018.

    2. Arguments from "rise of insta" paper on how insta is not research as much, but video and audio is superimportant.
  */


  // With the rise of YouTube as one of the most important social media networks on the Internet, it still lacks a thorough investigation @rauchfleischGermanFarrightYouTube2020.
  This article investigates how German political parties utilize YouTube as a platform for political communication, with particular attention to patterns of engagement and popularity.

  Of course, the German parties are also taking the opportunity to be represented on the platform, albeit with varying degrees of success.
  A brief glance of the parties' YouTube channels reveals a striking disparity in audience size: the populist Alternative for Germany (AfD) significantly outpaces all other parties in terms of subscribers and likes. This observation raises a critical question: How do German political parties employ YouTube, and to what extent does populist rhetoric contribute to their success on the platform?

  // Even without the direct interaction between content creators and viewers, this platform provides an easy way for almost everyone to create and share content.

  // While the audience is behind some of the more influential accounts on this platform, an examination of the content shared on YouTube enables us to examine the parties' self-representation in greater detail.
  // #footnote[There are some successful channels of German politicians like Sarah Wagenknecht (with 673,000 followers), or Alice Weidel (with 292,000 followers), with personal channels (checked on February 26, 2025).
  //   Nevertheless, in this study we focus on the party channels.]
  // This research aims to take a closer look at the use and spread of populism on YouTube by German political parties.

  #mnote[hier ggf nochmal was du vorhast zu machen oder, mMn noch besser, kurz ergebnisse zsfen]

  = Theory

  == YouTube as a Research Platform <youtube-as-a-research-platform>

  YouTube is very popular in Germany @allgaierRezoGermanClimate2020.
  A representative study among young Germans reports that 60% used the site daily or at least several times a week @feierabendJIMstudie2018Jugend2018.
  The study also shows that YouTube is the second most important site for respondents to obtain news and information, trailing only behind Google.
  While the YouTube is still dramatically understudied compared to other social media platforms @mungerPressingPlayPolitics2025, increasing effort is undertaken to systematically analyze content on YouTube in general and the _political_ YouTube in particular @bartlYouTubeChannelsUploads2018.


  // While data on Germany specifically are scarce, a study from 2016 investigating a sample of Americans reported that around 90% of youth and young adults have used YouTube at least once in the past three months @costelloWhoViewsOnline2016[315].
  // Motivated by these discoveries, we recognize the importance of examining parties' YouTube videos, particularly emphasizing the effects of populist content.

  YouTube can be seen as a social media platform.
  Since everybody can publish content on this platform with very few hurdles, and viewers can self-select what content they are willing to watch, it is natural to view YouTube as a social network between people that is centered around sharing video content—in a way like Instagram is a social network centered around images.
  Studies that take such an approach might see YouTube from a supply-and-demand perspective, analyzing the side of both the content creators and the viewers @mungerRightWingYouTubeSupply2022.
  While investigating YouTube through such a lens is a worthwhile endeavor, it might not be suitable to investigate political parties' and politicians' content.
  Many scholars have proposed theories on why politicians, particularly populists, choose social media platforms over traditional hierarchical media.
  YouTube is the only major social media network that is more popular among right-leaning users @mungerRightWingYouTubeSupply2022.  Additionally, and in contrast to other parties, populists prefer social media over talk shows @ernstPopulistsPreferSocial2019.
  As #cite(<engesserPopulismSocialMedia2017>, form: "prose", supplement: [1123]) indicate, the logic of social media platforms gives them more freedom to use strong language when attacking elites or ostracizing others.

  Nevertheless, populist leaders mostly utilize social media as a supplementary one-way broadcasting system, instead of interacting with citizens, as #cite(<jungherrTwitterUseElection2016>, form: "prose") shows in a systematic literature review on Twitter use in election campaigns. #mnote[ggf kürzen; das argument ist klar und gut]
  They might argue the social media facilitates personal and interactive conversations compared to the more traditional broadcasts through legacy media.
  #cite(<waisbordPopulistCommunicationDigital2017>, form: "prose"), for instance, have shown remarkably low interaction between Latin American politicians, populist and non-populist, on Twitter.
  This leads us to believe that videos of politicians and political parties on YouTube are best viewed from a content delivery perspective first.
  In contrast to, TV, however, it is possible to measure user engagement with content on YouTube in a variety of ways.
  The two that we will be focusing on in this study are:
  1) view count.
  The number of times a video was watched.
  While this is a rather naive metric, it is comparably insensitive to different interpretations.
  2) like count.
  The number of times a video is liked.
  It measures a deeper engagement with a video but also can have some shortcomings.
  While some users just might never like a video, others might just like all videos or like videos that they want to save for later in their "Liked Videos" tab on the website.

  == Populism

  There are several key approaches in the literature on populism: the ideational, the strategic, and the discursive-performative approach @moffittPopulism2020, or as a style of communication @jagersPopulismPoliticalCommunication2007.
  Although scholars have had a lively discussion about what the "correct" definition is @aslanidisPopulismIdeologyRefutation2016, we will follow #cite(<engesserPopulistOnlineCommunication2017>, form: "prose") and see these approaches not as mutually exclusive, but argue that all definitions shed light on different aspects of populism @engesserPopulismSocialMedia2017[p.~1280].
  Another scholar puts this aspect of the scholarly discussion as:

  #quote()[
    There is actually a fair degree of agreement among academics: most specialists are of the view that populism revolves around a central division between "the people" and "the elite".
    In other words, there is considerable consensus about the core features of populism. @moffittPopulism2020
  ]

  // What all approaches on populism share, is a common understanding that at its core, populism is about a

  The most popular definition of populism in the empirical literature is given by Cas #cite(<muddePopulistZeitgeist2004>, form: "prose").
  Populism in this context emphasizes the homogeneous nature of the people, often depicted as a cultural or economic entity, and defines the elite variably depending on context @muddeStudyingPopulismComparative2018.
  It is seen as a "thin-centered ideology" with a narrow scope compared to broader ideologies like nativism or socialism, which it can accompany @muddePopulistZeitgeist2004 @hawkinsIdeationalApproachPopulism2019a.
  Populism, seen as a thin ideology, describes a worldview that is characterized above all by the antagonistic relationship between the virtuous people and the corrupt elite, which is linked to a thick ideology @muddePopulistZeitgeist2004.
  Understanding populist rhetoric and claims that support this antagonism is thereby key to explaining their electoral success @devreesePopulismExpressionPolitical2018.

  This approach frames populism primarily as a conflict between the corrupt elite and the virtuous people, and therefore focuses on two key notions: anti-elitism and people-centrism.
  Anti-elitism is a moralizing critique of a perceived corrupt elite—such as political, economic, or cultural elites—accused of acting against the interests of the people.
  People-centrism refers to the idea that a homogenous and virtuous "people" are the sole legitimate source of political power, often contrasted with an elite that deprives them of their rights or identity.

  // Another notable perspective on populism is the discursive-performative approach.
  // Rooted in the work of Ernesto Laclau, it is by far the most common approach by political theorists @moffittPopulism2020.// (S. ~60 von 360, Beginn "The Discursive-Performative Approach")
  // Although this approach is less prevalent in the empirical literature, as it is considered "extremely abstract" and faces "serious problems when it comes to analysing populism in more concrete terms" #cite(<muddePopulismEuropeAmericas2012>, supplement: "p. 6"), it offers several valuable features that are applied in the in this work.
  While #cite(<moffittPopulism2020>, form: "prose", supplement: "Table 2.1") makes a clear distinction in that the ideational approach views populism as a purely binary attribute of political actors, Mudde recognizes a gradual "more or less populism" and merely qualifies that it does not make sense to speak of "weak populists" in the case of non-populist actors who use some populist phrases @muddePopulismIdeationalApproach2017.
  For the purpose of this research, we integrate both perspectives by conceptualizing populism as a binary attribute that can be assigned to political parties.
  In the current German Bundestag, two parties---the AfD and the Left---are classified as populist, according to the PopuList database @rooduijnPopuListDatabasePopulist2023.

  At the same time, we adopt a practice-oriented view of populism, understanding it as a strategic mode of communication that political actors may deliberately adopt to convey their ideological positions.
  This dual approach enables us to examine populism not only at the party level but also as a gradational phenomenon observable in individual texts.

  Assuming that political parties use YouTube in ways consistent with their broader communicative behavior, we propose the following hypothesis:
  // First, we follow the discursive-performative approach in that we define populism as a gradational concept, in contrast to a binary approach which is commonly used in research using the ideational definition. (CITE) // (CITE Moffit 2020, Table 2.1 -- roughly)


  #quote(block: true)[
    #strong[H1:]
    _Populist parties convey, on average, more populist content on YouTube than non-populist parties._
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

  Populism research is mostly divided into two different parts.
  There is one strain that detects populism in political actors or in certain parts of the discourse, such as speeches.
  And there is another strain that is concerned with measuring populist attitudes among populations @akkermanHowPopulistAre2014 @hawkinsActivationPopulistAttitudes2020.

  A notable aspect of analyzing populist communication on Social Media is that we are able to analyze direct feedback in terms of views, likes and comments on very specific bits of populist communication.
  According to #cite(<keffordPopulistAttitudesBringing2022>, form: "prose") they are the first to try to bridge this gap and try to link populist communication to populist attitudes in terms of voting behavior.
  From a theoretical perspective, they achieve this by combining the ideational approach and the discursive-performative approach.
  We follow their tradition somewhat loosely and believe we can at least get a rough grasp of the effect of populist rhetoric on user engagement.
  This highlights a major advantage of analyzing populist communication on social media platforms, namely the ability to gauge public responses to populist messaging.

  This process does not only involve detecting populist content published by political actors, but it also measures audience reactions through various platform-specific metrics, such as likes, dislikes, views, or shares.
  While the audiences on these platforms are often partisan and vary across different channels, comparing how viewers engage with content---whether it leans towards populism or not---offers valuable insights into broader public sentiment and interaction patterns.
  Given this premise, we can hypothesize some relationships about populist content of populist and non-populist parties and it's effect on user engagement.

  #quote(block: true)[
    #strong[H2a:]
    _For content of populist parties, we expect a positive relationship between a videos' amount of populism and it's user engagment._

    #strong[H2b:]
    _For content of non-populist channels, we expect no positive relationship between a videos' amount of populism and user engagement._
  ]


  // == Populism in the German Bundestag <sec:pop_in_bundestag>


  // Populism can be defined in a lot of different ways, with the two main approaches being "actor-centered" and "communication-centered" (larsson et al, the rise of instagram).
  // While the former approach sees populism as a property of some political entity, be it a politician or a party, the latter considers populism as a style of communication (e.g. Jacobs et al or Stanyer et al.-- see larson).
  // We combine both approaches in classifying the parties, based on an actor-centered approach (using PopuList) and identifying populist dimensions in the communication that is shared on the parties' YouTube channel.

  // Despite debates on the role of moralistic language in populism, recent scholarship suggests that combining moral, anti-elitist, and people-centric elements is essential to classify a statement as populist (Stavrakakis and Jäger 2018; Dai and Kustov 2022).
  // Thus, populism is characterized by these three intertwined attributes.

  = Data & Methods <data-methods>

  Our research methodology begins by retrieving the audio material from all of the videos under investigation.
  A speech-to-text tool is then employed to extract the transcripts from these videos, effectively converting the auditory data into analyzable text.
  Finally, an LLM model is applied to the transcripts to detect populism, providing a systematic and automated approach to identifying populist language in the content.
  All steps are described in the following in more detail.

  == YouTube Data

  Using their official channels, we collected a dataset comprising YouTube videos from all six political parties within the German Bundestag.
  The dataset is restricted to the period from December 6, 2017 (the date of the AfD's inaugural video on the platform) to February 24, 2025, the day of the Bundestagswahl 2025.
  For each party, two types of channels were collected: The official channel of the national party as well as the official channel of the faction in the Bundestag.
  This approach entails to problematic cases:
  First, the national party of the Left has changed channels as of 2024.
  For them, both channels are included in the analyses.
  Secondly, the CDU/CSU is a parliamentary alliance at the national level, consisting of the CSU—a party that operates exclusively in Bavaria—and the CDU, which is active in all other German federal states.
  However, both parties maintain partially separate social media presences.
  For the purposes of this analysis, we therefore aggregate the channels of the CSU and CDU, as well as the separate accounts of the CDU/CSU parliamentary group in the Bundestag and the CSU’s parliamentary group in the Bundestag.
  A full list of all 15 channels included in this analysis can be found in @ap:dataset.

  During the period of investigation, YouTube has updated its rules on Shorts.
  These are a separate video stream for short videos with an implementation comparable to TikTok.
  Since October 15, 2024, every video up to three minutes of length and with a square or vertical aspect ratio will be automatically categorized as a Short @youtube2025-shorts.
  Although we have explicitly not included Shorts during data collection, we there possibly have content that is not solely published as long-form video on YouTube in our data.
  To handle that and homogenize the data analysis, we create a variable in the data "is_short".
  It indicates whether a videos is up to 180 seconds in length.
  #mnote[könnte auch in appendix (die erklärung) und in main nur kurz dass du es unterscheidest]

  == Video transcripts

  The analysis of video material is very challenging, we therefore follow #cite(<schwemmerSocialMediaSellout2018>, form: "prose") and focus our analysis on the audio material.
  In order to do that, audio data of all videos and their accompanying metadata were downloaded using _yt-dlp_.
  In contrast to the abovementioned article, who use the pre-generated transcripts provided by YouTube, we use a state-of-the-art speech-to-text model to transcribe the audio material ourselves.
  While there exist professional captions on some of the videos, many of the videos in our corpus do not have such manually created captions.
  The quality of the automatically generated subtitles on YouTube is not sufficient for our purposes.
  Although they are sufficient to understand the content of the video without sound, they usually lack word case (a significantly bigger problem in German than in English) and almost all punctuation marks.
  While this is only a minor problem for simple text analysis approaches, such as bag-of-words, we assume that such differences between the training material and the data to be analyzed can have unpredictable effects on the predictive power of more complex LLMs, such as the BERT model used below to detect populism.
  We therefore aim to achieve the highest possible quality of the automated transcripts.

  The content of the videos was transcribed using OpenAI's advanced speech-to-text model, whisper-large-v3-turbo @radfordRobustSpeechRecognition2022.
  This model provides significantly faster transcription compared to whisper-large-v3 while maintaining comparable accuracy.
  However, Whisper models tend to produce erroneous transcriptions, known as hallucinations, particularly when the audio includes extended periods without speech, a common occurrence in YouTube videos.
  To address this issue, we employed the Silero voice activity detector @silerovad2024, isolating segments containing actual speech and passing only these segments to the Whisper transcription model.

  #let faulty_transcripts = read("inlines/n_broken.txt")
  #let hour_duration = read("inlines/sum_duration.txt")
  #let n_videos = read("inlines/n_videos.txt")
  #let n_sents = read("inlines/n_sents.txt")

  Although this approach effectively reduced the number of hallucinations, #faulty_transcripts videos had to be excluded from the analysis due to faulty transcripts.
  Faulty transcripts were identified by generating all n-grams for values of n between 2 and 10, and determining whether any n-gram appeared more than nine consecutive times within a transcript.
  Subsequently, the transcriptions were tokenized and segmented into sentences using the current version of the SoMaJo tokenizer and sentence-splitter @proislSoMaJoStateoftheartTokenization2016.
  After removing sentences with less than 3 tokens and videos with less than 5 sentences (often music-only videos optionally with written text on screen), our clean dataset comprises #n_videos videos, totaling #hour_duration hours of playtime and containing #n_sents sentences.

  == Detecting Populism <detection-of-populism>

  To detect populism in transcripts of YouTube videos from the official channels of the German parties in the Bundestag, we apply PopBERT, a BERT-based transformer model, fine-tuned to specifically detect anti-elitism and people-centrism in German political speech @erhardPopBERTDetectingPopulism2024.
  Although PopBERT was trained on transcripts of parliamentary speeches, we consider its application to videos from official party channels feasible.
  There is a high degree of similarity in tone, vocabulary, and rhetorical style between these two contexts.
  Additionally, there is substantial overlap in the speakers themselves, and the videos originate predominantly from the same time period as the training data.
  Therefore, we expect the model to reliably generalize to this closely related domain.

  To detect populism in the videos, we use the two core categories defined by PopBERT: anti-elitism and people-centrism.
  Analogous to the procedure in the associated article, the transcripts are divided into sentences and each sentence is fed into the model independently of the others and classified using the proposed thresholds.
  To obtain a value at the video level, the relative proportion of sentences that are classified as anti-elitist and people-centric is then calculated for each video.
  Since there are various possibilities in the literature for combining these dimensions, we examine both dimensions separately and choose to refrain from combining them into a single populism score.

  = Results <results>

  The analysis begins with an examination of the descriptive statistics across all channels.
  Subsequently, the focus shifts to exploring the relationship between populism and the popularity of videos.

  == German Parties on YouTube

  @tbl:channel_statistics provides an overview of all channels included in the subsequent analysis.
  Several patterns emerge immediately.
  Most notably, both AfD channels demonstrate substantially greater success compared to all other channels in the dataset.
  They attract significantly more followers and receive considerably higher average view counts.
  In addition, the total number of videos published across the two AfD channels exceeds that of any other party.

  #let table_array = csv("../tables/channel_summary.csv", row-type: array)
  #let header = table_array.first()
  #let table_content = table_array.slice(1)

  #figure(
    kind: table,
    context [
      #set text(size: 0.85em)
      #table(
        columns: (2.5cm, 4.5cm, 2cm, 1.3cm, 2cm, 2.3cm),
        align: (left, left, right, right, right, right),
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
    caption: [Summary statistics for all selected channels.],
  )<tbl:channel_statistics>

  The only channel that approaches the AfD's metrics is the federal-level channel of Die Linke (Left DE).
  However, a closer examination of this channel reveals a highly skewed distribution of views and likes, as indicated by a markedly higher mean compared to the median.
  This distortion can be attributed to the fact that the channel began accumulating the majority of its followers only in the second half of 2024.
  As a result, the channel's mean view count is inflated by recent high-performing videos, while the median remains comparatively low.
  Comparing median and mean values for both likes and views reveals a substantial analytical challenge inherent to YouTube data.
  Specifically, the means are substantially higher than the medians for all metrics, indicating a highly skewed distribution driven upward by a few exceptionally successful videos.

  Looking at the distributions of views and likes a bit more closely, we see a similar pattern between both.
  However, the average like count reported for the FDP may be misleading, as the like functionality has been disabled for all but one video on their channel.
  #mnote[die likes der fdp NA setzen?]
  @fig:view_count illustrates the distributions of views and likes to examine these disparities more closely. Due to considerable variation in the raw counts, views and likes are displayed on a logarithmic scale.

  #figure(placement: auto, image("figures/figure_1.svg", width: 100%), caption: [
    Distribution of likes and views per channel.
    All values are logged.
    The rectangle describes the .25, .5 and.75 quantiles.
    Outliers are represented by dots.
    Violin plots were superimposed on the boxplot to better visualize the distribution.
  ]) <fig:view_count>

  In addition to the above-mentioned differences in median views and likes, we can see in this figure that all parties have some very successful videos in terms of views.
  It is evident that all parties produce some successful videos, but the AfD stands out clearly here as well.

  // While the median of the views with values between 777 (Greens) and 1,613 (Left Party) is quite similar for the other parties, it is significantly higher for AfD BT with 14,547 and AfD TV with 17,767.
  // This picture becomes even clearer when looking at the number of likes.
  // While no other party reaches a median like count of 100---the Left achieves the highest count with 86---the AfD reaches 1,808 with AfD BT and as much as 2,233 with AfD TV.

  == Populism by German Parties on YouTube <sec:populism-on-yt>

  @fig:populism_dimensions shows the relative proportion of sentences classified by PopBERT as anti-elitist and people-centrist for each video.
  It becomes immediately apparent that both AfD channels contain a significantly higher share of anti-elitist statements than the channels of any other party.
  In many videos, the AfD channels reach proportions of anti-elitist content exceeding 10%, while most other parties remain well below 5%.
  The second-highest level of anti-elitist rhetoric is found in content from the Left, the other populist party in the Bundestag, although the proportion is substantially lower than that of the AfD.
  Notably, CSU BT also shows elevated levels of anti-elitist messaging compared to most non-populist parties.
  This suggests that anti-elitist rhetoric is not exclusive to parties commonly labeled as populist.

  #figure(
    image("figures/figure_2.svg", width: 100%),
    // placement: auto,
    caption: [
      Each case in this figure is a video; the values represent the relative proportion of sentences that are flagged with the respective populist dimension.
    ],
  ) <fig:populism_dimensions>

  This hypothesis is particularly supported in the dimension of anti-elitism: the channels of the AfD and the Left clearly contain more anti-elitist content than those of other parties.
  Additionally, the Left’s DE channel proportionally conveys the highest amount of people-centric content.
  However, the AfD channels display surprisingly limited people-centric appeals.
  The AfD TV channel exhibits a similar, though somewhat more moderate, pattern.
  Specifically, the AfD BT channel contains very little people-centric content and primarily focuses on an exceptionally high volume of anti-elitist messaging.
  It is worth noting that the AfD BT channel mainly features speeches by AfD members of parliament delivered in the Bundestag.

  To further examine H1—which posits that populist parties convey more populist content on YouTube than non-populist parties—we conducted Welch’s t-tests for both key dimensions of populist discourse, comparing videos from populist parties (AfD and the Left) with those from non-populist parties.
  For anti-elitism, the results strongly support *H1*: videos produced by populist parties exhibit a significantly higher level of anti-elitist content (M = 0.133) than those by non-populist parties (M = 0.036), a difference that is statistically significant (p < .001).
  In contrast, for people-centrism, the data reveal a small but statistically significant difference in the opposite direction: non-populist parties demonstrate slightly higher average levels of people-centric appeals (M = 0.028) compared to populist parties (M = 0.025; p < .001), thereby contradicting *H1*.
  One possible explanation for this pattern---high levels of anti-elitism coupled with comparatively low levels of people-centric messaging among populist parties---is that these parties may primarily use their parliamentary speaking time to criticize the governing parties, rather than to construct appeals directed toward "the people." This interpretation is further supported by the observation that, within the populist camp, the channels operated by the parliamentary factions (BT channels) exhibit higher average levels of anti-elitism than those managed by the federal party (DE channels) organizations.

  @fig:elite-over-time depicts the temporal development of anti-elitist rhetoric across YouTube videos from German political parties from 2018 to 2024.
  The analysis reveals distinct patterns between populist and non-populist parties.
  The AfD demonstrates consistently elevated levels of anti-elitist messaging throughout the observation period, with both their Bundestag and national channels frequently reaching average levels between 10-15% of sentences classified as anti-elitist per video.
  The Left party, as the other populist party in our sample, exhibits moderate but sustained anti-elitist rhetoric, maintaining levels generally higher than non-populist parties but substantially lower than the AfD.


  #figure(
    image("../figures/elite_over_time.svg", width: 100%),
    // placement: auto,
    caption: [
      Average amount of Anti-Elitism per video for each channel and party over time.
      Lines are drawn using a loess function with span of 0.3.
      Days of national elections are marked with vertical dashed lines.
    ],
  ) <fig:elite-over-time>

  Non-populist parties (CDU/CSU, FDP, Greens, SPD) display considerably lower baseline levels of anti-elitist content, typically remaining below 5%.
  However, these parties show notable increases in anti-elitist rhetoric approaching the 2025 federal election, suggesting a broader intensification of political discourse.

  In mid-2024, all three parties of the governing "traffic light" coalition (SPD, Greens, and FDP) experienced a marked spike in anti-elitist rhetoric on their YouTube channels, occurring just a few months before the coalition ultimately collapsed.
  The heightened political tensions during this period may have contributed to increased anti-establishment rhetoric across the political spectrum, as parties positioned themselves for the subsequent electoral campaign.
  For the Greens and the FDP, this period represents an all-time high in the share of anti-elitist content ever published on their channels.
  For the SPD, it marks the second-highest value on record, surpassed only by a surge at the end of 2023.
  That earlier spike coincides with the ruling of the Federal Constitutional Court declaring the government’s budget draft unconstitutional, which triggered intense internal disputes---most notably over the debt brake (Schuldenbremse).
  Around the same time, nationwide farmers' protests emerged in opposition to proposed cuts to tax subsidies for agricultural diesel.
  This turbulent political moment also coincided with a notable rise in anti-elitist rhetoric from the CDU/CSU, then in opposition, which reached its highest level of such content in the Bundestag during the observation period.

  @fig:pplcentr-over-time illustrates the temporal patterns of people-centric appeals in German parties' YouTube content over the same period.
  We see some similar patterns across both dimensions of populism for multiple parties. The AfD which shows a very consistent amount of both dimensions over the observation period, albeit with much lower total amounts for people-centrism.
  The SPD, CDU/CSU, and Greens show similar peaks for people-centrism as it showed above fro anti-elitism.
  The Left also shows its increase in people-centric appeals for the Left DE channels around the time anti-elitist content increased in 2022.
  The Left party's national channel exhibits the highest levels of people-centric messaging, reaching close to 10% during the electoral period 2021-2025 but also the CSU DE channel has some time periods with high amounts of people-centric appeals.

  In contrast to anti-elitist rhetoric, the FDP only shows a small and quickly decreasing surge of people-centric appeals in 2024.
  Notably, the AfD channels display only modest levels of people-centric content, particularly the Bundestag channel, which remains consistently low throughout the observation period.

  This finding challenges expectations about populist communication strategies and suggests that the AfD's YouTube presence focuses more heavily on attacking elites rather than appealing directly to "the people."

  #figure(
    image("../figures/pplcentr_over_time.svg", width: 100%),
    // placement: auto,
    caption: [
      Average amount of People-Centrism per video for each channel and party over time.
      Lines are drawn using a loess function with span of 0.3.
      Days of national elections are marked with vertical dashed lines.
    ],
  ) <fig:pplcentr-over-time>

  Overall, people-centrism appears less pronounced and more evenly distributed across parties compared to anti-elitist rhetoric, supporting our analytical approach of examining these populist dimensions separately rather than as a combined measure.


  == Populism and Popularity <populism-and-popularity>

  We now turn to the relationship between the amount of populist rhetoric in a video—operationalized through the share of anti-elitist and people-centric statements—and its popularity on YouTube. In the following, we focus on the number of views as the primary dependent variable; results for likes, which show highly similar patterns, are reported in @ap:reg_on_likes.#footnote[The results here are shown for the number of views as the dependent variable; results for the number of likes on the same data are shown in @ap:reg_on_likes.]

  === Quantile Regressions

  To capture potential heterogeneity across the distribution of video popularity, we employ Bayesian quantile regressions.
  This approach allows us to estimate how the association between populist dimensions and engagement varies between relatively unsuccessful videos and those at the very top of the distribution.
  For each of the six parties, we estimate 16 quantile models per populist dimension, resulting in a total of 192 quantile regressions.
  All models use the number of views per video as the dependent variable, standardized within channel and year to control for time- and party-specific baselines.
  In all models, we assume an asymmetric Laplace distribution for the dependent variable.
  We use weakly informative priors: N(0,15) for the intercept, N(0,2) for the coefficients, and Cauchy(0,2) for the sigma parameter.
  These priors reflect a conservative modeling approach, assuming no prior relationship by centering all distributions around zero.
  #mnote[describe control IVs where?]

  // We control for the year of a video's release, the number of sentences in the video's transcript.
  // #mnote[das in data-section]
  // Additionally, we control for short vs. long videos and add an interaction effect between the core populist dimension and the is_short variable to allow for different effects in short vs. long videos.
  // This is especially important since the populist dimension is measured as a _percentage of sentences that contain the populist dimension_ which might express something different in a video with very few sentences vs a video with many sentences.

  #figure(
    image("../figures/reg_views_elite.svg", width: 100%),
    // placement: auto,
    caption: [
      Coefficients of anti-elitism on views by tau for tau values $[.50, .99]$.
      Separate regressions are run for each channel.
      The solid black lines depict the Bayesian $R^2$ at each quantile and are associated with the right y-axis labels.
      The colored lines depict the coefficient size at the specific quantile for each party.
      The ribbons enclosed in dashed lines depict the 95% Credible Interval.
      Coefficients are associated with the left y-axis labels.
      To enhance readability of small values, all axes are transformed using a pseudo log transformation with $sigma = 3.7$.
    ],
  ) <fig:views_elite>


  The results for anti-elitism as the populist dimension of interest are depicted in @fig:views_elite.
  Across all parties, we find no or only negligible effects of anti-elitism at the lower quantiles of the view distribution.
  In other words, for less popular videos, the amount of anti-elitist content appears to have little systematic influence on viewership.
  However, the picture changes markedly in the upper quantiles: for all parties except the FDP, coefficients for anti-elitism increase sharply and almost exponentially toward the top end of the distribution.
  This pronounced non-linearity in the effects provides strong justification for the use of quantile regression over conventional mean-based methods, which would obscure such patterns.
  The substantive size of the effects at high quantiles is considerable.
  For example, a coefficient of 10 implies that a 1 percentage point increase in anti-elitist content predicts an additional 0.1 standard deviations of views compared to other videos from the same channel in the same year.
  These effects are accompanied by substantial increases in explanatory power: the Bayesian $R^2$ rises steeply with higher quantiles, reaching values around 0.40–0.45 for all parties in the upper tail of the distribution.
  #footnote[To ensure that these high $R^2$ values are not statistical artifacts, we ran a small simulation study showing that these increases are in fact not artifacts. The results can be found in @ap:sim_bayes_r2.].

  The FDP represents a notable outlier in this pattern.
  Here, high levels of anti-elitism are associated with negative effects on views at the top quantiles, while the models explain a comparable share of variance to those of other parties.
  Given the standardization within channel and year, this explained variance is primarily attributable to differences in the independent variables---most prominently anti-elitism---rather than to structural differences in baseline popularity.

  #figure(
    image("../figures/reg_views_pplcentr.svg", width: 100%),
    // placement: auto,
    caption: [
      Coefficients of people-centrism on views by tau for tau values $[.50, .99]$.
      Separate regressions are run for each channel.
      The solid black lines depict the Bayesian $R^2$ at each quantile and are associated with the right y-axis labels.
      The colored lines depict the coefficient size at the specific quantile for each party.
      The ribbons enclosed in dashed lines depict the 95% Credible Interval.
      Coefficients are associated with the left y-axis labels.
      To enhance readability of small values, all axes are transformed using a pseudo log transformation with $sigma = 3.7$.

    ],
  ) <fig:views_pplcentr>

  The results for people-centrism, depicted in @fig:views_pplcentr,are markedly weaker and more heterogeneuous than for anti-elitism.
  Coefficients are generally indistinguishable from zero through the lower and mid‑quantiles, with only modest movement until the upper tail.
  Near the top decile, some parties exhibit small positive effects, while others show null or even negative high‑quantile coefficients; overall magnitudes remain below those observed for anti‑elitism.
  These results align with the descriptive evidence that people‑centrism is less pronounced and more evenly distributed across parties than anti‑elitist rhetoric (cf. @sec:populism-on-yt), and they reinforce our conclusion that anti‑elitism---not people‑centrism---drives the non‑linear engagement gains at the top of the view distribution.


  To summarize with respect to *H2a*, we find partial support: anti-elitist content is strongly and positively associated with views for both populist parties, but only in the upper tail of the distribution.
  For the AfD, coefficients rise consistently across high quantiles, whereas for the Left the effects are smaller and become credibly positive only from about $tau ≈ 0.90$ onward.
  For people-centrism, the AfD again conforms to H2a with positive effects emerging only at very high quantiles; by contrast, estimates for the Left are unstable—briefly dipping below zero—and become credibly positive only at $tau ≈ 0.99$.
  Contrary to *H2b*, the non-populist parties exhibit broadly analogous patterns (near-zero effects at lower quantiles and steep increases at the top), with the notable exception of the FDP, whose anti-elitism coefficients turn negative at the very highest quantiles.

  === Hurdle Models

  The coefficient patterns observed suggest two potential mechanisms through which anti-elitism influences video performance: (1) selection into high-performing content: anti-elitist rhetoric increases the probability of a video entering the top performance tier, or (2) conditional amplification: anti-elitism enhances engagement only among videos that already achieve substantial viewership.

  To distinguish between these mechanisms, we estimate hurdle models that separate the probability of a video reaching the top 10% of channel-year performance from the magnitude of engagement within this elite tier.
  We define "very successful" videos as those in the top decile of view counts within each channel-year combination, setting all remaining video view counts to zero.
  This approach creates a two-stage process: a logistic hurdle component modeling selection into the top 10%, and a negative binomial component modeling view counts conditional on top-tier performance.
  We estimate separate models for each populist dimension and party using the same covariates as in the main analysis.
  Prior specifications include N(0,2) for negative binomial coefficients, N(0,4) for hurdle coefficients, N(qlogis(0.9), 0.5) for the hurdle intercept (reflecting the expected 90% zero-inflation), and N(log(mean_nonzero_views), 2) for the negative binomial intercept.
  Models converged within 4000 iterations (2000 warmup).

  #figure(
    image("../figures/hurdle_model_coefficients.svg", width: 100%),
    caption: [
      This plot displays coefficients for Anti-Elitism and People-Centrism from hurdle negative binomial models.
      Left panels show hurdle component coefficients, where negative values indicate increased probability of a video reaching the top 10% performance tier within its channel-year.
      Right panels show negative binomial component coefficients, where positive values indicate higher view counts among videos already in the top 10%.
    ],
  ) <fig:hurdle_models>

  @fig:hurdle_models presents results for both populist dimensions.
  In the hurdle component (left panels), negative coefficients indicate increased probability of top-tier performance, as the model estimates the probability of structural zeros.
  Anti-elitism shows substantial negative coefficients across most parties (excluding FDP and Greens), suggesting that anti-elitist rhetoric enhances selection into high-performing videos.
  In the negative binomial component (right panels), positive coefficients indicate amplification effects within the top tier.
  Here, only the populist parties (AfD and Left) exhibit positive coefficients for anti-elitism, suggesting that anti-elitist content provides additional engagement benefits exclusively among videos from these parties that already achieve top-tier status.

  People-centrism exhibits a somewhat different pattern (bottom panels).
  In the hurdle component, while most coefficients are smaller in magnitude than those for anti-elitism, there are notable negative coefficients for AfD, CDU/CSU, and Left, suggesting that people-centric rhetoric does contribute to selection into top-performing videos for these parties, albeit more modestly than anti-elitism.
  However, the negative binomial component reveals negative coefficients for some parties, particularly for CDU/CSU, Left, and SPD.
  This indicates that for these parties, people-centric rhetoric may actually reduce engagement within already successful videos.

  = Discussion <discussion>

  Anti-elitist content drives higher engagement across the German political spectrum on YouTube, fundamentally challenging the assumption that people-centrism is an equally important dimension of populism in digital political communication.
  Our findings reveal that while populist parties—particularly the AfD—produce substantially more anti-elitist rhetoric and achieve greater overall platform success, the relationship between anti-elitist messaging and audience engagement extends well beyond traditionally populist actors.
  Quantile regression analysis demonstrates that increased anti-elitist content correlates with exponentially higher view counts in the upper distribution for nearly all parties.
  This pattern could suggest that YouTube's attention economy systematically rewards confrontational political messaging that attacks established elites, regardless of the party's populist classification.
  In stark contrast, people-centric appeals show inconsistent and often negligible effects on engagement, questioning whether this dimension should be considered co-equal with anti-elitist rhetoric in understanding populist communication strategies on video platforms.

  The analysis reveals a fundamental asymmetry in how populist dimensions operate on YouTube.
  Anti-elitist rhetoric emerges as the primary driver of engagement, particularly for populist parties, while people-centric appeals show more limited and inconsistent effects.
  The AfD channels contain substantially higher levels of anti-elitist content compared to non-populist parties, supporting our first hypothesis.
  However, the finding that people-centrism is actually slightly higher among non-populist parties than populist parties challenges conventional expectations and suggests that confrontational content on YouTube may be favored over inclusive populist messaging.

  The hurdle model analysis distinguishes between two mechanisms through which anti-elitism influences video performance.
  The negative coefficients in the hurdle component indicate that anti-elitist content increases the probability of videos entering the top performance tier across most parties.
  However, only populist parties show positive coefficients in the negative binomial component, suggesting that anti-elitist rhetoric provides additional engagement benefits exclusively among already successful videos from populist channels.
  This finding supports the theoretical expectation that populist communication strategies are particularly effective within partisan audiences.

  However, several limitations warrant consideration.
  First, our analysis focuses solely on official party channels, potentially missing important populist communication occurring through individual politicians' accounts or unofficial channels.
  Second, while PopBERT demonstrates strong performance on parliamentary speech, its application to YouTube content represents a domain transfer that may introduce measurement error.
  Due to the lower performance of the classifier for the people-centric dimension, some existing patterns might also be obscured by false measurement for this dimension.
  Third, the study's focus on audio content necessarily excludes visual elements that may be crucial for understanding YouTube's full communicative impact.

  That said, the broader implications for democratic discourse are concerning.
  The systematic amplification of anti-elitist messaging, regardless of political alignment, suggests that YouTube's attention economy may contribute to the erosion of institutional trust and political civility.
  The finding that confrontational rhetoric correlates with higher engagement across the political spectrum indicates that the platform's incentive structure may push all parties toward more aggressive communication styles.
  Whether or not these finding hold true in other communicative settings also remains an open question.

  These findings underscore YouTube's significant role in contemporary political communication and its potential contribution to democratic polarization.
  Understanding how populist rhetoric operates on video platforms is crucial for developing informed responses to the challenges facing democratic societies in the digital age.

])
#pagebreak()
#set par(leading: 1em, spacing: 1.7em)
#bibliography("references.bib", style: "apa")
#pagebreak()

#show figure: set block(breakable: true)
#set heading(numbering: none)

#include "appendix.typ"
