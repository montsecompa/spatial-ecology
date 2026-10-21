# =====================================================================
#  Spatial Ecology  ·  Week 2
#  Wrangling and plotting ecological data with the tidyverse
# =====================================================================
#
#  Files needed in your project's data/ folder:
#    survey_points.csv      (from Week 1: one row per survey point)
#    bird_counts_wide.csv   (three visits per point, one column per species)
#    species_traits.csv     (one row per species)
#
#  The data are SIMULATED: 40 bird point counts in the (fictitious)
#  Sierra de Montfred, visited in April, May and June 2026.
#  The counts file contains a few deliberate problems to fix.
# =====================================================================

library(tidyverse)   # loads dplyr, tidyr, readr, ggplot2, stringr, lubridate...


# ---------------------------------------------------------------------
# 1. Read the data
# ---------------------------------------------------------------------
points <- read_csv("data/survey_points.csv")
counts <- read_csv("data/bird_counts_wide.csv")
traits <- read_csv("data/species_traits.csv")

glimpse(counts)
# Note: date was read as text (chr), not as a date. We fix that below.


# ---------------------------------------------------------------------
# 2. The pipe  |>
# ---------------------------------------------------------------------
# x |> f() means "take x, then do f to it". Read it as "and then".
# Shortcut: Ctrl + Shift + M  (Cmd + Shift + M on a Mac)
counts |> nrow()
counts |> count(visit)          # rows per visit: 40 each


# ---------------------------------------------------------------------
# 3. Spot and fix problems before analysing
# ---------------------------------------------------------------------
# 3a. Observer names are typed inconsistently
counts |> count(observer)
# "M. Puig", "m. puig", "M.Puig" are the same person.

counts <- counts |>
  mutate(
    obs_key  = str_to_upper(str_remove_all(observer, "[ .]")),   # "MPUIG"
    observer = case_when(obs_key == "MPUIG"   ~ "M. Puig",
                         obs_key == "JSERRA"  ~ "J. Serra",
                         obs_key == "AFERRER" ~ "A. Ferrer")
  ) |>
  select(-obs_key)

counts |> count(observer)       # now three observers

# 3b. Dates are text in day/month/year format. dmy() converts them.
counts <- counts |> mutate(date = dmy(date))
class(counts$date)              # "Date"

# 3c. Missing counts
counts |> summarise(across(european_robin:short_toed_treecreeper, ~ sum(is.na(.x))))
# NA means "not recorded", which is different from 0 ("looked, saw none").
# We keep NA as NA and remove those rows after reshaping.


# ---------------------------------------------------------------------
# 4. From wide to long format
# ---------------------------------------------------------------------
# Wide: one column per species. Long: one row per point x visit x species.
# Long ("tidy") data is what dplyr and ggplot2 expect.
counts_long <- counts |>
  pivot_longer(
    cols      = european_robin:short_toed_treecreeper,
    names_to  = "species",
    values_to = "count"
  ) |>
  filter(!is.na(count))

counts_long
nrow(counts_long)               # 40 points x 3 visits x 10 species, minus NAs


# ---------------------------------------------------------------------
# 5. Joining tables
# ---------------------------------------------------------------------
# left_join() keeps every row on the left and adds matching columns.
birds <- counts_long |>
  left_join(traits, by = "species") |>
  left_join(points, by = "point_id")


glimpse(birds)


# ---------------------------------------------------------------------
# 6. Summaries with group_by() + summarise()
# ---------------------------------------------------------------------
# Per point: species richness (species seen at least once over the
# three visits) and mean abundance per visit.
point_summary <- birds |>
  group_by(point_id, habitat, elevation_m, canopy_cover_pct, longitude, latitude) |>
  summarise(
    richness  = n_distinct(species[count > 0]),
    abundance = sum(count) / n_distinct(visit),
    .groups   = "drop"
  )

point_summary |> arrange(desc(richness))

# Per habitat
habitat_summary <- point_summary |>
  group_by(habitat) |>
  summarise(
    n_points       = n(),
    mean_richness  = mean(richness),
    sd_richness    = sd(richness),
    mean_abundance = mean(abundance)
  ) |>
  arrange(desc(mean_richness))

habitat_summary

# Which species are most common in each habitat?
species_by_habitat <- birds |>
  group_by(habitat, species) |>
  summarise(mean_count = mean(count), .groups = "drop")

species_by_habitat |>
  group_by(habitat) |>
  slice_max(mean_count, n = 2)


