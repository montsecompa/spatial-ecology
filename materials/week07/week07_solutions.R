# =====================================================================
#  Spatial Ecology  ·  Week 7  ·  Solutions
# =====================================================================
# Run sections 1 to 4 of week07_maps_tmap.R first.

# E1. Another palette, no hillshade
tm_shape(dem) +
  tm_raster(col.scale = tm_scale_continuous(values = "hcl.terrain2"),
            col.legend = tm_legend(title = "Elevation (m)")) +
  tm_shape(park) + tm_borders(lwd = 2) +
  tm_layout(legend.outside = TRUE)
# The hillshade helps us "read" the terrain; without it we only see elevation.

# E2. Stream labels
m_lc + tm_shape(streams) + tm_lines(col = "#2C6E91") + tm_text("name", size = 0.6, col = "#1B4965")

# E3. Slope in intervals
slope <- terrain(dem, "slope", unit = "degrees")
m_slope <- tm_shape(slope) +
  tm_raster(col.scale = tm_scale_intervals(breaks = c(0, 5, 15, 25, 90), values = "brewer.or_rd"),
            col.legend = tm_legend(title = "Slope (degrees)")) +
  tm_shape(park) + tm_borders() +
  tm_layout(legend.outside = TRUE)
m_slope

# E4. Three other species
other <- read_csv("data/bird_counts_wide.csv") |>
  group_by(point_id) |>
  summarise(across(c(coal_tit, sardinian_warbler, short_toed_treecreeper), ~ mean(.x, na.rm = TRUE))) |>
  pivot_longer(-point_id, names_to = "species", values_to = "mean_count")
tm_shape(park) + tm_fill("grey92") + tm_borders() +
  tm_shape(pts |> select(point_id) |> left_join(other, by = "point_id")) +
  tm_bubbles(size = "mean_count", fill = "#B5651D", col = "white") +
  tm_facets(by = "species", ncol = 3)

# E5. One-column PDF
tmap_save(m_lc, "outputs/map_landcover_richness.pdf", width = 17, height = 13, units = "cm")
