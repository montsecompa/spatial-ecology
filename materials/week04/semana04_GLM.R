# =====================================================================
#  Ecología Espacial  ·  Semana 4
#  GLM para conteos y presencia–ausencia
# =====================================================================
#  Archivos en data/: survey_points.csv, bird_counts_wide.csv
#  Paquetes: tidyverse, MASS, DHARMa, lme4
#    install.packages(c("MASS", "DHARMa", "lme4"))
#  Datos SIMULADOS (Sierra de Montfred, ficticia).
# =====================================================================

library(tidyverse)
library(MASS)      # glm.nb() para la binomial negativa
library(DHARMa)    # diagnóstico de residuos para GLM
library(lme4)      # modelos mixtos
select <- dplyr::select   # MASS también tiene select(); usamos la de dplyr


# ---------------------------------------------------------------------
# 1. Datos: un conteo total por punto y visita
# ---------------------------------------------------------------------
points <- read_csv("data/survey_points.csv")
counts <- read_csv("data/bird_counts_wide.csv") |>
  mutate(obs_key = str_to_upper(str_remove_all(observer, "[ .]")),
         observer = case_when(obs_key == "MPUIG" ~ "M. Puig", obs_key == "JSERRA" ~ "J. Serra", obs_key == "AFERRER" ~ "A. Ferrer")) |>
  select(-obs_key)

visits <- counts |>
  mutate(total = rowSums(across(european_robin:short_toed_treecreeper), na.rm = TRUE),
         visit = factor(visit)) |>
  left_join(points, by = "point_id") |>
  mutate(elev_100 = (elevation_m - 1000) / 100)   # altitud centrada en 1000 m, en unidades de 100 m

visits |> select(point_id, visit, observer, total, elevation_m, canopy_cover_pct)

# Los conteos son enteros >= 0 y su varianza suele crecer con la media.
# Por eso usamos un GLM con distribución de Poisson y enlace logarítmico:
#   log(media) = b0 + b1 * x1 + ...


# ---------------------------------------------------------------------
# 2. GLM de Poisson
# ---------------------------------------------------------------------
m_pois <- glm(total ~ elev_100 + canopy_cover_pct + observer + visit,
              family = poisson, data = visits)
summary(m_pois)

# Los coeficientes están en escala logarítmica. exp() los convierte en
# factores multiplicativos: exp(b) = cuántas veces cambia el conteo.
exp(coef(m_pois))
exp(confint.default(m_pois))


# ---------------------------------------------------------------------
# 3. Sobredispersión
# ---------------------------------------------------------------------
# Poisson supone varianza = media. Si la varianza es mayor
# (sobredispersión), los errores típicos salen demasiado pequeños.
sum(residuals(m_pois, type = "pearson")^2) / df.residual(m_pois)   # ~1 bien; >1.5 problema

sim_pois <- simulateResiduals(m_pois)
testDispersion(sim_pois)
plot(sim_pois)


# ---------------------------------------------------------------------
# 4. Binomial negativa
# ---------------------------------------------------------------------
m_nb <- glm.nb(total ~ elev_100 + canopy_cover_pct + observer + visit, data = visits)
summary(m_nb)
AIC(m_pois, m_nb)

sim_nb <- simulateResiduals(m_nb)
plot(sim_nb)

# ¿Hay efecto observador? Comparamos el modelo con y sin observador
m_nb0 <- update(m_nb, . ~ . - observer)
anova(m_nb0, m_nb)
exp(coef(m_nb))[c("observerJ. Serra", "observerM. Puig")]
# Un valor de 0,8 significa que ese observador anota un 20 % menos de aves
# que A. Ferrer (el nivel de referencia) en las mismas condiciones.


# ---------------------------------------------------------------------
# 5. Predicciones en la escala de la respuesta
# ---------------------------------------------------------------------
# Predecimos en la escala del enlace (log) y luego deshacemos con exp(),
# para que el intervalo nunca baje de cero.
grid <- tibble(elev_100 = seq(min(visits$elev_100), max(visits$elev_100), length.out = 100),
               canopy_cover_pct = mean(visits$canopy_cover_pct),
               observer = "A. Ferrer", visit = factor(2, levels = 1:3))
