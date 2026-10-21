// =====================================================================
//  COURSE CONTENT  ·  edit this file to update the website
// =====================================================================
//  To add materials for a week:
//   1. Put the files in materials/weekNN/  (for example materials/week03/)
//   2. Find that week below and add one line per file to "materials":
//        { "name": "week03_linear_models.R", "file": "materials/week03/week03_linear_models.R", "note": "Optional short note" },
//   3. Save, then commit/upload to GitHub. The site updates in about a minute.
//
//  Dates use the format "2026-11-04". Leave "" for "Date TBC".
//  Topics ("tracks"): "r", "stat", "gis".
//  Keep the quotes and commas exactly as they are: a missing comma stops
//  the page from loading. If that happens, check the last line you edited.
// =====================================================================
window.COURSE = {
  "course": {
    "title": "Spatial Ecology Sessions",
    "tagline": "Weekly hands-on classes in R, statistics and GIS for ecologists, working with real species and landscape data in R, QGIS and ArcGIS Pro.",
    "instructor": "",
    "when": "Weekly · day, time and room to be confirmed",
    "contact": "",
    "intro": "Each week has a short plan, what to prepare beforehand, and the materials for that class: slides, R scripts and datasets. Bring a laptop with the software from Week 1 installed."
  },
  "weeks": [
    {
      "title": "Getting set up: R, RStudio and QGIS",
      "date": "",
      "tracks": [
        "r",
        "gis"
      ],
      "summary": "Install the toolkit, organise a reproducible project folder, and take a first look at R and QGIS side by side.",
      "goals": [
        "Install R, RStudio and QGIS (LTR)",
        "Create an RStudio project with data/, scripts/ and outputs/ folders",
        "Run your first script: vectors, data frames and reading a CSV"
      ],
      "prep": "Install R, RStudio Desktop and QGIS LTR before class. Links are in the reference section at the bottom of this page.",
      "materials": [
        {
          "name": "Week01_Handout_Getting_set_up.pdf",
          "file": "materials/week01/Week01_Handout_Getting_set_up.pdf",
          "note": "Session plan, installation guide, QGIS steps and exercises"
        },
        {
          "name": "week01_intro_to_R.R",
          "file": "materials/week01/week01_intro_to_R.R",
          "note": "Download it and save it in your project's scripts/ folder."
        },
        {
          "name": "survey_points.csv",
          "file": "materials/week01/survey_points.csv",
          "note": "Save it in your project's data/ folder"
        },
        {
          "name": "week01_solutions.R",
          "file": "materials/week01/week01_solutions.R",
          "note": "Try the exercises before looking"
        }
      ]
    },
    {
      "title": "Wrangling and plotting ecological data",
      "date": "",
      "tracks": [
        "r"
      ],
      "summary": "Clean and summarise a field survey dataset with dplyr and tidyr, then build clear figures with ggplot2.",
      "goals": [
        "Filter, group and summarise with dplyr",
        "Reshape wide survey sheets to long format",
        "Plot abundance and richness with ggplot2"
      ],
      "prep": "Install the tidyverse package: install.packages(\"tidyverse\"). Bring your Week 1 project folder.",
      "materials": [
        {
          "name": "Week02_Handout_Wrangling_and_plotting.pdf",
          "file": "materials/week02/Week02_Handout_Wrangling_and_plotting.pdf",
          "note": "Tidy data, cleaning, joins, ggplot2 and exercises"
        },
        {
          "name": "week02_wrangling_and_plotting.R",
          "file": "materials/week02/week02_wrangling_and_plotting.R",
          "note": "Download it and save it in your project's scripts/ folder."
        },
        {
          "name": "bird_counts_wide.csv",
          "file": "materials/week02/bird_counts_wide.csv",
          "note": "Save in data/"
        },
        {
          "name": "species_traits.csv",
          "file": "materials/week02/species_traits.csv",
          "note": "Save in data/"
        },
        {
          "name": "survey_points.csv",
          "file": "materials/week02/survey_points.csv",
          "note": "Same file as Week 1"
        },
        {
          "name": "week02_solutions.R",
          "file": "materials/week02/week02_solutions.R",
          "note": "Try the exercises before looking"
        }
      ]
    },
    {
      "title": "Statistics foundations for ecologists",
      "date": "",
      "tracks": [
        "stat"
      ],
      "summary": "Distributions, sampling, confidence intervals and the linear model as the common thread behind t-tests and ANOVA.",
      "goals": [
        "Describe data with the right summary and plot",
        "Fit and interpret a linear model with lm()",
        "Check residuals and model assumptions"
      ],
      "prep": "Revise the Week 2 script; we reuse the same dataset.",
      "materials": []
    },
    {
      "title": "GLMs for counts and presence–absence",
      "date": "",
      "tracks": [
        "stat",
        "r"
      ],
      "summary": "Why ecological data rarely fit a normal distribution, and how Poisson, negative binomial and binomial GLMs handle counts and occupancy.",
      "goals": [
        "Choose a family and link function",
        "Fit and interpret Poisson and binomial GLMs",
        "Detect overdispersion and compare models with AIC"
      ],
      "prep": "Install MASS and DHARMa.",
      "materials": []
    },
    {
      "title": "GIS fundamentals in QGIS",
      "date": "",
      "tracks": [
        "gis"
      ],
      "summary": "Vector and raster data, attribute tables, and coordinate reference systems: why EPSG:4326 and a projected CRS give different distances and areas.",
      "goals": [
        "Load vector layers (GeoPackage, shapefile) and rasters (GeoTIFF)",
        "Reproject layers and set the project CRS",
        "Clip, buffer and join attributes by location"
      ],
      "prep": "Make sure QGIS opens without errors. Download the Week 5 data before class.",
      "materials": []
    },
    {
      "title": "Spatial data in R with sf and terra",
      "date": "",
      "tracks": [
        "r",
        "gis"
      ],
      "summary": "Repeat the Week 5 workflow in code: read, reproject, clip and extract values so the analysis is fully reproducible.",
      "goals": [
        "Read and write vector data with sf",
        "Handle rasters with terra: crop, mask, resample",
        "Extract raster values at survey points"
      ],
      "prep": "Install sf and terra. On macOS or Linux, tell me in advance if installation fails.",
      "materials": []
    },
    {
      "title": "Making maps: QGIS, ArcGIS Pro and tmap",
      "date": "",
      "tracks": [
        "gis"
      ],
      "summary": "Design publication-quality study area and results maps, comparing print layouts in QGIS and ArcGIS Pro with scripted maps in tmap.",
      "goals": [
        "Build a print layout with scale bar, north arrow and inset",
        "Pick colour scales suited to the data",
        "Export maps at journal resolution"
      ],
      "prep": "If you have a university ArcGIS Pro licence, sign in once before class.",
      "materials": []
    },
    {
      "title": "Species occurrence data from GBIF",
      "date": "",
      "tracks": [
        "r",
        "gis"
      ],
      "summary": "Download occurrence records with rgbif, clean coordinate errors, and map sampling bias.",
      "goals": [
        "Query and download GBIF records from R",
        "Flag problem records with CoordinateCleaner",
        "Thin points and visualise sampling effort"
      ],
      "prep": "Create a free GBIF account at gbif.org.",
      "materials": []
    },
    {
      "title": "Spatial autocorrelation and point patterns",
      "date": "",
      "tracks": [
        "stat"
      ],
      "summary": "Test whether nearby observations are more alike than distant ones, and whether individuals are clustered, random or regular.",
      "goals": [
        "Compute Moran's I and correlograms",
        "Fit and read a semivariogram with gstat",
        "Analyse point patterns with Ripley's K in spatstat"
      ],
      "prep": "Install spdep, gstat and spatstat.",
      "materials": []
    },
    {
      "title": "Species distribution models",
      "date": "",
      "tracks": [
        "stat",
        "gis"
      ],
      "summary": "Combine occurrences with WorldClim climate layers to model and map habitat suitability, and evaluate the model honestly.",
      "goals": [
        "Prepare background points and environmental predictors",
        "Fit a GLM-based SDM and compare with MaxEnt",
        "Evaluate with spatial block cross-validation"
      ],
      "prep": "Download WorldClim 2.1 bioclimatic variables at 10 arc-minute resolution.",
      "materials": []
    },
    {
      "title": "Home ranges and animal movement",
      "date": "",
      "tracks": [
        "r",
        "stat"
      ],
      "summary": "Estimate home ranges from GPS telemetry and explore movement metrics such as step length and turning angle.",
      "goals": [
        "Compute MCP and kernel density home ranges",
        "Derive step lengths and turning angles",
        "Relate space use to habitat covariates"
      ],
      "prep": "Install adehabitatHR and amt.",
      "materials": []
    },
    {
      "title": "Landscape metrics and project presentations",
      "date": "",
      "tracks": [
        "gis",
        "r"
      ],
      "summary": "Quantify habitat fragmentation from land-cover rasters, then present your own short spatial ecology project to the group.",
      "goals": [
        "Calculate patch and class metrics with landscapemetrics",
        "Compare fragmentation across sites",
        "Present a 5-minute project from data to map"
      ],
      "prep": "Bring your project figures (3–5 slides).",
      "materials": []
    }
  ]
};
