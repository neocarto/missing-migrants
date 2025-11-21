# ----------------------------
# DATA IMPORT SCRIPT
# ----------------------------
# 1993 - 1999 (United)

united <- read.csv("../data/Sources/United/United_before2000.csv")
united <- data.frame(
  year  = as.integer(united$year),
  cause = united$cause,
  lat   = as.numeric(united$latitude),
  lng   = as.numeric(united$longitude),
  nb    = as.integer(united$dead_and_missing)
)

# 2000 - 2013 (The migrants file)

migrantsfile <- read.csv("../data/Sources/TheMigrantsFile/DISCONTINUED ON JUNE 24, 2016 - Events during which someone died trying to reach or stay in Europe - Events.csv")
migrantsfile[migrantsfile$latitude == 26.3351 & migrantsfile$longitude == 17.228331, c("latitude", "longitude")] <- c(30, 17.228331) # patch
head(migrantsfile)
migrantsfile <- data.frame(
  year  = as.integer(migrantsfile$Year),
  cause = migrantsfile$cause_of_death,
  lat   = as.numeric(migrantsfile$latitude),
  lng   = as.numeric(migrantsfile$longitude),
  nb    = as.integer(migrantsfile$dead_and_missing)
)

migrantsfile <- migrantsfile[migrantsfile$year < 2014 & !is.na(migrantsfile$year), ]

# 2014 - now (IOM)

source("../data/Sources/IOM/download.R") # download
iom <- read.csv("../data/Sources/IOM/Missing_Migrants_Global_Figures_allData.csv")
coords <- do.call(rbind, strsplit(iom$Coordinates, ","))
iom <- data.frame(
  year  = as.integer(iom$`Incident.Year`),
  cause = iom$`Cause.of.Death`,
  lat   = as.numeric(coords[, 1]),
  lng   = as.numeric(coords[, 2]),
  nb    = as.integer(iom$`Total.Number.of.Dead.and.Missing`)
)
iom <- iom[iom$nb > 0, ]

# Merge all data

data <- rbind(united, migrantsfile, iom)

# Handle categories

categories <- list(
  list(
    type = 1,
    fr = "Noyade",
    en = "drowning",
    color = "#58ABD3",
    texts = c("Noyade", "drowned", "Drowning", "Drowning,Vehicle accident / death linked to hazardous transport")
  ),
  list(
    type = 2,
    fr = "Suicide",
    en = "Suicide",
    color = "#F8E91F",
    texts = c(
      "Suicide", "suicide - hanged", "suicide", "suicide - put on fire",
      "suicide - under train", "suicide - hungerstrike", "suicide - jumped from train",
      "suicide - jumped in water", "suicide - jumped from building", "suicide - other"
    )
  ),
  list(
    type = 3,
    fr = "Asphyxie",
    en = "Suffocation",
    color = "#6B2265",
    texts = c("Asphyxie", "asphyxiated")
  ),
  list(
    type = 4,
    fr = "Mort de faim, de soif, de froid ou d'épuisement",
    en = "Exhaustion, starving, thirst or freezing to death",
    color = "#1C7532",
    texts = c(
      "Mort de faim, de soif ou de froid", "starved", "frozen", "exhaustion",
      "died from dehydration", "heat exhaustion", "starved or died from dehydration",
      "hypothermia and dehydration", "hypothermia", "Harsh environmental conditions / lack of adequate shelter, food, water"
    )
  ),
  list(
    type = 5,
    fr = "Homicide, torture, absence de soin, violences policières",
    en = "Arson, homicide, torture, lack of care, police brutality",
    color = "#F49919",
    texts = c(
      "Incendie criminel, homicide, absence de soins", "tortured", "executed", "Violence",
      "died of kidney failure", "burned", "died (presumably) from ill treatments", "murdered",
      "killed by bomb", "shot", "heart failure", "lack of medical care", "died in childbirth",
      "burned or asphyxiated due to arson attack", "wrong medical treatment, overdose", "illness",
      "Sickness / lack of access to adequate healthcare", "police violence", "shot by the police"
    )
  ),
  list(
    type = 6,
    fr = "Empoisonnement, Champ de mine, accident, autre",
    en = "Poisoning, Minefield, accident, other",
    color = "#637A84",
    texts = c(
      "Empoisonnement", "Empoisonnement, champ de mise, accident, autre", "unknown",
      "Mixed or unknown", "died of suddent infant death", "car accident", "blown in minefield",
      "Accidental death", "run over by a bus", "run over by a car", "crushed", "fall",
      "Vehicle accident / death linked to hazardous transport", "run over by a truck",
      "run over", "run over by a train", "bled to death due to barbed wire",
      "died because of dangerous undeclared work", "died of a shock", "died after a fight",
      "attacked by animals", "electrocuted"
    )
  )
)

map_category <- function(cause_name, categories) {
  for (cat in categories) {
    if (any(sapply(cat$texts, function(x) grepl(x, cause_name, ignore.case = TRUE)))) {
      return(list(
        type = cat$type,
        fr = cat$fr,
        en = cat$en,
        color = cat$color
      ))
    }
  }
  return(list(
    type = NA,
    fr = NA,
    en = NA,
    color = NA
  ))
}

mapped <- lapply(data$cause, map_category, categories = categories)
mapped_df <- do.call(rbind, lapply(mapped, as.data.frame))
data <- cbind(data, mapped_df)

# Export

write.csv(data, "../data/data.csv")

# Date update log
writeLines(as.character(Sys.Date()), "../data/last_update.txt")
