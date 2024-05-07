#' Reorder categorical variables via hierarchical clustering for plotting heat maps.
#'
#' Often in heatmaps, we want to reorder our rows and columns via hierarchical clustering. This function takes in your dataframe and outputs a new dataframe, where your categorical variables have been converted to factors. The levels of these factors are the order of samples in a dendrogram. If wanted, this function can also return the dendrograms, for later plotting.
#' @param data A dataframe
#' @param grouping_var1 The first categorical variable you'd like to reorder, as a string (in quotes!)
#' @param grouping_var2 The second categorical variable you'd like to reorder (you can prevent reordering this variable by setting `order_both` to false).
#' @param count_var The continuous variable which will fill your heatmap
#' @param order_both Should both grouping_var1 and grouping_var2 be reordered? If false (default), only grouping_var1 is reordered.
#' @param value_fill Value to fill in for level combinations which don't have observations. Defaults to NULL (no filling).
#' @param return_dendro Should the dendrogram also be returned, in addition to the reordered dataframe? If false (the default) returns the dataframe with converted columns. If true, returns a list, in which `reord_df` holds the reordered dataframe, and `dendrogram` holds the dendrogram. If both grouping variables were reordered, the list will include `dendrogram1` for `grouping_var1` and `dendrogram2` for `grouping_var2`.
#' @returns Either a dataframe whose grouping columns have been converted to factors whose levels are in the same order as a hierarchical clustering dendrogram, or (if `return_dendro = TRUE`) a list holding the reordered dataframe as well as the computed dendrogram(s).
#' @importFrom tidyr pivot_wider
#' @importFrom dplyr one_of
#' @importFrom magrittr %>%
#' @export
reorder_variable_by_clustering <- function(data,
                                           grouping_var1,
                                           grouping_var2,
                                           count_var,
                                           order_both = FALSE,
                                           value_fill = NULL,
                                           return_dendro = FALSE) {
  if(!(is.character(data[[grouping_var1]])|is.character(data[[grouping_var1]]))){
    stop("Grouping variables should be characters, without non-standard symbols.")
  }

  if(!is.numeric(data[[count_var]])){
    stop("Count var should be numerical")
  }

  if (order_both) {
    if (is.null(value_fill)) {
      wide1 <- data[c(grouping_var1, grouping_var2, count_var)] %>%
        pivot_wider(names_from = one_of(grouping_var2),
                    values_from = one_of(count_var))

      wide2 <- data[c(grouping_var1, grouping_var2, count_var)] %>%
        pivot_wider(names_from = one_of(grouping_var1),
                    values_from = one_of(count_var))
    } else{
      wide1 <- data[c(grouping_var1, grouping_var2, count_var)] %>%
        pivot_wider(
          names_from = one_of(grouping_var2),
          values_from = one_of(count_var),
          values_fill = value_fill
        )
      wide2 <- data[c(grouping_var1, grouping_var2, count_var)] %>%
        pivot_wider(
          names_from = one_of(grouping_var1),
          values_from = one_of(count_var),
          values_fill = value_fill
        )
    }
  } else{
    if (is.null(value_fill)) {
      wide <- data[c(grouping_var1, grouping_var2, count_var)] %>%
        pivot_wider(names_from = one_of(grouping_var2),
                    values_from = one_of(count_var))
    } else{
      wide <- data[c(grouping_var1, grouping_var2, count_var)] %>%
        pivot_wider(
          names_from = one_of(grouping_var2),
          values_from = one_of(count_var),
          values_fill = value_fill
        )
    }
  }

  if (order_both) {
    dendrogram1 <- wide1 %>%
      dist() %>%
      hclust() %>%
      as.dendrogram()

    order_indices1 <- dendrogram1 %>%
      order.dendrogram()

    data[grouping_var1] <-
      factor(data[[grouping_var1]], levels = wide1[[grouping_var1]][order_indices1])

    dendrogram2 <- wide2 %>%
      dist() %>%
      hclust() %>%
      as.dendrogram()

    order_indices2 <- dendrogram2 %>%
      order.dendrogram()

    data[grouping_var2] <-
      factor(data[[grouping_var2]], levels = wide2[[grouping_var2]][order_indices2])


    if (return_dendro) {
      return(list(
        reord_df = data,
        dendrogram1 = dendrogram1,
        dendrogram2 = dendrogram2
      ))
    } else{
      return(data)
    }

  } else{
    dendrogram <- wide %>%
      dist() %>%
      hclust() %>%
      as.dendrogram()

    order_indices <- dendrogram %>%
      order.dendrogram()

    data[grouping_var1] <-
      factor(data[[grouping_var1]], levels = wide[[grouping_var1]][order_indices])



    if (return_dendro) {
      return(list(reord_df = data,
                  dendrogram = dendrogram))
    } else{
      return(data)
    }
  }
}
