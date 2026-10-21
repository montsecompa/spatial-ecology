# =====================================================================
#  Spatial Ecology  ·  Week 9  ·  Solutions
# =====================================================================
# Run week09_spatial_autocorrelation.R first.

# E1. Neighbours: the 4 nearest
lw_k4 <- nb2listw(knn2nb(knearneigh(xy, k = 4)), style = "W")
moran.test(pts$resid, lw_k4)

# E2. Moran's I for richness
rich <- read_csv("data/bird_counts_wide.csv") |>
  pivot_longer(european_robin:short_toed_treecreeper, names_to = "species", values_to = "count") |>
  filter(!is.na(count)) |>
  group_by(point_id) |>
  summarise(richness = n_distinct(species[count > 0]))
pts <- left_join(pts, rich, by = "point_id")
moran.test(pts$richness, lw, zero.policy = TRUE)

# E3. Exponential model
v_exp <- fit.variogram(v, vgm(psill = 6, model = "Exp", range = 2000, nugget = 2))
v_exp
# In the exponential model the "practical range" is about 3 times the
# range parameter (distance where 95% of the sill is reached).
3 * v_exp$range[2]

# E4. Mean nearest-neighbour distance
c(treecreeper = mean(nndist(tree)), bonelli = mean(nndist(bon)))

# E5. G function
plot(envelope(tree, Gest, nsim = 99, verbose = FALSE))
plot(envelope(bon, Gest, nsim = 99, verbose = FALSE))
# G(r) above the band indicates clustering; below it, regularity.
