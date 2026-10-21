# =====================================================================
#  Ecología Espacial  ·  Semana 3  ·  Soluciones
# =====================================================================
# Ejecuta antes la sección 1 de semana03_estadistica_basica.R.
library(tidyverse)

# E1. Media, mediana e intervalos de la riqueza
r <- point_summary$richness
mean(r); median(r)
mean(r) + c(-1, 1) * qt(0.975, length(r) - 1) * sd(r) / sqrt(length(r))
set.seed(2)
quantile(replicate(5000, mean(sample(r, replace = TRUE))), c(0.025, 0.975))
# Los dos intervalos son muy parecidos: con 40 puntos la media es casi normal.

# E2. Cobertura de copas: bosque frente a abierto
t.test(canopy_cover_pct ~ open, data = point_summary)
coef(lm(canopy_cover_pct ~ open, data = point_summary))
# La diferencia de medias de t.test() es el coeficiente de lm().

# E3. Riqueza y altitud
m_r <- lm(richness ~ elevation_m, data = point_summary)
summary(m_r)
coef(m_r)["elevation_m"] * 100            # cambio por 100 m
summary(m_r)$r.squared

# E4. Predecir fuera del rango
predict(m_r, tibble(elevation_m = 1800), interval = "prediction")
range(point_summary$elevation_m)
# 1.800 m está por encima del punto más alto muestreado: suponemos que la
# recta sigue igual donde no tenemos datos, y puede predecir valores
# imposibles (por debajo de 0 o por encima de 10 especies).

# E5. Residuos del modelo por hábitat
m_hab <- lm(abundance ~ habitat, data = point_summary)
par(mfrow = c(2, 2)); plot(m_hab); par(mfrow = c(1, 1))
# Con pocos puntos en algunos hábitats (3 a 6) la varianza de cada grupo se
# estima mal; la dispersión puede ser mayor en los hábitats con más aves.
