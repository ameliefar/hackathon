# 🐦 SPI-Birds Hackathon — November 25–26, 2025

This repository was created during a hackathon aimed at developing an interactive **Shiny App** to visualize **age distribution** across different bird species and locations.  
The objective was to build a simple tool to illustrate differences in **life-history strategies**, using **long-term monitoring data** in birds.

---

## 📁 Repository Structure

### **`data/`** — Datasets used in the project
- **`individual_data.csv`**  
  Simulated dataset containing counts of individuals by year, species, location, minimum age, and sex.
- **`site_codes.csv`**  
  SPI-Birds table with information about site locations.
- **`species_codes.csv`**  
  SPI-Birds table with species-related information.
- **`nest_data.csv`**  
  Dataset designed to provide an additional visualization related to breeding phenology.
- **`readme.md`**
  readme file detailing variables within each csv file

---

## 📄 Main Files

- **`app.R`**  
  Code required to run the Shiny application.

- **`dataset_sim.R`**  
  Script used to generate the simulated `individual_data` dataset.

- **`getdata_function.R`**  
  Function used to import and process data.

- **`hackathon.Rproj`**  
  RProject file associated with this repository.

---

## 🚀 How to Run the App

You will need **R** and the **Shiny** package installed.

### **1. Install required packages**
If necessary, install Shiny and other dependencies:

```r
install.packages(c("shiny", "tidyverse"))
