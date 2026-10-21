# =====================================================================
#  Spatial Ecology  ·  Week 11  ·  Solutions
# =====================================================================
# Run week11_home_ranges.R first.

# E1. Least-squares cross-validation bandwidth (LSCV)
ud_lscv <- kernelUD(gps_sp, h = "LSCV", grid = 200, extent = 1.2)
cbind(href = kernel.area(ud, percent = 95, unin = "m", unout = "ha"),
      lscv = kernel.area(ud_lscv, percent = 95, unin = "m", unout = "ha"))
# LSCV usually gives smaller areas. If it warns about convergence,
# look at plotLSCV(ud_lscv).

# E2. Overlap between GEN02 and GEN03
a <- filter(kde95_sf, id == "GEN02"); b <- filter(kde95_sf, id == "GEN03")
inter <- st_intersection(st_geometry(a), st_geometry(b))
overlap_ha <- if (length(inter)) sum(as.numeric(st_area(inter))) / 1e4 else 0
overlap_ha
ud_same <- kernelUD(gps_sp, h = "href", grid = 200, extent = 1.2, same4all = TRUE)   # same grid for all
kerneloverlaphr(ud_same, method = "HR", percent = 95)   # proportion of i's range inside j's

# E3. Total distance travelled
ld(traj) |> as_tibble() |> group_by(id) |> summarise(total_km = sum(dist, na.rm = TRUE) / 1000)
# This is a minimum: between two fixes the animal does not move in a straight line.

# E4. Night and day MCPs
gps_sf$period <- if_else(hour(gps_sf$timestamp) >= 18 | hour(gps_sf$timestamp) < 6, "night", "day")
for (p in c("night", "day")) {
  sub <- as(gps_sf[gps_sf$period == p, "animal_id"], "Spatial")
  cat(p, "\n"); print(as.data.frame(mcp(sub, percent = 95, unin = "m", unout = "ha")))
}
# During the day genets rest in dens and barely move, so the day MCP is
# usually smaller (it mostly shows where they sleep).

# E5. Most selected habitat per animal
selection |> filter(n_used >= 5) |> group_by(animal_id) |> slice_max(ratio, n = 1) |>
  select(animal_id, class_en, ratio)
