# =====================================================================
#  Spatial Ecology  ·  Week 3  ·  Solutions
# =====================================================================
# Run section 1 of week03_statistics_foundations.R first.
library(tidyverse)

# E1. Mean, median and intervals for richness
r <- point_summary$richness
mean(r); median(r)
mean(r) + c(-1, 1) * qt(0.975, length(r) - 1) * sd(r) / sqrt(length(r))
set.seed(2)
quantile(replicate(5000, mean(sample(r, replace = TRUE))), c(0.025, 0.975))
# Both intervals are very similar: with 40 points the mean is close to normal.

# E2. Canopy cover: forest versus open
t.test(canopy_cover_pct ~ open, data = point_summary)
coef(lm(canopy_cover_pct ~ open, data = point_summary))
# The difference in means from t.test() equals the lm() coefficient.

# E3. Richness and elevation
m_r <- lm(richness ~ elevation_m, data = point_summary)
summary(m_r)
coef(m_r)["elevation_m"] * 100            # change per 100 m
summary(m_r)$r.squared

# E4. Predicting outside the range
predict(m_r, tibble(elevation_m = 1800), interval = "prediction")
range(point_summary$elevation_m)
# 1,800 m is above the highest sampled point: we assume the line carries
# on where we have no data, and it can predict impossible values
# (below 0 or above 10 species).

# E5. Residuals of the habitat model
m_hab <- lm(abundance ~ habitat, data = point_summary)
par(mfrow = c(2, 2)); plot(m_hab); par(mfrow = c(1, 1))
# With few points in some habitats (3 to 6) each group's variance is
# poorly estimated; spread may be larger where there are more birds.
