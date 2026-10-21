# Spatial Ecology Sessions

Course website for weekly classes in R, statistics and GIS (QGIS and ArcGIS Pro) for spatial ecology.
It is a plain static site published with GitHub Pages.

## What is in this folder

| Path | What it is |
|---|---|
| `index.html` | The page itself. No need to edit. |
| `course-data.js` | **All the course content**: course details, the weekly sessions and their materials. Edit this. |
| `materials/weekNN/` | Handouts, R scripts and datasets for each week. |
| `style.css`, `app.js` | Design and page code. No need to edit. |

## Adding next week's materials

1. Open the repository on github.com and go into the `materials` folder.
2. Click **Add file → Upload files**. In the box at the top, type the folder name first (for example `week03/`), then drag in the files. Click **Commit changes**.
3. Open `course-data.js`, click the pencil icon (**Edit this file**) and find the week you're updating.
4. Inside its `"materials": [ ]`, add one line per file, separated by commas:

   ```js
   "materials": [
     { "name": "Week03_Handout.pdf", "file": "materials/week03/Week03_Handout.pdf", "note": "Read before class" },
     { "name": "week03_models.R", "file": "materials/week03/week03_models.R" }
   ]
   ```

   For something stored elsewhere (a large raster on Google Drive, say), use `"url"` instead of `"file"`:

   ```js
   { "name": "Land cover raster (Google Drive)", "url": "https://drive.google.com/..." }
   ```

5. Click **Commit changes**. The site updates within a minute or two.

You can change a week's `title`, `date` (format `"2026-11-04"`), `summary`, `goals` and `prep` in the same file.
Topics in `tracks` are `"r"`, `"stat"` and `"gis"`.

**If the page shows "The course content could not be loaded"**, there is a typing error in `course-data.js`,
usually a missing comma or quote. Check the last thing you changed.

## Who can edit

Only you, and anyone you add as a collaborator in **Settings → Collaborators**. Students only need the link.

Files on GitHub should stay under 25 MB each when uploaded through the website (100 MB is the hard limit).
For bigger datasets, share them from Google Drive or OneDrive and add them with `"url"`.

## Note on the data

The datasets in `materials/` are simulated for teaching. They imitate bird point counts on a Mediterranean
mountain but are not real survey data.
