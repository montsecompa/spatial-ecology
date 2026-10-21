# =====================================================================
#  Spatial Ecology  ·  Week 9
#  Spatial autocorrelation and point patterns
# =====================================================================
#  Files in data/: survey_points.csv, bird_counts_wide.csv, montfred.gpkg
#  Packages: install.packages(c("spdep", "gstat", "spatstat", "sf", "tidyverse"))
#
#  Tobler's first law of geography: everything is related to
#  everything else, but near things are more related than distant things.
# =====================================================================

library(tidyverse)
library(sf)
library(spdep)      # Moran's I
library(gstat)      # variograms
library(spatstat)   # point patterns


# ---------------------------------------------------------------------
# 1. Data: abundance per point in UTM coordinates
# ---------------------------------------------------------------------
abund <- read_csv("data/bird_counts_wide.csv") |>
  mutate(total = rowSums(across(european_robin:short_toed_treecreeper), na.rm = TRUE)) |>
  group_by(point_id) |>
  summarise(abundance = mean(total))
pts <- read_csv("data/survey_points.csv") |>
  left_join(abund, by = "point_id") |>
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326) |>
  st_transform(25831)
xy <- st_coordinates(pts)

# Non-spatial model from Week 3: are there spatial patterns left in the residuals?
m <- lm(abundance ~ elevation_m, data = pts)
pts$resid <- resid(m)


# ---------------------------------------------------------------------
# 2. Neighbours and spatial weights
# ---------------------------------------------------------------------
# Neighbours are points less than 2,500 m apart.
nb <- dnearneigh(xy, 0, 2500)
summary(nb)
lw <- nb2listw(nb, style = "W", zero.policy = TRUE)   # row-standardised weights

plot(st_geometry(pts), pch = 19)
plot(nb, xy, add = TRUE, col = "grey60")


# ---------------------------------------------------------------------
# 3. Moran's I
# ---------------------------------------------------------------------
# I > 0: similar values cluster; I ~ 0: random;
# I < 0: dissimilar values are neighbours (like a chessboard).
moran.test(pts$abundance, lw, zero.policy = TRUE)
moran.test(pts$resid, lw, zero.policy = TRUE)

# Permutation version (no normality assumption)
set.seed(9)
moran.mc(pts$resid, lw, nsim = 999, zero.policy = TRUE)


# ---------------------------------------------------------------------
# 4. Correlogram: Moran's I at different distances
# ---------------------------------------------------------------------
bands <- seq(0, 8000, by = 1000)
correlogram <- map_dfr(seq_len(length(bands) - 1), function(i) {
  nb_i <- dnearneigh(xy, bands[i], bands[i + 1])
  if (sum(card(nb_i)) == 0) return(NULL)
  mt <- moran.test(pts$abundance, nb2listw(nb_i, style = "W", zero.policy = TRUE), zero.policy = TRUE)
  tibble(distance_km = (bands[i] + bands[i + 1]) / 2000, I = mt$estimate[1], p = mt$p.value)
})
correlogram

p_cor <- ggplot(correlogram, aes(distance_km, I)) +
  geom_hline(yintercept = 0, linetype = 2) +
  geom_line() + geom_point(aes(fill = p < 0.05), shape = 21, size = 3) +
  scale_fill_manual(values = c(`TRUE` = "black", `FALSE` = "white"), name = "p < 0.05") +
  labs(x = "Distance (km)", y = "Moran's I", title = "Correlogram of bird abundance") +
  theme_minimal(base_size = 13)
p_cor


# ---------------------------------------------------------------------
# 5. Semivariogram
# ---------------------------------------------------------------------
# It measures how different values are as a function of distance.
# Nugget: variation at ~0 distance (error, micro-scale).
# Sill: total variation. Range: distance beyond which values are no
# more similar than expected.
v <- variogram(abundance ~ 1, data = pts, cutoff = 9000, width = 1000)
v_fit <- fit.variogram(v, vgm(psill = 6, model = "Sph", range = 4000, nugget = 2))
v_fit
plot(v, v_fit)

