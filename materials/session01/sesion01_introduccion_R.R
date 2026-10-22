# =====================================================================
#  Ecología Espacial  ·  Sesión 1
#  Puesta en marcha: primeros pasos en R
# =====================================================================
#
#  Cómo usar este script
#  ---------------------
#  1. Crea el proyecto de RStudio sesion01 (File > New Project...)
#     con las carpetas 1.Data, 2.Scripts y 3.Outputs.
#  2. Guarda survey_points.csv en la carpeta 1.Data/ del proyecto.
#  3. Ejecuta el script línea a línea con Ctrl + Intro
#     (Cmd + Intro en Mac) y lee los comentarios.
#
#  Las líneas que empiezan por # son comentarios: R las ignora.
#  Los datos son SIMULADOS con fines docentes: imitan censos de aves en la
#  Sierra de Montfred, un parque natural ficticio.
#  Los nombres de las columnas están en inglés, como en la mayoría de
#  bases de datos científicas.
# =====================================================================


# ---------------------------------------------------------------------
# 1. R como calculadora
# ---------------------------------------------------------------------
2 + 3
10 / 4
2^10          # potencias
sqrt(144)     # una función: nombre y argumentos entre paréntesis
log(100)      # logaritmo natural
log10(100)    # logaritmo en base 10


# ---------------------------------------------------------------------
# 2. Objetos: poner nombre a las cosas
# ---------------------------------------------------------------------
# La flecha <- guarda un valor en un objeto. Atajo: Alt + -
plot_area_m2 <- 50 * 50
plot_area_m2
plot_area_ha <- plot_area_m2 / 10000
plot_area_ha

# Nombres de objetos: empiezan por letra y no llevan espacios ni tildes.
# R distingue mayúsculas: Plot_area_ha NO es el mismo objeto.


# ---------------------------------------------------------------------
# 3. Vectores: varios valores en un objeto
# ---------------------------------------------------------------------
# c() combina valores. Aquí: petirrojos contados en seis puntos.
robins <- c(4, 2, 0, 5, 3, 1)

length(robins)   # ¿cuántos valores?
sum(robins)      # total de petirrojos
mean(robins)     # media por punto
max(robins)
range(robins)

# R trabaja con el vector entero a la vez ("vectorizado"):
robins * 2
robins > 2       # vector lógico: TRUE / FALSE para cada valor

# Indexar con corchetes: la primera posición es la 1
robins[1]
robins[2:4]
robins[robins > 2]   # solo los valores mayores que 2


# ---------------------------------------------------------------------
# 4. Tipos de datos
# ---------------------------------------------------------------------
habitats <- c("beech forest", "meadow", "beech forest", "heathland")
class(habitats)      # "character": texto

surveyed <- c(TRUE, TRUE, FALSE, TRUE)
class(surveyed)      # "logical": lógico

habitat_f <- factor(habitats)  # factor: categorías con niveles
levels(habitat_f)
table(habitat_f)               # cuántas veces aparece cada categoría

# Los valores perdidos son NA. Muchas funciones necesitan na.rm = TRUE.
counts <- c(3, NA, 5, 2)
mean(counts)                # NA, porque falta un valor
mean(counts, na.rm = TRUE)  # 3.33


# ---------------------------------------------------------------------
# 5. Pedir ayuda
# ---------------------------------------------------------------------
?mean
help("read.csv")
# Al final de cada página de ayuda hay ejemplos ("Examples").


# ---------------------------------------------------------------------
# 6. Data frames: la hoja de cálculo del ecólogo
# ---------------------------------------------------------------------
# Cada columna es una variable y cada fila una observación.
mini <- data.frame(
  point   = c("A", "B", "C"),
  habitat = c("meadow", "beech forest", "heathland"),
  birds   = c(6, 14, 4)
)
mini
mini$birds          # una columna, con $
mini[2, ]           # segunda fila, todas las columnas
mini[, "habitat"]   # todas las filas, una columna


# ---------------------------------------------------------------------
# 7. Leer un conjunto de datos
# ---------------------------------------------------------------------
# La ruta es relativa a la carpeta del proyecto. Si aparece
# "cannot open file", comprueba que el archivo está en 1.Data/.
points <- read.csv("1.Data/survey_points.csv")

