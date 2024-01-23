#' Calculate Distance Matrices at Specified Rarefaction Depth and Iteration Count
#'
#' This function repeatedly rarefies a phyloseq object (usually containing 16S data) and calculates a given distance metric for a set number of iterations. The average distance is then computed for each comparison and the dissimilarity matrix is returned as a `dist` object.
#' @param phy_object a phyloseq object containing an otu_table of feature counts
#' @param rarefy_depth read depth to rarefy to in each iteration; generally the read count of the sample with the fewest reads
#' @param iterations how many times the metric should be calculated before averaging; recommended minimum 100 up to 1000
#' @param method a distance metric as listed in the phyloseq::distance() function; recommended "bray"
#' @param seed an integer to set the random seed - required for reproducible calculations! Using set.seed will not be sufficient
#' @param threads how many threads to use. Optimum number will depend on your number of iterations. Generally if running 10000 iterations, I wouldn't use more than 20 threads.
#' @returns a dist object with average distance between each sample
#' @examples
#' # Calculate Bray-Curtis distance at a rarefied depth of 5000, 100 iterations, using 10 threads
#' bray_distance <- rarefaction_beta_calculations(phy_object = preprocessed_physeq, rarefy_depth = 5000, iterations = 100, method = "bray", seed = 031491, threads = 10)
#'
#' @importFrom phyloseq rarefy_even_depth distance nsamples
#' @importFrom future plan
#' @importFrom furrr future_map
#' @importFrom abind abind
#' @importFrom magrittr %in%
#'
#' @export
rarefaction_beta_calculations <- function(phy_object, rarefy_depth, iterations, method, seed, threads){

  print(paste("Calculating", method, "distance on", deparse(substitute(phy_object))))
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

  return(result)

}