# Variogram of the residuals: if elevation explains the spatial
# structure, it should be nearly flat.
v_res <- variogram(resid ~ 1, data = pts, cutoff = 9000, width = 1000)
plot(v_res)


# ---------------------------------------------------------------------
# 6. Point patterns: nests in a 2 x 2 km plot
# ---------------------------------------------------------------------
nests <- st_read("data/montfred.gpkg", "nests", quiet = TRUE)
plot_area <- st_read("data/montfred.gpkg", "nest_plot", quiet = TRUE)
count(st_drop_geometry(nests), species)

# spatstat uses its own format: ppp (point pattern) inside a
# window (owin).
win <- as.owin(st_geometry(plot_area))
make_ppp <- function(sp) {
  d <- st_coordinates(filter(nests, species == sp))
  ppp(d[, 1], d[, 2], window = win)
}
tree <- make_ppp("short_toed_treecreeper")
bon  <- make_ppp("western_bonellis_warbler")

par(mfrow = c(1, 2))
plot(tree, main = "Treecreeper", pch = 19, cex = 0.6); plot(bon, main = "Bonelli's warbler", pch = 19, cex = 0.6)
par(mfrow = c(1, 1))

# Intensity: nests per km²
intensity(tree) * 1e6
intensity(bon) * 1e6

# Quadrat test: does it fit a random (Poisson) pattern?
quadrat.test(tree, nx = 4, ny = 4)
quadrat.test(bon, nx = 4, ny = 4)


# ---------------------------------------------------------------------
# 7. Ripley's L function with simulation envelopes
# ---------------------------------------------------------------------
# L(r) - r > 0: more neighbours than expected at distance r (clustering).
# L(r) - r < 0: fewer neighbours (regularity, territoriality).
# The grey band is what to expect at random (99 simulations).
set.seed(99)
env_tree <- envelope(tree, Lest, nsim = 99, correction = "border", verbose = FALSE)
env_bon  <- envelope(bon,  Lest, nsim = 99, correction = "border", verbose = FALSE)

to_df <- function(env, label) as.data.frame(env) |> transmute(r, obs = obs - r, lo = lo - r, hi = hi - r, species = label)
env_df <- bind_rows(to_df(env_tree, "Treecreeper (clustered)"), to_df(env_bon, "Bonelli's warbler (regular)"))
p_L <- ggplot(env_df, aes(r)) +
  geom_ribbon(aes(ymin = lo, ymax = hi), fill = "grey80") +
  geom_hline(yintercept = 0, linetype = 2) +
  geom_line(aes(y = obs), linewidth = 0.9) +
  facet_wrap(~ species) +
  labs(x = "Distance r (m)", y = "L(r) - r", title = "Ripley's L function") +
  theme_minimal(base_size = 13)
p_L


# ---------------------------------------------------------------------
# 8. Save
# ---------------------------------------------------------------------
dir.create("outputs", showWarnings = FALSE)
ggsave("outputs/correlogram.png", p_cor, width = 7, height = 4.5, dpi = 300, bg = "white")
ggsave("outputs/ripley_L.png", p_L, width = 9, height = 4.5, dpi = 300, bg = "white")
png("outputs/variogram.png", width = 1600, height = 1200, res = 220); print(plot(v, v_fit)); dev.off()


# =====================================================================
#  EXERCISES  (answers in week09_solutions.R)
# =====================================================================
# E1. Repeat Moran's I for the residuals, defining neighbours as the 4
#     nearest points (knearneigh(xy, k = 4)). Does the conclusion change?
# E2. Calculate Moran's I for species richness.
# E3. Fit the variogram with an exponential model ("Exp"). What range
#     do you get?
# E4. Calculate the mean nearest-neighbour distance (nndist()) for each
#     species. Which one has the most widely spaced nests?
# E5. Use the G function (Gest) instead of L. Do you reach the same
#     conclusion?
# =====================================================================
