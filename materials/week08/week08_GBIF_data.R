# =====================================================================
#  Spatial Ecology  ·  Week 8
#  GBIF occurrence data: download, clean and check for bias
# =====================================================================
#  Files in data/: gbif_lullula_arborea_raw.csv, montfred.gpkg
#  Packages: install.packages(c("rgbif", "CoordinateCleaner", "sf", "tidyverse"))
#
#  Species: woodlark (Lullula arborea).
#  The class file imitates a GBIF download for the (fictitious) Sierra
#  de Montfred, with typical errors added on purpose.
# =====================================================================

library(tidyverse)
library(sf)
library(CoordinateCleaner)


# ---------------------------------------------------------------------
# 1. Downloading from GBIF with rgbif (needs internet)
# ---------------------------------------------------------------------
# Set run_gbif to TRUE to try a real download. occ_search() is for
# exploring (max 100,000 records). For a paper use occ_download(),
# which needs a GBIF account and gives a DOI you must cite.
run_gbif <- FALSE
if (run_gbif) {
  library(rgbif)
  key <- name_backbone("Lullula arborea")$usageKey
  real <- occ_search(taxonKey = key, country = "ES", hasCoordinate = TRUE,
                     year = "2015,2025", limit = 500)$data
  real |> count(basisOfRecord)
}


# ---------------------------------------------------------------------
# 2. Read and explore the download
# ---------------------------------------------------------------------
raw <- read_csv("data/gbif_lullula_arborea_raw.csv")
nrow(raw)
glimpse(raw)
raw |> count(basisOfRecord)
raw |> count(institutionCode)
summary(raw$coordinateUncertaintyInMeters)
range(raw$year)

# A quick map already shows problems: points at (0, 0) and far from the range
ggplot(raw, aes(decimalLongitude, decimalLatitude)) + geom_point(alpha = 0.5) +
  labs(x = "Longitude", y = "Latitude", title = "Raw records") +
  theme_minimal()


# ---------------------------------------------------------------------
# 3. Cleaning with explicit criteria
# ---------------------------------------------------------------------
# Record how many records each step removes: this documents the
# process for your methods section.
steps_log <- tibble(step = character(), n = integer())
log_step <- function(d, step) {
  cat(sprintf("%-42s %4d\n", step, nrow(d)))
  steps_log <<- add_row(steps_log, step = step, n = nrow(d))   # store the count
  d
}

clean <- raw |>
  log_step("0 raw / sin limpiar") |>
  filter(basisOfRecord %in% c("HUMAN_OBSERVATION", "OBSERVATION")) |>
  log_step("1 observations only / solo observaciones") |>
  filter(year >= 2000) |>
  log_step("2 year >= 2000") |>
  filter(coordinateUncertaintyInMeters <= 1000) |>
  log_step("3 uncertainty <= 1000 m") |>
  distinct(decimalLongitude, decimalLatitude, year, .keep_all = TRUE) |>
  log_step("4 no duplicates / sin duplicados")

# CoordinateCleaner runs automatic tests: (0, 0) coordinates, equal
# latitude and longitude, country capitals and centroids, and outliers
# far from the rest.
flags <- clean_coordinates(clean, lon = "decimalLongitude", lat = "decimalLatitude",
                           species = "species",
                           tests = c("zeros", "equal", "capitals", "centroids", "outliers"),
                           outliers_method = "distance", outliers_td = 50)
summary(flags)
clean <- clean[flags$.summary, ] |> log_step("5 CoordinateCleaner")


# ---------------------------------------------------------------------
# 4. Spatial filter: study area only
# ---------------------------------------------------------------------
park <- st_read("data/montfred.gpkg", "park_boundary", quiet = TRUE)
study_area <- st_buffer(park, 3000)   # the park plus 3 km around it

occ <- clean |>
  st_as_sf(coords = c("decimalLongitude", "decimalLatitude"), crs = 4326, remove = FALSE) |>
  st_transform(st_crs(park))
occ <- occ[lengths(st_intersects(occ, study_area)) > 0, ] |> log_step("6 inside study area / zona de estudio")

# Records with swapped latitude and longitude fall on another
# continent: the spatial filter removes them. Check:
raw |> filter(decimalLongitude > 30)


# ---------------------------------------------------------------------
# 5. Sampling bias and spatial thinning
# ---------------------------------------------------------------------
xy <- st_coordinates(occ)
occ$x <- xy[, 1]; occ$y <- xy[, 2]

# Clusters of records often show where people go (paths, viewpoints),
# not where the species is. Keep one record per 250 x 250 m cell.
occ$cell <- paste(floor(occ$x / 250), floor(occ$y / 250))
thinned <- occ |> distinct(cell, .keep_all = TRUE) |> log_step("7 thinned 250 m / aclarado 250 m")

p_map <- ggplot() +
  geom_sf(data = park, fill = "grey95") +
  geom_sf(data = occ, colour = "grey60", size = 1) +
  geom_sf(data = thinned, aes(colour = institutionCode), size = 1.6) +
  labs(title = "Woodlark: cleaned records", subtitle = "Grey: removed by thinning", colour = "Source") +
  theme_minimal()
p_map

p_year <- ggplot(st_drop_geometry(thinned), aes(year)) +
  geom_bar(fill = "#2C6E91") +
  labs(x = "Year", y = "Records", title = "Records per year") +
  theme_minimal()
p_year


# ---------------------------------------------------------------------
# 6. Save for Week 10
# ---------------------------------------------------------------------
dir.create("outputs", showWarnings = FALSE)
thinned |>
  st_drop_geometry() |>
  select(gbifID, species, decimalLongitude, decimalLatitude, x, y, year, institutionCode) |>
  write_csv("outputs/gbif_lullula_arborea_clean.csv")
ggsave("outputs/gbif_map.png", p_map, width = 7, height = 5.5, dpi = 300, bg = "white")
ggsave("outputs/gbif_years.png", p_year, width = 7, height = 4, dpi = 300, bg = "white")
# Always cite the DOI of your GBIF download in your work.


# =====================================================================
#  EXERCISES  (answers in week08_solutions.R)
# =====================================================================
# E1. How many records did each cleaning step remove? Make a table of
#     step and records remaining.
# E2. Which CoordinateCleaner tests flagged records? Use
#     colSums(!flags[, grep("^\\.", names(flags))]).
# E3. Repeat the thinning with 500 m cells. How many records remain?
# E4. Which source (institutionCode) contributes most records? Could
#     that bias a distribution model?
# E5. With internet: use rgbif to download Lullula arborea records for
#     your own region (hint: the geometry or gadmGid argument).
# =====================================================================
