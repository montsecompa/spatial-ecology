# =====================================================================
#  Ecología Espacial  ·  Semana 10
#  Modelos de distribución de especies (SDM)
# =====================================================================
#  Archivos en data/: gbif_lullula_arborea_clean.csv (de la semana 8),
#    dem.tif, landcover.tif, tavg.tif, prec.tif, montfred.gpkg
#  Paquetes: install.packages(c("terra", "sf", "maxnet", "tidyverse"))
#
#  Pregunta: ¿dónde es adecuado el hábitat para la alondra totovía en la
#  Sierra de Montfred? Usamos presencias (GBIF) y puntos de fondo.
#  Con datos reales usarías las capas de WorldClim (worldclim.org);
#  aquí tavg.tif y prec.tif imitan esas capas a escala local.
# =====================================================================

library(tidyverse)
library(sf)
library(terra)
library(maxnet)


# ---------------------------------------------------------------------
# 1. Variables ambientales (predictores)
# ---------------------------------------------------------------------
dem  <- rast("data/dem.tif")
lc   <- rast("data/landcover.tif")
tavg <- rast("data/tavg.tif")
prec <- rast("data/prec.tif")

# Los pájaros responden al paisaje alrededor, no a una celda de 30 m:
# calculamos la proporción de medio abierto (brezal, prado) en ~250 m.
open_cell <- lc %in% c(5, 6)
open_250  <- focal(open_cell, w = focalMat(open_cell, 250, "circle"), fun = "sum", na.rm = TRUE)
forest_cell <- lc %in% c(1, 2, 3, 4)
forest_250  <- focal(forest_cell, w = focalMat(forest_cell, 250, "circle"), fun = "sum", na.rm = TRUE)
slope <- terrain(dem, "slope", unit = "degrees")

env <- c(dem, tavg, prec, slope, open_250, forest_250)
names(env) <- c("elevation", "tavg", "prec", "slope", "open_250", "forest_250")
plot(env)


# ---------------------------------------------------------------------
# 2. Correlación entre predictores
# ---------------------------------------------------------------------
set.seed(10)
env_sample <- spatSample(env, 3000, "random", na.rm = TRUE)
round(cor(env_sample), 2)
# Temperatura y precipitación dependen casi por completo de la altitud
# (|r| > 0,9). Meter las tres a la vez da coeficientes inestables.
# Nos quedamos con una: la altitud. Igual con open_250 y forest_250.
env <- env[[c("elevation", "slope", "open_250")]]


# ---------------------------------------------------------------------
# 3. Presencias y puntos de fondo
# ---------------------------------------------------------------------
occ <- read_csv("data/gbif_lullula_arborea_clean.csv")
park <- st_read("data/montfred.gpkg", "park_boundary", quiet = TRUE)
study_area <- vect(st_buffer(park, 3000))
env <- crop(env, study_area) |> mask(study_area)

pres <- occ |> select(x, y)
# El fondo describe el ambiente disponible en la zona de estudio
set.seed(1)
bg <- spatSample(env[[1]], 3000, "random", na.rm = TRUE, xy = TRUE) |> select(x, y)

dat <- bind_rows(
  bind_cols(pres, terra::extract(env, as.matrix(pres)), pa = 1),
  bind_cols(bg,   terra::extract(env, as.matrix(bg)),   pa = 0)
) |> drop_na()
table(dat$pa)

# ¿Dónde están las presencias en comparación con el fondo?
dat |>
  pivot_longer(elevation:open_250) |>
  mutate(pa = if_else(pa == 1, "presencia", "fondo")) |>
  ggplot(aes(value, fill = pa)) +
  geom_density(alpha = 0.5) +
  facet_wrap(~ name, scales = "free") +
  labs(fill = NULL) + theme_minimal()


# ---------------------------------------------------------------------
# 4. Modelo 1: GLM (regresión logística ponderada)
# ---------------------------------------------------------------------
# Damos a presencias y fondo el mismo peso total. El término cuadrático
# permite un óptimo de altitud (curva en forma de campana).
w <- ifelse(dat$pa == 1, 1, sum(dat$pa == 1) / sum(dat$pa == 0))
m_glm <- glm(pa ~ elevation + I(elevation^2) + slope + open_250,
             family = binomial, weights = w, data = dat)
