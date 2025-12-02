#-----------------------------------------------------#
# Function to import data and add important variables #
#-----------------------------------------------------#

#' Packages
library('tidyverse')

#' Path to imported files
INDIVIDUAL_DATA_PATH <- "data/individual_data.csv"

SPECIES_CODE_PATH <- "data/species_codes.csv"

SITE_CODES_PATH <- "data/site_codes.csv"

#'Function to import dummy dataset
getdata_dummy <- function() {
  df <- readr::read_csv(INDIVIDUAL_DATA_PATH)
  species_code <- readr::read_csv(SPECIES_CODE_PATH)
  site_codes <- readr::read_csv(SITE_CODES_PATH)
  
  
  # Add vernacular name
  df <- df |>
    left_join(species_code |> select(speciesID, vernacularName), by = "speciesID")
  
  # Add site name
  df <- df |>
    left_join(site_codes |> select(siteID, siteName), by = "siteID")
  
  return(df)
}
