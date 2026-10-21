# =====================================================================
#  Spatial Ecology  ·  Week 6
#  Spatial data in R with sf and terra
# =====================================================================
#  Files in data/: survey_points.csv, montfred.gpkg, dem.tif,
#                  landcover.tif, landcover_classes.csv
#  Packages: install.packages(c("sf", "terra", "tidyverse"))
#  We repeat the Week 5 QGIS workflow in code, so the analysis is
#  fully reproducible.
# =====================================================================

library(tidyverse)
library(sf)      # vector data (points, lines, polygons)
library(terra)   # raster data


# ---------------------------------------------------------------------
# 1. Reading vector data
# ---------------------------------------------------------------------
st_layers("data/montfred.gpkg")    # layers inside the GeoPackage

park    <- st_read("data/montfred.gpkg", layer = "park_boundary")
streams <- st_read("data/montfred.gpkg", layer = "streams")

park              # an sf object is a data frame with a geometry column
st_crs(park)      # ETRS89 / UTM zone 31N (EPSG:25831), in metres

plot(st_geometry(park), col = "grey95")
plot(st_geometry(streams), col = "steelblue", add = TRUE)


# ---------------------------------------------------------------------
# 2. From CSV to points, and reprojecting
# ---------------------------------------------------------------------
pts_ll <- read_csv("data/survey_points.csv") |>
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)   # WGS84, degrees
st_crs(pts_ll)$epsg

# To measure distances and areas in metres, project to the park's CRS
pts <- st_transform(pts_ll, st_crs(park))
st_coordinates(pts)[1:3, ]

# Compare distances: in degrees they are meaningless; in UTM they are metres
st_distance(pts[1:3, ])


# ---------------------------------------------------------------------
# 3. Vector operations
# ---------------------------------------------------------------------
# Park area in hectares
as.numeric(st_area(park)) / 10000

# Which points are inside the park?
pts$in_park <- lengths(st_intersects(pts, park)) > 0
table(pts$in_park)

# A 150 m buffer around the streams
riparian <- st_buffer(streams, 150) |> st_union()
pts$riparian <- lengths(st_intersects(pts, riparian)) > 0
table(pts$riparian)

# Distance from each point to the nearest stream (check dist_stream_m)
pts$dist_calc <- apply(st_distance(pts, streams), 1, min)
pts |> st_drop_geometry() |> select(point_id, dist_stream_m, dist_calc) |> head()

# Length of each stream inside the park, in km
streams_park <- st_intersection(streams, park)
streams_park$length_km <- as.numeric(st_length(streams_park)) / 1000
streams_park |> st_drop_geometry() |> select(name, length_km)


# ---------------------------------------------------------------------
# 4. Reading and exploring rasters
# ---------------------------------------------------------------------
dem <- rast("data/dem.tif")
lc  <- rast("data/landcover.tif")
dem             # dimensions, resolution (30 m), extent and CRS
res(dem); crs(dem, describe = TRUE)
global(dem, c("min", "max", "mean"), na.rm = TRUE)

plot(dem)
plot(st_geometry(park), add = TRUE, border = "black")

# Terrain derivatives: slope, aspect and hillshade
slope  <- terrain(dem, "slope", unit = "degrees")
aspect <- terrain(dem, "aspect", unit = "radians")
hill   <- shade(terrain(dem, "slope", unit = "radians"), aspect, angle = 40, direction = 315)
plot(hill, col = grey(0:100 / 100), legend = FALSE)


# ---------------------------------------------------------------------
# 5. Crop, mask and reclassify
# ---------------------------------------------------------------------
dem_park <- crop(dem, park) |> mask(vect(park))   # crop to the extent, then mask outside the park
plot(dem_park)

# Elevation belts: < 600, 600–1000, 1000–1300, > 1300 m
rcl <- matrix(c(-Inf, 600, 1,  600, 1000, 2,  1000, 1300, 3,  1300, Inf, 4), ncol = 3, byrow = TRUE)
belts <- classify(dem_park, rcl)
freq(belts)

# Area of each land-cover class inside the park (ha)
classes <- read_csv("data/landcover_classes.csv")
lc_park <- crop(lc, park) |> mask(vect(park))
lc_area <- freq(lc_park) |>
  as_tibble() |>
  mutate(area_ha = count * prod(res(lc_park)) / 10000) |>
  left_join(classes, by = "value") |>
  select(value, class = class_en, area_ha) |>
  arrange(desc(area_ha))
lc_area


# ---------------------------------------------------------------------
# 6. Extract raster values at the points
# ---------------------------------------------------------------------
pts$dem_m  <- terra::extract(dem, vect(pts))[, 2]
pts$slope  <- terra::extract(slope, vect(pts))[, 2]
pts$lc_code <- terra::extract(lc, vect(pts))[, 2]

# GPS altimeter versus digital elevation model
ggplot(pts, aes(dem_m, elevation_m)) +
  geom_abline(linetype = 2) + geom_point() +
  labs(x = "DEM elevation (m)", y = "Field-recorded elevation (m)") +
  theme_minimal()

# Mean within a zone around each point: 250 m buffer
buf <- st_buffer(pts, 250)
pts$slope_250 <- terra::extract(slope, vect(buf), fun = mean, na.rm = TRUE)[, 2]

# Proportion of open habitat (heathland or meadow) within 250 m
open <- lc %in% c(5, 6)
pts$open_250 <- terra::extract(open, vect(buf), fun = mean, na.rm = TRUE)[, 2]
pts |> st_drop_geometry() |> select(point_id, habitat, slope_250, open_250) |> arrange(desc(open_250)) |> head()


# ---------------------------------------------------------------------
# 7. Save results
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
title("Sierra de Montfred: terrain, streams and survey points")
dev.off()


# =====================================================================
#  EXERCISES  (answers in week06_solutions.R)
# =====================================================================
# E1. How many survey points are less than 500 m from the park
#     boundary? (Hint: st_boundary() and st_distance().)
# E2. Calculate the area (ha) of each elevation belt (belts).
# E3. Extract the mean slope of the park and compare it with the mean
#     slope of the riparian zone (150 m buffer).
# E4. For each point, calculate the proportion of beech forest (code 4)
#     within 500 m. Which point has the most?
# E5. Challenge: save the elevation-belt raster and open it in QGIS.
# =====================================================================