# ---------------------------------------------------------------------
# 7. Plotting with ggplot2
# ---------------------------------------------------------------------
# Every ggplot has: data + aesthetics (aes: what maps to x, y, colour...)
# + geoms (the marks: points, boxes, lines). Add layers with +.

# 7a. Richness by habitat: boxplot plus the raw points
p_rich <- ggplot(point_summary,
                 aes(x = fct_reorder(habitat, richness), y = richness)) +
  geom_boxplot(fill = "grey90", outlier.shape = NA) +
  geom_jitter(width = 0.15, height = 0, alpha = 0.6) +
  labs(x = NULL, y = "Species richness (of 10 surveyed)",
       title = "Bird species richness by habitat") +
  coord_flip() +
  theme_minimal(base_size = 13)
p_rich

# 7b. Abundance along the elevation gradient
p_elev <- ggplot(point_summary, aes(x = elevation_m, y = abundance)) +
  geom_point(aes(colour = habitat), size = 2.5) +
  geom_smooth(method = "loess", se = TRUE, colour = "black", linewidth = 0.7) +
  labs(x = "Elevation (m)", y = "Birds per visit", colour = "Habitat",
       title = "Bird abundance along the elevation gradient") +
  theme_minimal(base_size = 13)
p_elev

# 7c. Which species live where: a heat map
p_heat <- ggplot(species_by_habitat,
                 aes(x = habitat, y = species, fill = mean_count)) +
  geom_tile(colour = "white") +
  scale_fill_viridis_c(name = "Mean count\nper visit") +
  labs(x = NULL, y = NULL, title = "Mean count of each species by habitat") +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))
p_heat

# 7d. Seasonal pattern: counts per visit, faceted by diet
p_season <- birds |>
  group_by(date, diet) |>
  summarise(mean_count = mean(count), .groups = "drop") |>
  ggplot(aes(x = date, y = mean_count)) +
  geom_line() + geom_point(size = 2) +
  facet_wrap(~ diet) +
  labs(x = NULL, y = "Mean count per point and species",
       title = "Counts across the three visits, by diet") +
  theme_minimal(base_size = 13)
p_season

# 7e. A first ggplot map: position on x/y, richness as point size.
# coord_quickmap() gives approximately correct proportions.
p_map <- ggplot(point_summary, aes(x = longitude, y = latitude)) +
  geom_point(aes(colour = habitat, size = richness), alpha = 0.8) +
  coord_quickmap() +
  labs(title = "Survey points", colour = "Habitat", size = "Richness") +
  theme_minimal(base_size = 13)
p_map


# ---------------------------------------------------------------------
# 8. Save tables and figures
# ---------------------------------------------------------------------
dir.create("outputs", showWarnings = FALSE)

write_csv(point_summary,   "outputs/point_summary.csv")
write_csv(habitat_summary, "outputs/habitat_summary.csv")

ggsave("outputs/richness_by_habitat.png", p_rich,   width = 7, height = 5, dpi = 300, bg = "white")
ggsave("outputs/abundance_elevation.png", p_elev,   width = 7, height = 5, dpi = 300, bg = "white")
ggsave("outputs/species_heatmap.png",     p_heat,   width = 7, height = 5, dpi = 300, bg = "white")
ggsave("outputs/season_by_diet.png",      p_season, width = 8, height = 4, dpi = 300, bg = "white")
ggsave("outputs/survey_map.png",          p_map,    width = 6, height = 5, dpi = 300, bg = "white")


# =====================================================================
#  EXERCISES  (answers are in week02_solutions.R; try first!)
# =====================================================================
# E1. How many birds in total did each observer record? Who recorded
#     the most per visit, on average?
#
# E2. Using `birds`, find the three species with the highest total
#     count across all points and visits.
#
# E3. Make a new column `forest` that is "open" for heathland and
#     meadow and "forest" for the rest (hint: if_else() and %in%).
#     Compare mean richness between forest and open points.
#
# E4. Plot canopy cover (x) against richness (y) from point_summary.
#     Colour by habitat and add a straight-line trend with
#     geom_smooth(method = "lm").
#
# E5. Make a bar chart of mean count per visit for each diet group in
#     each habitat (hint: geom_col() and position = "dodge").
#
# E6. Challenge: reshape species_by_habitat back to a wide table with
#     one row per species and one column per habitat (pivot_wider()).
#     Save it as outputs/species_by_habitat_wide.csv.
# =====================================================================
