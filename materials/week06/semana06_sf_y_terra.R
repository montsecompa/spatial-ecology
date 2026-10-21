# =====================================================================
#  Ecología Espacial  ·  Semana 6
#  Datos espaciales en R con sf y terra
# =====================================================================
#  Archivos en data/: survey_points.csv, montfred.gpkg, dem.tif,
#                     landcover.tif, landcover_classes.csv
#  Paquetes: install.packages(c("sf", "terra", "tidyverse"))
#  Repetimos en código el trabajo de QGIS de la semana 5, para que el
#  análisis sea reproducible.
# =====================================================================

library(tidyverse)
library(sf)      # datos vectoriales (puntos, líneas, polígonos)
library(terra)   # datos ráster


# ---------------------------------------------------------------------
# 1. Leer datos vectoriales
# ---------------------------------------------------------------------
st_layers("data/montfred.gpkg")    # capas dentro del GeoPackage

park    <- st_read("data/montfred.gpkg", layer = "park_boundary")
streams <- st_read("data/montfred.gpkg", layer = "streams")

park              # un objeto sf es un data frame con una columna de geometría
st_crs(park)      # ETRS89 / UTM 31N (EPSG:25831), en metros

plot(st_geometry(park), col = "grey95")
plot(st_geometry(streams), col = "steelblue", add = TRUE)


# ---------------------------------------------------------------------
# 2. De CSV a puntos, y reproyectar
# ---------------------------------------------------------------------
pts_ll <- read_csv("data/survey_points.csv") |>
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)   # WGS84, grados
st_crs(pts_ll)$epsg

# Para medir distancias y áreas en metros, pasamos a la proyección del parque
pts <- st_transform(pts_ll, st_crs(park))
st_coordinates(pts)[1:3, ]

# Comparar distancias: en grados no tienen sentido; en UTM son metros
st_distance(pts[1:3, ])


# ---------------------------------------------------------------------
# 3. Operaciones vectoriales
# ---------------------------------------------------------------------
# Área del parque en hectáreas
as.numeric(st_area(park)) / 10000

# ¿Qué puntos están dentro del parque?
pts$in_park <- lengths(st_intersects(pts, park)) > 0
table(pts$in_park)

# Zona de influencia (buffer) de 150 m alrededor de los torrentes
riparian <- st_buffer(streams, 150) |> st_union()
pts$riparian <- lengths(st_intersects(pts, riparian)) > 0
table(pts$riparian)

# Distancia de cada punto al torrente más cercano (comprueba dist_stream_m)
pts$dist_calc <- apply(st_distance(pts, streams), 1, min)
pts |> st_drop_geometry() |> select(point_id, dist_stream_m, dist_calc) |> head()

# Longitud de cada torrente dentro del parque, en km
streams_park <- st_intersection(streams, park)
streams_park$length_km <- as.numeric(st_length(streams_park)) / 1000
streams_park |> st_drop_geometry() |> select(name, length_km)


# ---------------------------------------------------------------------
# 4. Leer y explorar rásteres
# ---------------------------------------------------------------------
dem <- rast("data/dem.tif")
lc  <- rast("data/landcover.tif")
dem             # dimensiones, resolución (30 m), extensión y SRC
res(dem); crs(dem, describe = TRUE)
global(dem, c("min", "max", "mean"), na.rm = TRUE)

plot(dem)
plot(st_geometry(park), add = TRUE, border = "black")

# Derivados del relieve: pendiente, orientación y sombreado
slope  <- terrain(dem, "slope", unit = "degrees")
aspect <- terrain(dem, "aspect", unit = "radians")
hill   <- shade(terrain(dem, "slope", unit = "radians"), aspect, angle = 40, direction = 315)
plot(hill, col = grey(0:100 / 100), legend = FALSE)


# ---------------------------------------------------------------------
# 5. Recortar, enmascarar y reclasificar
# ---------------------------------------------------------------------
dem_park <- crop(dem, park) |> mask(vect(park))   # recortar a la extensión y enmascarar fuera del parque
plot(dem_park)

