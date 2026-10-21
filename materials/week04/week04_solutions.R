# =====================================================================
#  Spatial Ecology  ·  Week 4  ·  Solutions
# =====================================================================
# Run sections 1 to 7 of week04_GLMs.R first.

# E1. Robins per visit
m_robin <- glm(european_robin ~ elev_100 + habitat, family = poisson, data = visits)
summary(m_robin)
sum(residuals(m_robin, type = "pearson")^2) / df.residual(m_robin)
testDispersion(simulateResiduals(m_robin))
# If the ratio is close to 1 and the DHARMa test is not significant,
# Poisson is good enough for this species.

# E2. Effect of 100 m of elevation in m_nb
exp(coef(m_nb)["elev_100"])
exp(confint.default(m_nb)["elev_100", ])

# E3. Elevation instead of canopy cover
m_bin_elev <- glm(present ~ elev_100, family = binomial, data = woodlark)
AIC(m_bin, m_bin_elev)

# E4. Canopy cover at which the probability is 0.5
b <- coef(m_bin)
-b[1] / b[2]
# On the logit scale, p = 0.5 when b0 + b1 * x = 0, so x = -b0 / b1.

# E5. Observer in the fixed-effects and the mixed model
cbind(glm_nb = coef(m_nb)[c("observerJ. Serra", "observerM. Puig")],
      glmer  = fixef(m_mix)[c("observerJ. Serra", "observerM. Puig")])
# The estimates are usually similar, but the mixed model's standard
# errors are more honest because it does not treat three visits to the
# same point as independent data.
