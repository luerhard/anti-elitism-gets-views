#set text(
  font: "Times New Roman",
  size: 12pt
)

#set page(
  paper: "a4",
  margin: (x: 3cm, y: 3cm),
  numbering: "1"
)

#set par(
  leading: 1.3em,
  justify: true,
  linebreaks: "optimized"
)
#show par: set block(below: 1em, above: 2em)

#set heading(numbering: "1.1.1")

= Introduction <introduction>

Populist parties threaten democratic values and contribute to ideological polarization @robertsPopulismPolarizationComparative2022. Populism, seen as a thin ideology, describes a worldview that is characterized above all by the antagonistic relationship between the virtuous people and the corrupt elite, which is linked to a thick ideology @muddePopulistZeitgeist2004. Understanding populist rhetoric and claims that support this antagonism is thereby key to explaining their electoral success @devreesePopulismExpressionPolitical2018. Social media, especially YouTube as one of the largest platforms, is an important but under-researched place where populism is spread.

While in the past years, TV was "considered to be the most important advertising medium and televised political advertising a leading way of communication between candidates voters" @vesnic-alujevicYouTubePoliticalAdvertising2014[199] and it probably still is, its place at the top is heavily contested by emergent players on the web. With the rise of YouTube as one of the most important social media networks on the internet, it still lacks a thorough investigation @rauchfleischGermanFarrightYouTube2020. But YouTube is not "just" a social media platform. Even without the direct interaction of content creators and viewers, this platform allows for an easy way to create and share content for just about everybody. The German parties naturally also take the opportunity to be represented on it, albeit with very different degrees of success. While the viewership is behind some of the more influential accounts on this platform, investigating the content shared on YouTube allows us to examine the parties’ self-representation in more detail. #footnote[There are some successful channels of German politicians like Sarah Wagenknecht (with 664,000 followers) or Alice Weidel (with 189,000 followers) with personal channels. Still, we focus on the party channels in this study.] This research aims to take a closer look at the use and dissemination of populism on YouTube by German political parties.

#quote(block: true)[
#strong[Research Questions:] What type of content do German political parties share on YouTube, and which content tends to gain the most traction or success? Additionally, does the element of populism contribute to the popularity of certain content?
]

== Populism and the Bundestag <populism-and-the-bundestag>

There are currently two parties in the German Bundestag that are considered populist, the AfD and the Left @rooduijnPopuListDatabasePopulist2023.

Populism, seen as a thin ideology, describes a worldview that is characterized above all by the antagonistic relationship between the virtuous people and the corrupt elite, which is linked to a thick ideology @muddePopulistZeitgeist2004. Understanding populist rhetoric and claims that support this antagonism is thereby key to explaining their electoral success @devreesePopulismExpressionPolitical2018.

= YouTube as a research platform <youtube-as-a-research-platform>

YouTube is the only major social media network more popular among right-leaning users @mungerRightWingYouTubeSupply2022. Additionally, and in contrast to other parties, populists prefer social media over talk shows @ernstPopulistsPreferSocial2019. As #cite(<engesserPopulismSocialMedia2017>, form: "prose", supplement: [1123]) indicate, the logic of social media platforms gives them more freedom to use strong language when attacking elites or ostracizing others.

While data on Germany specifically are scarce, a study from 2016 investigating a sample of Americans reported that around 90% of youth and young adults have used YouTube at least once in the past three months @costelloWhoViewsOnline2016[315];. Motivated by these discoveries, we recognize the importance of examining parties’ YouTube videos, particularly emphasizing the effects of populist content.

YouTube can be seen as a social media platform. Since everybody can publish content on this platform with very few hurdles, and viewers can self-select what content they are willing to watch, it is natural to view YouTube as a social network between people that is centered around sharing video content—in a way like Instagram is a social network centered around images. Studies that take such an approach might see YouTube from a supply-and-demand perspective, analyzing the side of the content creators and the viewers @mungerRightWingYouTubeSupply2022. While investigating YouTube through such a lens is a worthwhile endeavor, it might not be suitable to investigate politicians’ content. Many scholars have proposed theories on why politicians, particularly populists, choose social media platforms over traditional hierarchical media. Nevertheless, populist leaders mostly utilize social media as a supplementary one-way broadcasting system, instead of interacting with citizens as #cite(<jungherrTwitterUseElection2016>, form: "prose") shows in a systematic literature review on twitter use in election campaigns. They might argue the social media facilitates personal and interactive conversations compared to the more traditional broadcasts through legacy media. #cite(<waisbordPopulistCommunicationDigital2017>, form: "prose");, for instance, have shown remarkably low interaction between Latin American politicians, populist and non-populist, on Twitter.