summary(m_glm)

suit_glm <- predict(env, m_glm, type = "response")
plot(suit_glm)


# ---------------------------------------------------------------------
# 5. Modelo 2: MaxEnt (paquete maxnet)
# ---------------------------------------------------------------------
m_mx <- maxnet(dat$pa, dat[, c("elevation", "slope", "open_250")],
               f = maxnet.formula(dat$pa, dat[, c("elevation", "slope", "open_250")], classes = "lqh"))
plot(m_mx, type = "cloglog")   # curvas de respuesta

suit_mx <- predict(env, m_mx, type = "cloglog", na.rm = TRUE)
plot(suit_mx)


# ---------------------------------------------------------------------
# 6. Evaluación: AUC con validación cruzada aleatoria y por bloques
# ---------------------------------------------------------------------
# AUC = probabilidad de que una presencia al azar tenga más idoneidad
# que un punto de fondo al azar (0,5 = azar, 1 = perfecto).
auc <- function(p, a) mean(outer(p, a, ">") + 0.5 * outer(p, a, "=="))

# Validación aleatoria: 5 grupos al azar
set.seed(5)
dat$fold_random <- sample(rep(1:5, length.out = nrow(dat)))
# Validación por bloques: cuadrados de 3 km; cada bloque entero va a un grupo
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
# La validación por bloques suele dar un AUC más bajo y más realista:
# los datos de prueba están lejos de los de entrenamiento, como al
# predecir en un sitio nuevo.


# ---------------------------------------------------------------------
# 7. Mapa de presencia/ausencia con un umbral
# ---------------------------------------------------------------------
# Umbral que maximiza sensibilidad + especificidad
p_pres <- predict(m_glm, dat[dat$pa == 1, ], type = "response")
p_bg   <- predict(m_glm, dat[dat$pa == 0, ], type = "response")
th <- seq(0.01, 0.99, by = 0.01)
tss <- sapply(th, function(t) mean(p_pres >= t) + mean(p_bg < t) - 1)
best <- th[which.max(tss)]
best

suitable <- suit_glm >= best
# Superficie adecuada dentro del parque (ha)
suit_park <- mask(crop(suitable, vect(park)), vect(park))
sum(values(suit_park) == 1, na.rm = TRUE) * prod(res(suit_park)) / 10000


# ---------------------------------------------------------------------
# 8. Guardar
# ---------------------------------------------------------------------
dir.create("outputs", showWarnings = FALSE)
writeRaster(suit_glm, "outputs/woodlark_suitability_glm.tif", overwrite = TRUE)
writeRaster(suit_mx, "outputs/woodlark_suitability_maxent.tif", overwrite = TRUE)
png("outputs/sdm_maps.png", width = 2400, height = 1100, res = 220)
par(mfrow = c(1, 2), mar = c(2, 2, 3, 5))
plot(suit_glm, main = "GLM: idoneidad", range = c(0, 1)); plot(st_geometry(park), add = TRUE)
points(pres, pch = 20, cex = 0.4)
plot(suit_mx, main = "MaxEnt: idoneidad (cloglog)", range = c(0, 1)); plot(st_geometry(park), add = TRUE)
dev.off()


# =====================================================================
#  EJERCICIOS  (soluciones en semana10_soluciones.R)
# =====================================================================
# E1. Ajusta el GLM sin el término cuadrático. ¿Qué modelo tiene menor
#     AIC? Dibuja la curva de respuesta a la altitud de ambos.
# E2. Cambia la altitud por la temperatura (tavg). ¿Cambia el mapa?
#     ¿Por qué?
# E3. Calcula la correlación entre los mapas del GLM y de MaxEnt
#     (pista: layerCor() o cor() de los valores).
# E4. Repite la validación por bloques con cuadrados de 1,5 y 5 km.
#     ¿Cómo cambia el AUC?
# E5. ¿Qué porcentaje del parque es adecuado según el umbral?
# =====================================================================
