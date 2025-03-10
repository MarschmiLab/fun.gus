#' Rapidly calculate rarefaction curves at specified Hill numbers
#'
#' This function uses the `rmvhyper()` function from the `extraDistr` package to rapidly estimate rarefaction across your OTU table. This makes it much faster than the `rarefy_even_depth` function from `phyloseq`, or the manual rarefaction performed in `iNEXT`.
#' @param physeq a phyloseq object containing an otu_table of NON-NORMALIZED, INTEGER feature counts. Do not use rarefied, normalized, or relative counts.
#' @param iterations how many times alpha diversity should be calculated at each step for each sample
#' @param steps how many equally spaced steps at which to rarefy for each sample
#' @param seed an integer to set the random seed
#' @returns a dataframe with estimated alpha diversity at three hill numbers (hill0 - hill2) at an specified number of equally spaced depths for all samples in long-format.

#' @importFrom phyloseq otu_table taxa_are_rows
#' @importFrom dplyr bind_rows
#' @importFrom purrr map2 bind_rows
#'
#' @export
fast_rarefaction_curves <- function(physeq, iterations, steps, seed = 1){

  if(taxa_are_rows(phy_object)){

    df <-
      physeq %>%
        otu_table() %>%
        data.frame()

  }else{

    df <-
      physeq %>%
      otu_table() %>%
      data.frame() %>%
      t()
  }

  df <- physeq %>%
    otu_table() %>%
    data.frame()

  map2(df, colnames(df), \(x,y)rarefy_sample(x, iterations = iterations, steps = steps, sample_id = y, seed = seed)) %>%
    bind_rows()

}




#' Estimate alpha diversity in a given sample of the OTU table
#'
#' This function works under the hood in the `fast_rarefaction_curves` function; not recommended for user.
#' @param otu_vector vector of NON-NORMALIZED read counts for each OTU in a single sample
#' @param steps how many equally spaced steps to rarefy for each sample
#' @param iterations how many times alpha diversity should be calculated at each step for each sample
#' @param sample_id ID of sample for which the calculation is being performed
#' @param seed an integer to set the random seed
#' @returns a dataframe with estimated alpha diversity at three hill numbers (hill0 - hill2) at an specified number of equally spaced depths for that sample.

#' @importFrom extraDistr rmvhyper
#' @importFrom dplyr bind_rows
#' @importFrom purrr map
#'
#' @export
rarefy_sample <- function(otu_vector, steps, iterations, sample_id, seed){

  set.seed(seed)

  total <- sum(otu_vector)

  depths <- seq.int(from = 1, to = total, length.out = steps) %>% floor()

  map(depths, \(d){

    counts <- rmvhyper(iterations, otu_vector, d)

    rel_counts <- counts / d

    hill1 = exp(
      (rel_counts * log(rel_counts)) %>%
        rowSums(na.rm = TRUE)*(-1)
    )

    hill2 = 1 / rowSums(rel_counts * rel_counts)

    data.frame(sample_id = sample_id,
               depth = d,
               hill0 = rowSums(counts != 0),
               hill1 = hill1,
               hill2 = hill2)
  }) %>%
    bind_rows()
}

