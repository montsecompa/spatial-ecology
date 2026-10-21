# =====================================================================
#  Ecología Espacial  ·  Semana 4  ·  Soluciones
# =====================================================================
# Ejecuta antes las secciones 1 a 7 de semana04_GLM.R.

# E1. Petirrojos por visita
m_robin <- glm(european_robin ~ elev_100 + habitat, family = poisson, data = visits)
summary(m_robin)
sum(residuals(m_robin, type = "pearson")^2) / df.residual(m_robin)
testDispersion(simulateResiduals(m_robin))
# Si el cociente está cerca de 1 y la prueba de DHARMa no es
# significativa, Poisson es suficiente para esta especie.

# E2. Efecto de 100 m de altitud en m_nb
exp(coef(m_nb)["elev_100"])
exp(confint.default(m_nb)["elev_100", ])

# E3. Altitud en lugar de cobertura
m_bin_elev <- glm(present ~ elev_100, family = binomial, data = woodlark)
AIC(m_bin, m_bin_elev)

# E4. Cobertura a la que la probabilidad es 0,5
b <- coef(m_bin)
-b[1] / b[2]
# En logit, p = 0,5 cuando b0 + b1 * x = 0, es decir x = -b0 / b1.

# E5. Observador en el modelo de efectos fijos y en el mixto
cbind(glm_nb = coef(m_nb)[c("observerJ. Serra", "observerM. Puig")],
      glmer  = fixef(m_mix)[c("observerJ. Serra", "observerM. Puig")])
# Los efectos suelen ser parecidos, pero los errores típicos del modelo
# mixto son más honestos porque no trata las tres visitas a un mismo
# punto como datos independientes.
