# =====================================================================
#  Spatial Ecology  ·  Week 12  ·  Solutions
# =====================================================================
# Run week12_landscape_metrics.R first.

# E1. What 1990 meadow became (row "6")
trans_ha["6", ]
c(to_heathland = trans_ha["6", "5"], to_beech = trans_ha["6", "4"])

# E2. Beech forest edge density
bind_rows(lsm_c_ed(lc90_p) |> mutate(year = 1990), lsm_c_ed(lc26_p) |> mutate(year = 2026)) |>
  filter(class == 4) |> select(year, value)

# E3. 3 km squares
grid3 <- st_make_grid(st_as_sfc(st_bbox(lc26)), cellsize = 3000) |> st_sf()
s3 <- sample_lsm(lc26, y = grid3, what = "lsm_l_shdi")
grid3$shdi <- s3$value[match(seq_len(nrow(grid3)), s3$plot_id)]
ggplot(grid3) + geom_sf(aes(fill = shdi)) + geom_sf(data = park, fill = NA) +
  scale_fill_viridis_c() + theme_minimal()
# With bigger cells each square holds more habitat types: diversity rises
# and the pattern smooths out. Metrics depend on scale.

# E4. Examples: lsm_l_pd (patch density), lsm_l_ai (aggregation index),
# lsm_l_te (total edge).
calculate_lsm(lc26_p, what = c("lsm_l_pd", "lsm_l_ai", "lsm_l_te"))
