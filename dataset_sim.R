### ------------------------------------------------------------ ###
### Creating data simulation to the age distribution visualisation #
### ------------------------------------------------------------ ###

set.seed(123)

### -----------------------------------------------------------
### 1. Rules definition
### -----------------------------------------------------------

species_by_site <- list(
  AMM = c("STRALU", "CERBRA"),
  BAN = c("MACGIG"),
  CHO = c("STEHIR", "HAEOST"),
  HAR = c("STRALU", "CERBRA", "STEHIR"),
  KEV = c("STRALU", "CERBRA", "PARMAJ"),
  MIA = c("STRALU", "PARMAJ"),
  CAC = c("CERBRA", "PARMAJ")
)

year_ranges <- list(
  AMM = c(1935:1960, 1975:1990),
  BAN = 2010:2025,
  CHO = c(1978:2002, 2021:2025),
  HAR = 1995:2025,
  KEV = 2022:2025,
  MIA = 2017:2024,
  CAC = 1982:2019
)

age_ranges <- list(
  STRALU = 0:35,
  CERBRA = 0:10,
  MACGIG = 0:65,
  STEHIR = 0:22,
  HAEOST = 0:33,
  PARMAJ = 0:10
)


### -----------------------------------------------------------
### 2. Grid: 
###    - age=0 → observedSex = NA (1 row)
###    - age>0 → M + F (2 rows)
### -----------------------------------------------------------

df_list <- list()

for (site in names(species_by_site)) {
  for (sp in species_by_site[[site]]) {
    years <- year_ranges[[site]]
    ages  <- age_ranges[[sp]]
    
    for (yr in years) {
      for (age in ages) {
        
        if (age == 0) {
          df_list[[length(df_list)+1]] <- data.frame(
            siteID      = site,
            speciesID   = sp,
            captureYear = yr,
            minimumAge  = age,
            observedSex = NA,
            stringsAsFactors = FALSE
          )
          
        } else {
          for (sx in c("M", "F")) {
            df_list[[length(df_list)+1]] <- data.frame(
              siteID      = site,
              speciesID   = sp,
              captureYear = yr,
              minimumAge  = age,
              observedSex = sx,
              stringsAsFactors = FALSE
            )
          }
        }
      }
    }
  }
}

df <- do.call(rbind, df_list)
row.names(df) <- NULL


### -----------------------------------------------------------
### 3. Randomly adding rows with observedSex "U" when age > 0
###    - ~3% of combination → one suplementary "U" 
### -----------------------------------------------------------

# Setting rules to get unique combination for which it is possible to add "U"
combos <- unique(df[df$minimumAge > 0, c("siteID", "speciesID", "captureYear", "minimumAge")])

# Selecting combinations to be supplemented
prop_U <- 0.03   # proportion (adjustable if necessary)
n_U <- round(nrow(combos) * prop_U)

chosen <- combos[sample(nrow(combos), n_U), ]

# Creating "U" rows
df_U <- chosen
df_U$observedSex <- "U"

# Add them to dataset
df <- rbind(df, df_U)


### -----------------------------------------------------------
### 4. Generating n (theoretical values according to rules)
### -----------------------------------------------------------

generate_n_base <- function(sp, age) {
  
  if (age == 0) {
    if (sp == "STRALU") return(sample(30:50,1))
    if (sp == "CERBRA") return(sample(150:200,1))
    if (sp == "MACGIG") return(sample(50:200,1))
    if (sp == "STEHIR") return(sample(500:1897,1))
    if (sp == "HAEOST") return(sample(3000:12000,1))
    if (sp == "PARMAJ") return(sample(200:450,1))
  }
  
  if (sp == "STRALU") {
    if (age > 20) return(sample(0:10,1))
    return(sample(10:50,1))
  }
  
  if (sp == "CERBRA") {
    return(max(0, 50 - age*5))
  }
  
  if (sp == "MACGIG") {
    if (age > 40) return(sample(0:80,1))
    return(sample(50:200,1))
  }
  
  if (sp == "STEHIR") {
    if (age >= 10) return(sample(0:30,1))
    return(sample(20:100,1))
  }
  
  if (sp == "HAEOST") {
    if (age >= 17) return(sample(0:200,1))
    return(max(0, 500 - age*20))
  }
  
  if (sp == "PARMAJ") {
    if (age >= 1) return(max(0, 50 - age*4))
  }
  
  0
}

df$n_base <- mapply(generate_n_base, df$speciesID, df$minimumAge)


### -----------------------------------------------------------
### 5. Adding realistic stochasticity (log-normal function)
### -----------------------------------------------------------

sigma <- 0.25 # ~25% of variability
df$n <- round(df$n_base * exp(rnorm(nrow(df), 0, sigma)))

df$n[df$n < 0] <- 0

df$n_base <- NULL



### -----------------------------------------------------------
### 6. Saving dataframe as a csv file
### -----------------------------------------------------------


write.table(df, "data/individual_data.csv", 
            sep = ",", row.names = FALSE, fileEncoding = "UTF-8")

