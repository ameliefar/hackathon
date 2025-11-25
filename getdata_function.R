#' Data wrangling function

library('tidyverse')

INDIVIDUAL_DATA_PATH <- "data/individual_data.csv"

SPECIES_CODE_PATH <- "data/species_codes.csv"

SITE_CODES_PATH <- "data/site_codes.csv"

#'Function to import dummy dataset
getdata_dummy <- function() {
  df <- readr::read_csv(INDIVIDUAL_DATA_PATH)
  species_code <- readr::read_csv(SPECIES_CODE_PATH)
  site_codes <- readr::read_csv(SITE_CODES_PATH)
  
  # Retirer le suffixe de studyID pour obtenir siteID
  df <- df |>
    mutate(siteID = sub("-.*$", "", studyID))
  
  # Ajouter le nom vernaculaire
  df <- df |>
    left_join(species_code |> select(speciesID, vernacularName), by = "speciesID")
  
  # Ajouter le nom du site
  df <- df |>
    left_join(site_codes |> select(siteID, siteName), by = "siteID")
  
  return(df)
}
