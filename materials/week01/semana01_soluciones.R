# =====================================================================
#  Ecología Espacial  ·  Semana 1  ·  Soluciones de los ejercicios
# =====================================================================
# Casi siempre hay más de una forma correcta. Si la tuya da el mismo
# resultado, es correcta.

points <- read.csv("data/survey_points.csv")

# E1. Velocidad en km/h
transect_km <- 2.5
time_min <- 50
speed_kmh <- transect_km / (time_min / 60)
speed_kmh                                   # 3 km/h

# E2. Mirlos
blackbirds <- c(1, 0, 3, 2, 2, 4, 0, 1)
mean(blackbirds)                            # 1.625
sum(blackbirds == 0)                        # 2

# E3. Puntos en pinar de repoblación
sum(points$habitat == "pine plantation")
# o bien: table(points$habitat)

# E4. Rango de altitud de los puntos de hayedo
range(points$elevation_m[points$habitat == "beech forest"])

# E5. Punto más cercano a un torrente
closest <- points[which.min(points$dist_stream_m), ]
closest[, c("point_id", "habitat", "dist_stream_m")]

# E6. Cobertura de copas frente a altitud
plot(canopy_cover_pct ~ elevation_m, data = points, pch = 19,
     main = "Cobertura de copas a lo largo del gradiente altitudinal",
     xlab = "Altitud (m)", ylab = "Cobertura de copas (%)")
# Patrón: la cobertura se mantiene alta (bosque) hasta unos 1.300 m y
# cae bruscamente en las cumbres, donde empiezan el brezal y los prados.
