# =====================================================================
#  Ecología Espacial  ·  Semana 7  ·  Soluciones
# =====================================================================
# Ejecuta antes las secciones 1 a 4 de semana07_mapas_tmap.R.

# E1. Otra paleta, sin sombreado
tm_shape(dem) +
  tm_raster(col.scale = tm_scale_continuous(values = "hcl.terrain2"),
            col.legend = tm_legend(title = "Altitud (m)")) +
  tm_shape(park) + tm_borders(lwd = 2) +
  tm_layout(legend.outside = TRUE)
# El sombreado ayuda a "leer" el relieve; sin él, solo vemos la altitud.

# E2. Etiquetas de los torrentes
m_lc + tm_shape(streams) + tm_lines(col = "#2C6E91") + tm_text("name", size = 0.6, col = "#1B4965")

# E3. Pendiente por intervalos
slope <- terrain(dem, "slope", unit = "degrees")
m_slope <- tm_shape(slope) +
  tm_raster(col.scale = tm_scale_intervals(breaks = c(0, 5, 15, 25, 90), values = "brewer.or_rd"),
            col.legend = tm_legend(title = "Pendiente (grados)")) +
  tm_shape(park) + tm_borders() +
  tm_layout(legend.outside = TRUE)
m_slope

# E4. Otras tres especies
other <- read_csv("data/bird_counts_wide.csv") |>
  group_by(point_id) |>
  summarise(across(c(coal_tit, sardinian_warbler, short_toed_treecreeper), ~ mean(.x, na.rm = TRUE))) |>
  pivot_longer(-point_id, names_to = "species", values_to = "mean_count")
tm_shape(park) + tm_fill("grey92") + tm_borders() +
  tm_shape(pts |> select(point_id) |> left_join(other, by = "point_id")) +
  tm_bubbles(size = "mean_count", fill = "#B5651D", col = "white") +
  tm_facets(by = "species", ncol = 3)

# E5. PDF de una columna
tmap_save(m_lc, "outputs/map_landcover_richness.pdf", width = 17, height = 13, units = "cm")
