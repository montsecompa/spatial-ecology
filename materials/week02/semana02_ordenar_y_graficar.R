# =====================================================================
#  Ecología Espacial  ·  Semana 2
#  Ordenar y representar datos ecológicos con el tidyverse
# =====================================================================
#
#  Archivos necesarios en la carpeta data/ del proyecto:
#    survey_points.csv      (de la semana 1: una fila por punto)
#    bird_counts_wide.csv   (tres visitas por punto, una columna por especie)
#    species_traits.csv     (una fila por especie)
#    landcover_classes.csv  (nombres de los hábitats en inglés y castellano)
#
#  Datos SIMULADOS: 40 puntos de censo de aves en la Sierra de Montfred
#  (ficticia), visitados en abril, mayo y junio de 2026. El archivo de
#  conteos tiene a propósito algunos errores que hay que corregir.
# =====================================================================

library(tidyverse)   # carga dplyr, tidyr, readr, ggplot2, stringr, lubridate...


# ---------------------------------------------------------------------
# 1. Leer los datos
# ---------------------------------------------------------------------
points <- read_csv("data/survey_points.csv")
counts <- read_csv("data/bird_counts_wide.csv")
traits <- read_csv("data/species_traits.csv")

glimpse(counts)
# Fíjate: date se ha leído como texto (chr), no como fecha. Lo arreglamos abajo.


# ---------------------------------------------------------------------
# 2. La tubería (pipe)  |>
# ---------------------------------------------------------------------
# x |> f() significa "coge x y luego aplícale f". Léelo como "y después".
# Atajo: Ctrl + Mayús + M  (Cmd + Mayús + M en Mac)
counts |> nrow()
counts |> count(visit)          # filas por visita: 40 en cada una


# ---------------------------------------------------------------------
# 3. Detectar y corregir problemas antes de analizar
# ---------------------------------------------------------------------
# 3a. Los nombres de los observadores están escritos de formas distintas
counts |> count(observer)
# "M. Puig", "m. puig" y "M.Puig" son la misma persona.

counts <- counts |>
  mutate(
    obs_key  = str_to_upper(str_remove_all(observer, "[ .]")),   # "MPUIG"
    observer = case_when(obs_key == "MPUIG"   ~ "M. Puig",
                         obs_key == "JSERRA"  ~ "J. Serra",
                         obs_key == "AFERRER" ~ "A. Ferrer")
  ) |>
  select(-obs_key)

counts |> count(observer)       # ahora, tres observadores

# 3b. Las fechas son texto con formato día/mes/año. dmy() las convierte.
counts <- counts |> mutate(date = dmy(date))
class(counts$date)              # "Date"

# 3c. Conteos que faltan
counts |> summarise(across(european_robin:short_toed_treecreeper, ~ sum(is.na(.x))))
# NA significa "no se anotó", que no es lo mismo que 0 ("miré y no había").
# Mantenemos NA como NA y quitamos esas filas después de reorganizar.


# ---------------------------------------------------------------------
# 4. De formato ancho a formato largo
# ---------------------------------------------------------------------
# Ancho: una columna por especie. Largo: una fila por punto x visita x especie.
# El formato largo ("ordenado", tidy) es el que esperan dplyr y ggplot2.
counts_long <- counts |>
  pivot_longer(
    cols      = european_robin:short_toed_treecreeper,
    names_to  = "species",
    values_to = "count"
  ) |>
  filter(!is.na(count))

counts_long
nrow(counts_long)               # 40 puntos x 3 visitas x 10 especies, menos los NA


# ---------------------------------------------------------------------
# 5. Unir tablas
# ---------------------------------------------------------------------
# left_join() conserva todas las filas de la izquierda y añade las
# columnas que coinciden de la tabla de la derecha.
birds <- counts_long |>
  left_join(traits, by = "species") |>
  left_join(points, by = "point_id")

# Los hábitats están en inglés en los datos. Añadimos su nombre en
# castellano con otra unión, usando la tabla de clases.
classes <- read_csv("data/landcover_classes.csv")
birds <- birds |>
  left_join(select(classes, class_en, habitat_es = class_es), by = c("habitat" = "class_en"))
count(birds, habitat, habitat_es)

glimpse(birds)


# ---------------------------------------------------------------------
# 6. Resúmenes con group_by() + summarise()
# ---------------------------------------------------------------------
# Por punto: riqueza de especies (especies vistas al menos una vez en
# las tres visitas) y abundancia media por visita.
point_summary <- birds |>
  group_by(point_id, habitat, habitat_es, elevation_m, canopy_cover_pct, longitude, latitude) |>
  summarise(
    richness  = n_distinct(species[count > 0]),
    abundance = sum(count) / n_distinct(visit),
    .groups   = "drop"
  )

