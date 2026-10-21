# =====================================================================
#  Ecología Espacial  ·  Semana 3
#  Fundamentos de estadística para ecólogos
# =====================================================================
#  Archivos en data/: survey_points.csv, bird_counts_wide.csv
#  Datos SIMULADOS (Sierra de Montfred, ficticia).
#
#  Hoy: describir datos, intervalos de confianza, comparar grupos y el
#  modelo lineal, que está detrás de la prueba t, el ANOVA y la regresión.
# =====================================================================

library(tidyverse)


# ---------------------------------------------------------------------
# 1. Preparar los datos: un resumen por punto (como en la semana 2)
# ---------------------------------------------------------------------
points <- read_csv("data/survey_points.csv")
counts <- read_csv("data/bird_counts_wide.csv")

point_summary <- counts |>
  pivot_longer(european_robin:short_toed_treecreeper, names_to = "species", values_to = "count") |>
  filter(!is.na(count)) |>
  group_by(point_id) |>
  summarise(richness  = n_distinct(species[count > 0]),
            abundance = sum(count) / n_distinct(visit)) |>
  left_join(points, by = "point_id") |>
  mutate(open = if_else(habitat %in% c("heathland", "meadow"), "abierto", "bosque"))

point_summary


# ---------------------------------------------------------------------
# 2. Describir una variable
# ---------------------------------------------------------------------
x <- point_summary$abundance
mean(x); median(x); sd(x)
se <- sd(x) / sqrt(length(x))   # error típico de la media
se
quantile(x, c(0.05, 0.25, 0.5, 0.75, 0.95))

ggplot(point_summary, aes(abundance)) +
  geom_histogram(binwidth = 1, fill = "grey70", colour = "white") +
  labs(x = "Aves por visita", y = "Número de puntos") +
  theme_minimal()

# La desviación típica (sd) describe la variación entre puntos.
# El error típico (se) describe la incertidumbre de la MEDIA: disminuye
# al aumentar el tamaño de muestra.


# ---------------------------------------------------------------------
# 3. Intervalos de confianza
# ---------------------------------------------------------------------
# IC del 95 % basado en la distribución t
n <- length(x)
mean(x) + c(-1, 1) * qt(0.975, df = n - 1) * se

# IC por remuestreo (bootstrap): remuestreamos los puntos con reemplazo
# muchas veces y miramos cómo varía la media.
set.seed(1)
boot_means <- replicate(5000, mean(sample(x, replace = TRUE)))
quantile(boot_means, c(0.025, 0.975))


# ---------------------------------------------------------------------
# 4. Comparar dos grupos: bosque frente a medios abiertos
# ---------------------------------------------------------------------
ggplot(point_summary, aes(open, abundance)) +
  geom_boxplot(fill = "grey90", outlier.shape = NA) +
  geom_jitter(width = 0.1, height = 0) +
  labs(x = NULL, y = "Aves por visita") +
  theme_minimal()

t.test(abundance ~ open, data = point_summary)   # prueba t de Welch

# La misma comparación como modelo lineal: el coeficiente "openbosque"
# es la diferencia de medias entre bosque y abierto (el nivel de referencia).
m_open <- lm(abundance ~ open, data = point_summary)
summary(m_open)


# ---------------------------------------------------------------------
# 5. Más de dos grupos: ANOVA
# ---------------------------------------------------------------------
m_hab <- lm(abundance ~ habitat, data = point_summary)
anova(m_hab)            # ¿difiere la abundancia entre hábitats?
summary(m_hab)          # cada coeficiente se compara con el nivel de referencia

# Comparaciones por pares, corrigiendo por comparaciones múltiples
TukeyHSD(aov(abundance ~ habitat, data = point_summary))


# ---------------------------------------------------------------------
# 6. Regresión lineal: abundancia y altitud
# ---------------------------------------------------------------------
m_elev <- lm(abundance ~ elevation_m, data = point_summary)
summary(m_elev)
confint(m_elev)

