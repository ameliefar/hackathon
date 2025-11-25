#' Data wrangling function

library('tidyverse')

INDIVIDUAL_DATA_PATH <- "data/individual_data.csv"

#'Function to import dummy dataset
getdata_dummy <- function(file = '') {
  if(missing(file)) file <- INDIVIDUAL_DATA_PATH
  read.table(file, sep = ",", header = T, fileEncoding = "UTF-8")
}
