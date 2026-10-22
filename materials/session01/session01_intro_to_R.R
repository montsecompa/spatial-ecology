# =====================================================================
#  Spatial Ecology  ·  Session 1
#  Getting set up: first steps in R
# =====================================================================
#
#  How to use this script
#  ----------------------
#  1. Open your course RStudio project (File > Open Project...).
#  2. Put survey_points.csv inside the project's data/ folder.
#  3. Run the script one line at a time with Ctrl + Enter
#     (Cmd + Enter on a Mac). Read the comments as you go.
#
#  Lines starting with # are comments: R ignores them.
#  The data are SIMULATED for teaching: they imitate bird surveys in the
#  Sierra de Montfred, a fictitious natural park.
# =====================================================================


# ---------------------------------------------------------------------
# 1. R as a calculator
# ---------------------------------------------------------------------
2 + 3
10 / 4
2^10          # powers
sqrt(144)     # a function: name, then arguments in brackets
log(100)      # natural log
log10(100)    # base-10 log


# ---------------------------------------------------------------------
# 2. Objects: giving things names
# ---------------------------------------------------------------------
# The arrow <- stores a value in an object. Shortcut: Alt + -
plot_area_m2 <- 50 * 50
plot_area_m2
plot_area_ha <- plot_area_m2 / 10000
plot_area_ha

# Object names: start with a letter, no spaces. snake_case is easy to read.
# R is case sensitive: Plot_area_ha is NOT the same object.


# ---------------------------------------------------------------------
# 3. Vectors: many values in one object
# ---------------------------------------------------------------------
# c() combines values. Here: robins counted at six survey points.
robins <- c(4, 2, 0, 5, 3, 1)

length(robins)   # how many values?
sum(robins)      # total robins
mean(robins)     # average per point
max(robins)
range(robins)

# R works on the whole vector at once ("vectorised"):
robins * 2
robins > 2       # a logical vector: TRUE / FALSE for each value

# Indexing with square brackets: position starts at 1
robins[1]
robins[2:4]
robins[robins > 2]   # only the values greater than 2


# ---------------------------------------------------------------------
# 4. Types of data
# ---------------------------------------------------------------------
habitats <- c("beech forest", "meadow", "beech forest", "heathland")
class(habitats)      # "character": text

surveyed <- c(TRUE, TRUE, FALSE, TRUE)
class(surveyed)      # "logical"

habitat_f <- factor(habitats)  # a factor: categories with levels
levels(habitat_f)
table(habitat_f)               # count of each category

# Missing values are NA. Many functions need na.rm = TRUE to skip them.
counts <- c(3, NA, 5, 2)
mean(counts)                # NA, because one value is unknown
mean(counts, na.rm = TRUE)  # 3.33


# ---------------------------------------------------------------------
# 5. Getting help
# ---------------------------------------------------------------------
?mean
help("read.csv")
# Scroll to the "Examples" section at the bottom of any help page.


# ---------------------------------------------------------------------
# 6. Data frames: the ecologist's spreadsheet
# ---------------------------------------------------------------------
# Each column is a variable, each row an observation.
mini <- data.frame(
  point   = c("A", "B", "C"),
  habitat = c("meadow", "beech forest", "heathland"),
  birds   = c(6, 14, 4)
)
mini
mini$birds          # one column, with $
mini[2, ]           # second row, all columns
mini[, "habitat"]   # all rows, one column


# ---------------------------------------------------------------------
# 7. Reading a dataset
# ---------------------------------------------------------------------
# The path is relative to your project folder. If you get
# "cannot open file", check that the file really is in data/.
points <- read.csv("data/survey_points.csv")

head(points)        # first six rows
str(points)         # structure: column names and types
summary(points)     # quick summary of every column
nrow(points)
names(points)

table(points$habitat)
mean(points$elevation_m)


# ---------------------------------------------------------------------
# 8. Selecting rows with conditions
# ---------------------------------------------------------------------
high <- points[points$elevation_m > 1200, ]
nrow(high)

beech <- points[points$habitat == "beech forest", ]   # == tests equality
summary(beech$canopy_cover_pct)

# Several conditions: & means AND, | means OR
open_high <- points[points$canopy_cover_pct < 30 & points$elevation_m > 1200, ]
open_high


# ---------------------------------------------------------------------
# 9. New columns and group summaries
# ---------------------------------------------------------------------
points$elevation_km <- points$elevation_m / 1000

# Mean elevation in each habitat
aggregate(elevation_m ~ habitat, data = points, FUN = mean)

# Mean canopy cover in each habitat, sorted
canopy <- aggregate(canopy_cover_pct ~ habitat, data = points, FUN = mean)
canopy[order(canopy$canopy_cover_pct, decreasing = TRUE), ]


# ---------------------------------------------------------------------
# 10. First plots with base R
# ---------------------------------------------------------------------
hist(points$elevation_m, main = "Elevation of survey points",
     xlab = "Elevation (m)", col = "grey80", border = "white")

par(mar = c(9, 4.5, 1, 1))   # wide bottom margin for the labels
boxplot(elevation_m ~ habitat, data = points, las = 2, xlab = "", ylab = "Elevation (m)", cex.axis = 0.8)
par(mar = c(5, 4, 4, 2))

# A first "map": longitude on x, latitude on y.
# This is not yet a proper map (no projection); that comes in Session 5.
points$habitat <- factor(points$habitat)
plot(latitude ~ longitude, data = points,
     col = as.integer(points$habitat), pch = 19,
     main = "Survey points coloured by habitat")
legend("bottomright", legend = levels(points$habitat),
       col = seq_along(levels(points$habitat)), pch = 19, cex = 0.7)


# ---------------------------------------------------------------------
# 11. Saving your work
# ---------------------------------------------------------------------
dir.create("outputs", showWarnings = FALSE)   # create outputs/ if it does not exist

write.csv(canopy, "outputs/canopy_by_habitat.csv", row.names = FALSE)

png("outputs/elevation_histogram.png", width = 1600, height = 1200, res = 200)
hist(points$elevation_m, main = "Elevation of survey points",
     xlab = "Elevation (m)", col = "grey80", border = "white")
dev.off()


# ---------------------------------------------------------------------
# 12. Get ready for Session 2
# ---------------------------------------------------------------------
# Run this once (it takes a few minutes). Remove the # first.
# install.packages("tidyverse")


# =====================================================================
#  EXERCISES  (answers are in session01_solutions.R; try first!)
# =====================================================================
# E1. A transect of 2.5 km was walked in 50 minutes. Store both values
#     in objects and calculate walking speed in km per hour.
#
# E2. Blackbirds counted at eight points: 1, 0, 3, 2, 2, 4, 0, 1.
#     Store them in a vector. What is the mean? How many points had
#     no blackbirds? (Hint: sum() of a logical vector counts TRUEs.)
#
# E3. How many survey points are in pine plantation?
#
# E4. What is the lowest and highest elevation of the beech forest points?
#
# E5. Which survey point is closest to a stream? Give its point_id
#     and habitat. (Hint: which.min())
#
# E6. Make a scatter plot of canopy cover (y) against elevation (x).
#     Add a title and axis labels with units. What pattern do you see?
# =====================================================================
