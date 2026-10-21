# =====================================================================
#  Spatial Ecology  ·  Week 6  ·  Solutions
# =====================================================================
# Run week06_sf_and_terra.R up to section 6 first.

# E1. Points within 500 m of the park boundary
d_edge <- as.numeric(st_distance(pts, st_boundary(park)))
sum(d_edge < 500)

# E2. Area of each elevation belt
freq(belts) |> as_tibble() |> mutate(area_ha = count * prod(res(belts)) / 10000)

# E3. Mean slope in the park and in the riparian zone
riparian_park <- st_intersection(st_sf(geometry = riparian), park)
c(park     = terra::extract(slope, vect(park), fun = mean, na.rm = TRUE)[, 2],
  riparian = terra::extract(slope, vect(riparian_park), fun = mean, na.rm = TRUE)[, 2])

# E4. Proportion of beech forest within 500 m
beech <- lc == 4
pts$beech_500 <- terra::extract(beech, vect(st_buffer(pts, 500)), fun = mean, na.rm = TRUE)[, 2]
pts |> st_drop_geometry() |> select(point_id, habitat, beech_500) |> slice_max(beech_500, n = 3)

# E5. Save the elevation belts
writeRaster(belts, "outputs/elevation_belts.tif", overwrite = TRUE)
# In QGIS: Layer > Add Layer > Add Raster Layer, then use the
# "Paletted/Unique values" symbology.
