#' Interactively Define Gates for Flow Cytometry Flow Set
#'
#' This function launches a Shiny app wherein you can interactively define gates for a flow cytometry flow set. Produce your flowset using flowCore::read.flowSet(). Use drop-down menus to select axes for your plots. Click on the plots to draw your gate. Use the Remove Point button to remove vertices, in reverse order that you created them. The Gate Name text input will determine the name of the polygon gate you will create; as such it must follow R guidelines for naming objects. Use Export button to save the gave as an .RData file, which will create a polygonGate as defined by flowCore.
#' @param flo_set A flow set produced using `flowCore::read.flowSet()`
#' @returns Opens a a shiny app where you can interactively define gates and export them as an .RData object.
#'
#' @importFrom flowCore sampleNames pData
#'
#' @export
rename_flowset_samples <- function(flo_set, new_names){
  if(length(new_names) != length(flowCore::sampleNames(flo_set))){
    stop("Length of new_names doesn't match number of samples in flowset. Needed ", length(flowCore::sampleNames(flowset))," new names, ", length(new_names), " provided")
  }
  flo_copy <- flo_set
  flowCore::pData(flo_copy)$name <- new_names
  return(flo_copy)
}
