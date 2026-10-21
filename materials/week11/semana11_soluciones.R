# =====================================================================
#  Ecología Espacial  ·  Semana 11  ·  Soluciones
# =====================================================================
# Ejecuta antes semana11_areas_de_campeo.R.

# E1. Ancho de banda por validación cruzada (LSCV)
ud_lscv <- kernelUD(gps_sp, h = "LSCV", grid = 200, extent = 1.2)
cbind(href = kernel.area(ud, percent = 95, unin = "m", unout = "ha"),
      lscv = kernel.area(ud_lscv, percent = 95, unin = "m", unout = "ha"))
# LSCV suele dar áreas menores. Si avisa de que no converge, mira
# plotLSCV(ud_lscv).

# E2. Solapamiento entre GEN02 y GEN03
a <- filter(kde95_sf, id == "GEN02"); b <- filter(kde95_sf, id == "GEN03")
inter <- st_intersection(st_geometry(a), st_geometry(b))
overlap_ha <- if (length(inter)) sum(as.numeric(st_area(inter))) / 1e4 else 0
overlap_ha
ud_same <- kernelUD(gps_sp, h = "href", grid = 200, extent = 1.2, same4all = TRUE)   # misma rejilla para todos
kerneloverlaphr(ud_same, method = "HR", percent = 95)   # proporción del área de i dentro de j

# E3. Distancia total recorrida
ld(traj) |> as_tibble() |> group_by(id) |> summarise(total_km = sum(dist, na.rm = TRUE) / 1000)
# Es un mínimo: entre dos localizaciones el animal no va en línea recta.

# E4. MCP de noche y de día
gps_sf$period <- if_else(hour(gps_sf$timestamp) >= 18 | hour(gps_sf$timestamp) < 6, "night", "day")
for (p in c("night", "day")) {
  sub <- as(gps_sf[gps_sf$period == p, "animal_id"], "Spatial")
  cat(p, "\n"); print(as.data.frame(mcp(sub, percent = 95, unin = "m", unout = "ha")))
}
# De día las ginetas descansan en sus encames y apenas se mueven, así que
# el MCP diurno suele ser más pequeño (refleja sobre todo dónde duermen).

# E5. Hábitat más seleccionado por cada animal
selection |> filter(n_used >= 5) |> group_by(animal_id) |> slice_max(ratio, n = 1) |>
  select(animal_id, class_es, ratio)
