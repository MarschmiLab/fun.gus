#' Launch an interactive webpage to convert well maps to long format
#'
#' There are no arguments for this function, as it launches a Shiny app for user input. You can either input values directly by double clicking on cells, or paste data
#' from Excel or Google Sheets. If pasting from Excel/Google Sheets, only copy well values, not headers (column numbers) or row names (letters like A, B, etc.)
#'
#' There are buttons on the bottom to download long-converted data to .csv or .txt (tab delimited) files.
#'
#' @examples
#' make_wellmap_long() # Launch shiny app
#'
#' @export
make_wellmap_long <- function() {
  appDir <- system.file("myapp", package = "fun.gus")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `fun.gus`.", call. = FALSE)
  }

  shiny::runApp(appDir, display.mode = "normal")
}
