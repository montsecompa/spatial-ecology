# Ecología Espacial · Spatial Ecology

Web del curso de R, estadística y SIG (QGIS y ArcGIS Pro) para ecología espacial, en castellano e inglés.
Course website for R, statistics and GIS (QGIS and ArcGIS Pro) for spatial ecology, in Spanish and English.

## Contenido / Contents

| Ruta / Path | Qué es / What it is |
|---|---|
| `index.html`, `app.js`, `style.css` | La página. No hace falta editarlos. / The page. No need to edit. |
| `course-data.js` | **Todo el contenido**: datos del curso, semanas y materiales. / **All the content**: course details, weeks and materials. |
| `materials/weekNN/` | Guías (PDF), scripts de R, soluciones y datos de cada semana. / Handouts (PDF), R scripts, solutions and data for each week. |

Archivos con prefijo `S`/`semana` = castellano; `W`/`week` = inglés. Los datos son comunes.
Files starting with `S`/`semana` are Spanish; `W`/`week` are English. Data files are shared.

## Añadir o cambiar materiales / Adding or changing materials

1. En github.com, entra en `materials/weekNN/` y usa **Add file → Upload files**. / On github.com, open `materials/weekNN/` and use **Add file → Upload files**.
2. Edita `course-data.js` (icono del lápiz) y añade una línea en `"materials"` de esa semana: / Edit `course-data.js` (pencil icon) and add a line to that week's `"materials"`:

   ```js
   { "name": "S03_Diapositivas.pdf", "file": "materials/week03/S03_Diapositivas.pdf", "lang": "es" },
   { "name": "W03_Slides.pdf", "file": "materials/week03/W03_Slides.pdf", "lang": "en" }
   ```

   Sin `"lang"`, el archivo aparece en los dos idiomas. Para un enlace externo usa `"url"` en lugar de `"file"`.
   Without `"lang"` the file shows in both languages. For an external link use `"url"` instead of `"file"`.

3. **Commit changes**. La web se actualiza en uno o dos minutos. / The site updates in a minute or two.

Fechas: `"date": "2026-11-04"`. Si aparece "No se ha podido cargar el contenido", falta una coma o unas comillas en `course-data.js`.
Dates: `"date": "2026-11-04"`. If the page says the content could not be loaded, a comma or quote is missing in `course-data.js`.

## Datos / Data

Todos los datos son **simulados con fines docentes** (Sierra de Montfred, un parque natural ficticio), en ETRS89 / UTM 31N (EPSG:25831).
All data are **simulated for teaching** (Sierra de Montfred, a fictitious natural park), in ETRS89 / UTM 31N (EPSG:25831).
Los scripts se han ejecutado de principio a fin con R 4.4. / The scripts have been run end to end with R 4.4.
