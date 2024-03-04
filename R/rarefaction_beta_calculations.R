#' Calculate Distance Matrices at Specified Rarefaction Depth and Iteration Count
#'
#' This function repeatedly rarefies a phyloseq object (usually containing 16S data) and calculates a given distance metric for a set number of iterations. The average distance is then computed for each comparison and the dissimilarity matrix is returned as a `dist` object.
#' @param phy_object a phyloseq object containing an otu_table of feature counts
#' @param rarefy_depth read depth to rarefy to in each iteration; generally the read count of the sample with the fewest reads
#' @param iterations how many times the metric should be calculated before averaging; recommended minimum 100 up to 1000
#' @param method a distance metric as listed in the phyloseq::distance() function OR method = "sorensen" (which runs method = 'bray', binary = TRUE under the hood).
#' @param seed an integer to set the random seed - required for reproducible calculations! Using set.seed will not be sufficient
#' @param threads how many threads to use. Optimum number will depend on your number of iterations. Generally if running 1000 iterations, I wouldn't use more than 20 threads.
#' @returns a dist object with average distance between each sample
#' @examples
#' # Calculate Bray-Curtis distance at a rarefied depth of 5000, 100 iterations, using 10 threads
#' bray_distance <- rarefaction_beta_calculations(phy_object = preprocessed_physeq, rarefy_depth = 5000, iterations = 100, method = "bray", seed = 031491, threads = 10)
#'
#' @importFrom phyloseq rarefy_even_depth distance nsamples
#' @importFrom future plan multisession
#' @importFrom furrr future_map furrr_options
#' @importFrom abind abind
#' @importFrom magrittr %>%
#'
#' @export
rarefaction_beta_calculations <- function(phy_object, rarefy_depth, iterations, method, seed, threads){

  sam_sums <- sample_sums(phy_object)

  num_smaller <- sum(sam_sums < rarefy_depth)

  if(num_smaller > 0){
    warning(paste0("Sample sums for ",num_smaller," sample(s) are less than your rarefy_depth. Samples may be dropped"), immediate. = TRUE)
  }

  print(paste("Calculating", method, "distance on", deparse(substitute(phy_object))))

  if(method != "sorensen"){

  samples <- nsamples(phy_object)

  plan(multisession, workers = threads)

  res_list <- future_map(1:iterations, .options = furrr_options(seed=seed), .progress = TRUE, function(x){
    rarefy_even_depth(phy_object, sample.size = rarefy_depth, replace = FALSE, rngseed = FALSE, verbose = FALSE) %>%
      phyloseq::distance(method = method)%>%
      as.matrix()

  })

  result <-  abind(res_list, along = 0) %>%
    apply(2:3, mean)%>%
    as.dist()

  }else{
    samples <- nsamples(phy_object)

    plan(multisession, workers = threads)

    res_list <- future_map(1:iterations, .options = furrr_options(seed=seed), .progress = TRUE, function(x){
      rarefy_even_depth(phy_object, sample.size = rarefy_depth, replace = FALSE, rngseed = FALSE, verbose = FALSE) %>%
        phyloseq::distance(method = "bray", binary = TRUE)%>%
        as.matrix()

    })

    result <-  abind(res_list, along = 0) %>%
      apply(2:3, mean)%>%
      as.dist()


  }
  if(num_smaller > 0){
    warning(paste0("Sample sums for ",num_smaller," sample(s) are less than your rarefy_depth. Samples may be dropped (this message is repeated)"), immediate. = TRUE)
  }
  return(result)
}
