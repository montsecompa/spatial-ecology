# =====================================================================
#  Spatial Ecology  ·  Week 10  ·  Solutions
# =====================================================================
# Run week10_species_distribution_models.R first.

# E1. Without the quadratic term
m_lin <- glm(pa ~ elevation + slope + open_250, family = binomial, weights = w, data = dat)
AIC(m_lin, m_glm)
curve_df <- tibble(elevation = seq(min(dat$elevation), max(dat$elevation), length.out = 200),
                   slope = mean(dat$slope), open_250 = mean(dat$open_250))
curve_df$quadratic <- predict(m_glm, curve_df, type = "response")
curve_df$linear    <- predict(m_lin, curve_df, type = "response")
curve_df |>
  pivot_longer(c(quadratic, linear), names_to = "model", values_to = "suitability") |>
  ggplot(aes(elevation, suitability, colour = model)) + geom_line(linewidth = 1) + theme_minimal()

# E2. Temperature instead of elevation
tavg_c <- crop(tavg, study_area) |> mask(study_area); names(tavg_c) <- "tavg"
dat$tavg <- terra::extract(tavg_c, as.matrix(dat[, c("x", "y")]))[, 1]
m_t <- glm(pa ~ tavg + I(tavg^2) + slope + open_250, family = binomial, weights = w, data = dat)
suit_t <- predict(c(env, tavg_c), m_t, type = "response")
global(c(suit_glm, suit_t), "mean", na.rm = TRUE)
# The map is almost identical: here temperature is nearly a linear
# transformation of elevation. The model cannot tell them apart.

# E3. Correlation between GLM and MaxEnt
v <- na.omit(cbind(values(suit_glm), values(suit_mx)))
cor(v[, 1], v[, 2])

# E4. Block size
for (size in c(1500, 3000, 5000)) {
  dat$block <- paste(floor(dat$x / size), floor(dat$y / size))
  bl <- unique(dat$block); set.seed(5)
  dat$fold_block <- setNames(sample(rep(1:5, length.out = length(bl))), bl)[dat$block]
  cat(size, "m:", round(mean(cv_auc("fold_block")), 3), "\n")
}
# Bigger blocks = test data further away = lower AUC.

# E5. Percentage of the park that is suitable
100 * global(suit_park, "mean", na.rm = TRUE)[1, 1]
