# =====================================================================
#  Ecología Espacial  ·  Semana 12
#  Métricas de paisaje y cambio de usos del suelo
# =====================================================================
#  Archivos en data/: landcover.tif (2026), landcover1990.tif,
#                     landcover_classes.csv, montfred.gpkg
#  Paquetes: install.packages(c("landscapemetrics", "terra", "sf", "tidyverse"))
#
#  Pregunta: ¿cómo ha cambiado el paisaje de la sierra desde 1990, con
#  el abandono rural? ¿Está más fragmentado o más homogéneo?
# =====================================================================

library(tidyverse)
library(sf)
library(terra)
library(landscapemetrics)


# ---------------------------------------------------------------------
# 1. Datos
# ---------------------------------------------------------------------
lc26 <- rast("data/landcover.tif")
lc90 <- rast("data/landcover1990.tif")
classes <- read_csv("data/landcover_classes.csv")
park <- st_read("data/montfred.gpkg", "park_boundary", quiet = TRUE)

# Recortamos los dos mapas al parque
lc26_p <- crop(lc26, park) |> mask(vect(park))
lc90_p <- crop(lc90, park) |> mask(vect(park))

# Comprobación previa de landscapemetrics: el ráster debe estar en una
# proyección en metros y tener clases enteras.
check_landscape(lc26_p)

par(mfrow = c(1, 2))
cols <- c("#34502A", "#86B07A", "#D3DB86", "#2E9C6A", "#B98BB0", "#F0E3A0", "#E8A85C", "#7A7A7A")
plot(lc90_p, col = cols, type = "classes", main = "1990", legend = FALSE)
plot(lc26_p, col = cols, type = "classes", main = "2026", legend = FALSE)
par(mfrow = c(1, 1))


# ---------------------------------------------------------------------
# 2. ¿Cuánto ocupa cada clase? (nivel de clase)
# ---------------------------------------------------------------------
# Las métricas tienen prefijo lsm_ y luego el nivel: p (mancha),
# c (clase) o l (paisaje). pland = porcentaje del paisaje.
pland <- bind_rows(
  lsm_c_pland(lc90_p) |> mutate(year = 1990),
  lsm_c_pland(lc26_p) |> mutate(year = 2026)
) |> left_join(classes, by = c("class" = "value"))

pland |>
  select(year, class_es, value) |>
  pivot_wider(names_from = year, values_from = value, names_prefix = "pct_") |>
  mutate(change = pct_2026 - pct_1990) |>
  arrange(change)

p_pland <- ggplot(pland, aes(x = factor(year), y = value, fill = factor(class))) +
  geom_col() +
  scale_fill_manual(values = cols, labels = classes$class_es, name = NULL) +
  labs(x = NULL, y = "% del parque", title = "Composición del paisaje") +
  theme_minimal(base_size = 13)
p_pland


# ---------------------------------------------------------------------
# 3. Matriz de transición: de qué a qué ha cambiado cada celda
# ---------------------------------------------------------------------
trans <- crosstab(c(lc90_p, lc26_p))   # filas 1990, columnas 2026 (número de celdas)
trans_ha <- round(trans * prod(res(lc26_p)) / 10000)
trans_ha
# La diagonal es lo que no cambió. Fíjate en la fila "6" (prado en 1990):
# ¿en qué se ha convertido?


# ---------------------------------------------------------------------
# 4. Configuración: fragmentación (nivel de paisaje)
# ---------------------------------------------------------------------
metrics <- c("lsm_l_np", "lsm_l_ed", "lsm_l_shdi", "lsm_l_contag", "lsm_l_lpi")
land <- bind_rows(
  calculate_lsm(lc90_p, what = metrics) |> mutate(year = 1990),
  calculate_lsm(lc26_p, what = metrics) |> mutate(year = 2026)
)
land |> select(year, metric, value) |> pivot_wider(names_from = year, values_from = value)
# np: número de manchas · ed: densidad de borde (m/ha) · shdi: diversidad
# de Shannon · contag: contagio (agregación, 0–100) · lpi: % ocupado por
# la mancha más grande.

