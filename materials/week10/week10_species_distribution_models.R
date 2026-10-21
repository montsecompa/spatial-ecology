# =====================================================================
#  Spatial Ecology  ·  Week 10
#  Species distribution models (SDMs)
# =====================================================================
#  Files in data/: gbif_lullula_arborea_clean.csv (from Week 8),
#    dem.tif, landcover.tif, tavg.tif, prec.tif, montfred.gpkg
#  Packages: install.packages(c("terra", "sf", "maxnet", "tidyverse"))
#
#  Question: where is habitat suitable for woodlark in the Sierra de
#  Montfred? We use presences (GBIF) and background points.
#  With real data you would use WorldClim layers (worldclim.org); here
#  tavg.tif and prec.tif imitate those layers at a local scale.
# =====================================================================

library(tidyverse)
library(sf)
library(terra)
library(maxnet)


# ---------------------------------------------------------------------
# 1. Environmental variables (predictors)
# ---------------------------------------------------------------------
dem  <- rast("data/dem.tif")
lc   <- rast("data/landcover.tif")
tavg <- rast("data/tavg.tif")
prec <- rast("data/prec.tif")

# Birds respond to the surrounding landscape, not a single 30 m cell:
# we calculate the proportion of open habitat (heath, meadow) in ~250 m.
open_cell <- lc %in% c(5, 6)
open_250  <- focal(open_cell, w = focalMat(open_cell, 250, "circle"), fun = "sum", na.rm = TRUE)
forest_cell <- lc %in% c(1, 2, 3, 4)
forest_250  <- focal(forest_cell, w = focalMat(forest_cell, 250, "circle"), fun = "sum", na.rm = TRUE)
slope <- terrain(dem, "slope", unit = "degrees")

env <- c(dem, tavg, prec, slope, open_250, forest_250)
names(env) <- c("elevation", "tavg", "prec", "slope", "open_250", "forest_250")
plot(env)


# ---------------------------------------------------------------------
# 2. Correlation among predictors
# ---------------------------------------------------------------------
set.seed(10)
env_sample <- spatSample(env, 3000, "random", na.rm = TRUE)
round(cor(env_sample), 2)
# Temperature and precipitation depend almost entirely on elevation
# (|r| > 0.9). Using all three gives unstable coefficients. Keep one:
# elevation. The same goes for open_250 and forest_250.
env <- env[[c("elevation", "slope", "open_250")]]


# ---------------------------------------------------------------------
# 3. Presences and background points
# ---------------------------------------------------------------------
occ <- read_csv("data/gbif_lullula_arborea_clean.csv")
park <- st_read("data/montfred.gpkg", "park_boundary", quiet = TRUE)
study_area <- vect(st_buffer(park, 3000))
env <- crop(env, study_area) |> mask(study_area)

pres <- occ |> select(x, y)
# The background describes the environment available in the study area
set.seed(1)
bg <- spatSample(env[[1]], 3000, "random", na.rm = TRUE, xy = TRUE) |> select(x, y)

dat <- bind_rows(
  bind_cols(pres, terra::extract(env, as.matrix(pres)), pa = 1),
  bind_cols(bg,   terra::extract(env, as.matrix(bg)),   pa = 0)
) |> drop_na()
table(dat$pa)

# Where are the presences compared with the background?
dat |>
  pivot_longer(elevation:open_250) |>
  mutate(pa = if_else(pa == 1, "presence", "background")) |>
  ggplot(aes(value, fill = pa)) +
  geom_density(alpha = 0.5) +
  facet_wrap(~ name, scales = "free") +
  labs(fill = NULL) + theme_minimal()


# ---------------------------------------------------------------------
# 4. Model 1: GLM (weighted logistic regression)
# ---------------------------------------------------------------------
# Give presences and background the same total weight. The quadratic
# term allows an elevation optimum (bell-shaped curve).
w <- ifelse(dat$pa == 1, 1, sum(dat$pa == 1) / sum(dat$pa == 0))
m_glm <- glm(pa ~ elevation + I(elevation^2) + slope + open_250,
             family = binomial, weights = w, data = dat)
summary(m_glm)

suit_glm <- predict(env, m_glm, type = "response")
plot(suit_glm)


