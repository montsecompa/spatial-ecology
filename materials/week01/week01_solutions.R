# =====================================================================
#  Spatial Ecology  ·  Week 1  ·  Exercise solutions
# =====================================================================
# There is usually more than one correct way. If yours gives the same
# answer, it is right.

points <- read.csv("data/survey_points.csv")

# E1. Walking speed in km per hour
transect_km <- 2.5
time_min <- 50
speed_kmh <- transect_km / (time_min / 60)
speed_kmh                                   # 3 km/h

# E2. Blackbirds
blackbirds <- c(1, 0, 3, 2, 2, 4, 0, 1)
mean(blackbirds)                            # 1.625
sum(blackbirds == 0)                        # 2

# E3. Points in pine plantation
sum(points$habitat == "pine plantation")
# or: table(points$habitat)

# E4. Elevation range of beech forest points
range(points$elevation_m[points$habitat == "beech forest"])

# E5. Point closest to a stream
closest <- points[which.min(points$dist_stream_m), ]
closest[, c("point_id", "habitat", "dist_stream_m")]

# E6. Canopy cover against elevation
plot(canopy_cover_pct ~ elevation_m, data = points, pch = 19,
     main = "Canopy cover along the elevation gradient",
     xlab = "Elevation (m)", ylab = "Canopy cover (%)")
# Pattern: canopy stays high (forest) up to about 1,300 m, then drops
# sharply on the summits, where heathland and meadows start.
