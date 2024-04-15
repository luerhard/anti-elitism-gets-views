---
# Bibliography
bibliography: rsc/library/references.json
csl: rsc/library/style.csl
lang: english

title: Populist Content on YouTube
subtitle: Online-Communication Strategies of German Parties
author: Lukas Erhard
institute: University of Stuttgart

date: \today
toc: false

---

# Theory

## YouTube

- Around 90\% of youth and young (U.S.) adults have used YouTube at least once in the past three months [@costelloWhoViewsOnline2016, 315].
- YouTube is the only major social media network more popular among right-leaning users in the U.S. [@mungerRightWingYouTubeSupply2022].

# Data / Methods

## Data Collection

- Download all audio files from all YouTube content of the official German parties.
- After cleaning, setting time constraints, and tokenization, we are left with:
    - 9394 videos with 1485 hours
    - 708,549 sentences
- Application of 2 models on the data:
    1. PopBERT to classify populist dimensions
    2. Manifesto Roberta to classify content of sentences. (not sure how to best analyze this, yet.)

## Summary of the Dataset

\small
\begin{tabular}{lrrrrrrrr}
\toprule
 & AfD BT & AfD TV & Left & Greens & SPD & FDP & CDU & CSU \\
\midrule
ch\_followers & 388000 & 250000 & 29000 & 26100 & 24200 & 23300 & 21900 & 5170 \\
ch\_videos & 5207 & 1457 & 435 & 459 & 480 & 487 & 629 & 145 \\
n\_sentences & 299414 & 145525 & 46823 & 46964 & 66999 & 36930 & 54267 & 10463 \\
n\_sent\_elite & 40413 & 17477 & 2499 & 1463 & 1433 & 1400 & 947 & 290 \\
n\_sent\_pplcentr & 6117 & 3663 & 1425 & 1358 & 2253 & 929 & 1450 & 239 \\
avg\_comments & 398.3 & 398.7 & 45.0 & 0.2 & 25.0 & 0.7 & 41.2 & 7.5 \\
avg\_duration & 436.2 & 657.2 & 832.4 & 892.2 & 1088.2 & 620.3 & 616.0 & 442.2 \\
avg\_likes & 3867.4 & 3627.1 & 255.8 & 79.7 & 102.1 & 0.5 & 64.4 & 35.6 \\
avg\_views & 45832.0 & 43363.7 & 10426.9 & 4537.7 & 5065.4 & 5874.0 & 9624.1 & 22332.8 \\
\bottomrule
\end{tabular}


## Distribution of Views and Likes per Channel
\centering
![](rsc/img/view_count_violin.pdf){height=80% margin=auto}

# Results

## Regression


- Negative binomial regression
- Main effect: Interaction between `channel` and `elite`
- Control variables: `year`, `duration`
- `elite` z-standardized within `channel`

```
like_count = channel + elite + channel * elite + year + duration
```

###
\centering
![](rsc/img/nb_regression_like_count.pdf){height=90% margin=auto}


# Manifesto Roberta {.allowframebreaks}

\scriptsize
\begin{longtable}{p{1.3cm}p{4.5cm}r|p{4.5cm}r}

\toprule
Channel & All Sentences & Count & Populist Sentences & Count\\
\midrule
\endhead

\textbf{AfD TV }& 304 - Political Corruption & 5639 & 304 - Political Corruption & 1406 \\
& 202 - Democracy & 4128 & 110 - European Community/Union: Negative & 756 \\
& 601 - National Way of Life: Positive & 3747 & 601 - National Way of Life: Positive & 630 \\
& 605 - Law and Order: Positive & 3613 & 202 - Democracy & 412 \\
& 501 - Environmental Protection: Positive & 3134 & 608 - Multiculturalism: Negative & 398 \\
 & & \\
\textbf{AfD BT }& 501 - Environmental Protection: Positive & 12390 & 304 - Political Corruption & 2330 \\
& 304 - Political Corruption & 9313 & 110 - European Community/Union: Negative & 1377 \\
& 202 - Democracy & 8235 & 601 - National Way of Life: Positive & 941 \\
& 605 - Law and Order: Positive & 7670 & 202 - Democracy & 832 \\
& 504 - Welfare State Expansion & 7307 & 501 - Environmental Protection: Positive & 821 \\
 & & \\
\textbf{Greens }& 501 - Environmental Protection: Positive & 3559 & 503 - Equality: Positive & 150 \\
& 202 - Democracy & 2312 & 501 - Environmental Protection: Positive & 143 \\
& 503 - Equality: Positive & 1860 & 606 - Civic Mindedness: Positive & 113 \\
& 506 - Education Expansion & 1191 & 202 - Democracy & 103 \\
& 606 - Civic Mindedness: Positive & 1175 & 201 - Freedom and Human Rights & 81 \\
 & & \\
\textbf{CDU }& 202 - Democracy & 2243 & 606 - Civic Mindedness: Positive & 96 \\
& 411 - Technology and Infrastructure & 1678 & 706 - Non-economic Demographic Groups & 56 \\
& 501 - Environmental Protection: Positive & 1446 & 701 - Labour Groups: Positive & 54 \\
& 606 - Civic Mindedness: Positive & 1253 & 202 - Democracy & 51 \\
& 504 - Welfare State Expansion & 1193 & 605 - Law and Order: Positive & 51 \\
 & & \\
\textbf{CSU }& 411 - Technology and Infrastructure & 539 & 501 - Environmental Protection: Positive & 19 \\
& 501 - Environmental Protection: Positive & 459 & 601 - National Way of Life: Positive & 18 \\
& 502 - Culture: Positive & 419 & 603 - Traditional Morality: Positive & 13 \\
& 603 - Traditional Morality: Positive & 372 & 606 - Civic Mindedness: Positive & 12 \\
& 202 - Democracy & 251 & 605 - Law and Order: Positive & 11 \\
 & & \\
\textbf{Left }& 701 - Labour Groups: Positive & 3291 & 503 - Equality: Positive & 375 \\
& 503 - Equality: Positive & 2695 & 701 - Labour Groups: Positive & 271 \\
& 504 - Welfare State Expansion & 2223 & 504 - Welfare State Expansion & 164 \\
& 501 - Environmental Protection: Positive & 1416 & 304 - Political Corruption & 127 \\
& 502 - Culture: Positive & 1150 & 105 - Military: Negative & 107 \\
 & & \\
\textbf{FDP }& 506 - Education Expansion & 1471 & 201 - Freedom and Human Rights & 83 \\
& 411 - Technology and Infrastructure & 1164 & 202 - Democracy & 58 \\
& 202 - Democracy & 1045 & 503 - Equality: Positive & 53 \\
& 501 - Environmental Protection: Positive & 1040 & 506 - Education Expansion & 51 \\
& 201 - Freedom and Human Rights & 1021 & 606 - Civic Mindedness: Positive & 51 \\
 & & \\
\textbf{SPD }& 701 - Labour Groups: Positive & 4121 & 701 - Labour Groups: Positive & 305 \\
& 503 - Equality: Positive & 2917 & 503 - Equality: Positive & 210 \\
& 504 - Welfare State Expansion & 2793 & 606 - Civic Mindedness: Positive & 167 \\
& 202 - Democracy & 1985 & 504 - Welfare State Expansion & 133 \\
& 411 - Technology and Infrastructure & 1939 & 202 - Democracy & 86 \\
\bottomrule
\label{tab:manifesto}

\end{longtable}

# Literatur {.unnumbered .unlisted}
<!-- if references are too many, add .allowframebramebreak in the {} above to allow multiple slides of refs.-->
\footnotesize
::: {#refs}
:::
