# =====================================================================
#  Spatial Ecology  ·  Week 4
#  GLMs for counts and presence–absence
# =====================================================================
#  Files in data/: survey_points.csv, bird_counts_wide.csv
#  Packages: tidyverse, MASS, DHARMa, lme4
#    install.packages(c("MASS", "DHARMa", "lme4"))
#  SIMULATED data (fictitious Sierra de Montfred).
# =====================================================================

library(tidyverse)
library(MASS)      # glm.nb() for negative binomial
library(DHARMa)    # residual checks for GLMs
library(lme4)      # mixed models
select <- dplyr::select   # MASS also has select(); use dplyr's


# ---------------------------------------------------------------------
# 1. Data: one total count per point and visit
# ---------------------------------------------------------------------
points <- read_csv("data/survey_points.csv")
counts <- read_csv("data/bird_counts_wide.csv") |>
  mutate(obs_key = str_to_upper(str_remove_all(observer, "[ .]")),
         observer = case_when(obs_key == "MPUIG" ~ "M. Puig", obs_key == "JSERRA" ~ "J. Serra", obs_key == "AFERRER" ~ "A. Ferrer")) |>
  select(-obs_key)

visits <- counts |>
  mutate(total = rowSums(across(european_robin:short_toed_treecreeper), na.rm = TRUE),
         visit = factor(visit)) |>
  left_join(points, by = "point_id") |>
  mutate(elev_100 = (elevation_m - 1000) / 100)   # elevation centred at 1000 m, in 100 m units

visits |> select(point_id, visit, observer, total, elevation_m, canopy_cover_pct)

# Counts are whole numbers >= 0 and their variance usually grows with
# the mean. So we use a GLM with a Poisson distribution and a log link:
#   log(mean) = b0 + b1 * x1 + ...


# ---------------------------------------------------------------------
# 2. Poisson GLM
# ---------------------------------------------------------------------
m_pois <- glm(total ~ elev_100 + canopy_cover_pct + observer + visit,
              family = poisson, data = visits)
summary(m_pois)

# Coefficients are on the log scale. exp() turns them into
# multiplicative effects: exp(b) = how many times the count changes.
exp(coef(m_pois))
exp(confint.default(m_pois))


# ---------------------------------------------------------------------
# 3. Overdispersion
# ---------------------------------------------------------------------
# Poisson assumes variance = mean. If the variance is larger
# (overdispersion), standard errors are too small.
sum(residuals(m_pois, type = "pearson")^2) / df.residual(m_pois)   # ~1 fine; >1.5 a problem

sim_pois <- simulateResiduals(m_pois)
testDispersion(sim_pois)
plot(sim_pois)


# ---------------------------------------------------------------------
# 4. Negative binomial
# ---------------------------------------------------------------------
m_nb <- glm.nb(total ~ elev_100 + canopy_cover_pct + observer + visit, data = visits)
summary(m_nb)
AIC(m_pois, m_nb)

sim_nb <- simulateResiduals(m_nb)
plot(sim_nb)

# Is there an observer effect? Compare the model with and without it
m_nb0 <- update(m_nb, . ~ . - observer)
anova(m_nb0, m_nb)
exp(coef(m_nb))[c("observerJ. Serra", "observerM. Puig")]
# A value of 0.8 means that observer records 20% fewer birds than
# A. Ferrer (the reference level) under the same conditions.


# ---------------------------------------------------------------------
# 5. Predictions on the response scale
# ---------------------------------------------------------------------
# Predict on the link (log) scale, then back-transform with exp(), so
# the interval can never go below zero.
grid <- tibble(elev_100 = seq(min(visits$elev_100), max(visits$elev_100), length.out = 100),
               canopy_cover_pct = mean(visits$canopy_cover_pct),
               observer = "A. Ferrer", visit = factor(2, levels = 1:3))
