---
title: Installing RevBayes
---

> ## About
> RevBayes provides an interactive environment for statistical computation in phylogenetics. It is primarily intended for modeling, simulation, and Bayesian inference in evolutionary biology, particularly phylogenetics. However, the environment is quite general and can be useful for many complex modeling tasks.
>
> RevBayes uses its own language, Rev, which is a probabilistic programming language like JAGS, STAN, Edward, PyMC3, and related software. However, phylogenetic models require inference machinery and distributions that are unavailable in these other tools.
>
> The Rev language is similar to the language used in R. Like the R language, Rev is designed to support interactive analysis. It supports both functional and procedural programming models, and makes a clear distinction between the two. Rev is also more strongly typed than R.

Go to [RevBayes download](https://revbayes.github.io/download) section to download the executable. The latest version at time of writing is 1.4.1.

After installation you should be able to open RevBayes on the command-line. Try to enter `1 + 1` to see if it works!

```
$ rb

RevBayes version (1.4.1)
Build from tags/v1.4.1 (3a504e) on Fri Jul 17 08:58:20 UTC 2026

Visit the website www.RevBayes.com for more information about RevBayes.

RevBayes is free software released under the GPL license, version 3. Type 'license()' for details.

To quit RevBayes type 'quit()' or 'q()'.


> 1 + 1
   2
```
