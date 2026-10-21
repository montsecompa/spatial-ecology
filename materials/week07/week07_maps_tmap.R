# =====================================================================
#  Spatial Ecology  ·  Week 7
#  Publication-quality maps with tmap (and ggplot2)
# =====================================================================
#  Files in data/: survey_points.csv, bird_counts_wide.csv,
#    montfred.gpkg, dem.tif, landcover.tif, landcover_classes.csv
#  Packages: install.packages(c("tmap", "sf", "terra", "tidyverse"))
#  This script uses tmap 4 (the current version). Examples online with
#  tm_raster(palette = ...) are written for tmap 3.
# =====================================================================

library(tidyverse)
library(sf)
library(terra)
library(tmap)
tmap_mode("plot")   # static maps; tmap_mode("view") makes them interactive


# ---------------------------------------------------------------------
# 1. Data
# ---------------------------------------------------------------------
park    <- st_read("data/montfred.gpkg", "park_boundary", quiet = TRUE)
streams <- st_read("data/montfred.gpkg", "streams", quiet = TRUE)
dem     <- rast("data/dem.tif")
lc      <- rast("data/landcover.tif")
classes <- read_csv("data/landcover_classes.csv")

# Richness per point (as in Week 2), turned into UTM points
richness <- read_csv("data/bird_counts_wide.csv") |>
  pivot_longer(european_robin:short_toed_treecreeper, names_to = "species", values_to = "count") |>
  filter(!is.na(count)) |>
  group_by(point_id) |>
  summarise(richness = n_distinct(species[count > 0]))
pts <- read_csv("data/survey_points.csv") |>
  left_join(richness, by = "point_id") |>
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326) |>
  st_transform(st_crs(park))

# Hillshade
hill <- shade(terrain(dem, "slope", unit = "radians"), terrain(dem, "aspect", unit = "radians"), 40, 315)

# Land cover as a categorical raster with names
levels(lc) <- data.frame(value = classes$value, class = classes$class_en)
lc_cols <- c("#34502A", "#86B07A", "#D3DB86", "#2E9C6A", "#B98BB0", "#F0E3A0", "#E8A85C", "#7A7A7A")


# ---------------------------------------------------------------------
# 2. Study area map
# ---------------------------------------------------------------------
m_area <- tm_shape(hill) +
  tm_raster(col.scale = tm_scale_continuous(values = "brewer.greys"), col.legend = tm_legend_hide()) +
  tm_shape(dem) +
  tm_raster(col_alpha = 0.55,
            col.scale = tm_scale_continuous(values = "brewer.yl_gn"),
            col.legend = tm_legend(title = "Elevation (m)")) +
  tm_shape(park) + tm_borders(col = "black", lwd = 2) +
  tm_shape(streams) + tm_lines(col = "#2C6E91", lwd = 1.5) +
  tm_shape(pts) + tm_symbols(shape = 21, fill = "white", col = "black", size = 0.45) +
  tm_compass(position = c("left", "top")) +
  tm_scalebar(breaks = c(0, 2, 4), position = c("left", "bottom")) +
  tm_title("Sierra de Montfred (fictitious)") +
  tm_layout(legend.outside = TRUE, frame = TRUE)
m_area


# ---------------------------------------------------------------------
# 3. Land-cover map with bird richness
# ---------------------------------------------------------------------
m_lc <- tm_shape(lc) +
  tm_raster(col.scale = tm_scale_categorical(values = lc_cols),
            col.legend = tm_legend(title = "Land cover")) +
  tm_shape(park) + tm_borders(col = "#B03A2E", lwd = 2) +
  tm_shape(pts) +
  tm_bubbles(size = "richness", fill = "white", col = "black",
             size.scale = tm_scale_continuous(values.scale = 1.2),
             size.legend = tm_legend(title = "Richness (species)")) +
  tm_scalebar(breaks = c(0, 2, 4), position = c("left", "bottom")) +
  tm_title("Land cover and bird richness") +
  tm_layout(legend.outside = TRUE)
m_lc


# ---------------------------------------------------------------------
# 4. Small multiples (facets): one species per panel
# ---------------------------------------------------------------------
three <- read_csv("data/bird_counts_wide.csv") |>
  group_by(point_id) |>
  summarise(across(c(european_robin, woodlark, rock_bunting), ~ mean(.x, na.rm = TRUE))) |>
  pivot_longer(-point_id, names_to = "species", values_to = "mean_count")
pts_sp <- pts |> select(point_id) |> left_join(three, by = "point_id")

m_facets <- tm_shape(park) + tm_fill("grey92") + tm_borders() +
  tm_shape(pts_sp) +
  tm_bubbles(size = "mean_count", fill = "#2C6E91", col = "white",
             size.legend = tm_legend(title = "Mean per visit")) +
  tm_facets(by = "species", ncol = 3) +
  tm_layout(legend.outside = TRUE)
m_facets


# ---------------------------------------------------------------------
# 5. The same idea with ggplot2 and geom_sf()
# ---------------------------------------------------------------------
p_gg <- ggplot() +
  geom_sf(data = park, fill = "grey95") +
  geom_sf(data = streams, colour = "#2C6E91") +
  geom_sf(data = pts, aes(size = richness, colour = habitat)) +
  labs(title = "Bird richness", size = "Richness", colour = "Habitat") +
  coord_sf(datum = st_crs(park)) +   # axes in UTM coordinates
  theme_minimal()
p_gg


# ---------------------------------------------------------------------
# 6. Interactive map (for exploring, not publishing)
# ---------------------------------------------------------------------
# Remove the # to try it in RStudio: it opens a map with a web basemap.
# tmap_mode("view")
# tm_shape(pts) + tm_dots(fill = "habitat", popup.vars = c("point_id", "richness"))
# tmap_mode("plot")


# ---------------------------------------------------------------------
# 7. Export at journal resolution
# ---------------------------------------------------------------------
dir.create("outputs", showWarnings = FALSE)
tmap_save(m_area, "outputs/map_study_area.png", width = 18, height = 14, units = "cm", dpi = 300)
tmap_save(m_lc, "outputs/map_landcover_richness.png", width = 18, height = 14, units = "cm", dpi = 300)
tmap_save(m_facets, "outputs/map_species_facets.png", width = 24, height = 9, units = "cm", dpi = 300)
ggsave("outputs/map_ggplot.png", p_gg, width = 18, height = 14, units = "cm", dpi = 300, bg = "white")
# For journals that want vector files: tmap_save(m_area, "map.pdf")


# =====================================================================
#  EXERCISES  (answers in week07_solutions.R)
# =====================================================================
# E1. Change the DEM palette in m_area to "hcl.terrain2" and remove the
#     hillshade. Which version reads better?
# E2. Add stream name labels to m_lc (tm_text("name")).
# E3. Map slope (terrain(dem, "slope")) with an interval colour scale
#     (tm_scale_intervals) of 0–5, 5–15, 15–25 and > 25 degrees.
# E4. Redo m_facets with three other species you are interested in.
# E5. Export m_lc as a PDF 17 cm wide (one journal column).
# =====================================================================
