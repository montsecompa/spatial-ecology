# =====================================================================
#  Ecología Espacial  ·  Semana 9
#  Autocorrelación espacial y patrones de puntos
# =====================================================================
#  Archivos en data/: survey_points.csv, bird_counts_wide.csv, montfred.gpkg
#  Paquetes: install.packages(c("spdep", "gstat", "spatstat", "sf", "tidyverse"))
#
#  Primera ley de la geografía (Tobler): todo está relacionado con todo,
#  pero lo cercano está más relacionado que lo lejano.
# =====================================================================

library(tidyverse)
library(sf)
library(spdep)      # índice de Moran
library(gstat)      # variogramas
library(spatstat)   # patrones de puntos


# ---------------------------------------------------------------------
# 1. Datos: abundancia por punto en coordenadas UTM
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

# Modelo no espacial de la semana 3: ¿quedan patrones espaciales en los residuos?
m <- lm(abundance ~ elevation_m, data = pts)
pts$resid <- resid(m)


# ---------------------------------------------------------------------
# 2. Vecinos y pesos espaciales
# ---------------------------------------------------------------------
# Definimos como vecinos los puntos a menos de 2.500 m.
nb <- dnearneigh(xy, 0, 2500)
summary(nb)
lw <- nb2listw(nb, style = "W", zero.policy = TRUE)   # pesos estandarizados por fila

plot(st_geometry(pts), pch = 19)
plot(nb, xy, add = TRUE, col = "grey60")


# ---------------------------------------------------------------------
# 3. Índice de Moran
# ---------------------------------------------------------------------
# I > 0: valores parecidos juntos (agregación); I ~ 0: al azar;
# I < 0: valores distintos juntos (como un tablero de ajedrez).
moran.test(pts$abundance, lw, zero.policy = TRUE)
moran.test(pts$resid, lw, zero.policy = TRUE)

# Versión por permutaciones (no supone normalidad)
set.seed(9)
moran.mc(pts$resid, lw, nsim = 999, zero.policy = TRUE)


# ---------------------------------------------------------------------
# 4. Correlograma: Moran a distintas distancias
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
  labs(x = "Distancia (km)", y = "I de Moran", title = "Correlograma de la abundancia de aves") +
  theme_minimal(base_size = 13)
p_cor


# ---------------------------------------------------------------------
# 5. Semivariograma
# ---------------------------------------------------------------------
# Mide cuánto difieren los valores en función de la distancia.
# Pepita (nugget): variación a distancia ~0 (error, microescala).
# Meseta (sill): variación total. Alcance (range): distancia a partir de
# la cual los valores ya no se parecen más de lo esperado.
v <- variogram(abundance ~ 1, data = pts, cutoff = 9000, width = 1000)
v_fit <- fit.variogram(v, vgm(psill = 6, model = "Sph", range = 4000, nugget = 2))
v_fit
plot(v, v_fit)

# Variograma de los residuos: si la altitud explica la estructura
# espacial, debería salir casi plano.
v_res <- variogram(resid ~ 1, data = pts, cutoff = 9000, width = 1000)
plot(v_res)


# ---------------------------------------------------------------------
# 6. Patrones de puntos: nidos en una parcela de 2 x 2 km
# ---------------------------------------------------------------------
nests <- st_read("data/montfred.gpkg", "nests", quiet = TRUE)
plot_area <- st_read("data/montfred.gpkg", "nest_plot", quiet = TRUE)
count(st_drop_geometry(nests), species)

# spatstat usa su propio formato: ppp (patrón de puntos) dentro de una
# ventana (owin).
win <- as.owin(st_geometry(plot_area))
make_ppp <- function(sp) {
  d <- st_coordinates(filter(nests, species == sp))
  ppp(d[, 1], d[, 2], window = win)
}
tree <- make_ppp("short_toed_treecreeper")
bon  <- make_ppp("western_bonellis_warbler")

par(mfrow = c(1, 2))
plot(tree, main = "Agateador", pch = 19, cex = 0.6); plot(bon, main = "Mosquitero papialbo", pch = 19, cex = 0.6)
par(mfrow = c(1, 1))

# Intensidad: nidos por km²
intensity(tree) * 1e6
intensity(bon) * 1e6

# Prueba de cuadrantes: ¿se ajusta a un patrón aleatorio (Poisson)?
quadrat.test(tree, nx = 4, ny = 4)
quadrat.test(bon, nx = 4, ny = 4)


# ---------------------------------------------------------------------
# 7. Función L de Ripley con envolventes de simulación
# ---------------------------------------------------------------------
# L(r) - r > 0: más vecinos de lo esperado a distancia r (agregación).
# L(r) - r < 0: menos vecinos (regularidad, territorialidad).
# La banda gris es lo que se espera al azar (99 simulaciones).
set.seed(99)
env_tree <- envelope(tree, Lest, nsim = 99, correction = "border", verbose = FALSE)
env_bon  <- envelope(bon,  Lest, nsim = 99, correction = "border", verbose = FALSE)

to_df <- function(env, label) as.data.frame(env) |> transmute(r, obs = obs - r, lo = lo - r, hi = hi - r, species = label)
env_df <- bind_rows(to_df(env_tree, "Agateador (agregado)"), to_df(env_bon, "Mosquitero papialbo (regular)"))
p_L <- ggplot(env_df, aes(r)) +
  geom_ribbon(aes(ymin = lo, ymax = hi), fill = "grey80") +
  geom_hline(yintercept = 0, linetype = 2) +
  geom_line(aes(y = obs), linewidth = 0.9) +
  facet_wrap(~ species) +
  labs(x = "Distancia r (m)", y = "L(r) - r", title = "Función L de Ripley") +
  theme_minimal(base_size = 13)
p_L


# ---------------------------------------------------------------------
# 8. Guardar
# ---------------------------------------------------------------------
dir.create("outputs", showWarnings = FALSE)
ggsave("outputs/correlogram.png", p_cor, width = 7, height = 4.5, dpi = 300, bg = "white")
ggsave("outputs/ripley_L.png", p_L, width = 9, height = 4.5, dpi = 300, bg = "white")
png("outputs/variogram.png", width = 1600, height = 1200, res = 220); print(plot(v, v_fit)); dev.off()


# =====================================================================
#  EJERCICIOS  (soluciones en semana09_soluciones.R)
# =====================================================================
# E1. Repite el índice de Moran de los residuos definiendo los vecinos
#     como los 4 puntos más cercanos (knearneigh(xy, k = 4)).
#     ¿Cambia la conclusión?
# E2. Calcula el índice de Moran de la riqueza de especies.
# E3. Ajusta el variograma con un modelo exponencial ("Exp").
#     ¿Qué alcance obtienes?
# E4. Calcula la distancia media al vecino más cercano (nndist()) de
#     cada especie. ¿Cuál tiene los nidos más espaciados?
# E5. Usa la función G (Gest) en lugar de L. ¿Llegas a la misma
#     conclusión?
# =====================================================================
