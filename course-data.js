// =====================================================================
//  CONTENIDO DEL CURSO / COURSE CONTENT
//  Edita este archivo para actualizar la web. / Edit this file to update the website.
// =====================================================================
//  Cada texto tiene versión "es" (castellano) y "en" (inglés).
//  Each text has an "es" (Spanish) and "en" (English) version.
//
//  Fechas / dates: "2026-11-04"  ("" = por confirmar / to be confirmed)
//  Temas / tracks: "r", "stat", "gis"
//  Materiales / materials:
//    { "name": "archivo.pdf", "file": "materials/session03/archivo.pdf", "lang": "es" }
//    "lang": "es" o "en" = solo se muestra en ese idioma; sin "lang" = en los dos.
//    "lang": "es" or "en" = shown only in that language; no "lang" = both.
//    Para un enlace externo usa "url" en lugar de "file". / For an external link use "url" instead of "file".
//
//  Respeta comillas y comas: una coma de menos impide que la página cargue.
//  Keep quotes and commas exactly: a missing comma stops the page loading.
// =====================================================================
window.COURSE = {
  "course": {
    "title": {
      "es": "Ecología Espacial",
      "en": "Spatial Ecology"
    },
    "tagline": {
      "es": "Clases prácticas de R, estadística y SIG para ecólogos, con datos de especies y paisaje en R, QGIS y ArcGIS Pro.",
      "en": "Hands-on classes in R, statistics and GIS for ecologists, working with species and landscape data in R, QGIS and ArcGIS Pro."
    },
    "instructor": "",
    "when": {
      "es": "Día, hora y aula por confirmar",
      "en": "Day, time and room to be confirmed"
    },
    "contact": "",
    "intro": {
      "es": "Cada sesión tiene una guía en PDF, el script de R, las soluciones y los datos. Trae un portátil con el software de la sesión 1 instalado. Todos los datos son simulados con fines docentes (Sierra de Montfred, un parque natural ficticio).",
      "en": "Each session has a PDF handout, the R script, the solutions and the data. Bring a laptop with the Session 1 software installed. All data are simulated for teaching (Sierra de Montfred, a fictitious natural park)."
    },
    "all_data": ""
  },
  "weeks": [
    {
      "title": {
        "es": "Puesta en marcha: R, RStudio y QGIS",
        "en": "Getting set up: R, RStudio and QGIS"
      },
      "date": "",
      "tracks": [
        "r",
        "gis"
      ],
      "summary": {
        "es": "Instalar las herramientas, crear el proyecto de RStudio de cada sesión y un primer vistazo a R y QGIS con los mismos datos.",
        "en": "Install the toolkit, set up the RStudio project used in every session, and take a first look at R and QGIS with the same data."
      },
      "goals": {
        "es": [
          "Instalar R, RStudio y QGIS (LTR)",
          "Crear un proyecto de RStudio con las carpetas 1.Data/, 2.Scripts/ y 3.Outputs/",
          "Primer script: vectores, data frames y leer un CSV",
          "Cargar los puntos en QGIS y guardar un GeoPackage"
        ],
        "en": [
          "Install R, RStudio and QGIS (LTR)",
          "Create an RStudio project with 1.Data/, 2.Scripts/ and 3.Outputs/ folders",
          "First script: vectors, data frames and reading a CSV",
          "Load the points in QGIS and save a GeoPackage"
        ]
      },
      "prep": {
        "es": "Instala R, RStudio Desktop y QGIS LTR antes de clase. Los enlaces están en la sección de referencia, al final de la página.",
        "en": "Install R, RStudio Desktop and QGIS LTR before class. Links are in the reference section at the bottom of this page."
      },
      "materials": [
        {
          "name": "S01_Guia_Puesta_en_marcha.pdf",
          "file": "materials/session01/S01_Guia_Puesta_en_marcha.pdf",
          "lang": "es",
          "kind": "handout",
          "note": {
            "es": "Guía de la clase: explicaciones, pasos y ejercicios",
            "en": "Class handout: explanations, steps and exercises"
          }
        },
        {
          "name": "S01_Handout_Getting_set_up.pdf",
          "file": "materials/session01/S01_Handout_Getting_set_up.pdf",
          "lang": "en",
          "kind": "handout",
          "note": {
            "es": "Guía de la clase: explicaciones, pasos y ejercicios",
            "en": "Class handout: explanations, steps and exercises"
          }
        },
        {
          "name": "sesion01_introduccion_R.R",
          "file": "materials/session01/sesion01_introduccion_R.R",
          "lang": "es",
          "kind": "script",
          "note": {
            "es": "Guárdalo en la carpeta 2.Scripts/",
            "en": "Save it in your 2.Scripts/ folder"
          }
        },
        {
          "name": "session01_intro_to_R.R",
          "file": "materials/session01/session01_intro_to_R.R",
          "lang": "en",
          "kind": "script",
          "note": {
            "es": "Guárdalo en la carpeta 2.Scripts/",
            "en": "Save it in your 2.Scripts/ folder"
          }
        },
        {
          "name": "survey_points.csv",
          "file": "materials/session01/survey_points.csv",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta 1.Data/ del proyecto",
            "en": "Save it in your project's 1.Data/ folder"
          }
        },
        {
          "name": "sesion01_soluciones.R",
          "file": "materials/session01/sesion01_soluciones.R",
          "lang": "es",
          "kind": "solutions",
          "note": {
            "es": "Intenta los ejercicios antes de mirar",
            "en": "Try the exercises before looking"
          }
        },
        {
          "name": "session01_solutions.R",
          "file": "materials/session01/session01_solutions.R",
          "lang": "en",
          "kind": "solutions",
          "note": {
            "es": "Intenta los ejercicios antes de mirar",
            "en": "Try the exercises before looking"
          }
        }
      ]
    },
    {
      "title": {
        "es": "Ordenar y representar datos ecológicos",
        "en": "Wrangling and plotting ecological data"
      },
      "date": "",
      "tracks": [
        "r"
      ],
      "summary": {
        "es": "Limpiar y resumir un censo de aves con dplyr y tidyr, y hacer figuras claras con ggplot2.",
        "en": "Clean and summarise a bird survey with dplyr and tidyr, then build clear figures with ggplot2."
      },
      "goals": {
        "es": [
          "Detectar y corregir errores en datos de campo",
          "Pasar de formato ancho a largo y unir tablas",
          "Calcular riqueza y abundancia por punto y hábitat",
          "Hacer y guardar gráficos con ggplot2"
        ],
        "en": [
          "Find and fix errors in field data",
          "Reshape wide to long and join tables",
          "Calculate richness and abundance per point and habitat",
          "Build and save plots with ggplot2"
        ]
      },
      "prep": {
        "es": "Instala el tidyverse: install.packages(\"tidyverse\"). Al empezar crearemos el proyecto sesion02.",
        "en": "Install the tidyverse: install.packages(\"tidyverse\"). We start by creating the project session02."
      },
      "materials": []
    },
    {
      "title": {
        "es": "Fundamentos de estadística para ecólogos",
        "en": "Statistics foundations for ecologists"
      },
      "date": "",
      "tracks": [
        "stat"
      ],
      "summary": {
        "es": "Describir datos, intervalos de confianza y el modelo lineal como hilo común de la prueba t, el ANOVA y la regresión.",
        "en": "Describing data, confidence intervals, and the linear model as the common thread behind t-tests, ANOVA and regression."
      },
      "goals": {
        "es": [
          "Distinguir desviación típica y error típico",
          "Intervalos de confianza con t y bootstrap",
          "Ajustar e interpretar modelos lineales",
          "Comprobar los supuestos con los residuos"
        ],
        "en": [
          "Tell the standard deviation from the standard error",
          "Confidence intervals with t and bootstrap",
          "Fit and interpret linear models",
          "Check assumptions with residuals"
        ]
      },
      "prep": {
        "es": "Repasa el script de la sesión 2; usamos los mismos datos.",
        "en": "Revise the Session 2 script; we reuse the same data."
      },
      "materials": []
    },
    {
      "title": {
        "es": "GLM para conteos y presencia–ausencia",
        "en": "GLMs for counts and presence–absence"
      },
      "date": "",
      "tracks": [
        "stat",
        "r"
      ],
      "summary": {
        "es": "Por qué los datos ecológicos rara vez son normales, y cómo los GLM de Poisson, binomial negativa y binomial tratan conteos y presencias.",
        "en": "Why ecological data are rarely normal, and how Poisson, negative binomial and binomial GLMs handle counts and presences."
      },
      "goals": {
        "es": [
          "Elegir distribución y función de enlace",
          "Detectar sobredispersión y usar la binomial negativa",
          "Regresión logística de presencia–ausencia",
          "Visitas repetidas con modelos mixtos"
        ],
        "en": [
          "Choose a distribution and link function",
          "Detect overdispersion and use the negative binomial",
          "Logistic regression for presence–absence",
          "Repeated visits with mixed models"
        ]
      },
      "prep": {
        "es": "Instala install.packages(c(\"MASS\", \"DHARMa\", \"lme4\")).",
        "en": "Install install.packages(c(\"MASS\", \"DHARMa\", \"lme4\"))."
      },
      "materials": []
    },
    {
      "title": {
        "es": "Fundamentos de SIG con QGIS",
        "en": "GIS fundamentals in QGIS"
      },
      "date": "",
      "tracks": [
        "gis"
      ],
      "summary": {
        "es": "Datos vectoriales y ráster, sistemas de referencia (EPSG:4326 frente a UTM), buffers, recortes y extracción de valores en un parque natural.",
        "en": "Vector and raster data, reference systems (EPSG:4326 versus UTM), buffers, clipping and extracting values in a natural park."
      },
      "goals": {
        "es": [
          "Cargar GeoPackages y GeoTIFF y fijar el SRC del proyecto",
          "Simbolizar un MDE con sombreado y los usos del suelo",
          "Buffer, recorte y selección por localización",
          "Extraer valores ráster en puntos y calcular superficies"
        ],
        "en": [
          "Load GeoPackages and GeoTIFFs and set the project CRS",
          "Style a DEM with hillshade, and land cover",
          "Buffer, clip and select by location",
          "Extract raster values at points and calculate areas"
        ]
      },
      "prep": {
        "es": "Comprueba que QGIS se abre sin errores y descarga los datos de esta sesión en tu carpeta 1.Data/.",
        "en": "Make sure QGIS opens without errors and download this session's data into your 1.Data/ folder."
      },
      "materials": []
    },
    {
      "title": {
        "es": "Datos espaciales en R con sf y terra",
        "en": "Spatial data in R with sf and terra"
      },
      "date": "",
      "tracks": [
        "r",
        "gis"
      ],
      "summary": {
        "es": "Repetir en código el trabajo de QGIS: leer, reproyectar, recortar y extraer valores para que el análisis sea reproducible.",
        "en": "Repeat the QGIS workflow in code: read, reproject, clip and extract values so the analysis is reproducible."
      },
      "goals": {
        "es": [
          "Leer y escribir datos vectoriales con sf",
          "Rásteres con terra: recortar, enmascarar, reclasificar",
          "Extraer valores ráster en puntos y buffers",
          "Variables de paisaje alrededor de cada punto"
        ],
        "en": [
          "Read and write vector data with sf",
          "Rasters with terra: crop, mask, reclassify",
          "Extract raster values at points and buffers",
          "Landscape variables around each point"
        ]
      },
      "prep": {
        "es": "Instala install.packages(c(\"sf\", \"terra\")). En Mac o Linux, avísame si falla.",
        "en": "Install install.packages(c(\"sf\", \"terra\")). On macOS or Linux, tell me if it fails."
      },
      "materials": []
    },
    {
      "title": {
        "es": "Mapas: QGIS, ArcGIS Pro y tmap",
        "en": "Making maps: QGIS, ArcGIS Pro and tmap"
      },
      "date": "",
      "tracks": [
        "gis"
      ],
      "summary": {
        "es": "Mapas de calidad para publicar: composiciones de impresión en QGIS y ArcGIS Pro y mapas reproducibles con tmap.",
        "en": "Publication-quality maps: print layouts in QGIS and ArcGIS Pro and reproducible maps with tmap."
      },
      "goals": {
        "es": [
          "Composición con escala, norte, leyenda y mapa de situación",
          "Elegir paletas según el tipo de dato",
          "Mapas con tmap 4, incluidos mapas múltiples",
          "Exportar a resolución de revista"
        ],
        "en": [
          "Layout with scale bar, north arrow, legend and overview map",
          "Choose palettes for each data type",
          "Maps with tmap 4, including small multiples",
          "Export at journal resolution"
        ]
      },
      "prep": {
        "es": "Instala install.packages(\"tmap\"). Si tienes licencia de ArcGIS Pro, inicia sesión una vez antes de clase.",
        "en": "Install install.packages(\"tmap\"). If you have an ArcGIS Pro licence, sign in once before class."
      },
      "materials": []
    },
    {
      "title": {
        "es": "Datos de presencia de GBIF",
        "en": "Species occurrence data from GBIF"
      },
      "date": "",
      "tracks": [
        "r",
        "gis"
      ],
      "summary": {
        "es": "Descargar registros con rgbif, limpiar errores de coordenadas con criterios explícitos y detectar el sesgo de muestreo.",
        "en": "Download records with rgbif, clean coordinate errors with explicit criteria, and detect sampling bias."
      },
      "goals": {
        "es": [
          "Buscar y descargar registros de GBIF desde R",
          "Limpiar paso a paso y con CoordinateCleaner",
          "Documentar la limpieza para los métodos",
          "Aclarado espacial y sesgo de muestreo"
        ],
        "en": [
          "Search and download GBIF records from R",
          "Clean step by step and with CoordinateCleaner",
          "Document the cleaning for your methods",
          "Spatial thinning and sampling bias"
        ]
      },
      "prep": {
        "es": "Crea una cuenta gratuita en gbif.org e instala install.packages(c(\"rgbif\", \"CoordinateCleaner\")).",
        "en": "Create a free account at gbif.org and install install.packages(c(\"rgbif\", \"CoordinateCleaner\"))."
      },
      "materials": []
    },
    {
      "title": {
        "es": "Autocorrelación espacial y patrones de puntos",
        "en": "Spatial autocorrelation and point patterns"
      },
      "date": "",
      "tracks": [
        "stat"
      ],
      "summary": {
        "es": "Comprobar si los puntos cercanos se parecen más que los lejanos, y si los nidos están agregados, al azar o regularmente espaciados.",
        "en": "Test whether nearby points are more alike than distant ones, and whether nests are clustered, random or regular."
      },
      "goals": {
        "es": [
          "Índice de Moran y correlogramas",
          "Semivariogramas con gstat",
          "Autocorrelación en los residuos de un modelo",
          "Función L de Ripley con spatstat"
        ],
        "en": [
          "Moran's I and correlograms",
          "Semivariograms with gstat",
          "Autocorrelation in model residuals",
          "Ripley's L function with spatstat"
        ]
      },
      "prep": {
        "es": "Instala install.packages(c(\"spdep\", \"gstat\", \"spatstat\")).",
        "en": "Install install.packages(c(\"spdep\", \"gstat\", \"spatstat\"))."
      },
      "materials": []
    },
    {
      "title": {
        "es": "Modelos de distribución de especies",
        "en": "Species distribution models"
      },
      "date": "",
      "tracks": [
        "stat",
        "gis"
      ],
      "summary": {
        "es": "Relacionar las presencias de GBIF con el ambiente para mapear la idoneidad del hábitat, y evaluar el modelo de forma honesta.",
        "en": "Relate GBIF presences to the environment to map habitat suitability, and evaluate the model honestly."
      },
      "goals": {
        "es": [
          "Preparar predictores y revisar la colinealidad",
          "SDM con GLM y con MaxEnt (maxnet)",
          "Validación cruzada por bloques espaciales",
          "Mapas de idoneidad y presencia/ausencia"
        ],
        "en": [
          "Prepare predictors and check collinearity",
          "SDMs with GLM and MaxEnt (maxnet)",
          "Spatial-block cross-validation",
          "Suitability and presence/absence maps"
        ]
      },
      "prep": {
        "es": "Instala install.packages(\"maxnet\") y ten a mano el CSV limpio de la sesión 8.",
        "en": "Install install.packages(\"maxnet\") and have the cleaned CSV from Session 8 ready."
      },
      "materials": []
    },
    {
      "title": {
        "es": "Áreas de campeo y movimiento animal",
        "en": "Home ranges and animal movement"
      },
      "date": "",
      "tracks": [
        "r",
        "stat"
      ],
      "summary": {
        "es": "Estimar áreas de campeo con datos GPS de ginetas, describir su movimiento y comparar uso y disponibilidad de hábitat.",
        "en": "Estimate home ranges from genet GPS data, describe their movement and compare habitat use with availability."
      },
      "goals": {
        "es": [
          "Revisar datos de telemetría",
          "MCP y estimación por núcleo (KDE)",
          "Longitud de paso, giros y ritmo de actividad",
          "Razones de selección de hábitat"
        ],
        "en": [
          "Check telemetry data",
          "MCP and kernel density estimation (KDE)",
          "Step length, turning angles and activity rhythm",
          "Habitat selection ratios"
        ]
      },
      "prep": {
        "es": "Instala install.packages(\"adehabitatHR\").",
        "en": "Install install.packages(\"adehabitatHR\")."
      },
      "materials": []
    },
    {
      "title": {
        "es": "Métricas de paisaje y proyectos finales",
        "en": "Landscape metrics and final projects"
      },
      "date": "",
      "tracks": [
        "gis",
        "r"
      ],
      "summary": {
        "es": "Medir con landscapemetrics cómo ha cambiado la sierra desde 1990 y presentar vuestro propio análisis espacial.",
        "en": "Measure with landscapemetrics how the mountain changed since 1990, and present your own spatial analysis."
      },
      "goals": {
        "es": [
          "Composición y configuración del paisaje",
          "Matriz de transición entre dos fechas",
          "Las métricas dependen de la escala",
          "Presentar un proyecto de los datos al mapa"
        ],
        "en": [
          "Landscape composition and configuration",
          "Transition matrix between two dates",
          "Metrics depend on scale",
          "Present a project from data to map"
        ]
      },
      "prep": {
        "es": "Instala install.packages(\"landscapemetrics\") y prepara tu proyecto (3–5 diapositivas).",
        "en": "Install install.packages(\"landscapemetrics\") and prepare your project (3–5 slides)."
      },
      "materials": []
    }
  ]
};
