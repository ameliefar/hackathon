### ---------------------------------------------------------
### Creating the dummy dataset with simulation
### ---------------------------------------------------------

set.seed(123)   # pour reproductibilité

# Nombre de lignes désirées
N <- 5000

# Variables catégorielles
siteID_levels <- c("AMM", "BAN", "CHO", "HAR", "HOC", "KEV", "MIA", "CAC")
species_levels <- c("STEHIR", "STRALU", "MACGIG", "HAEOST", "PARMAJ", "CERBRA")
sex_levels <- c("F", "M", "U")

# Fonction pour générer captureYear selon speciesID (distributions différentes)
gen_year_by_species <- function(species) {
  if (species %in% c("CERBRA", "PARMAJ")) {
    # espèces plus récentes
    return(sample(1980:2025, 1, prob = dpois(1:length(1980:2025), lambda=20)))
  } else if (species %in% c("HAEOST", "STRALU", "STEHIR")) {
    # espèces présentes longtemps
    return(sample(1935:2025, 1, prob = dnorm(1935:2025, mean=1980, sd=20)))
  } else {
    # MACGIG distribution intermédiaire
    return(sample(1950:2025, 1, prob = dnorm(1950:2025, mean=1990, sd=15)))
  }
}

# Fonction pour générer l'âge selon les contraintes
gen_age <- function(species) {
  if (species %in% c("CERBRA", "PARMAJ")) {
    return(sample(0:15, 1))
  } else if (species %in% c("HAEOST", "STRALU", "STEHIR")) {
    return(sample(0:35, 1))
  } else {
    return(sample(0:65, 1))  # cas général
  }
}

# Génération du tableau
data_sim <- data.frame(
  siteID       = sample(siteID_levels, N, replace = TRUE),
  speciesID    = sample(species_levels, N, replace = TRUE),
  observedSex  = sample(sex_levels, N, replace = TRUE),
  stringsAsFactors = FALSE
)

# Ajout des colonnes dépendant de speciesID
data_sim$captureYear <- sapply(data_sim$speciesID, gen_year_by_species)
data_sim$minimumAge  <- sapply(data_sim$speciesID, gen_age)

# Variable n entre 0 et 1500
data_sim$n <- sample(0:1500, N, replace = TRUE)

# Aperçu
head(data_sim)

write.table(data_sim, "data/individual_data.csv", sep = ",", row.names = FALSE, fileEncoding = "UTF-8")