head(points)        # primeras seis filas
str(points)         # estructura: columnas y tipos
summary(points)     # resumen de cada columna
nrow(points)
names(points)

table(points$habitat)
mean(points$elevation_m)


# ---------------------------------------------------------------------
# 8. Seleccionar filas que cumplen una condición
# ---------------------------------------------------------------------
high <- points[points$elevation_m > 1200, ]
nrow(high)

beech <- points[points$habitat == "beech forest", ]   # == comprueba igualdad
summary(beech$canopy_cover_pct)

# Varias condiciones: & significa Y, | significa O
open_high <- points[points$canopy_cover_pct < 30 & points$elevation_m > 1200, ]
open_high


# ---------------------------------------------------------------------
# 9. Columnas nuevas y resúmenes por grupo
# ---------------------------------------------------------------------
points$elevation_km <- points$elevation_m / 1000

# Altitud media de cada hábitat
aggregate(elevation_m ~ habitat, data = points, FUN = mean)

# Cobertura de copas media por hábitat, ordenada
canopy <- aggregate(canopy_cover_pct ~ habitat, data = points, FUN = mean)
canopy[order(canopy$canopy_cover_pct, decreasing = TRUE), ]


# ---------------------------------------------------------------------
# 10. Primeros gráficos con R base
# ---------------------------------------------------------------------
hist(points$elevation_m, main = "Altitud de los puntos de muestreo",
     xlab = "Altitud (m)", ylab = "Frecuencia", col = "grey80", border = "white")

par(mar = c(9, 4.5, 1, 1))   # margen inferior amplio para las etiquetas
boxplot(elevation_m ~ habitat, data = points, las = 2, xlab = "", ylab = "Altitud (m)", cex.axis = 0.8)
par(mar = c(5, 4, 4, 2))

# Un primer "mapa": longitud en x, latitud en y.
# Aún no es un mapa de verdad (sin proyección); eso llega en la sesión 5.
points$habitat <- factor(points$habitat)
plot(latitude ~ longitude, data = points,
     col = as.integer(points$habitat), pch = 19,
     main = "Puntos de muestreo por hábitat")
legend("bottomright", legend = levels(points$habitat),
       col = seq_along(levels(points$habitat)), pch = 19, cex = 0.7)


# ---------------------------------------------------------------------
# 11. Guardar el trabajo
# ---------------------------------------------------------------------
dir.create("3.Outputs", showWarnings = FALSE)   # crea 3.Outputs/ si no existe

write.csv(canopy, "3.Outputs/canopy_by_habitat.csv", row.names = FALSE)

png("3.Outputs/elevation_histogram.png", width = 1600, height = 1200, res = 200)
hist(points$elevation_m, main = "Altitud de los puntos de muestreo",
     xlab = "Altitud (m)", ylab = "Frecuencia", col = "grey80", border = "white")
dev.off()


# ---------------------------------------------------------------------
# 12. Preparar la sesión 2
# ---------------------------------------------------------------------
# Ejecuta esto una vez (tarda unos minutos). Quita primero el #.
# install.packages("tidyverse")


# =====================================================================
#  EJERCICIOS  (soluciones en sesion01_soluciones.R; ¡inténtalo antes!)
# =====================================================================
# E1. Se recorrió un transecto de 2,5 km en 50 minutos. Guarda ambos
#     valores en objetos y calcula la velocidad en km/h.
#
# E2. Mirlos contados en ocho puntos: 1, 0, 3, 2, 2, 4, 0, 1.
#     Guárdalos en un vector. ¿Cuál es la media? ¿En cuántos puntos no
#     hubo mirlos? (Pista: sum() de un vector lógico cuenta los TRUE.)
#
# E3. ¿Cuántos puntos de muestreo están en pinar de repoblación
#     ("pine plantation")?
#
# E4. ¿Cuál es la altitud mínima y máxima de los puntos de hayedo
#     ("beech forest")?
#
# E5. ¿Qué punto está más cerca de un torrente? Da su point_id y su
#     hábitat. (Pista: which.min())
#
# E6. Haz un gráfico de dispersión de la cobertura de copas (y) frente a
#     la altitud (x), con título y ejes con unidades. ¿Qué patrón ves?
# =====================================================================
