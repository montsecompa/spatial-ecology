# =====================================================================
#  Ecología Espacial  ·  Semana 9  ·  Soluciones
# =====================================================================
# Ejecuta antes semana09_autocorrelacion_espacial.R.

# E1. Vecinos: los 4 más cercanos
lw_k4 <- nb2listw(knn2nb(knearneigh(xy, k = 4)), style = "W")
moran.test(pts$resid, lw_k4)

# E2. Moran de la riqueza
rich <- read_csv("data/bird_counts_wide.csv") |>
  pivot_longer(european_robin:short_toed_treecreeper, names_to = "species", values_to = "count") |>
  filter(!is.na(count)) |>
  group_by(point_id) |>
  summarise(richness = n_distinct(species[count > 0]))
pts <- left_join(pts, rich, by = "point_id")
moran.test(pts$richness, lw, zero.policy = TRUE)

# E3. Modelo exponencial
v_exp <- fit.variogram(v, vgm(psill = 6, model = "Exp", range = 2000, nugget = 2))
v_exp
# En el modelo exponencial, el "alcance práctico" es unas 3 veces el
# parámetro range (distancia a la que se alcanza el 95 % de la meseta).
3 * v_exp$range[2]

# E4. Distancia media al vecino más cercano
c(treecreeper = mean(nndist(tree)), bonelli = mean(nndist(bon)))

# E5. Función G
plot(envelope(tree, Gest, nsim = 99, verbose = FALSE))
plot(envelope(bon, Gest, nsim = 99, verbose = FALSE))
# G(r) por encima de la banda indica agregación; por debajo, regularidad.
