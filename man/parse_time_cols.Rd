% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/parse_time_cols.R
\name{parse_time_cols}
\alias{parse_time_cols}
\title{Parse the terrible export of date times from our Data Log}
\usage{
parse_time_cols(dataframe, bad_column, new_name)
}
\arguments{
\item{dataframe}{Your dataframe (or tibble)}

\item{bad_column}{The poorly formatted time column, not in quotes. Values of this column usually start with "Sat Dec 30".}

\item{new_name}{The name for your new, well-formatted column, not in quotes.}
}
\value{
A dataframe with the bad column removed and a fresh column inserted.
}
\description{
You have probably noticed the Google Data log backups have very weird export formats. This function helps parse them to more usable times. This function is just extracted the time from a poorly formatted time column; if you want the full date time, you'll need to parse and combine a date column after using this function to get a clean time column.
}
