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
//    { "name": "archivo.pdf", "file": "materials/week03/archivo.pdf", "lang": "es" }
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
      "es": "Clases semanales prácticas de R, estadística y SIG para ecólogos, con datos de especies y paisaje en R, QGIS y ArcGIS Pro.",
      "en": "Weekly hands-on classes in R, statistics and GIS for ecologists, working with species and landscape data in R, QGIS and ArcGIS Pro."
    },
    "instructor": "",
    "when": {
      "es": "Semanal · día, hora y aula por confirmar",
      "en": "Weekly · day, time and room to be confirmed"
    },
    "contact": "",
    "intro": {
      "es": "Cada semana tiene una guía en PDF, el script de R, las soluciones y los datos. Trae un portátil con el software de la semana 1 instalado. Todos los datos son simulados con fines docentes (Sierra de Montfred, un parque natural ficticio).",
      "en": "Each week has a PDF handout, the R script, the solutions and the data. Bring a laptop with the Week 1 software installed. All data are simulated for teaching (Sierra de Montfred, a fictitious natural park)."
    },
    "all_data": "materials/course_data_datos_curso.zip"
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
        "es": "Instalar las herramientas, organizar un proyecto reproducible y un primer vistazo a R y QGIS con los mismos datos.",
        "en": "Install the toolkit, organise a reproducible project folder, and take a first look at R and QGIS with the same data."
      },
      "goals": {
        "es": [
          "Instalar R, RStudio y QGIS (LTR)",
          "Crear un proyecto de RStudio con las carpetas data/, scripts/ y outputs/",
          "Primer script: vectores, data frames y leer un CSV",
          "Cargar los puntos en QGIS y guardar un GeoPackage"
        ],
        "en": [
          "Install R, RStudio and QGIS (LTR)",
          "Create an RStudio project with data/, scripts/ and outputs/ folders",
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
          "file": "materials/week01/S01_Guia_Puesta_en_marcha.pdf",
          "lang": "es",
          "kind": "handout",
          "note": {
            "es": "Guía de la clase: explicaciones, pasos y ejercicios",
            "en": "Class handout: explanations, steps and exercises"
          }
        },
        {
          "name": "W01_Handout_Getting_set_up.pdf",
          "file": "materials/week01/W01_Handout_Getting_set_up.pdf",
          "lang": "en",
          "kind": "handout",
          "note": {
            "es": "Guía de la clase: explicaciones, pasos y ejercicios",
            "en": "Class handout: explanations, steps and exercises"
          }
        },
        {
          "name": "semana01_introduccion_R.R",
          "file": "materials/week01/semana01_introduccion_R.R",
          "lang": "es",
          "kind": "script",
          "note": {
            "es": "Guárdalo en la carpeta scripts/",
            "en": "Save it in your scripts/ folder"
          }
        },
        {
          "name": "week01_intro_to_R.R",
          "file": "materials/week01/week01_intro_to_R.R",
          "lang": "en",
          "kind": "script",
          "note": {
            "es": "Guárdalo en la carpeta scripts/",
            "en": "Save it in your scripts/ folder"
          }
        },
        {
          "name": "survey_points.csv",
          "file": "materials/week01/survey_points.csv",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "semana01_soluciones.R",
          "file": "materials/week01/semana01_soluciones.R",
          "lang": "es",
          "kind": "solutions",
          "note": {
            "es": "Intenta los ejercicios antes de mirar",
            "en": "Try the exercises before looking"
          }
        },
        {
          "name": "week01_solutions.R",
          "file": "materials/week01/week01_solutions.R",
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
        "es": "Instala el tidyverse: install.packages(\"tidyverse\"). Trae la carpeta del proyecto de la semana 1.",
        "en": "Install the tidyverse: install.packages(\"tidyverse\"). Bring your Week 1 project folder."
      },
      "materials": [
        {
          "name": "S02_Guia_Ordenar_y_graficar.pdf",
          "file": "materials/week02/S02_Guia_Ordenar_y_graficar.pdf",
          "lang": "es",
          "kind": "handout",
          "note": {
            "es": "Guía de la clase: explicaciones, pasos y ejercicios",
            "en": "Class handout: explanations, steps and exercises"
          }
        },
        {
          "name": "W02_Handout_Wrangling_and_plotting.pdf",
          "file": "materials/week02/W02_Handout_Wrangling_and_plotting.pdf",
          "lang": "en",
          "kind": "handout",
          "note": {
            "es": "Guía de la clase: explicaciones, pasos y ejercicios",
            "en": "Class handout: explanations, steps and exercises"
          }
        },
        {
          "name": "semana02_ordenar_y_graficar.R",
          "file": "materials/week02/semana02_ordenar_y_graficar.R",
          "lang": "es",
          "kind": "script",
          "note": {
            "es": "Guárdalo en la carpeta scripts/",
            "en": "Save it in your scripts/ folder"
          }
        },
        {
          "name": "week02_wrangling_and_plotting.R",
          "file": "materials/week02/week02_wrangling_and_plotting.R",
          "lang": "en",
          "kind": "script",
          "note": {
            "es": "Guárdalo en la carpeta scripts/",
            "en": "Save it in your scripts/ folder"
          }
        },
        {
          "name": "survey_points.csv",
          "file": "materials/week02/survey_points.csv",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "bird_counts_wide.csv",
          "file": "materials/week02/bird_counts_wide.csv",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "species_traits.csv",
          "file": "materials/week02/species_traits.csv",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "landcover_classes.csv",
          "file": "materials/week02/landcover_classes.csv",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "semana02_soluciones.R",
          "file": "materials/week02/semana02_soluciones.R",
          "lang": "es",
          "kind": "solutions",
          "note": {
            "es": "Intenta los ejercicios antes de mirar",
            "en": "Try the exercises before looking"
          }
        },
        {
          "name": "week02_solutions.R",
          "file": "materials/week02/week02_solutions.R",
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
        "es": "Repasa el script de la semana 2; usamos los mismos datos.",
        "en": "Revise the Week 2 script; we reuse the same data."
      },
      "materials": [
        {
          "name": "S03_Guia_Estadistica_basica.pdf",
          "file": "materials/week03/S03_Guia_Estadistica_basica.pdf",
          "lang": "es",
          "kind": "handout",
          "note": {
            "es": "Guía de la clase: explicaciones, pasos y ejercicios",
            "en": "Class handout: explanations, steps and exercises"
          }
        },
        {
          "name": "W03_Handout_Statistics_foundations.pdf",
          "file": "materials/week03/W03_Handout_Statistics_foundations.pdf",
          "lang": "en",
          "kind": "handout",
          "note": {
            "es": "Guía de la clase: explicaciones, pasos y ejercicios",
            "en": "Class handout: explanations, steps and exercises"
          }
        },
        {
          "name": "semana03_estadistica_basica.R",
          "file": "materials/week03/semana03_estadistica_basica.R",
          "lang": "es",
          "kind": "script",
          "note": {
            "es": "Guárdalo en la carpeta scripts/",
            "en": "Save it in your scripts/ folder"
          }
        },
        {
          "name": "week03_statistics_foundations.R",
          "file": "materials/week03/week03_statistics_foundations.R",
          "lang": "en",
          "kind": "script",
          "note": {
            "es": "Guárdalo en la carpeta scripts/",
            "en": "Save it in your scripts/ folder"
          }
        },
        {
          "name": "survey_points.csv",
          "file": "materials/week03/survey_points.csv",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "bird_counts_wide.csv",
          "file": "materials/week03/bird_counts_wide.csv",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "semana03_soluciones.R",
          "file": "materials/week03/semana03_soluciones.R",
          "lang": "es",
          "kind": "solutions",
          "note": {
            "es": "Intenta los ejercicios antes de mirar",
            "en": "Try the exercises before looking"
          }
        },
        {
          "name": "week03_solutions.R",
          "file": "materials/week03/week03_solutions.R",
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
      "materials": [
        {
          "name": "S04_Guia_GLM.pdf",
          "file": "materials/week04/S04_Guia_GLM.pdf",
          "lang": "es",
          "kind": "handout",
          "note": {
            "es": "Guía de la clase: explicaciones, pasos y ejercicios",
            "en": "Class handout: explanations, steps and exercises"
          }
        },
        {
          "name": "W04_Handout_GLMs.pdf",
          "file": "materials/week04/W04_Handout_GLMs.pdf",
          "lang": "en",
          "kind": "handout",
          "note": {
            "es": "Guía de la clase: explicaciones, pasos y ejercicios",
            "en": "Class handout: explanations, steps and exercises"
          }
        },
        {
          "name": "semana04_GLM.R",
          "file": "materials/week04/semana04_GLM.R",
          "lang": "es",
          "kind": "script",
          "note": {
            "es": "Guárdalo en la carpeta scripts/",
            "en": "Save it in your scripts/ folder"
          }
        },
        {
          "name": "week04_GLMs.R",
          "file": "materials/week04/week04_GLMs.R",
          "lang": "en",
          "kind": "script",
          "note": {
            "es": "Guárdalo en la carpeta scripts/",
            "en": "Save it in your scripts/ folder"
          }
        },
        {
          "name": "survey_points.csv",
          "file": "materials/week04/survey_points.csv",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "bird_counts_wide.csv",
          "file": "materials/week04/bird_counts_wide.csv",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "semana04_soluciones.R",
          "file": "materials/week04/semana04_soluciones.R",
          "lang": "es",
          "kind": "solutions",
          "note": {
            "es": "Intenta los ejercicios antes de mirar",
            "en": "Try the exercises before looking"
          }
        },
        {
          "name": "week04_solutions.R",
          "file": "materials/week04/week04_solutions.R",
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
        "es": "Comprueba que QGIS se abre sin errores y descarga los datos de esta semana en tu carpeta data/.",
        "en": "Make sure QGIS opens without errors and download this week's data into your data/ folder."
      },
      "materials": [
        {
          "name": "S05_Guia_SIG_con_QGIS.pdf",
          "file": "materials/week05/S05_Guia_SIG_con_QGIS.pdf",
          "lang": "es",
          "kind": "handout",
          "note": {
            "es": "Guía de la clase: explicaciones, pasos y ejercicios",
            "en": "Class handout: explanations, steps and exercises"
          }
        },
        {
          "name": "W05_Handout_GIS_in_QGIS.pdf",
          "file": "materials/week05/W05_Handout_GIS_in_QGIS.pdf",
          "lang": "en",
          "kind": "handout",
          "note": {
            "es": "Guía de la clase: explicaciones, pasos y ejercicios",
            "en": "Class handout: explanations, steps and exercises"
          }
        },
        {
          "name": "survey_points.csv",
          "file": "materials/week05/survey_points.csv",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "montfred.gpkg",
          "file": "materials/week05/montfred.gpkg",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "dem.tif",
          "file": "materials/week05/dem.tif",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "landcover.tif",
          "file": "materials/week05/landcover.tif",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "landcover_classes.csv",
          "file": "materials/week05/landcover_classes.csv",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        }
      ]
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
      "materials": [
        {
          "name": "S06_Guia_sf_y_terra.pdf",
          "file": "materials/week06/S06_Guia_sf_y_terra.pdf",
          "lang": "es",
          "kind": "handout",
          "note": {
            "es": "Guía de la clase: explicaciones, pasos y ejercicios",
            "en": "Class handout: explanations, steps and exercises"
          }
        },
        {
          "name": "W06_Handout_sf_and_terra.pdf",
          "file": "materials/week06/W06_Handout_sf_and_terra.pdf",
          "lang": "en",
          "kind": "handout",
          "note": {
            "es": "Guía de la clase: explicaciones, pasos y ejercicios",
            "en": "Class handout: explanations, steps and exercises"
          }
        },
        {
          "name": "semana06_sf_y_terra.R",
          "file": "materials/week06/semana06_sf_y_terra.R",
          "lang": "es",
          "kind": "script",
          "note": {
            "es": "Guárdalo en la carpeta scripts/",
            "en": "Save it in your scripts/ folder"
          }
        },
        {
          "name": "week06_sf_and_terra.R",
          "file": "materials/week06/week06_sf_and_terra.R",
          "lang": "en",
          "kind": "script",
          "note": {
            "es": "Guárdalo en la carpeta scripts/",
            "en": "Save it in your scripts/ folder"
          }
        },
        {
          "name": "survey_points.csv",
          "file": "materials/week06/survey_points.csv",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "montfred.gpkg",
          "file": "materials/week06/montfred.gpkg",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "dem.tif",
          "file": "materials/week06/dem.tif",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "landcover.tif",
          "file": "materials/week06/landcover.tif",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "landcover_classes.csv",
          "file": "materials/week06/landcover_classes.csv",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "semana06_soluciones.R",
          "file": "materials/week06/semana06_soluciones.R",
          "lang": "es",
          "kind": "solutions",
          "note": {
            "es": "Intenta los ejercicios antes de mirar",
            "en": "Try the exercises before looking"
          }
        },
        {
          "name": "week06_solutions.R",
          "file": "materials/week06/week06_solutions.R",
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
      "materials": [
        {
          "name": "S07_Guia_Mapas.pdf",
          "file": "materials/week07/S07_Guia_Mapas.pdf",
          "lang": "es",
          "kind": "handout",
          "note": {
            "es": "Guía de la clase: explicaciones, pasos y ejercicios",
            "en": "Class handout: explanations, steps and exercises"
          }
        },
        {
          "name": "W07_Handout_Making_maps.pdf",
          "file": "materials/week07/W07_Handout_Making_maps.pdf",
          "lang": "en",
          "kind": "handout",
          "note": {
            "es": "Guía de la clase: explicaciones, pasos y ejercicios",
            "en": "Class handout: explanations, steps and exercises"
          }
        },
        {
          "name": "semana07_mapas_tmap.R",
          "file": "materials/week07/semana07_mapas_tmap.R",
          "lang": "es",
          "kind": "script",
          "note": {
            "es": "Guárdalo en la carpeta scripts/",
            "en": "Save it in your scripts/ folder"
          }
        },
        {
          "name": "week07_maps_tmap.R",
          "file": "materials/week07/week07_maps_tmap.R",
          "lang": "en",
          "kind": "script",
          "note": {
            "es": "Guárdalo en la carpeta scripts/",
            "en": "Save it in your scripts/ folder"
          }
        },
        {
          "name": "survey_points.csv",
          "file": "materials/week07/survey_points.csv",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "bird_counts_wide.csv",
          "file": "materials/week07/bird_counts_wide.csv",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "species_traits.csv",
          "file": "materials/week07/species_traits.csv",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "montfred.gpkg",
          "file": "materials/week07/montfred.gpkg",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "dem.tif",
          "file": "materials/week07/dem.tif",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "landcover.tif",
          "file": "materials/week07/landcover.tif",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "landcover_classes.csv",
          "file": "materials/week07/landcover_classes.csv",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "semana07_soluciones.R",
          "file": "materials/week07/semana07_soluciones.R",
          "lang": "es",
          "kind": "solutions",
          "note": {
            "es": "Intenta los ejercicios antes de mirar",
            "en": "Try the exercises before looking"
          }
        },
        {
          "name": "week07_solutions.R",
          "file": "materials/week07/week07_solutions.R",
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
      "materials": [
        {
          "name": "S08_Guia_Datos_GBIF.pdf",
          "file": "materials/week08/S08_Guia_Datos_GBIF.pdf",
          "lang": "es",
          "kind": "handout",
          "note": {
            "es": "Guía de la clase: explicaciones, pasos y ejercicios",
            "en": "Class handout: explanations, steps and exercises"
          }
        },
        {
          "name": "W08_Handout_GBIF_data.pdf",
          "file": "materials/week08/W08_Handout_GBIF_data.pdf",
          "lang": "en",
          "kind": "handout",
          "note": {
            "es": "Guía de la clase: explicaciones, pasos y ejercicios",
            "en": "Class handout: explanations, steps and exercises"
          }
        },
        {
          "name": "semana08_datos_GBIF.R",
          "file": "materials/week08/semana08_datos_GBIF.R",
          "lang": "es",
          "kind": "script",
          "note": {
            "es": "Guárdalo en la carpeta scripts/",
            "en": "Save it in your scripts/ folder"
          }
        },
        {
          "name": "week08_GBIF_data.R",
          "file": "materials/week08/week08_GBIF_data.R",
          "lang": "en",
          "kind": "script",
          "note": {
            "es": "Guárdalo en la carpeta scripts/",
            "en": "Save it in your scripts/ folder"
          }
        },
        {
          "name": "gbif_lullula_arborea_raw.csv",
          "file": "materials/week08/gbif_lullula_arborea_raw.csv",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "montfred.gpkg",
          "file": "materials/week08/montfred.gpkg",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "semana08_soluciones.R",
          "file": "materials/week08/semana08_soluciones.R",
          "lang": "es",
          "kind": "solutions",
          "note": {
            "es": "Intenta los ejercicios antes de mirar",
            "en": "Try the exercises before looking"
          }
        },
        {
          "name": "week08_solutions.R",
          "file": "materials/week08/week08_solutions.R",
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
      "materials": [
        {
          "name": "S09_Guia_Autocorrelacion_espacial.pdf",
          "file": "materials/week09/S09_Guia_Autocorrelacion_espacial.pdf",
          "lang": "es",
          "kind": "handout",
          "note": {
            "es": "Guía de la clase: explicaciones, pasos y ejercicios",
            "en": "Class handout: explanations, steps and exercises"
          }
        },
        {
          "name": "W09_Handout_Spatial_autocorrelation.pdf",
          "file": "materials/week09/W09_Handout_Spatial_autocorrelation.pdf",
          "lang": "en",
          "kind": "handout",
          "note": {
            "es": "Guía de la clase: explicaciones, pasos y ejercicios",
            "en": "Class handout: explanations, steps and exercises"
          }
        },
        {
          "name": "semana09_autocorrelacion_espacial.R",
          "file": "materials/week09/semana09_autocorrelacion_espacial.R",
          "lang": "es",
          "kind": "script",
          "note": {
            "es": "Guárdalo en la carpeta scripts/",
            "en": "Save it in your scripts/ folder"
          }
        },
        {
          "name": "week09_spatial_autocorrelation.R",
          "file": "materials/week09/week09_spatial_autocorrelation.R",
          "lang": "en",
          "kind": "script",
          "note": {
            "es": "Guárdalo en la carpeta scripts/",
            "en": "Save it in your scripts/ folder"
          }
        },
        {
          "name": "survey_points.csv",
          "file": "materials/week09/survey_points.csv",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "bird_counts_wide.csv",
          "file": "materials/week09/bird_counts_wide.csv",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "montfred.gpkg",
          "file": "materials/week09/montfred.gpkg",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "semana09_soluciones.R",
          "file": "materials/week09/semana09_soluciones.R",
          "lang": "es",
          "kind": "solutions",
          "note": {
            "es": "Intenta los ejercicios antes de mirar",
            "en": "Try the exercises before looking"
          }
        },
        {
          "name": "week09_solutions.R",
          "file": "materials/week09/week09_solutions.R",
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
        "es": "Instala install.packages(\"maxnet\") y ten a mano el CSV limpio de la semana 8.",
        "en": "Install install.packages(\"maxnet\") and have the cleaned CSV from Week 8 ready."
      },
      "materials": [
        {
          "name": "S10_Guia_Modelos_de_distribucion.pdf",
          "file": "materials/week10/S10_Guia_Modelos_de_distribucion.pdf",
          "lang": "es",
          "kind": "handout",
          "note": {
            "es": "Guía de la clase: explicaciones, pasos y ejercicios",
            "en": "Class handout: explanations, steps and exercises"
          }
        },
        {
          "name": "W10_Handout_Species_distribution_models.pdf",
          "file": "materials/week10/W10_Handout_Species_distribution_models.pdf",
          "lang": "en",
          "kind": "handout",
          "note": {
            "es": "Guía de la clase: explicaciones, pasos y ejercicios",
            "en": "Class handout: explanations, steps and exercises"
          }
        },
        {
          "name": "semana10_modelos_distribucion.R",
          "file": "materials/week10/semana10_modelos_distribucion.R",
          "lang": "es",
          "kind": "script",
          "note": {
            "es": "Guárdalo en la carpeta scripts/",
            "en": "Save it in your scripts/ folder"
          }
        },
        {
          "name": "week10_species_distribution_models.R",
          "file": "materials/week10/week10_species_distribution_models.R",
          "lang": "en",
          "kind": "script",
          "note": {
            "es": "Guárdalo en la carpeta scripts/",
            "en": "Save it in your scripts/ folder"
          }
        },
        {
          "name": "gbif_lullula_arborea_clean.csv",
          "file": "materials/week10/gbif_lullula_arborea_clean.csv",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "dem.tif",
          "file": "materials/week10/dem.tif",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "landcover.tif",
          "file": "materials/week10/landcover.tif",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "tavg.tif",
          "file": "materials/week10/tavg.tif",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "prec.tif",
          "file": "materials/week10/prec.tif",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "montfred.gpkg",
          "file": "materials/week10/montfred.gpkg",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "semana10_soluciones.R",
          "file": "materials/week10/semana10_soluciones.R",
          "lang": "es",
          "kind": "solutions",
          "note": {
            "es": "Intenta los ejercicios antes de mirar",
            "en": "Try the exercises before looking"
          }
        },
        {
          "name": "week10_solutions.R",
          "file": "materials/week10/week10_solutions.R",
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
      "materials": [
        {
          "name": "S11_Guia_Areas_de_campeo.pdf",
          "file": "materials/week11/S11_Guia_Areas_de_campeo.pdf",
          "lang": "es",
          "kind": "handout",
          "note": {
            "es": "Guía de la clase: explicaciones, pasos y ejercicios",
            "en": "Class handout: explanations, steps and exercises"
          }
        },
        {
          "name": "W11_Handout_Home_ranges.pdf",
          "file": "materials/week11/W11_Handout_Home_ranges.pdf",
          "lang": "en",
          "kind": "handout",
          "note": {
            "es": "Guía de la clase: explicaciones, pasos y ejercicios",
            "en": "Class handout: explanations, steps and exercises"
          }
        },
        {
          "name": "semana11_areas_de_campeo.R",
          "file": "materials/week11/semana11_areas_de_campeo.R",
          "lang": "es",
          "kind": "script",
          "note": {
            "es": "Guárdalo en la carpeta scripts/",
            "en": "Save it in your scripts/ folder"
          }
        },
        {
          "name": "week11_home_ranges.R",
          "file": "materials/week11/week11_home_ranges.R",
          "lang": "en",
          "kind": "script",
          "note": {
            "es": "Guárdalo en la carpeta scripts/",
            "en": "Save it in your scripts/ folder"
          }
        },
        {
          "name": "genet_gps.csv",
          "file": "materials/week11/genet_gps.csv",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "genet_animals.csv",
          "file": "materials/week11/genet_animals.csv",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "landcover.tif",
          "file": "materials/week11/landcover.tif",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "landcover_classes.csv",
          "file": "materials/week11/landcover_classes.csv",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "montfred.gpkg",
          "file": "materials/week11/montfred.gpkg",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "semana11_soluciones.R",
          "file": "materials/week11/semana11_soluciones.R",
          "lang": "es",
          "kind": "solutions",
          "note": {
            "es": "Intenta los ejercicios antes de mirar",
            "en": "Try the exercises before looking"
          }
        },
        {
          "name": "week11_solutions.R",
          "file": "materials/week11/week11_solutions.R",
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
      "materials": [
        {
          "name": "S12_Guia_Metricas_de_paisaje.pdf",
          "file": "materials/week12/S12_Guia_Metricas_de_paisaje.pdf",
          "lang": "es",
          "kind": "handout",
          "note": {
            "es": "Guía de la clase: explicaciones, pasos y ejercicios",
            "en": "Class handout: explanations, steps and exercises"
          }
        },
        {
          "name": "W12_Handout_Landscape_metrics.pdf",
          "file": "materials/week12/W12_Handout_Landscape_metrics.pdf",
          "lang": "en",
          "kind": "handout",
          "note": {
            "es": "Guía de la clase: explicaciones, pasos y ejercicios",
            "en": "Class handout: explanations, steps and exercises"
          }
        },
        {
          "name": "semana12_metricas_paisaje.R",
          "file": "materials/week12/semana12_metricas_paisaje.R",
          "lang": "es",
          "kind": "script",
          "note": {
            "es": "Guárdalo en la carpeta scripts/",
            "en": "Save it in your scripts/ folder"
          }
        },
        {
          "name": "week12_landscape_metrics.R",
          "file": "materials/week12/week12_landscape_metrics.R",
          "lang": "en",
          "kind": "script",
          "note": {
            "es": "Guárdalo en la carpeta scripts/",
            "en": "Save it in your scripts/ folder"
          }
        },
        {
          "name": "landcover.tif",
          "file": "materials/week12/landcover.tif",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "landcover1990.tif",
          "file": "materials/week12/landcover1990.tif",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "landcover_classes.csv",
          "file": "materials/week12/landcover_classes.csv",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "montfred.gpkg",
          "file": "materials/week12/montfred.gpkg",
          "kind": "data",
          "note": {
            "es": "Guárdalo en la carpeta data/ del proyecto",
            "en": "Save it in your project's data/ folder"
          }
        },
        {
          "name": "semana12_soluciones.R",
          "file": "materials/week12/semana12_soluciones.R",
          "lang": "es",
          "kind": "solutions",
          "note": {
            "es": "Intenta los ejercicios antes de mirar",
            "en": "Try the exercises before looking"
          }
        },
        {
          "name": "week12_solutions.R",
          "file": "materials/week12/week12_solutions.R",
          "lang": "en",
          "kind": "solutions",
          "note": {
            "es": "Intenta los ejercicios antes de mirar",
            "en": "Try the exercises before looking"
          }
        }
      ]
    }
  ]
};
