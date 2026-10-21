# =====================================================================
#  Ecología Espacial  ·  Semana 10  ·  Soluciones
# =====================================================================
# Ejecuta antes semana10_modelos_distribucion.R.

# E1. Sin término cuadrático
m_lin <- glm(pa ~ elevation + slope + open_250, family = binomial, weights = w, data = dat)
AIC(m_lin, m_glm)
curve_df <- tibble(elevation = seq(min(dat$elevation), max(dat$elevation), length.out = 200),
                   slope = mean(dat$slope), open_250 = mean(dat$open_250))
curve_df$quadratic <- predict(m_glm, curve_df, type = "response")
curve_df$linear    <- predict(m_lin, curve_df, type = "response")
curve_df |>
  pivot_longer(c(quadratic, linear), names_to = "model", values_to = "suitability") |>
  ggplot(aes(elevation, suitability, colour = model)) + geom_line(linewidth = 1) + theme_minimal()

# E2. Temperatura en lugar de altitud
tavg_c <- crop(tavg, study_area) |> mask(study_area); names(tavg_c) <- "tavg"
dat$tavg <- terra::extract(tavg_c, as.matrix(dat[, c("x", "y")]))[, 1]
m_t <- glm(pa ~ tavg + I(tavg^2) + slope + open_250, family = binomial, weights = w, data = dat)
suit_t <- predict(c(env, tavg_c), m_t, type = "response")
global(c(suit_glm, suit_t), "mean", na.rm = TRUE)
# El mapa es casi igual: en esta sierra la temperatura es casi una
# transformación lineal de la altitud. El modelo no puede distinguirlas.

# E3. Correlación entre GLM y MaxEnt
v <- na.omit(cbind(values(suit_glm), values(suit_mx)))
cor(v[, 1], v[, 2])

# E4. Tamaño de bloque
for (size in c(1500, 3000, 5000)) {
  dat$block <- paste(floor(dat$x / size), floor(dat$y / size))
  bl <- unique(dat$block); set.seed(5)
  dat$fold_block <- setNames(sample(rep(1:5, length.out = length(bl))), bl)[dat$block]
  cat(size, "m:", round(mean(cv_auc("fold_block")), 3), "\n")
}
# Bloques más grandes = datos de prueba más alejados = AUC más bajo.

# E5. Porcentaje del parque adecuado
100 * global(suit_park, "mean", na.rm = TRUE)[1, 1]
