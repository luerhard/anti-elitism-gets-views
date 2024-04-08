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

# Data / Methods

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

### Setup
- This is the regression

### Results
\centering
![](rsc/img/nb_regression_like_count.pdf){height=80% margin=auto}
