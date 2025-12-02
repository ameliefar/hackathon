## 📁 data repository
This folder contains datasets used in app.R function. Importing function is already embedded in app.R but it is possible to import it directly using read.csv() or readr::read_csv().
---
  
## 📄 Main Files
- **`individual_data.csv`**  
  Simulated dataset containing counts of individuals by year, species, location, minimum age, and sex.
  
  | Variable      | Type                  | Description                                                                |
  | ------------- | --------------------- | -------------------------------------------------------------------------- |
  | `siteID`      | character (3 letters) | Study site identifier. No missing values.                                  |
  | `speciesID`   | character (6 letters) | Species code (genus + species). No missing values.                         |
  | `captureYear` | integer (4 digits)    | Year of capture. No missing values.                                        |
  | `minimumAge`  | integer (1–2 digits)  | Real age when known; otherwise minimum possible age based on capture info. |
  | `observedSex` | character (F/M/U/NA)  | Sex of the individual. Missing values allowed (`NA`).                      |
  | `n`           | integer               | Sample size per population for a given year.                               |
  

  
- **`site_codes.csv`**  
  SPI-Birds table with information about site locations.
  Current version available on SPI-Birds pipeline repository

  | Variable              | Type                  | Description                                                   |
  | --------------------- | --------------------- | ------------------------------------------------------------- |
  | `siteID`              | character (3 letters) | Study site identifier. No missing values.                     |
  | `siteName`            | character             | Name of the study site.                                       |
  | `country`             | character             | Country name. No missing values.                              |
  | `countryCode`         | character (2 letters) | Country ISO-like code. No missing values.                     |
  | `decimalLatitude`     | numeric               | Latitude in decimal degrees (WGS84). Missing values allowed.  |
  | `decimalLongitude`    | numeric               | Longitude in decimal degrees (WGS84). Missing values allowed. |
  | `locationAccordingTo` | character             | Source of geographic information.                             |
  

- **`species_codes.csv`**  
  SPI-Birds table with species-related information.
  Current version available on SPI-Birds pipeline repository
  
  | Variable                                            | Type                  | Description                                             |
  | --------------------------------------------------- | --------------------- | ------------------------------------------------------- |
  | `speciesCode`                                       | numeric (6 digits)    | SPI-Birds species code. No missing values.              |
  | `speciesID`                                         | character (6 letters) | SPI-Birds standard 1.0 species code. No missing values. |
  | `speciesEURINGcode`                                 | integer               | European bird ringing code. Missing values allowed.     |
  | `speciesCOLID`                                      | alphanumeric          | Catalogue of Life identifier. Missing values allowed.   |
  | `speciesEOLpageID`                                  | integer               | Encyclopedia of Life identifier. No missing values.     |
  | `kingdom` / `phylum` / `class` / `order` / `family` | character             | Taxonomic classification.                               |
  | `genus`                                             | character             | Genus name.                                             |
  | `specificEpithet`                                   | character             | Species epithet.                                        |
  | `scientificNameAuthorship`                          | character             | Reference describing the taxon concept.                 |
  | `vernacularName`                                    | character             | English common name.                                    |
  

- **`nest_data.csv`**  
  Dataset designed to provide an additional visualization related to breeding phenology.
  This dataset is based on real data but should be modified for simulated data encompassing more variation across species*
  
  | Variable                    | Type                   | Description                                                     |
  | --------------------------- | ---------------------- | --------------------------------------------------------------- |
  | `studyID`                   | alphanumeric (5 chars) | Population where data were collected. No missing values.        |
  | `speciesID`                 | character (6 letters)  | Species code. No missing values.                                |
  | `observedLayYear`           | integer (4 digits)     | Estimated laying year. Missing values allowed (`NA`).           |
  | `mean_clutch`               | integer                | Rounded mean number of eggs per clutch. Missing values allowed. |
  | `min_clutch` / `max_clutch` | integer                | Minimum / maximum clutch size. Missing values allowed.          |
  | `mean_brood`                | integer                | Rounded mean number of hatched chicks. Missing values allowed.  |
  | `min_brood` / `max_brood`   | integer                | Minimum / maximum brood size. Missing values allowed.           |
  | `mean_fledge`               | integer                | Rounded mean number of fledglings. Missing values allowed.      |
  | `min_fledge` / `max_fledge` | integer                | Minimum / maximum fledgling counts. Missing values allowed.     |
  | `n_row`                     | integer                | Sample size per population per year.                            |
  