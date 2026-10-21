# =====================================================================
#  Spatial Ecology  ·  Week 11
#  Home ranges and animal movement
# =====================================================================
#  Files in data/: genet_gps.csv, genet_animals.csv, landcover.tif,
#                  landcover_classes.csv, montfred.gpkg
#  Packages: install.packages(c("adehabitatHR", "sf", "terra", "tidyverse"))
#  (adehabitatHR also installs adehabitatLT, for trajectories)
#
#  SIMULATED data: three common genets (Genetta genetta) with GPS
#  collars, one fix every 2 hours for 30 days (March 2026).
# =====================================================================

library(tidyverse)
library(sf)
library(terra)
library(adehabitatHR)
library(adehabitatLT)


# ---------------------------------------------------------------------
# 1. Read and check the fixes
# ---------------------------------------------------------------------
# read_csv() recognises the timestamp column as date-time (UTC)
gps <- read_csv("data/genet_gps.csv") |>
  arrange(animal_id, timestamp)
class(gps$timestamp)
animals <- read_csv("data/genet_animals.csv")
animals

gps |> count(animal_id)
# Interval between fixes: should be 2 h; gaps are missed fixes
gps |>
  group_by(animal_id) |>
  mutate(dt_h = as.numeric(difftime(timestamp, lag(timestamp), units = "hours"))) |>
  count(dt_h)

park <- st_read("data/montfred.gpkg", "park_boundary", quiet = TRUE)
gps_sf <- st_as_sf(gps, coords = c("x", "y"), crs = 25831, remove = FALSE)

p_tracks <- ggplot() +
  geom_sf(data = park, fill = "grey95") +
  geom_path(data = gps, aes(x, y, colour = animal_id), linewidth = 0.3, alpha = 0.7) +
  geom_point(data = gps, aes(x, y, colour = animal_id), size = 0.6) +
  labs(x = NULL, y = NULL, colour = "Genet", title = "GPS tracks") +
  coord_sf(datum = st_crs(park)) +
  theme_minimal()
p_tracks


# ---------------------------------------------------------------------
# 2. Minimum convex polygon (MCP)
# ---------------------------------------------------------------------
# adehabitatHR uses objects from the sp package, sf's predecessor.
gps_sp <- as(gps_sf[, "animal_id"], "Spatial")

mcp95  <- mcp(gps_sp, percent = 95, unin = "m", unout = "ha")
mcp100 <- mcp(gps_sp, percent = 100, unin = "m", unout = "ha")
as.data.frame(mcp95)

# How does area change with the percentage of fixes included?
mcp.area(gps_sp, percent = seq(50, 100, by = 10), unin = "m", unout = "ha")


# ---------------------------------------------------------------------
# 3. Kernel density estimation (KDE)
# ---------------------------------------------------------------------
# h = "href" is the reference bandwidth; it tends to overestimate area
# when use is highly concentrated. Also try h = "LSCV".
ud <- kernelUD(gps_sp, h = "href", grid = 200, extent = 1.2)
image(ud)

kde95 <- getverticeshr(ud, percent = 95, unin = "m", unout = "ha")
kde50 <- getverticeshr(ud, percent = 50, unin = "m", unout = "ha")   # core area

hr <- bind_rows(
  as.data.frame(mcp95)  |> mutate(method = "MCP 95%"),
  as.data.frame(kde95)  |> mutate(method = "KDE 95%"),
  as.data.frame(kde50)  |> mutate(method = "KDE 50%")
) |> rename(animal_id = id, area_ha = area) |>
  pivot_wider(names_from = method, values_from = area_ha) |>
  left_join(animals, by = "animal_id")
hr

kde95_sf <- st_as_sf(kde95)
kde50_sf <- st_as_sf(kde50)
mcp95_sf <- st_as_sf(mcp95)

p_hr <- ggplot() +
  geom_sf(data = park, fill = "grey97", colour = "grey60") +
  geom_sf(data = kde95_sf, aes(fill = id), alpha = 0.25, colour = NA) +
  geom_sf(data = kde50_sf, aes(fill = id), alpha = 0.6, colour = NA) +
  geom_sf(data = mcp95_sf, aes(colour = id), fill = NA, linetype = 2) +
  geom_point(data = gps, aes(x, y), size = 0.2, colour = "grey30") +
  labs(x = NULL, y = NULL, fill = "KDE 50 and 95%", colour = "MCP 95%", title = "Genet home ranges") +
  coord_sf(xlim = range(gps$x) + c(-800, 800), ylim = range(gps$y) + c(-800, 800), datum = st_crs(park)) +
  theme_minimal()