# Documentación de cualquier métrica:
list_lsm(metric = "contag")


# ---------------------------------------------------------------------
# 5. Prados de montaña: manchas cada vez más pequeñas
# ---------------------------------------------------------------------
meadow <- bind_rows(
  calculate_lsm(lc90_p, what = c("lsm_c_np", "lsm_c_area_mn", "lsm_c_pland")) |> mutate(year = 1990),
  calculate_lsm(lc26_p, what = c("lsm_c_np", "lsm_c_area_mn", "lsm_c_pland")) |> mutate(year = 2026)
) |> filter(class == 6)
meadow |> select(year, metric, value) |> pivot_wider(names_from = metric, values_from = value)

# Tamaño de cada mancha de prado (en ha)
patch_area <- bind_rows(
  lsm_p_area(lc90_p) |> mutate(year = 1990),
  lsm_p_area(lc26_p) |> mutate(year = 2026)
) |> filter(class == 6)

p_patches <- ggplot(patch_area, aes(value, fill = factor(year))) +
  geom_histogram(bins = 25, position = "dodge") +
  scale_x_log10(labels = scales::label_number(drop0trailing = TRUE)) +
  labs(x = "Superficie de la mancha (ha, escala log)", y = "Número de manchas", fill = NULL,
       title = "Manchas de prado en 1990 y 2026") +
  theme_minimal(base_size = 13)
p_patches


# ---------------------------------------------------------------------
# 6. Métricas en ventanas: la escala importa
# ---------------------------------------------------------------------
# Calculamos la diversidad de Shannon en cuadrados de 1,5 km en todo el
# mapa de 2026: ¿dónde está el paisaje más diverso?
grid <- st_make_grid(st_as_sfc(st_bbox(lc26)), cellsize = 1500) |> st_sf()
shdi_grid <- sample_lsm(lc26, y = grid, what = "lsm_l_shdi")
grid$shdi <- shdi_grid$value[match(seq_len(nrow(grid)), shdi_grid$plot_id)]

p_grid <- ggplot(grid) +
  geom_sf(aes(fill = shdi), colour = "white") +
  geom_sf(data = park, fill = NA, colour = "black", linewidth = 0.8) +
  scale_fill_viridis_c(name = "SHDI") +
  labs(title = "Diversidad de Shannon en cuadrados de 1,5 km (2026)") +
  coord_sf(datum = st_crs(park)) +
  theme_minimal()
p_grid


# ---------------------------------------------------------------------
# 7. Guardar
# ---------------------------------------------------------------------
dir.create("outputs", showWarnings = FALSE)
write_csv(land, "outputs/landscape_metrics_1990_2026.csv")
write.csv(trans_ha, "outputs/transition_matrix_ha.csv")
ggsave("outputs/composition.png", p_pland, width = 7, height = 5, dpi = 300, bg = "white")
ggsave("outputs/meadow_patches.png", p_patches, width = 7, height = 4.5, dpi = 300, bg = "white")
ggsave("outputs/shdi_grid.png", p_grid, width = 7, height = 6, dpi = 300, bg = "white")


# =====================================================================
#  EJERCICIOS  (soluciones en semana12_soluciones.R)
# =====================================================================
# E1. ¿Cuántas hectáreas de prado de 1990 son hoy brezal? ¿Y hayedo?
#     (Usa trans_ha.)
# E2. Calcula la densidad de borde del hayedo (lsm_c_ed) en 1990 y 2026.
# E3. Repite la sección 6 con cuadrados de 3 km. ¿Cambia el patrón?
# E4. Elige tres métricas de paisaje que no hayamos usado
#     (list_lsm(level = "landscape")) y explica qué miden.
# E5. Proyecto final: prepara un análisis corto con estos datos (u otros
#     tuyos) que vaya de los datos al mapa. Ver la guía de la semana 12.
# =====================================================================
