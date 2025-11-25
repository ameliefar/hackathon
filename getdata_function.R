#' Data wrangling function

library('tidyverse')

PATH <- "data/individual_data.csv"

#'Function to import dummy dataset
getdata_dummy <- function(file = PATH) {
  if(missing(file)) file <- PATH
  read.table(file, sep = ",", header = T, fileEncoding = "UTF-8")
}


#'NA in minimal age that we should get rid of
#'U & NA in observedSex
#'
df 