pr <- predict(m_nb, grid, type = "link", se.fit = TRUE)
grid <- grid |>
  mutate(fit = exp(pr$fit), lo = exp(pr$fit - 1.96 * pr$se.fit), hi = exp(pr$fit + 1.96 * pr$se.fit),
         elevation_m = elev_100 * 100 + 1000)

p_nb <- ggplot(grid, aes(elevation_m, fit)) +
  geom_ribbon(aes(ymin = lo, ymax = hi), fill = "grey80") +
  geom_line(linewidth = 1) +
  geom_point(data = visits, aes(y = total), alpha = 0.4) +
  labs(x = "Altitud (m)", y = "Aves por visita", title = "Binomial negativa: aves según la altitud",
       subtitle = "Cobertura de copas media, observador A. Ferrer, visita de mayo") +
  theme_minimal(base_size = 13)
p_nb


# ---------------------------------------------------------------------
# 6. Presencia–ausencia: GLM binomial (regresión logística)
# ---------------------------------------------------------------------
# ¿Se detectó la alondra totovía (woodlark) en alguna de las tres visitas?
woodlark <- counts |>
  group_by(point_id) |>
  summarise(present = as.integer(any(woodlark > 0, na.rm = TRUE))) |>
  left_join(points, by = "point_id") |>
  mutate(elev_100 = (elevation_m - 1000) / 100)
table(woodlark$present)

m_bin <- glm(present ~ canopy_cover_pct, family = binomial, data = woodlark)
summary(m_bin)
# Escala logit: exp(b) es una razón de probabilidades (odds ratio).
exp(coef(m_bin))

grid_b <- tibble(canopy_cover_pct = 0:100)
pb <- predict(m_bin, grid_b, type = "link", se.fit = TRUE)
grid_b <- grid_b |> mutate(p = plogis(pb$fit), lo = plogis(pb$fit - 1.96 * pb$se.fit), hi = plogis(pb$fit + 1.96 * pb$se.fit))

p_bin <- ggplot(grid_b, aes(canopy_cover_pct, p)) +
  geom_ribbon(aes(ymin = lo, ymax = hi), fill = "grey80") +
  geom_line(linewidth = 1) +
  geom_jitter(data = woodlark, aes(y = present), height = 0.03, width = 0, alpha = 0.6) +
  labs(x = "Cobertura de copas (%)", y = "Probabilidad de detección",
       title = "Alondra totovía: presencia según la cobertura de copas") +
  theme_minimal(base_size = 13)
p_bin


# ---------------------------------------------------------------------
# 7. Medidas repetidas: modelo mixto con el punto como efecto aleatorio
# ---------------------------------------------------------------------
# Cada punto se visitó tres veces: esas visitas no son independientes.
# (1 | point_id) permite que cada punto tenga su propio nivel medio.
m_mix <- glmer(total ~ elev_100 + observer + visit + (1 | point_id),
               family = poisson, data = visits)
summary(m_mix)
VarCorr(m_mix)


# ---------------------------------------------------------------------
# 8. Guardar
# ---------------------------------------------------------------------
dir.create("outputs", showWarnings = FALSE)
ggsave("outputs/nb_elevation.png", p_nb, width = 7, height = 5, dpi = 300, bg = "white")
ggsave("outputs/woodlark_logistic.png", p_bin, width = 7, height = 5, dpi = 300, bg = "white")
png("outputs/dharma_poisson.png", width = 2000, height = 1000, res = 200); plot(sim_pois); dev.off()


# =====================================================================
#  EJERCICIOS  (soluciones en semana04_soluciones.R)
# =====================================================================
# E1. Ajusta un GLM de Poisson para el número de petirrojos
#     (european_robin) por visita, con elev_100 y hábitat. ¿Hay
#     sobredispersión?
# E2. Con m_nb, ¿cuántas veces cambia el número de aves por cada 100 m
#     de subida? Da el intervalo de confianza.
# E3. En el modelo binomial, sustituye la cobertura por la altitud
#     (elev_100). ¿Qué modelo tiene menor AIC?
# E4. ¿A qué cobertura de copas la probabilidad de detectar la alondra
#     totovía baja del 50 %? (Pista: -b0 / b1.)
# E5. Compara los coeficientes del observador en m_nb y m_mix.
#     ¿Cambia la conclusión al tener en cuenta las visitas repetidas?
# =====================================================================
