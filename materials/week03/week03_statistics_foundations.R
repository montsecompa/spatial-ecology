# =====================================================================
#  Spatial Ecology  ·  Week 3
#  Statistics foundations for ecologists
# =====================================================================
#  Files in data/: survey_points.csv, bird_counts_wide.csv
#  SIMULATED data (fictitious Sierra de Montfred).
#
#  Today: describing data, confidence intervals, comparing groups and
#  the linear model behind t-tests, ANOVA and regression.
# =====================================================================

library(tidyverse)


# ---------------------------------------------------------------------
# 1. Prepare the data: one summary row per point (as in Week 2)
# ---------------------------------------------------------------------
points <- read_csv("data/survey_points.csv")
counts <- read_csv("data/bird_counts_wide.csv")

point_summary <- counts |>
  pivot_longer(european_robin:short_toed_treecreeper, names_to = "species", values_to = "count") |>
  filter(!is.na(count)) |>
  group_by(point_id) |>
  summarise(richness  = n_distinct(species[count > 0]),
            abundance = sum(count) / n_distinct(visit)) |>
  left_join(points, by = "point_id") |>
  mutate(open = if_else(habitat %in% c("heathland", "meadow"), "open", "forest"))

point_summary


# ---------------------------------------------------------------------
# 2. Describing a variable
# ---------------------------------------------------------------------
x <- point_summary$abundance
mean(x); median(x); sd(x)
se <- sd(x) / sqrt(length(x))   # standard error of the mean
se
quantile(x, c(0.05, 0.25, 0.5, 0.75, 0.95))

ggplot(point_summary, aes(abundance)) +
  geom_histogram(binwidth = 1, fill = "grey70", colour = "white") +
  labs(x = "Birds per visit", y = "Number of points") +
  theme_minimal()

# The standard deviation (sd) describes variation between points.
# The standard error (se) describes uncertainty in the MEAN: it shrinks
# as sample size grows.


# ---------------------------------------------------------------------
# 3. Confidence intervals
# ---------------------------------------------------------------------
# 95% CI from the t distribution
n <- length(x)
mean(x) + c(-1, 1) * qt(0.975, df = n - 1) * se

# Bootstrap CI: resample the points with replacement many times and
# look at how the mean varies.
set.seed(1)
boot_means <- replicate(5000, mean(sample(x, replace = TRUE)))
quantile(boot_means, c(0.025, 0.975))


# ---------------------------------------------------------------------
# 4. Comparing two groups: forest versus open habitats
# ---------------------------------------------------------------------
ggplot(point_summary, aes(open, abundance)) +
  geom_boxplot(fill = "grey90", outlier.shape = NA) +
  geom_jitter(width = 0.1, height = 0) +
  labs(x = NULL, y = "Birds per visit") +
  theme_minimal()

t.test(abundance ~ open, data = point_summary)   # Welch t-test

# The same comparison as a linear model: the "openopen" coefficient is
# the difference in means between the two groups.
m_open <- lm(abundance ~ open, data = point_summary)
summary(m_open)


# ---------------------------------------------------------------------
# 5. More than two groups: ANOVA
# ---------------------------------------------------------------------
m_hab <- lm(abundance ~ habitat, data = point_summary)
anova(m_hab)            # does abundance differ among habitats?
summary(m_hab)          # each coefficient is compared with the reference level

# Pairwise comparisons, corrected for multiple testing
TukeyHSD(aov(abundance ~ habitat, data = point_summary))


# ---------------------------------------------------------------------
# 6. Linear regression: abundance and elevation
# ---------------------------------------------------------------------
m_elev <- lm(abundance ~ elevation_m, data = point_summary)
summary(m_elev)
confint(m_elev)

# The slope is in "birds per metre". Easier to read per 100 m:
coef(m_elev)["elevation_m"] * 100

# Predictions with confidence intervals
new <- tibble(elevation_m = c(600, 1000, 1400))
predict(m_elev, newdata = new, interval = "confidence")

ggplot(point_summary, aes(elevation_m, abundance)) +
  geom_point() +
  geom_smooth(method = "lm", colour = "black") +
  labs(x = "Elevation (m)", y = "Birds per visit") +
  theme_minimal()


# ---------------------------------------------------------------------
# 7. Multiple regression and correlated predictors
# ---------------------------------------------------------------------
cor(point_summary$elevation_m, point_summary$canopy_cover_pct)

m_both <- lm(abundance ~ elevation_m + canopy_cover_pct, data = point_summary)
summary(m_both)
# Each coefficient is the effect of one variable holding the other
# constant. Strongly correlated predictors make coefficients unstable:
# compare with m_elev.

AIC(m_elev, m_both)   # lower AIC = better balance of fit and complexity


# ---------------------------------------------------------------------
# 8. Checking assumptions with residuals
# ---------------------------------------------------------------------
par(mfrow = c(2, 2)); plot(m_both); par(mfrow = c(1, 1))
# What to look for:
#  - Residuals vs fitted: a shapeless cloud (no curve, no funnel).
#  - Q-Q: points close to the line (roughly normal residuals).
#  - Residuals vs leverage: no point with Cook's distance > 1.

diag_df <- tibble(fitted = fitted(m_both), resid = resid(m_both))
p_resid <- ggplot(diag_df, aes(fitted, resid)) +
  geom_hline(yintercept = 0, linetype = 2) + geom_point() +
  labs(x = "Fitted values", y = "Residuals") +
  theme_minimal()
p_resid

# Careful: richness and counts are whole numbers >= 0. A linear model
# can predict negative values and assumes constant variance.
# Week 4 solves this with generalised linear models (GLMs).


# ---------------------------------------------------------------------
# 9. Save
# ---------------------------------------------------------------------
dir.create("outputs", showWarnings = FALSE)
write_csv(point_summary, "outputs/point_summary.csv")
p_reg <- ggplot(point_summary, aes(elevation_m, abundance)) +
  geom_point(aes(colour = open), size = 2.5) +
  geom_smooth(method = "lm", colour = "black") +
  labs(x = "Elevation (m)", y = "Birds per visit", colour = NULL, title = "Abundance and elevation") +
  theme_minimal(base_size = 13)
ggsave("outputs/regression_elevation.png", p_reg, width = 7, height = 5, dpi = 300, bg = "white")
ggsave("outputs/residuals.png", p_resid, width = 6, height = 4.5, dpi = 300, bg = "white")


# =====================================================================
#  EXERCISES  (answers in week03_solutions.R)
# =====================================================================
# E1. Calculate the mean, median and 95% CI (t and bootstrap) of
#     richness. Do the two intervals agree?
# E2. Does canopy cover differ between forest and open points? Use
#     t.test() and lm() and check they give the same difference.
# E3. Fit lm(richness ~ elevation_m). How much does richness change per
#     100 m climbed? What share of the variation does it explain (R²)?
# E4. Predict richness at 1,800 m with the E3 model. Does it make
#     ecological sense? Why is predicting outside the data range risky?
# E5. Look at the residual plots of m_hab. Do you see any problem?
# =====================================================================
