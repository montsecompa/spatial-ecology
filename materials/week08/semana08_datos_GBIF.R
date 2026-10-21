# =====================================================================
#  Ecología Espacial  ·  Semana 8
#  Datos de presencia de GBIF: descargar, limpiar y revisar sesgos
# =====================================================================
#  Archivos en data/: gbif_lullula_arborea_raw.csv, montfred.gpkg
#  Paquetes: install.packages(c("rgbif", "CoordinateCleaner", "sf", "tidyverse"))
#
#  Especie: alondra totovía (Lullula arborea).
#  El archivo de clase imita una descarga de GBIF para la Sierra de
#  Montfred (ficticia), con errores típicos añadidos a propósito.
# =====================================================================

library(tidyverse)
library(sf)
library(CoordinateCleaner)


# ---------------------------------------------------------------------
# 1. Descargar de GBIF con rgbif (necesita internet)
# ---------------------------------------------------------------------
# Cambia run_gbif a TRUE para probar la descarga real. occ_search() es
# para explorar (máx. 100.000 registros). Para un artículo usa
# occ_download(), que exige una cuenta de GBIF y genera un DOI que
# hay que citar.
run_gbif <- FALSE
if (run_gbif) {
  library(rgbif)
  key <- name_backbone("Lullula arborea")$usageKey
  real <- occ_search(taxonKey = key, country = "ES", hasCoordinate = TRUE,
                     year = "2015,2025", limit = 500)$data
  real |> count(basisOfRecord)
}


# ---------------------------------------------------------------------
# 2. Leer y explorar la descarga
# ---------------------------------------------------------------------
raw <- read_csv("data/gbif_lullula_arborea_raw.csv")
nrow(raw)
glimpse(raw)
raw |> count(basisOfRecord)
raw |> count(institutionCode)
summary(raw$coordinateUncertaintyInMeters)
range(raw$year)

# Un mapa rápido ya muestra problemas: puntos en (0, 0) y lejos de la sierra
ggplot(raw, aes(decimalLongitude, decimalLatitude)) + geom_point(alpha = 0.5) +
  labs(x = "Longitud", y = "Latitud", title = "Registros sin limpiar") +
  theme_minimal()


# ---------------------------------------------------------------------
# 3. Limpieza con criterios explícitos
# ---------------------------------------------------------------------
# Anotamos cuántos registros se quitan en cada paso: así el proceso
# queda documentado para la sección de métodos.
steps_log <- tibble(step = character(), n = integer())
log_step <- function(d, step) {
  cat(sprintf("%-42s %4d\n", step, nrow(d)))
  steps_log <<- add_row(steps_log, step = step, n = nrow(d))   # guarda el recuento
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

# CoordinateCleaner aplica pruebas automáticas: coordenadas (0, 0),
# latitud igual a longitud, capitales y centroides de países, y valores
# atípicos muy alejados del resto.
flags <- clean_coordinates(clean, lon = "decimalLongitude", lat = "decimalLatitude",
                           species = "species",
                           tests = c("zeros", "equal", "capitals", "centroids", "outliers"),
                           outliers_method = "distance", outliers_td = 50)
summary(flags)
clean <- clean[flags$.summary, ] |> log_step("5 CoordinateCleaner")


# ---------------------------------------------------------------------
# 4. Filtro espacial: solo la zona de estudio
# ---------------------------------------------------------------------
park <- st_read("data/montfred.gpkg", "park_boundary", quiet = TRUE)
study_area <- st_buffer(park, 3000)   # el parque y 3 km alrededor

occ <- clean |>
  st_as_sf(coords = c("decimalLongitude", "decimalLatitude"), crs = 4326, remove = FALSE) |>
  st_transform(st_crs(park))
occ <- occ[lengths(st_intersects(occ, study_area)) > 0, ] |> log_step("6 inside study area / zona de estudio")

# Los registros con latitud y longitud intercambiadas caen en otro
# continente: el filtro espacial los elimina. Compruébalo:
raw |> filter(decimalLongitude > 30)


# ---------------------------------------------------------------------
# 5. Sesgo de muestreo y aclarado espacial
# ---------------------------------------------------------------------
xy <- st_coordinates(occ)
occ$x <- xy[, 1]; occ$y <- xy[, 2]

# Muchos registros juntos suelen reflejar dónde va la gente (caminos,
# miradores), no dónde está la especie. Nos quedamos con un registro
# por celda de 250 x 250 m.
occ$cell <- paste(floor(occ$x / 250), floor(occ$y / 250))
thinned <- occ |> distinct(cell, .keep_all = TRUE) |> log_step("7 thinned 250 m / aclarado 250 m")

p_map <- ggplot() +
  geom_sf(data = park, fill = "grey95") +
  geom_sf(data = occ, colour = "grey60", size = 1) +
  geom_sf(data = thinned, aes(colour = institutionCode), size = 1.6) +
  labs(title = "Alondra totovía: registros limpios", subtitle = "Gris: eliminados al aclarar", colour = "Fuente") +
  theme_minimal()
p_map

p_year <- ggplot(st_drop_geometry(thinned), aes(year)) +
  geom_bar(fill = "#2C6E91") +
  labs(x = "Año", y = "Registros", title = "Registros por año") +
  theme_minimal()
p_year


# ---------------------------------------------------------------------
# 6. Guardar para la semana 10
# ---------------------------------------------------------------------
dir.create("outputs", showWarnings = FALSE)
thinned |>
  st_drop_geometry() |>
  select(gbifID, species, decimalLongitude, decimalLatitude, x, y, year, institutionCode) |>
  write_csv("outputs/gbif_lullula_arborea_clean.csv")
ggsave("outputs/gbif_map.png", p_map, width = 7, height = 5.5, dpi = 300, bg = "white")
ggsave("outputs/gbif_years.png", p_year, width = 7, height = 4, dpi = 300, bg = "white")
# Cita siempre el DOI de la descarga de GBIF en tus trabajos.


# =====================================================================
#  EJERCICIOS  (soluciones en semana08_soluciones.R)
# =====================================================================
# E1. ¿Cuántos registros quitó cada paso de limpieza? Haz una tabla
#     con el paso y el número de registros que quedan.
# E2. ¿Qué pruebas de CoordinateCleaner marcaron registros? Usa
#     colSums(!flags[, grep("^\\.", names(flags))]).
# E3. Repite el aclarado con celdas de 500 m. ¿Cuántos registros quedan?
# E4. ¿Qué fuente (institutionCode) aporta más registros? ¿Puede eso
#     sesgar un modelo de distribución?
# E5. Con internet: descarga con rgbif los registros de Lullula arborea
#     en tu provincia (pista: argumento geometry o gadmGid).
# =====================================================================
