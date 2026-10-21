# =====================================================================
#  Spatial Ecology  ·  Week 12
#  Landscape metrics and land-cover change
# =====================================================================
#  Files in data/: landcover.tif (2026), landcover1990.tif,
#                  landcover_classes.csv, montfred.gpkg
#  Packages: install.packages(c("landscapemetrics", "terra", "sf", "tidyverse"))
#
#  Question: how has the mountain landscape changed since 1990, with
#  rural abandonment? Is it more fragmented or more homogeneous?
# =====================================================================

library(tidyverse)
library(sf)
library(terra)
library(landscapemetrics)


# ---------------------------------------------------------------------
# 1. Data
# ---------------------------------------------------------------------
lc26 <- rast("data/landcover.tif")
lc90 <- rast("data/landcover1990.tif")
classes <- read_csv("data/landcover_classes.csv")
park <- st_read("data/montfred.gpkg", "park_boundary", quiet = TRUE)

# Clip both maps to the park
lc26_p <- crop(lc26, park) |> mask(vect(park))
lc90_p <- crop(lc90, park) |> mask(vect(park))

# landscapemetrics pre-check: the raster must be in a projected CRS in
# metres and have integer classes.
check_landscape(lc26_p)

par(mfrow = c(1, 2))
cols <- c("#34502A", "#86B07A", "#D3DB86", "#2E9C6A", "#B98BB0", "#F0E3A0", "#E8A85C", "#7A7A7A")
plot(lc90_p, col = cols, type = "classes", main = "1990", legend = FALSE)
plot(lc26_p, col = cols, type = "classes", main = "2026", legend = FALSE)
par(mfrow = c(1, 1))


# ---------------------------------------------------------------------
# 2. How much of each class? (class level)
# ---------------------------------------------------------------------
# Metrics start with lsm_ and then the level: p (patch), c (class) or
# l (landscape). pland = percentage of landscape.
pland <- bind_rows(
  lsm_c_pland(lc90_p) |> mutate(year = 1990),
  lsm_c_pland(lc26_p) |> mutate(year = 2026)
) |> left_join(classes, by = c("class" = "value"))

pland |>
  select(year, class_en, value) |>
  pivot_wider(names_from = year, values_from = value, names_prefix = "pct_") |>
  mutate(change = pct_2026 - pct_1990) |>
  arrange(change)

p_pland <- ggplot(pland, aes(x = factor(year), y = value, fill = factor(class))) +
  geom_col() +
  scale_fill_manual(values = cols, labels = classes$class_en, name = NULL) +
  labs(x = NULL, y = "% of park", title = "Landscape composition") +
  theme_minimal(base_size = 13)
p_pland


# ---------------------------------------------------------------------
# 3. Transition matrix: what changed into what
# ---------------------------------------------------------------------
trans <- crosstab(c(lc90_p, lc26_p))   # rows 1990, columns 2026 (cell counts)
trans_ha <- round(trans * prod(res(lc26_p)) / 10000)
trans_ha
# The diagonal is what stayed the same. Look at row "6" (meadow in 1990):
# what did it become?


# ---------------------------------------------------------------------
# 4. Configuration: fragmentation (landscape level)
# ---------------------------------------------------------------------
metrics <- c("lsm_l_np", "lsm_l_ed", "lsm_l_shdi", "lsm_l_contag", "lsm_l_lpi")
land <- bind_rows(
  calculate_lsm(lc90_p, what = metrics) |> mutate(year = 1990),
  calculate_lsm(lc26_p, what = metrics) |> mutate(year = 2026)
)
land |> select(year, metric, value) |> pivot_wider(names_from = year, values_from = value)
# np: number of patches · ed: edge density (m/ha) · shdi: Shannon
# diversity · contag: contagion (aggregation, 0–100) · lpi: % covered
# by the largest patch.

# Documentation for any metric:
list_lsm(metric = "contag")


# ---------------------------------------------------------------------
# 5. Mountain meadows: patches getting smaller
# ---------------------------------------------------------------------
meadow <- bind_rows(
  calculate_lsm(lc90_p, what = c("lsm_c_np", "lsm_c_area_mn", "lsm_c_pland")) |> mutate(year = 1990),
  calculate_lsm(lc26_p, what = c("lsm_c_np", "lsm_c_area_mn", "lsm_c_pland")) |> mutate(year = 2026)
) |> filter(class == 6)
meadow |> select(year, metric, value) |> pivot_wider(names_from = metric, values_from = value)

# Size of each meadow patch (ha)
patch_area <- bind_rows(
  lsm_p_area(lc90_p) |> mutate(year = 1990),
  lsm_p_area(lc26_p) |> mutate(year = 2026)
) |> filter(class == 6)

p_patches <- ggplot(patch_area, aes(value, fill = factor(year))) +
  geom_histogram(bins = 25, position = "dodge") +
  scale_x_log10(labels = scales::label_number(drop0trailing = TRUE)) +
  labs(x = "Patch area (ha, log scale)", y = "Number of patches", fill = NULL,
       title = "Meadow patches in 1990 and 2026") +
  theme_minimal(base_size = 13)
p_patches


# ---------------------------------------------------------------------
# 6. Metrics in windows: scale matters
# ---------------------------------------------------------------------
# Shannon diversity in 1.5 km squares across the 2026 map: where is the
# landscape most diverse?
grid <- st_make_grid(st_as_sfc(st_bbox(lc26)), cellsize = 1500) |> st_sf()
shdi_grid <- sample_lsm(lc26, y = grid, what = "lsm_l_shdi")
grid$shdi <- shdi_grid$value[match(seq_len(nrow(grid)), shdi_grid$plot_id)]

p_grid <- ggplot(grid) +
  geom_sf(aes(fill = shdi), colour = "white") +
  geom_sf(data = park, fill = NA, colour = "black", linewidth = 0.8) +
  scale_fill_viridis_c(name = "SHDI") +
  labs(title = "Shannon diversity in 1.5 km squares (2026)") +
  coord_sf(datum = st_crs(park)) +
  theme_minimal()
p_grid


# ---------------------------------------------------------------------
# 7. Save
# ---------------------------------------------------------------------
dir.create("outputs", showWarnings = FALSE)
write_csv(land, "outputs/landscape_metrics_1990_2026.csv")
write.csv(trans_ha, "outputs/transition_matrix_ha.csv")
ggsave("outputs/composition.png", p_pland, width = 7, height = 5, dpi = 300, bg = "white")
ggsave("outputs/meadow_patches.png", p_patches, width = 7, height = 4.5, dpi = 300, bg = "white")
ggsave("outputs/shdi_grid.png", p_grid, width = 7, height = 6, dpi = 300, bg = "white")


# =====================================================================
#  EXERCISES  (answers in week12_solutions.R)
# =====================================================================
# E1. How many hectares of 1990 meadow are heathland today? And beech
#     forest? (Use trans_ha.)
# E2. Calculate beech forest edge density (lsm_c_ed) in 1990 and 2026.
# E3. Repeat section 6 with 3 km squares. Does the pattern change?
# E4. Pick three landscape metrics we have not used
#     (list_lsm(level = "landscape")) and explain what they measure.
# E5. Final project: prepare a short analysis with these data (or your
#     own) that goes from data to map. See the Week 12 handout.
# =====================================================================
