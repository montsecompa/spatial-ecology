# =====================================================================
#  Ecología Espacial  ·  Semana 12  ·  Soluciones
# =====================================================================
# Ejecuta antes semana12_metricas_paisaje.R.

# E1. Destino de los prados de 1990 (fila "6")
trans_ha["6", ]
c(to_heathland = trans_ha["6", "5"], to_beech = trans_ha["6", "4"])

# E2. Densidad de borde del hayedo
bind_rows(lsm_c_ed(lc90_p) |> mutate(year = 1990), lsm_c_ed(lc26_p) |> mutate(year = 2026)) |>
  filter(class == 4) |> select(year, value)

# E3. Cuadrados de 3 km
grid3 <- st_make_grid(st_as_sfc(st_bbox(lc26)), cellsize = 3000) |> st_sf()
s3 <- sample_lsm(lc26, y = grid3, what = "lsm_l_shdi")
grid3$shdi <- s3$value[match(seq_len(nrow(grid3)), s3$plot_id)]
ggplot(grid3) + geom_sf(aes(fill = shdi)) + geom_sf(data = park, fill = NA) +
  scale_fill_viridis_c() + theme_minimal()
# Con celdas más grandes cada cuadrado incluye más tipos de hábitat: la
# diversidad sube y el patrón se suaviza. Las métricas dependen de la escala.

# E4. Ejemplos: lsm_l_pd (densidad de manchas), lsm_l_ai (índice de
# agregación), lsm_l_te (borde total).
calculate_lsm(lc26_p, what = c("lsm_l_pd", "lsm_l_ai", "lsm_l_te"))
