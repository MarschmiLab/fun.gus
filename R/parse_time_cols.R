#' Parse the terrible export of date times from our Data Log
#'
#' You have probably noticed the Google Data log backups have very weird export formats. This function helps parse them to more usable times. This function is just extracted the time from a poorly formatted time column; if you want the full date time, you'll need to parse and combine a date column after using this function to get a clean time column.
#' @param dataframe Your dataframe (or tibble)
#' @param bad_column The poorly formatted time column, not in quotes. Values of this column usually start with "Sat Dec 30".
#' @param new_name The name for your new, well-formatted column, not in quotes.
#' @returns A dataframe with the bad column removed and a fresh column inserted.
#' @importFrom dplyr mutate
#' @importFrom dplyr select
#' @importFrom tidyr separate
#' @importFrom lubridate as_datetime
#' @importFrom magrittr %>%
#' @importFrom rlang enquo
#' @export
parse_time_cols <- function(dataframe, bad_column, new_name){
  bc = enquo(bad_column)
  nn = enquo(new_name)

  dataframe %>%
    tidyr::separate(!!bc,  sep = " ", extra = "drop",into = c("Weekday", "Month", "Day", "Year", "Time", "Tmz"))%>%
    dplyr::mutate(!!nn := lubridate::as_datetime(Time, format = "%H:%M:%S"))%>%
    dplyr::select(-Weekday, -Month, -Day, -Year, -Time,  - Tmz)
}
