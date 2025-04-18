% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rarefaction_alpha_calculations.R
\name{rarefaction_alpha_calculations}
\alias{rarefaction_alpha_calculations}
\title{Calculate taxonomic and phylogenetic alpha diversity using rarefaction and hill numbers}
\usage{
rarefaction_alpha_calculations(
  phy_object,
  rarefy_depth,
  iterations,
  method = "both",
  seed = 1,
  threads
)
}
\arguments{
\item{phy_object}{a phyloseq object containing an otu_table of feature counts}

\item{rarefy_depth}{read depth to rarefy to in each iteration; generally the read count of the sample with the fewest reads}

\item{iterations}{how many times the metric should be calculated before averaging; recommended minimum 100 up to 1000}

\item{method}{whether to calculate taxonomic or phylogenetic hill diversity numbers (or both). Acceptable values include "taxonomic","phylo", or "both"}

\item{seed}{an integer to set the random seed - required for reproducible calculations! Using set.seed will not be sufficient}

\item{threads}{how many threads to use. Optimum number will depend on your number of iterations. Generally if running 1000 iterations, I wouldn't use more than 20 threads.}
}
\value{
a dataframe with estimated diversity (qD) for hill numbers 0-2 for each sample.
}
\description{
This function repeatedly rarefies a phyloseq object (usually containing 16S data) and calculates alpha diversity measures using Hill Diversity numbers. Can also calculate phylogenetic distance, if your phyloseq object contains a tree.
}