p_hr


# ---------------------------------------------------------------------
# 4. Trajectories: step length and turning angle
# ---------------------------------------------------------------------
traj <- as.ltraj(xy = gps[, c("x", "y")], date = gps$timestamp, id = gps$animal_id)
traj
steps <- ld(traj) |>
  as_tibble() |>
  mutate(hour = hour(date), speed_m_h = dist / (dt / 3600)) |>
  filter(!is.na(dist), dt == 7200)   # only exact 2 h steps

# Genets are nocturnal: do they move more at night?
p_activity <- steps |>
  group_by(id, hour) |>
  summarise(step_m = median(dist), .groups = "drop") |>
  ggplot(aes(hour, step_m, colour = id)) +
  geom_line() + geom_point() +
  scale_x_continuous(breaks = seq(0, 22, 2)) +
  labs(x = "Hour (UTC)", y = "Median 2 h step (m)", colour = "Genet", title = "Activity rhythm") +
  theme_minimal()
p_activity

# Distribution of turning angles (rel.angle, radians)
ggplot(filter(steps, dist > 50), aes(rel.angle)) +
  geom_histogram(bins = 24, fill = "grey70", colour = "white") +
  labs(x = "Turning angle (radians)", y = "Steps") +
  theme_minimal()


# ---------------------------------------------------------------------
# 5. Habitat selection: use versus availability
# ---------------------------------------------------------------------
lc <- rast("data/landcover.tif")
classes <- read_csv("data/landcover_classes.csv")

# Use: habitat at each fix. Availability: habitat inside each animal's
# 100% MCP (third-order selection, Johnson 1980).
used <- gps |>
  mutate(value = terra::extract(lc, as.matrix(gps[, c("x", "y")]))[, 1]) |>
  count(animal_id, value, name = "n_used")
avail <- map_dfr(seq_len(nrow(mcp100)), function(i) {
  poly <- vect(st_as_sf(mcp100[i, ]))
  freq(mask(crop(lc, poly), poly)) |> as_tibble() |> transmute(animal_id = mcp100$id[i], value, n_avail = count)
})
selection <- full_join(used, avail, by = c("animal_id", "value")) |>
  replace_na(list(n_used = 0, n_avail = 0)) |>
  group_by(animal_id) |>
  mutate(prop_used = n_used / sum(n_used), prop_avail = n_avail / sum(n_avail),
         ratio = prop_used / prop_avail) |>   # > 1 selected, < 1 avoided
  ungroup() |>
  left_join(classes, by = "value")
selection |> select(animal_id, class_en, prop_used, prop_avail, ratio) |> arrange(animal_id, desc(ratio))


# ---------------------------------------------------------------------
# 6. Save
# ---------------------------------------------------------------------
dir.create("outputs", showWarnings = FALSE)
write_csv(hr, "outputs/home_range_areas.csv")
st_write(kde95_sf, "outputs/home_ranges.gpkg", "kde95", delete_dsn = TRUE, quiet = TRUE)
st_write(kde50_sf, "outputs/home_ranges.gpkg", "kde50", append = TRUE, quiet = TRUE)
ggsave("outputs/home_ranges.png", p_hr, width = 8, height = 6, dpi = 300, bg = "white")
ggsave("outputs/activity.png", p_activity, width = 7, height = 4, dpi = 300, bg = "white")


# =====================================================================
#  EXERCISES  (answers in week11_solutions.R)
# =====================================================================
# E1. Recalculate the KDEs with h = "LSCV". Are the areas larger or
#     smaller than with href?
# E2. How much do the 95% KDEs of GEN02 and GEN03 overlap? (Hint:
#     st_intersection() and st_area(), or kerneloverlaphr().)
# E3. What total distance did each genet travel during the month?
# E4. Calculate the 95% MCP with night fixes only (18–06 h) and with
#     day fixes only. Which is larger?
# E5. Which habitat does each animal select most? Do all three agree?
# =====================================================================