# La pendiente está en "aves por metro". Más fácil de leer por 100 m:
coef(m_elev)["elevation_m"] * 100

# Predicciones con su intervalo de confianza
new <- tibble(elevation_m = c(600, 1000, 1400))
predict(m_elev, newdata = new, interval = "confidence")

ggplot(point_summary, aes(elevation_m, abundance)) +
  geom_point() +
  geom_smooth(method = "lm", colour = "black") +
  labs(x = "Altitud (m)", y = "Aves por visita") +
  theme_minimal()


# ---------------------------------------------------------------------
# 7. Regresión múltiple y correlación entre predictores
# ---------------------------------------------------------------------
cor(point_summary$elevation_m, point_summary$canopy_cover_pct)

m_both <- lm(abundance ~ elevation_m + canopy_cover_pct, data = point_summary)
summary(m_both)
# Cada coeficiente es el efecto de una variable manteniendo la otra
# constante. Si los predictores están muy correlacionados, los
# coeficientes se vuelven inestables: compara con m_elev.

AIC(m_elev, m_both)   # menor AIC = mejor equilibrio entre ajuste y complejidad


# ---------------------------------------------------------------------
# 8. Comprobar los supuestos con los residuos
# ---------------------------------------------------------------------
par(mfrow = c(2, 2)); plot(m_both); par(mfrow = c(1, 1))
# Qué mirar:
#  - Residuos frente a ajustados: nube sin forma (sin curva ni embudo).
#  - Q-Q: los puntos cerca de la diagonal (residuos aproximadamente normales).
#  - Residuals vs Leverage: ningún punto con distancia de Cook > 1.

diag_df <- tibble(fitted = fitted(m_both), resid = resid(m_both))
p_resid <- ggplot(diag_df, aes(fitted, resid)) +
  geom_hline(yintercept = 0, linetype = 2) + geom_point() +
  labs(x = "Valores ajustados", y = "Residuos") +
  theme_minimal()
p_resid

# Ojo: la riqueza y los conteos son números enteros >= 0. El modelo
# lineal puede predecir valores negativos y suponer varianza constante.
# La semana 4 resuelve esto con modelos lineales generalizados (GLM).


# ---------------------------------------------------------------------
# 9. Guardar
# ---------------------------------------------------------------------
dir.create("outputs", showWarnings = FALSE)
write_csv(point_summary, "outputs/point_summary.csv")
p_reg <- ggplot(point_summary, aes(elevation_m, abundance)) +
  geom_point(aes(colour = open), size = 2.5) +
  geom_smooth(method = "lm", colour = "black") +
  labs(x = "Altitud (m)", y = "Aves por visita", colour = NULL, title = "Abundancia y altitud") +
  theme_minimal(base_size = 13)
ggsave("outputs/regression_elevation.png", p_reg, width = 7, height = 5, dpi = 300, bg = "white")
ggsave("outputs/residuals.png", p_resid, width = 6, height = 4.5, dpi = 300, bg = "white")


# =====================================================================
#  EJERCICIOS  (soluciones en semana03_soluciones.R)
# =====================================================================
# E1. Calcula la media, la mediana y el IC del 95 % (t y bootstrap) de
#     la riqueza. ¿Coinciden los dos intervalos?
# E2. ¿Difiere la cobertura de copas entre bosque y medios abiertos?
#     Usa t.test() y lm() y comprueba que dan la misma diferencia.
# E3. Ajusta lm(richness ~ elevation_m). ¿Cuánto cambia la riqueza
#     por cada 100 m de subida? ¿Qué proporción de la variación explica
#     el modelo (R²)?
# E4. Predice la riqueza a 1.800 m con el modelo de E3. ¿Tiene sentido
#     ecológico? ¿Por qué es arriesgado predecir fuera del rango de datos?
# E5. Revisa los gráficos de residuos de m_hab. ¿Ves algún problema?
# =====================================================================