This leds to believe, that videos on YouTube are best viewed from content delivery perspective first.

= Data & Methods <data-methods>

Using their official channels, we collected a dataset comprising YouTube videos from all six political parties within the German Bundestag. The FDP (Free Democratic Party) with \@FDP, the Greens with \@DieGruenen, the SPD (Social Democratic Party) with \@spdde and the Left with \@DIELINKE have easily identifiable main official party channels. The CDU (Christian Democratic Union) and CSU (Christian Social Union) are two separate political parties in Germany that operate as sister parties. The CDU is active in all German states except Bavaria, where the CSU operates exclusively. For this reason, both parties also maintain separate YouTube channels with \@cdutv and \@csumedia, although they are regarded as a single party within the Bundestag. Conversely, the AfD’s (Alternative for Germany) official channel (\@AfDTV) is distinct from the parliamentary group’s channel (\@AfDFraktionimBundestag). Both channels, exhibiting comparable follower counts, were incorporated into our analysis. Consequently, our dataset encompasses a total of eight channels. The dataset is restricted to the period from December 6, 2017 (the final channel’s inaugural video publication) to January 20, 2024 (a week before data collection) to give all videos time to accumulate views and likes.

#block[
#figure(
  align(center)[#table(
    columns: 9,
    align: (left,right,right,right,right,right,right,right,right,),
    table.header([], [AfD BT], [AfD TV], [Left], [Greens], [SPD], [FDP], [CDU], [CSU],),
    table.hline(),
    [ch\_followers], [388000], [250000], [29000], [26100], [24200], [23300], [21900], [5170],
    [ch\_videos], [5207], [1457], [435], [459], [480], [487], [629], [145],
    [n\_sentences], [299414], [145525], [46823], [46964], [66999], [36930], [54267], [10463],
    [n\_sent\_elite], [40413], [17477], [2499], [1463], [1433], [1400], [947], [290],
    [n\_sent\_pplcentr], [6117], [3663], [1425], [1358], [2253], [929], [1450], [239],
    [avg\_comments], [398.3], [398.7], [45.0], [0.2], [25.0], [0.7], [41.2], [7.5],
    [avg\_duration], [436.2], [657.2], [832.4], [892.2], [1088.2], [620.3], [616.0], [442.2],
    [avg\_likes], [3867.4], [3627.1], [255.8], [79.7], [102.1], [0.5], [64.4], [35.6],
    [avg\_views], [45832.0], [43363.7], [10426.9], [4537.7], [5065.4], [5874.0], [9624.1], [22332.8],
  )]
  , caption: [Summary statistics of the dataset.]
  , kind: table
  )

] <tab:descriptives>
<tab:descriptives>

It is particularly striking that each of the two AfD channels, \@AfDFraktionimBundestag (388,000 followers), herein after referred to as AfD BT, and \@AfDTV (250,000), has more than twice as many followers as all the other analyzed channels combined (219,670). While all parties have some successful videos (see Figure Xfig:view_count), average views and likes per video diverge up to a factor of 10 between the AfD channels and all others. Notably, the FDP consistently disables the like/dislike functionality across most of their videos, excluding them from upcoming like-based analyses.

The videos’ content was transcribed using OpenAI’s state-of-the-art speech-to-text model, whisper-large-v3 @radfordRobustSpeechRecognition2022. Subsequently, the transcriptions were tokenized and segmented into sentences using the current version of SoMaJo @proislSoMaJoStateoftheartTokenization2016 tokenizer and sentence-splitter. After removing sentences with less than 5 tokens and videos with less than 5 sentences (mostly music-only videos with written text on screen), our clean dataset comprises 9,394 videos, totaling 1,485 hours and featuring 708,549 sentences. Summary statistics per channel are presented in Table Xtab:descriptives. Figure Xfig:view_count depicts the distributions of likes and views. While all parties have some successful videos, these numbers indicate that each of the AfD’s channels has more than double the followers, views, and likes of all other parties combined. Notably, the FDP consistently disables the like/dislike functionality across most of their videos and, in conjunction with the Greens (Grüne), opts to disable comments.