# ---------------------------------------------------------------------
# 5. Model 2: MaxEnt (maxnet package)
# ---------------------------------------------------------------------
m_mx <- maxnet(dat$pa, dat[, c("elevation", "slope", "open_250")],
               f = maxnet.formula(dat$pa, dat[, c("elevation", "slope", "open_250")], classes = "lqh"))
plot(m_mx, type = "cloglog")   # response curves

suit_mx <- predict(env, m_mx, type = "cloglog", na.rm = TRUE)
plot(suit_mx)


# ---------------------------------------------------------------------
# 6. Evaluation: AUC with random and spatial-block cross-validation
# ---------------------------------------------------------------------
# AUC = probability that a random presence scores higher than a random
# background point (0.5 = random, 1 = perfect).
auc <- function(p, a) mean(outer(p, a, ">") + 0.5 * outer(p, a, "=="))

# Random CV: 5 random folds
set.seed(5)
dat$fold_random <- sample(rep(1:5, length.out = nrow(dat)))
# Block CV: 3 km squares; each whole block goes to one fold
dat$block <- paste(floor(dat$x / 3000), floor(dat$y / 3000))
blocks <- unique(dat$block)
dat$fold_block <- setNames(sample(rep(1:5, length.out = length(blocks))), blocks)[dat$block]

cv_auc <- function(fold_col) {
  sapply(1:5, function(k) {
    train <- dat[dat[[fold_col]] != k, ]; test <- dat[dat[[fold_col]] == k, ]
    wk <- ifelse(train$pa == 1, 1, sum(train$pa == 1) / sum(train$pa == 0))
    mk <- glm(pa ~ elevation + I(elevation^2) + slope + open_250, family = binomial, weights = wk, data = train)
    pr <- predict(mk, test, type = "response")
    auc(pr[test$pa == 1], pr[test$pa == 0])
  })
}
cv <- tibble(random = cv_auc("fold_random"), blocks = cv_auc("fold_block"))
cv
colMeans(cv)
# Block CV usually gives a lower, more realistic AUC: test data are far
# from training data, as when predicting to a new place.


# ---------------------------------------------------------------------
# 7. Presence/absence map with a threshold
# ---------------------------------------------------------------------
# Threshold that maximises sensitivity + specificity
p_pres <- predict(m_glm, dat[dat$pa == 1, ], type = "response")
p_bg   <- predict(m_glm, dat[dat$pa == 0, ], type = "response")
th <- seq(0.01, 0.99, by = 0.01)
tss <- sapply(th, function(t) mean(p_pres >= t) + mean(p_bg < t) - 1)
best <- th[which.max(tss)]
best

suitable <- suit_glm >= best
# Suitable area inside the park (ha)
suit_park <- mask(crop(suitable, vect(park)), vect(park))
sum(values(suit_park) == 1, na.rm = TRUE) * prod(res(suit_park)) / 10000


# ---------------------------------------------------------------------
# 8. Save
# ---------------------------------------------------------------------
dir.create("outputs", showWarnings = FALSE)
writeRaster(suit_glm, "outputs/woodlark_suitability_glm.tif", overwrite = TRUE)
writeRaster(suit_mx, "outputs/woodlark_suitability_maxent.tif", overwrite = TRUE)
png("outputs/sdm_maps.png", width = 2400, height = 1100, res = 220)
par(mfrow = c(1, 2), mar = c(2, 2, 3, 5))
plot(suit_glm, main = "GLM: suitability", range = c(0, 1)); plot(st_geometry(park), add = TRUE)
points(pres, pch = 20, cex = 0.4)
plot(suit_mx, main = "MaxEnt: suitability (cloglog)", range = c(0, 1)); plot(st_geometry(park), add = TRUE)
dev.off()


# =====================================================================
#  EXERCISES  (answers in week10_solutions.R)
# =====================================================================
# E1. Fit the GLM without the quadratic term. Which model has the lower
#     AIC? Plot the elevation response curve of both.
# E2. Replace elevation with temperature (tavg). Does the map change?
#     Why?
# E3. Calculate the correlation between the GLM and MaxEnt maps
#     (hint: layerCor() or cor() of the values).
# E4. Repeat block CV with 1.5 km and 5 km squares. How does AUC change?
# E5. What percentage of the park is suitable according to the threshold?
# =====================================================================
