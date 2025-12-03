# :bird: SPI-Birds Hackathon — November 25–26, 2025

This repository was created during a hackathon aimed at developing an interactive *Shiny App* to visualize *age distribution* across different bird species and locations.  
The objective was to build a simple tool to illustrate differences in *life-history strategies*, using *long-term monitoring data* in birds.

---

# 1. Repository Structure

## 1.1 *`data/`* — datasets used in the project

- *`individual_data.csv`*  
- *`site_codes.csv`*  
- *`species_codes.csv`*  
- *`nest_data.csv`*  

---

## ▶️ Detailed *data/* repository  
(*Click to expand*)

<details>
<summary><strong>📁 data repository (click)</strong></summary>

This folder contains datasets used in *app.R*. Importing function is already embedded in *app.R* but it is possible to import files directly using `read.csv()` or `readr::read_csv()`.

---

## **individual_data.csv**

Simulated dataset containing counts of individuals by year, species, location, minimum age, and sex.

| Variable      | Type                  | Description                                                                |
| ------------- | --------------------- | -------------------------------------------------------------------------- |
| `siteID`      | character (3 letters) | Study site identifier. No missing values.                                  |
| `speciesID`   | character (6 letters) | Species code (genus + species). No missing values.                         |
| `captureYear` | integer (4 digits)    | Year of capture. No missing values.                                        |
| `minimumAge`  | integer (1–2 digits)  | Real age when known; otherwise minimum possible age.                       |
| `observedSex` | character (F/M/U/NA)  | Sex of the individual. Missing values allowed (`NA`).                      |
| `n`           | integer               | Sample size per population per year.                                       |

---

## **site_codes.csv**

SPI-Birds table with information about site locations.  
Current version available on the SPI-Birds pipeline repository.

| Variable              | Type                  | Description                                                   |
| --------------------- | --------------------- | ------------------------------------------------------------- |
| `siteID`              | character (3 letters) | Study site identifier. No missing values.                     |
| `siteName`            | character             | Name of the study site.                                       |
| `country`             | character             | Country name. No missing values.                              |
| `countryCode`         | character (2 letters) | Country ISO-like code. No missing values.                     |
| `decimalLatitude`     | numeric               | Latitude (WGS84). Missing values allowed.                     |
| `decimalLongitude`    | numeric               | Longitude (WGS84). Missing values allowed.                    |
| `locationAccordingTo` | character             | Source of geographic information.                             |

---

## **species_codes.csv**

SPI-Birds table with species-related information.  
Current version available on the SPI-Birds pipeline repository.

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

---

## **nest_data.csv**

Dataset designed to provide an additional visualization related to breeding phenology.  
Based on real data but should be modified for simulated data with more variation across species.

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

</details>

---

# 2. Main Files

- *`app.R`*  
  Code required to run the Shiny application.

- *`dataset_sim.R`*  
  Script used to generate the simulated *individual_data* dataset.

- *`getdata_function.R`*  
  Function used to import and process data.
  
---

# 3. How to Run the App

You will need *R* and the *Shiny* package installed.

## 3.1 Install required packages

```r
install.packages(c("shiny", "tidyverse"))
