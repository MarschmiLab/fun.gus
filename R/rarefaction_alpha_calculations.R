#' Calculate taxonomic and phylogenetic alpha diversity using rarefaction and hill numbers
#'
#' This function repeatedly rarefies a phyloseq object (usually containing 16S data) and calculates alpha diversity measures using Hill Divesity numbers. Can also calculate phylogenetic distance, if your phyloseq object contains a tree.
#' @param phy_object a phyloseq object containing an otu_table of feature counts
#' @param rarefy_depth read depth to rarefy to in each iteration; generally the read count of the sample with the fewest reads
#' @param iterations how many times the metric should be calculated before averaging; recommended minimum 100 up to 1000
#' @param method whether to calculate taxonomic or phylogenetic hill diversity numbers (or both). Acceptables values include "taxonomic","phylo", or "both"
#' @param seed an integer to set the random seed - required for reproducible calculations! Using set.seed will not be sufficient
#' @param threads how many threads to use. Optimum number will depend on your number of iterations. Generally if running 1000 iterations, I wouldn't use more than 20 threads.
#' @returns a dataframe with estimated diversity (qD) for hill numbers 0-2 for each sample.

#' @importFrom phyloseq rarefy_even_depth phy_tree taxa_are_rows
#' @importFrom future plan multisession
#' @importFrom furrr future_map furrr_options
#' @importFrom abind abind
#' @importFrom magrittr %>%
#' @importFrom dplyr mutate
#' @importFrom tidyr pivot_longer
#' @importFrom purrr map_dfr
#'
#' @export
rarefaction_alpha_calculations <- function(phy_object, rarefy_depth, iterations, method = "both", seed, threads){

  if(!method%in%c("both", "taxonomic", "phylo")){
    error("Method must be either 'both', 'taxonomic' or 'phylo'")
  }


  if(taxa_are_rows(phy_object)){
    input_maker <- function(phy){
      phy %>%
        otu_table() %>%
        data.frame() %>%
        t()
    }
    }else{

      input_maker <- function(phy){
        phy %>%
          otu_table() %>%
          data.frame()
    }
  }
  sam_sums <- sample_sums(phy_object)

  num_smaller <- sum(sam_sums < rarefy_depth)

  if(num_smaller > 0){
    warning(paste0("Sample sums for ",num_smaller," sample(s) are less than your rarefy_depth. Samples may be dropped"), immediate. = TRUE)
  }

  print(paste("Calculating", method, "diversity approaches on", deparse(substitute(phy_object))))

  if(method == "phylo"){

    q_nums <- c("Phylo_Richness" = 0, "Phylo_Shannon" = 1, "Phylo_Simpson" = 2)

    plan(multisession, workers = threads)

    res_list <- future_map(1:iterations, .options = furrr_options(seed=seed), .progress = TRUE, function(x){

      rare_physeq <- rarefy_even_depth(phy_object, sample.size = rarefy_depth, replace = FALSE, rngseed = FALSE, verbose = FALSE)

      input_df <- input_maker(rare_physeq)

      map_dfr(q_nums, \(.q)hill_phylo(input_df, phy_tree(rare_physeq), q = .q)) %>%
        as.matrix()

    })

    result <-  abind(res_list, along = 0) %>%
      apply(2:3, mean)%>%
      data.frame() %>%
      mutate(Measure = names(q_nums)) %>%
      pivot_longer(!Measure, names_to = "Sample", values_to = "qD")

  }else if (method == "taxonomic"){

    t_nums <- c("Richness" = 0, "Shannon" = 1, "Simpson" = 2)

    plan(multisession, workers = threads)

    res_list <- future_map(1:iterations, .options = furrr_options(seed=seed), .progress = TRUE, function(x){

      rare_physeq <- rarefy_even_depth(phy_object, sample.size = rarefy_depth, replace = FALSE, rngseed = FALSE, verbose = FALSE)

      input_df <- input_maker(rare_physeq)

      map_dfr(t_nums, \(.q)hill_taxa(input_df, q = .q)) %>%
        as.matrix()

    })


    result <-  abind(res_list, along = 0) %>%
      apply(2:3, mean)%>%
      data.frame() %>%
      mutate(Measure = names(t_nums)) %>%
      pivot_longer(!Measure, names_to = "Sample", values_to = "qD")


  }else{
    t_nums <- c("Richness" = 0, "Shannon" = 1, "Simpson" = 2)
    q_nums <- c("Phylo_Richness" = 0, "Phylo_Shannon" = 1, "Phylo_Simpson" = 2)

    plan(multisession, workers = threads)

    res_list <- future_map(1:iterations, .options = furrr_options(seed=seed), .progress = TRUE, function(x){

      rare_physeq <- rarefy_even_depth(phy_object, sample.size = rarefy_depth, replace = FALSE, rngseed = FALSE, verbose = FALSE)

      input_df <- input_maker(rare_physeq)

      tax_mat <- map_dfr(t_nums, \(.q)hill_taxa(input_df, q = .q)) %>%
        as.matrix()

      phylo_mat <- map_dfr(q_nums, \(.q)hill_phylo(input_df, phy_tree(rare_physeq), q = .q)) %>%
        as.matrix()

      rbind(tax_mat, phylo_mat)

    })

    result <-  abind(res_list, along = 0) %>%
      apply(2:3, mean)%>%
      data.frame() %>%
      mutate(Measure = c(names(t_nums), names(q_nums))) %>%
      pivot_longer(!Measure, names_to = "Sample", values_to = "qD")

  }
  if(num_smaller > 0){
    warning(paste0("Sample sums for ",num_smaller," sample(s) are less than your rarefy_depth. Samples may be dropped (this message is repeated)"), immediate. = TRUE)
  }
  return(result)
}
