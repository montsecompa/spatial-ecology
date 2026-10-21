# =====================================================================
#  Ecología Espacial  ·  Semana 7
#  Mapas de calidad para publicar con tmap (y ggplot2)
# =====================================================================
#  Archivos en data/: survey_points.csv, bird_counts_wide.csv,
#    montfred.gpkg, dem.tif, landcover.tif, landcover_classes.csv
#  Paquetes: install.packages(c("tmap", "sf", "terra", "tidyverse"))
#  Este script usa tmap 4 (la versión actual). Si encuentras ejemplos
#  en internet con tm_raster(palette = ...), son de tmap 3.
# =====================================================================

library(tidyverse)
library(sf)
library(terra)
library(tmap)
tmap_mode("plot")   # mapas estáticos; tmap_mode("view") los hace interactivos


# ---------------------------------------------------------------------
# 1. Datos
# ---------------------------------------------------------------------
park    <- st_read("data/montfred.gpkg", "park_boundary", quiet = TRUE)
streams <- st_read("data/montfred.gpkg", "streams", quiet = TRUE)
dem     <- rast("data/dem.tif")
lc      <- rast("data/landcover.tif")
classes <- read_csv("data/landcover_classes.csv")

# Riqueza por punto (como en la semana 2), convertida en puntos UTM
richness <- read_csv("data/bird_counts_wide.csv") |>
  pivot_longer(european_robin:short_toed_treecreeper, names_to = "species", values_to = "count") |>
  filter(!is.na(count)) |>
  group_by(point_id) |>
  summarise(richness = n_distinct(species[count > 0]))
pts <- read_csv("data/survey_points.csv") |>
  left_join(richness, by = "point_id") |>
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326) |>
  st_transform(st_crs(park))

# Sombreado del relieve
hill <- shade(terrain(dem, "slope", unit = "radians"), terrain(dem, "aspect", unit = "radians"), 40, 315)

# Uso del suelo como ráster categórico con nombres
levels(lc) <- data.frame(value = classes$value, class = classes$class_es)
lc_cols <- c("#34502A", "#86B07A", "#D3DB86", "#2E9C6A", "#B98BB0", "#F0E3A0", "#E8A85C", "#7A7A7A")


# ---------------------------------------------------------------------
# 2. Mapa de la zona de estudio
# ---------------------------------------------------------------------
m_area <- tm_shape(hill) +
  tm_raster(col.scale = tm_scale_continuous(values = "brewer.greys"), col.legend = tm_legend_hide()) +
  tm_shape(dem) +
  tm_raster(col_alpha = 0.55,
            col.scale = tm_scale_continuous(values = "brewer.yl_gn"),
            col.legend = tm_legend(title = "Altitud (m)")) +
  tm_shape(park) + tm_borders(col = "black", lwd = 2) +
  tm_shape(streams) + tm_lines(col = "#2C6E91", lwd = 1.5) +
  tm_shape(pts) + tm_symbols(shape = 21, fill = "white", col = "black", size = 0.45) +
  tm_compass(position = c("left", "top")) +
  tm_scalebar(breaks = c(0, 2, 4), position = c("left", "bottom")) +
  tm_title("Sierra de Montfred (ficticia)") +
  tm_layout(legend.outside = TRUE, frame = TRUE)
m_area


# ---------------------------------------------------------------------
# 3. Mapa de usos del suelo con la riqueza de aves
# ---------------------------------------------------------------------
m_lc <- tm_shape(lc) +
  tm_raster(col.scale = tm_scale_categorical(values = lc_cols),
            col.legend = tm_legend(title = "Uso del suelo")) +
  tm_shape(park) + tm_borders(col = "#B03A2E", lwd = 2) +
  tm_shape(pts) +
  tm_bubbles(size = "richness", fill = "white", col = "black",
             size.scale = tm_scale_continuous(values.scale = 1.2),
             size.legend = tm_legend(title = "Riqueza (especies)")) +
  tm_scalebar(breaks = c(0, 2, 4), position = c("left", "bottom")) +
  tm_title("Usos del suelo y riqueza de aves") +
  tm_layout(legend.outside = TRUE)
m_lc


# ---------------------------------------------------------------------
# 4. Mapas pequeños múltiples (facets): una especie por panel
# ---------------------------------------------------------------------
three <- read_csv("data/bird_counts_wide.csv") |>
  group_by(point_id) |>
  summarise(across(c(european_robin, woodlark, rock_bunting), ~ mean(.x, na.rm = TRUE))) |>
  pivot_longer(-point_id, names_to = "species", values_to = "mean_count")
# Nombres comunes en castellano para los títulos de los paneles
three <- three |> left_join(read_csv("data/species_traits.csv") |> select(species, common_name_es), by = "species") |>
  mutate(species = common_name_es) |> select(-common_name_es)
pts_sp <- pts |> select(point_id) |> left_join(three, by = "point_id")

m_facets <- tm_shape(park) + tm_fill("grey92") + tm_borders() +
  tm_shape(pts_sp) +
  tm_bubbles(size = "mean_count", fill = "#2C6E91", col = "white",
             size.legend = tm_legend(title = "Media por visita")) +
  tm_facets(by = "species", ncol = 3) +
  tm_layout(legend.outside = TRUE)
m_facets


# ---------------------------------------------------------------------
# 5. La misma idea con ggplot2 y geom_sf()
# ---------------------------------------------------------------------
p_gg <- ggplot() +
  geom_sf(data = park, fill = "grey95") +
  geom_sf(data = streams, colour = "#2C6E91") +
  geom_sf(data = pts, aes(size = richness, colour = habitat)) +
  labs(title = "Riqueza de aves", size = "Riqueza", colour = "Hábitat") +
  coord_sf(datum = st_crs(park)) +   # ejes en coordenadas UTM
  theme_minimal()
p_gg


# ---------------------------------------------------------------------
# 6. Mapa interactivo (para explorar, no para publicar)
# ---------------------------------------------------------------------
# Quita los # para probarlo en RStudio: abre un mapa con fondo web.
# tmap_mode("view")
# tm_shape(pts) + tm_dots(fill = "habitat", popup.vars = c("point_id", "richness"))
# tmap_mode("plot")


# ---------------------------------------------------------------------
# 7. Exportar a resolución de revista
# ---------------------------------------------------------------------
dir.create("outputs", showWarnings = FALSE)
tmap_save(m_area, "outputs/map_study_area.png", width = 18, height = 14, units = "cm", dpi = 300)
tmap_save(m_lc, "outputs/map_landcover_richness.png", width = 18, height = 14, units = "cm", dpi = 300)
tmap_save(m_facets, "outputs/map_species_facets.png", width = 24, height = 9, units = "cm", dpi = 300)
ggsave("outputs/map_ggplot.png", p_gg, width = 18, height = 14, units = "cm", dpi = 300, bg = "white")
# Para revistas que piden vectorial: tmap_save(m_area, "mapa.pdf")


# =====================================================================
#  EJERCICIOS  (soluciones en semana07_soluciones.R)
# =====================================================================
# E1. Cambia la paleta del MDE en m_area por "hcl.terrain2" y quita el
#     sombreado. ¿Qué versión se lee mejor?
# E2. Añade a m_lc las etiquetas de los torrentes (tm_text("name")).
# E3. Haz un mapa de la pendiente (terrain(dem, "slope")) con una
#     escala de colores por intervalos (tm_scale_intervals) de 0–5,
#     5–15, 15–25 y > 25 grados.
# E4. Rehaz m_facets con otras tres especies que te interesen.
# E5. Exporta m_lc en PDF de 17 cm de ancho (una columna de revista).
# =====================================================================