/*
#figure(image("img/view_count_violin.pdf", width: 100%),
  caption: [
    Distribution of logged view and like counts per channel.
  ]
)
<fig:view_count>
*/

== Detection of Populism <detection-of-populism>

To detect populist dimensions in the viewos, we used PopBERT @erhardPopBERTDetectingPopulism2023, a BERT-based transformer model.

fine-tuned on German political speech.

to detect populist dimensions in all sentences, classifying the two central dimensions of populism: anti-elitism and people-centrism.

== Content Classification <content-classification>

We use a coding scheme for content classification with 56 categories created by the Manifesto Project @volkensManifestoProjectDataset2020. It is hierarchically organized and was created while annotating 4582 election programs from 1154 parties in 56 countries.

Additionally, the manifestoroberta model— an xlm-roberta-large based model fine-tuned on sentences from party manifestos to categorize content into 56 distinct categories @burstManifestoberta2023—was applied to all sentences.

Despite not being fine-tuned on German specifically, the multilingual capacity of the underlying xlm-roberta-large ensured effective classification. Classifications of the manifesto classifier were only kept if the probability for the most probable class was higher than $0.5$. Nevertheless, class #emph[305 - Political Authority] appears to be some default category when analyzing transcripts from political YouTube videos as they span 37.8% of all classifications. We thus omit this category from further analysis as it does not reveal any information to us.

= Results <results>
/*
<results>
#figure(image("img/populism_over_time.pdf", width: 100%),
  caption: [
    Populism over time.
  ]
)
<fig:populism_over_time>
*/

== Videos by type <videos-by-type>

- We investigate the broad types of video content published by each party to connect this with popularity and hopefully see some differences between AfD and the rest. - Potential types are: politische Rede (mostly Bundestag), Demo-Rede, Diskussionsrunde, Promo-Video, Fernsehbeitrag?,

== Populism and Popularity <populism-and-popularity>

A key finding here is that only the populist parties (both AfD channels and the Left) show a clear correlation between the number of likes of a video and populist dimensions. This suggests that people who watch videos from populist parties do so deliberately and in search of anti-elitist content. This effect is not seen for people-centrism.

/*
#figure(image("img/nb_regression_like_count.pdf", width: 100%),
  caption: [
    Negative Binomial Regression on Number of Likes per Video. Anti-elitism is z-transformed by the channel mean. Channel and Anti-Elitism are modeled using an interaction effect. We control for the year of release and video length.
  ]
)
<fig:nb_reg>
*/

== Populism and Content <populism-and-content>

Table XX shows the top-5 most associated content categories for either anti-elitist or people-centric sentences. The top categories for the AfD are almost identical for both channels, indicating similar populist content. They tend to focus, among others, the populist statements on the need to eliminate political corruption (304), appeals to pride of citizenship, patriotism and natonalism (601), and negative references of the European Union (110), all known topics from the AfD electoral program @afdAfDWahlprogramm20232023. Other parties also show topics in their top 5 that they are known for. They are populist when talking about the concept of social justice and the need of fair treatment for all people (503), favorable references to all labor groups, good working conditions, and fair wages (701), topics like child/elder care and social housing (504) or during negative references to the military (105). All these are topics the Left is known for @dielinkeLINKEWahlprogramm2023. Even the non-populist parties follow this pattern: The neo-liberal Free Democratic Party (FDP) focuses on favorable mentions of the importance of personal freedom and civil rights (201), the employee-friendly Social Democratic Party (SPD) on the abovementioned good working conditions (701).

== The most successful videos <the-most-successful-videos>

- We could do a superstar analysis, investigating the most successful videos per channel

== Sentiment in comments <sentiment-in-comments>

- We could check the sentiment in comments for the videos (probably mostly interesting for the AfD channels) to check user engagement and positioning towards topics.

- Also, test how often the channel accounts respond to comments. It could be a nice indicator of engagement.

= Discussion <discussion>

#pagebreak()
#set par(leading: 0.65em)
#show par: set block(below: 0em, above: 0em)
#bibliography("references.bib", style: "apa")
