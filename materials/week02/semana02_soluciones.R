# =====================================================================
#  Ecología Espacial  ·  Semana 2  ·  Soluciones de los ejercicios
# =====================================================================
# Ejecuta antes las secciones 1 a 6 de semana02_ordenar_y_graficar.R
# para que existan `birds`, `point_summary` y `species_by_habitat`.

library(tidyverse)

# E1. Aves anotadas por cada observador
birds |>
  group_by(observer) |>
  summarise(
    total_birds     = sum(count),
    visits          = n_distinct(point_id, visit),
    birds_per_visit = total_birds / visits
  ) |>
  arrange(desc(birds_per_visit))
# El total depende de cuántas visitas hizo cada persona, así que compara
# la columna por visita. Las diferencias entre observadores ("efecto
# observador") son un problema real en los censos; lo modelizamos en la
# semana 4.

# E2. Las tres especies más contadas
birds |>
  group_by(species) |>
  summarise(total = sum(count)) |>
  slice_max(total, n = 3)

# E3. Bosque frente a medios abiertos
point_summary <- point_summary |>
  mutate(forest = if_else(habitat %in% c("heathland", "meadow"), "abierto", "bosque"))

point_summary |>
  group_by(forest) |>
  summarise(n = n(), mean_richness = mean(richness), mean_abundance = mean(abundance))

# E4. Cobertura de copas y riqueza
ggplot(point_summary, aes(x = canopy_cover_pct, y = richness)) +
  geom_point(aes(colour = habitat_es), size = 2.5) +
  geom_smooth(method = "lm", colour = "black") +
  labs(x = "Cobertura de copas (%)", y = "Riqueza de especies", colour = "Hábitat") +
  theme_minimal()

# E5. Conteo medio por dieta y hábitat
birds |>
  group_by(habitat_es, diet) |>
  summarise(mean_count = mean(count), .groups = "drop") |>
  ggplot(aes(x = habitat_es, y = mean_count, fill = diet)) +
  geom_col(position = "dodge") +
  labs(x = NULL, y = "Conteo medio por visita", fill = "Dieta") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

# E6. Volver a formato ancho
species_wide <- species_by_habitat |>
  mutate(mean_count = round(mean_count, 2)) |>
  pivot_wider(names_from = habitat_es, values_from = mean_count)
species_wide
write_csv(species_wide, "outputs/species_by_habitat_wide.csv")