point_summary |> arrange(desc(richness))

# Por hábitat
habitat_summary <- point_summary |>
  group_by(habitat_es) |>
  summarise(
    n_points       = n(),
    mean_richness  = mean(richness),
    sd_richness    = sd(richness),
    mean_abundance = mean(abundance)
  ) |>
  arrange(desc(mean_richness))

habitat_summary

# ¿Qué especies son más comunes en cada hábitat?
species_by_habitat <- birds |>
  group_by(habitat_es, species) |>
  summarise(mean_count = mean(count), .groups = "drop")

species_by_habitat |>
  group_by(habitat_es) |>
  slice_max(mean_count, n = 2)


# ---------------------------------------------------------------------
# 7. Gráficos con ggplot2
# ---------------------------------------------------------------------
# Todo ggplot tiene: datos + estéticas (aes: qué va en x, y, color...)
# + geometrías (geom: puntos, cajas, líneas). Las capas se suman con +.

# 7a. Riqueza por hábitat: diagrama de cajas más los puntos
p_rich <- ggplot(point_summary,
                 aes(x = fct_reorder(habitat_es, richness), y = richness)) +
  geom_boxplot(fill = "grey90", outlier.shape = NA) +
  geom_jitter(width = 0.15, height = 0, alpha = 0.6) +
  labs(x = NULL, y = "Riqueza de especies (de 10 censadas)",
       title = "Riqueza de aves por hábitat") +
  coord_flip() +
  theme_minimal(base_size = 13)
p_rich

# 7b. Abundancia a lo largo del gradiente altitudinal
p_elev <- ggplot(point_summary, aes(x = elevation_m, y = abundance)) +
  geom_point(aes(colour = habitat_es), size = 2.5) +
  geom_smooth(method = "loess", se = TRUE, colour = "black", linewidth = 0.7) +
  labs(x = "Altitud (m)", y = "Aves por visita", colour = "Hábitat",
       title = "Abundancia de aves según la altitud") +
  theme_minimal(base_size = 13)
p_elev

# 7c. Qué especies viven dónde: mapa de calor
p_heat <- ggplot(species_by_habitat,
                 aes(x = habitat_es, y = species, fill = mean_count)) +
  geom_tile(colour = "white") +
  scale_fill_viridis_c(name = "Media por\nvisita") +
  labs(x = NULL, y = NULL, title = "Abundancia media de cada especie por hábitat") +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))
p_heat

# 7d. Patrón estacional: conteos por visita, en paneles según la dieta
p_season <- birds |>
  group_by(date, diet) |>
  summarise(mean_count = mean(count), .groups = "drop") |>
  ggplot(aes(x = date, y = mean_count)) +
  geom_line() + geom_point(size = 2) +
  facet_wrap(~ diet) +
  labs(x = NULL, y = "Conteo medio por punto y especie",
       title = "Conteos en las tres visitas, según la dieta") +
  theme_minimal(base_size = 13)
p_season

# 7e. Un primer mapa con ggplot: posición en x/y y riqueza como tamaño.
# coord_quickmap() da unas proporciones aproximadamente correctas.
p_map <- ggplot(point_summary, aes(x = longitude, y = latitude)) +
  geom_point(aes(colour = habitat_es, size = richness), alpha = 0.8) +
  coord_quickmap() +
  labs(title = "Puntos de muestreo", x = "Longitud", y = "Latitud", colour = "Hábitat", size = "Riqueza") +
  theme_minimal(base_size = 13)
p_map


# ---------------------------------------------------------------------
# 8. Guardar tablas y figuras
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
#  EJERCICIOS  (soluciones en semana02_soluciones.R; ¡inténtalo antes!)
# =====================================================================
# E1. ¿Cuántas aves anotó en total cada observador? ¿Quién anotó más
#     por visita, de media?
#
# E2. Con `birds`, busca las tres especies con mayor conteo total en
#     todos los puntos y visitas.
#
# E3. Crea una columna `forest` que valga "abierto" para brezal y prado
#     y "bosque" para el resto (pista: if_else() y %in%). Compara la
#     riqueza media entre bosque y medios abiertos.
#
# E4. Representa la cobertura de copas (x) frente a la riqueza (y) con
#     point_summary. Colorea por hábitat y añade una recta de tendencia
#     con geom_smooth(method = "lm").
#
# E5. Haz un gráfico de barras con el conteo medio por visita de cada
#     grupo de dieta en cada hábitat (pista: geom_col() y
#     position = "dodge").
#
# E6. Reto: vuelve a pasar species_by_habitat a formato ancho, con una
#     fila por especie y una columna por hábitat (pivot_wider()).
#     Guárdalo como outputs/species_by_habitat_wide.csv.
# =====================================================================