pr <- predict(m_nb, grid, type = "link", se.fit = TRUE)
grid <- grid |>
  mutate(fit = exp(pr$fit), lo = exp(pr$fit - 1.96 * pr$se.fit), hi = exp(pr$fit + 1.96 * pr$se.fit),
         elevation_m = elev_100 * 100 + 1000)

p_nb <- ggplot(grid, aes(elevation_m, fit)) +
  geom_ribbon(aes(ymin = lo, ymax = hi), fill = "grey80") +
  geom_line(linewidth = 1) +
  geom_point(data = visits, aes(y = total), alpha = 0.4) +
  labs(x = "Elevation (m)", y = "Birds per visit", title = "Negative binomial: birds and elevation",
       subtitle = "Mean canopy cover, observer A. Ferrer, May visit") +
  theme_minimal(base_size = 13)
p_nb


# ---------------------------------------------------------------------
# 6. Presence–absence: binomial GLM (logistic regression)
# ---------------------------------------------------------------------
# Was the woodlark detected in any of the three visits?
woodlark <- counts |>
  group_by(point_id) |>
  summarise(present = as.integer(any(woodlark > 0, na.rm = TRUE))) |>
  left_join(points, by = "point_id") |>
  mutate(elev_100 = (elevation_m - 1000) / 100)
table(woodlark$present)

m_bin <- glm(present ~ canopy_cover_pct, family = binomial, data = woodlark)
summary(m_bin)
# Logit scale: exp(b) is an odds ratio.
exp(coef(m_bin))

grid_b <- tibble(canopy_cover_pct = 0:100)
pb <- predict(m_bin, grid_b, type = "link", se.fit = TRUE)
grid_b <- grid_b |> mutate(p = plogis(pb$fit), lo = plogis(pb$fit - 1.96 * pb$se.fit), hi = plogis(pb$fit + 1.96 * pb$se.fit))

p_bin <- ggplot(grid_b, aes(canopy_cover_pct, p)) +
  geom_ribbon(aes(ymin = lo, ymax = hi), fill = "grey80") +
  geom_line(linewidth = 1) +
  geom_jitter(data = woodlark, aes(y = present), height = 0.03, width = 0, alpha = 0.6) +
  labs(x = "Canopy cover (%)", y = "Probability of detection",
       title = "Woodlark: presence and canopy cover") +
  theme_minimal(base_size = 13)
p_bin


# ---------------------------------------------------------------------
# 7. Repeated measures: mixed model with point as a random effect
# ---------------------------------------------------------------------
# Each point was visited three times: those visits are not independent.
# (1 | point_id) lets each point have its own average level.
m_mix <- glmer(total ~ elev_100 + observer + visit + (1 | point_id),
               family = poisson, data = visits)
summary(m_mix)
VarCorr(m_mix)


# ---------------------------------------------------------------------
# 8. Save
# ---------------------------------------------------------------------
dir.create("outputs", showWarnings = FALSE)
ggsave("outputs/nb_elevation.png", p_nb, width = 7, height = 5, dpi = 300, bg = "white")
ggsave("outputs/woodlark_logistic.png", p_bin, width = 7, height = 5, dpi = 300, bg = "white")
png("outputs/dharma_poisson.png", width = 2000, height = 1000, res = 200); plot(sim_pois); dev.off()


# =====================================================================
#  EXERCISES  (answers in week04_solutions.R)
# =====================================================================
# E1. Fit a Poisson GLM for the number of robins (european_robin) per
#     visit, with elev_100 and habitat. Is there overdispersion?
# E2. With m_nb, by what factor does the number of birds change per
#     100 m climbed? Give the confidence interval.
# E3. In the binomial model, replace canopy cover with elevation
#     (elev_100). Which model has the lower AIC?
# E4. At what canopy cover does the probability of detecting woodlark
#     drop below 50%? (Hint: -b0 / b1.)
# E5. Compare the observer coefficients in m_nb and m_mix. Does the
#     conclusion change once repeated visits are accounted for?
# =====================================================================