# Pisos altitudinales: < 600, 600–1000, 1000–1300, > 1300 m
rcl <- matrix(c(-Inf, 600, 1,  600, 1000, 2,  1000, 1300, 3,  1300, Inf, 4), ncol = 3, byrow = TRUE)
belts <- classify(dem_park, rcl)
freq(belts)

# Superficie de cada uso del suelo dentro del parque (ha)
classes <- read_csv("data/landcover_classes.csv")
lc_park <- crop(lc, park) |> mask(vect(park))
lc_area <- freq(lc_park) |>
  as_tibble() |>
  mutate(area_ha = count * prod(res(lc_park)) / 10000) |>
  left_join(classes, by = "value") |>
  select(value, class = class_es, area_ha) |>
  arrange(desc(area_ha))
lc_area


# ---------------------------------------------------------------------
# 6. Extraer valores del ráster en los puntos
# ---------------------------------------------------------------------
pts$dem_m  <- terra::extract(dem, vect(pts))[, 2]
pts$slope  <- terra::extract(slope, vect(pts))[, 2]
pts$lc_code <- terra::extract(lc, vect(pts))[, 2]

# Altímetro del GPS frente a modelo digital de elevaciones
ggplot(pts, aes(dem_m, elevation_m)) +
  geom_abline(linetype = 2) + geom_point() +
  labs(x = "Altitud del MDE (m)", y = "Altitud anotada en campo (m)") +
  theme_minimal()

# Media en una zona alrededor de cada punto: buffer de 250 m
buf <- st_buffer(pts, 250)
pts$slope_250 <- terra::extract(slope, vect(buf), fun = mean, na.rm = TRUE)[, 2]

# Proporción de medios abiertos (brezal o prado) en 250 m
open <- lc %in% c(5, 6)
pts$open_250 <- terra::extract(open, vect(buf), fun = mean, na.rm = TRUE)[, 2]
pts |> st_drop_geometry() |> select(point_id, habitat, slope_250, open_250) |> arrange(desc(open_250)) |> head()


# ---------------------------------------------------------------------
# 7. Guardar resultados
# ---------------------------------------------------------------------
dir.create("outputs", showWarnings = FALSE)
st_write(pts, "outputs/survey_points_covariates.gpkg", delete_dsn = TRUE, quiet = TRUE)
write_csv(st_drop_geometry(pts), "outputs/survey_points_covariates.csv")
writeRaster(slope, "outputs/slope.tif", overwrite = TRUE)

png("outputs/terrain_map.png", width = 1800, height = 1500, res = 220)
plot(hill, col = grey(0:100 / 100), legend = FALSE, mar = c(2, 2, 2, 2))
plot(dem, col = terrain.colors(50), alpha = 0.45, add = TRUE, legend = FALSE)
plot(st_geometry(park), add = TRUE, border = "black", lwd = 2)
plot(st_geometry(streams), add = TRUE, col = "steelblue", lwd = 1.5)
plot(st_geometry(pts), add = TRUE, pch = 21, bg = "white", cex = 1.1)
title("Sierra de Montfred: relieve, torrentes y puntos de muestreo")
dev.off()


# =====================================================================
#  EJERCICIOS  (soluciones en semana06_soluciones.R)
# =====================================================================
# E1. ¿Cuántos puntos de muestreo quedan a menos de 500 m del límite
#     del parque? (Pista: st_boundary() y st_distance().)
# E2. Calcula la superficie (ha) de cada piso altitudinal (belts).
# E3. Extrae la pendiente media del parque y compárala con la de las
#     zonas de ribera (buffer de 150 m).
# E4. Calcula, para cada punto, la proporción de hayedo (código 4) en
#     un radio de 500 m. ¿Qué punto tiene más?
# E5. Reto: guarda el ráster de pisos altitudinales y ábrelo en QGIS.
# =====================================================================
