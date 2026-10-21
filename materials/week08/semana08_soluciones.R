# =====================================================================
#  Ecología Espacial  ·  Semana 8  ·  Soluciones
# =====================================================================
# Ejecuta antes semana08_datos_GBIF.R hasta la sección 5.

# E1. Registros que quedan tras cada paso
steps_log |> mutate(removed = lag(n) - n)

# E2. Pruebas que marcaron registros
colSums(!flags[, grep("^\\.", names(flags))])

# E3. Aclarado con celdas de 500 m
occ |> mutate(cell500 = paste(floor(x / 500), floor(y / 500))) |> distinct(cell500) |> nrow()

# E4. Registros por fuente
thinned |> st_drop_geometry() |> count(institutionCode, sort = TRUE)
# Si una fuente se concentra en zonas accesibles, el modelo aprenderá
# "dónde hay observadores" además de "dónde vive la especie".

# E5. (Necesita internet; ejemplo para Mallorca con un rectángulo WKT)
# library(rgbif)
# occ_search(scientificName = "Lullula arborea", hasCoordinate = TRUE, limit = 300,
#            geometry = "POLYGON((2.3 39.3, 3.5 39.3, 3.5 40.0, 2.3 40.0, 2.3 39.3))")$data
