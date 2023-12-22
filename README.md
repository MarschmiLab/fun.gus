# fun.gus
An R package with functions Gus has written to help data analysis. 

# To install:
```
if (!requireNamespace("devtools", quietly=TRUE))
    install.packages("devtools")
devtools::install_github("MarschmiLab/fun.gus")
```

# `list_metadata_names`

Find names of data sheets in SCHMIDT_LAB_DATA_LOG


## Description

Our lab metadata is stored in a Google Sheet [(SCHMIDT_LAB_DATA_LOG)](https://docs.google.com/spreadsheets/d/1fuiuulXpJf7foikNzMMIkFyYfYsHiCYYjmj4mWTMzss/edit?usp=sharing) , which is then exported to CSV files into a [Github repo.](https://github.com/MarschmiLab/SCHMIDT_LAB_DATA_LOG) To use these metadata, you should clone that repo onto your computer, pull before doing any analysis, and then read those CSVs into your R session. This function returns a character vector of the available data sheets.


## Usage

```r
list_metadata_names(path_to_data_dir)
```


## Arguments

Argument      |Description
------------- |----------------
`path_to_data_dir`     |     String, absolute or relative path to the SCHMIDT_LAB_DATA_LOG directory


## Value

Character vector of data sheet names


## Examples

```r
list_metadata_names("path/to/datasheets") # Find names of data sheets
```

# `load_schmidt_metadata`

Load Schmidt Lab Data_Log Files

`load_schmidt_metadata` helps you read in data from these sheets. You can specify which sheets you want to read in. To list available sheets, use [load_metadata_names](#loadmetadatanames) .


## Usage

```r
load_schmidt_metadata(
  path_to_data_dir,
  name_vector = NULL,
  as_list = TRUE,
  project = NULL
)
```


## Arguments

Argument      |Description
------------- |----------------
`path_to_data_dir`     |     String, absolute or relative path to the SCHMIDT_LAB_DATA_LOG directory
`name_vector`     |     Optional string vector of data sheet names to load (otherwise loads all of them)
`as_list`     |     Logical, whether to bring in data sheets as a list, or as separate R objects.
`project`     |     Optional Project_ID; results will be filtered to that project (if relevant to data sheet)


## Value

Either a list of tibbles or loads separate tibbles in your environment for each data sheet specified


## Examples

```r
list_metadata_names("path/to/datasheets") # Find names of data sheets

load_schmidt_metadata("path/to/datasheets") # Read in an return all datasheets as a list of dataframes

load_schmidt_metadata("path/to/datasheets", name_vector = c("Station_Log","Deployment_Log","Freezer_Log")) # Only load in specified datasheets

load_schmidt_metadata("path/to/datasheets", as_list = FALSE) # Load datasheets as R objects, instead of as a list

load_schmidt_metadata("path/to/datasheets", project = "AAH") # Filter data sheets just for Project_ID AAH

# `make_wellmap_long`

Convert a "wide-formatted" 96-well plate map into long format

## Usage

```r
make_wellmape_long()
```

This will launch an interactive Shiny session where you can enter values manually or copy and paste from Excel/Google Sheets.
```


