# =====================================================================
#  Spatial Ecology  ·  Week 8  ·  Solutions
# =====================================================================
# Run week08_GBIF_data.R up to section 5 first.

# E1. Records left after each step
steps_log |> mutate(removed = lag(n) - n)

# E2. Tests that flagged records
colSums(!flags[, grep("^\\.", names(flags))])

# E3. Thinning with 500 m cells
occ |> mutate(cell500 = paste(floor(x / 500), floor(y / 500))) |> distinct(cell500) |> nrow()

# E4. Records per source
thinned |> st_drop_geometry() |> count(institutionCode, sort = TRUE)
# If one source concentrates on accessible areas, the model learns
# "where observers go" as well as "where the species lives".

# E5. (Needs internet; example for Mallorca with a WKT rectangle)
# library(rgbif)
# occ_search(scientificName = "Lullula arborea", hasCoordinate = TRUE, limit = 300,
#            geometry = "POLYGON((2.3 39.3, 3.5 39.3, 3.5 40.0, 2.3 40.0, 2.3 39.3))")$data
