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

``` r
list_metadata_names(path_to_data_dir)
```

## Arguments

| Argument           | Description                                                             |
|--------------------------------|----------------------------------------|
| `path_to_data_dir` | String, absolute or relative path to the SCHMIDT_LAB_DATA_LOG directory |

## Value

Character vector of data sheet names

## Examples

``` r
list_metadata_names("path/to/datasheets") # Find names of data sheets
```

# `load_schmidt_metadata`

Load Schmidt Lab Data_Log Files

`load_schmidt_metadata` helps you read in data from these sheets. You can specify which sheets you want to read in. To list available sheets, use [load_metadata_names](#loadmetadatanames) .

## Usage

``` r
load_schmidt_metadata(
  path_to_data_dir,
  name_vector = NULL,
  as_list = TRUE,
  project = NULL
)
```

## Arguments

| Argument           | Description                                                                               |
|--------------------------------|----------------------------------------|
| `path_to_data_dir` | String, absolute or relative path to the SCHMIDT_LAB_DATA_LOG directory                   |
| `name_vector`      | Optional string vector of data sheet names to load (otherwise loads all of them)          |
| `as_list`          | Logical, whether to bring in data sheets as a list, or as separate R objects.             |
| `project`          | Optional Project_ID; results will be filtered to that project (if relevant to data sheet) |

## Value

Either a list of tibbles or loads separate tibbles in your environment for each data sheet specified

## Examples

``` r
list_metadata_names("path/to/datasheets") # Find names of data sheets

load_schmidt_metadata("path/to/datasheets") # Read in an return all datasheets as a list of dataframes

load_schmidt_metadata("path/to/datasheets", name_vector = c("Station_Log","Deployment_Log","Freezer_Log")) # Only load in specified datasheets

load_schmidt_metadata("path/to/datasheets", as_list = FALSE) # Load datasheets as R objects, instead of as a list

load_schmidt_metadata("path/to/datasheets", project = "AAH") # Filter data sheets just for Project_ID AAH
```

# `make_wellmap_long`

Convert a "wide-formatted" 96-well plate map into long format

## Usage

``` r
make_wellmap_long()
```

This will launch an interactive Shiny session where you can enter values manually or copy and paste from Excel/Google Sheets

# `rarefaction_beta_calculations`

Calculate Distance Matrices at Specified Rarefaction Depth and Iteration Count

This function repeatedly rarefies a phyloseq object (usually containing 16S data) and calculates a given distance metric for a set number of iterations. The average distance is then computed for each comparison and the dissimilarity matrix is returned as a `dist` object.

## Usage

``` r
rarefaction_beta_calculations(
  phy_object, 
  rarefy_depth, 
  iterations, 
  method, 
  seed, 
  threads
)
```

## Arguments

| Argument       | Description                                                                                                                                                   |
|--------------------------------|----------------------------------------|
| `phy_object`   | a phyloseq object containing an otu_table of feature counts                                                                                                   |
| `rarefy_depth` | read depth to rarefy to in each iteration; generally the read count of the sample with the fewest reads                                                       |
| `iterations`   | how many times the metric should be calculated before averaging; recommended minimum 100 up to 1000                                                           |
| `method`       | a distance metric as listed in the phyloseq::distance() function; recommended "bray"                                                                          |
| `seed`         | an integer to set the random seed - required for reproducible calculations! Using set.seed will not be sufficient                                             |
| `threads`      | how many threads to use. Optimum number will depend on your number of iterations. Generally if running 10000 iterations, I wouldn't use more than 20 threads. |

## Value

a dist object with average distance between each sample

## Examples

``` r
# Calculate Bray-Curtis distance at a rarefied depth of 5000, 100 iterations, using 10 threads
bray_distance <- rarefaction_beta_calculations(phy_object = preprocessed_physeq, rarefy_depth = 5000, iterations = 100, method = "bray", seed = 031491, threads = 10)
```

# `rarefaction_alpha_calculations`

Calculate taxonomic and phylogenetic alpha diversity using rarefaction and hill numbers

This function repeatedly rarefies a phyloseq object (usually containing 16S data) and calculates alpha diversity measures using Hill Divesity numbers. Can also calculate phylogenetic distance, if your phyloseq object contains a tree.

## Usage

``` r
rarefaction_alpha_calculations(
  phy_object, 
  rarefy_depth, 
  iterations, 
  method = "both", 
  seed, 
  threads
)
```

## Arguments

| Argument       | Description                                                                                                                                                   |
|--------------------------------|----------------------------------------|
| `phy_object`   | a phyloseq object containing an otu_table of feature counts and (optionally) a phylogenetic tree with branch lengths                                          |
| `rarefy_depth` | read depth to rarefy to in each iteration; generally the read count of the sample with the fewest reads                                                       |
| `iterations`   | how many times the metric should be calculated before averaging; recommended minimum 100 up to 1000                                                           |
| `method`       | whether to calculate taxonomic or phylogenetic hill diversity numbers (or both). Acceptables values include "taxonomic","phylo", or "both"                    |
| `seed`         | an integer to set the random seed - required for reproducible calculations! Using set.seed will not be sufficient                                             |
| `threads`      | how many threads to use. Optimum number will depend on your number of iterations. Generally if running 10000 iterations, I wouldn't use more than 20 threads. |

## Value

A dataframe with estimated diversity (qD) for Hill numbers 0-2 for each sample.
