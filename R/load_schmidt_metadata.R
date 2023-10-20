#' Load Schmidt Lab Data_Log Files
#'
#' Our lab metadata is stored in a Google Sheet \href{https://docs.google.com/spreadsheets/d/1fuiuulXpJf7foikNzMMIkFyYfYsHiCYYjmj4mWTMzss/edit?usp=sharing}{(SCHMIDT_LAB_DATA_LOG)}, which is then exported to CSV files into a \href{https://github.com/MarschmiLab/SCHMIDT_LAB_DATA_LOG}{Github repo.} To use these metadata, you should clone that repo onto your computer, pull before doing any analysis, and then read those CSVs into your R session. `load_schmidt_metadata` helps you read in data from these sheets. You can specify which sheets you want to read in. To list available sheets, use \link{load_metadata_names}.
#' @param path_to_data_dir String, absolute or relative path to the SCHMIDT_LAB_DATA_LOG directory
#' @param name_vector Optional string vector of data sheet names to load (otherwise loads all of them)
#' @param as_list Logical, whether to bring in data sheets as a list, or as separate R objects.
#' @param project Optional Project_ID; results will be filtered to that project (if relevant to data sheet)
#' @returns Either a list of tibbles or loads separate tibbles in your environment for each data sheet specified
#' @importFrom purrr keep
#' @importFrom purrr map
#' @importFrom readr read_csv
#' @importFrom dplyr filter
#' @importFrom stringr str_remove
#' @export
load_schmidt_metadata <- function(path_to_data_dir, name_vector = NULL, as_list = TRUE, project = NULL){

    datalog_files <- list.files(path_to_data_dir, pattern = "*.csv", full.names = TRUE) # Find data log files

    names(datalog_files) <- str_remove(basename(datalog_files), ".csv") # Get clean file names

    if(is.null(name_vector)){
      names_to_keep <- names(datalog_files) # If no names supplied, use all names (load all sheets)
    }else{
      names_to_keep <- name_vector
    }

    relevant_files <- keep(datalog_files, names(datalog_files)%in%names_to_keep) # Filter for relevant data files

    data_dfs <- map(relevant_files, read_csv) # Read in relevant data files as tibbles

    if(!is.null(project)){
      data_dfs <- map(data_dfs, function(df){ # If filtering for a project, search through and filter dataframes
        columns <- names(df)
        if("Project_ID"%in%c(columns)){
          return(dplyr::filter(df, Project_ID==project))
        }else{
          return(df)
        }
      })
    }

    if(!as_list){
      list2env(data_dfs, envir = .GlobalEnv) # If not returning as a list, load into global environment
      return("Done!")
    }

    return(data_dfs)
}

#' Find names of data sheets in SCHMIDT_LAB_DATA_LOG
#'
#' Our lab metadata is stored in a Google Sheet \href{https://docs.google.com/spreadsheets/d/1fuiuulXpJf7foikNzMMIkFyYfYsHiCYYjmj4mWTMzss/edit?usp=sharing}{(SCHMIDT_LAB_DATA_LOG)}, which is then exported to CSV files into a \href{https://github.com/MarschmiLab/SCHMIDT_LAB_DATA_LOG}{Github repo.} To use these metadata, you should clone that repo onto your computer, pull before doing any analysis, and then read those CSVs into your R session. This function returns a character vector of the available data sheets.
#' @param path_to_data_dir String, absolute or relative path to the SCHMIDT_LAB_DATA_LOG directory
#' @returns Character vector of data sheet names
#' @importFrom stringr str_remove
#' @export
list_metadata_names <- function(path_to_data_dir){

  datalog_files <- list.files(path_to_data_dir, pattern = "*.csv", full.names = TRUE) # Find data log files

  return(str_remove(basename(datalog_files), ".csv")) # Get clean file names
}
