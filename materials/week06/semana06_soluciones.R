# =====================================================================
#  Ecología Espacial  ·  Semana 6  ·  Soluciones
# =====================================================================
# Ejecuta antes semana06_sf_y_terra.R hasta la sección 6.

# E1. Puntos a menos de 500 m del límite del parque
d_edge <- as.numeric(st_distance(pts, st_boundary(park)))
sum(d_edge < 500)

# E2. Superficie de cada piso altitudinal
freq(belts) |> as_tibble() |> mutate(area_ha = count * prod(res(belts)) / 10000)

# E3. Pendiente media en el parque y en la ribera
riparian_park <- st_intersection(st_sf(geometry = riparian), park)
c(park     = terra::extract(slope, vect(park), fun = mean, na.rm = TRUE)[, 2],
  riparian = terra::extract(slope, vect(riparian_park), fun = mean, na.rm = TRUE)[, 2])

# E4. Proporción de hayedo en 500 m
beech <- lc == 4
pts$beech_500 <- terra::extract(beech, vect(st_buffer(pts, 500)), fun = mean, na.rm = TRUE)[, 2]
pts |> st_drop_geometry() |> select(point_id, habitat, beech_500) |> slice_max(beech_500, n = 3)

# E5. Guardar los pisos altitudinales
writeRaster(belts, "outputs/elevation_belts.tif", overwrite = TRUE)
# En QGIS: Capa > Añadir capa > Añadir capa ráster, y simbología
# "Valores únicos (Paletted/Unique values)".
