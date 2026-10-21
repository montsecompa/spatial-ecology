# =====================================================================
#  Spatial Ecology  ·  Week 2  ·  Exercise solutions
# =====================================================================
# Run sections 1 to 6 of week02_wrangling_and_plotting.R first, so that
# `birds`, `point_summary` and `species_by_habitat` exist.

library(tidyverse)

# E1. Birds recorded per observer
birds |>
  group_by(observer) |>
  summarise(
    total_birds     = sum(count),
    visits          = n_distinct(point_id, visit),
    birds_per_visit = total_birds / visits
  ) |>
  arrange(desc(birds_per_visit))
# Totals depend on how many visits each person did, so compare the
# per-visit column. Differences between observers are a real issue in
# bird surveys ("observer effects"); we model it in Week 4.

# E2. Three most counted species
birds |>
  group_by(species) |>
  summarise(total = sum(count)) |>
  slice_max(total, n = 3)

# E3. Forest versus open habitats
point_summary <- point_summary |>
  mutate(forest = if_else(habitat %in% c("heathland", "meadow"), "open", "forest"))

point_summary |>
  group_by(forest) |>
  summarise(n = n(), mean_richness = mean(richness), mean_abundance = mean(abundance))

# E4. Canopy cover and richness
ggplot(point_summary, aes(x = canopy_cover_pct, y = richness)) +
  geom_point(aes(colour = habitat), size = 2.5) +
  geom_smooth(method = "lm", colour = "black") +
  labs(x = "Canopy cover (%)", y = "Species richness", colour = "Habitat") +
  theme_minimal()

# E5. Mean count by diet and habitat
birds |>
  group_by(habitat, diet) |>
  summarise(mean_count = mean(count), .groups = "drop") |>
  ggplot(aes(x = habitat, y = mean_count, fill = diet)) +
  geom_col(position = "dodge") +
  labs(x = NULL, y = "Mean count per visit", fill = "Diet") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

# E6. Back to wide format
species_wide <- species_by_habitat |>
  mutate(mean_count = round(mean_count, 2)) |>
  pivot_wider(names_from = habitat, values_from = mean_count)
species_wide
write_csv(species_wide, "outputs/species_by_habitat_wide.csv")
