// Página del curso / course page. Renders everything from course-data.js. No need to edit this file.
(function () {
  "use strict";
  var state = window.COURSE;
  var app = document.getElementById("app");
  if (!state) {
    app.innerHTML = '<div class="wrap" style="padding-block:40px"><h2>No se ha podido cargar el contenido / The course content could not be loaded</h2>' +
      '<p>Probablemente hay un error de escritura en <code>course-data.js</code> (una coma o unas comillas). / There is probably a typing error in <code>course-data.js</code> (a comma or a quote).</p></div>';
    return;
  }

  var UI = {
    es: { sessions: "sesiones", course: "Curso", instructor: "Docente", meets: "Horario", contact: "Contacto",
      legend: "Leyenda · filtrar por tema", all: "Todas las sesiones", next: "Próxima clase", goWeek: "Ir a esta sesión",
      jump: "Ir a", refLink: "Software, libros y datos", allData: "Todos los datos del curso (zip)",
      weekly: "Sesiones", showingAll: "Todas", showing: "Mostrando", learn: "Aprenderás a", before: "Antes de clase",
      materials: "Materiales de la clase", soon: "Los materiales se publicarán aquí antes de la clase.", none: "Todavía no hay sesiones de este tema.",
      download: "Descargar", tbc: "Fecha por confirmar", ref: "Referencia", refTitle: "Software, libros y datos",
      pkgs: "Paquetes de R que usamos", pkgsNote: "Instálalos sesión a sesión o todos de una vez:",
      kinds: { handout: "Guía", script: "Script R", data: "Datos", solutions: "Soluciones", link: "Enlace" },
      tracks: { r: "Programación en R", stat: "Estadística", gis: "SIG y cartografía" }, mark: "S" },
    en: { sessions: "sessions", course: "Course", instructor: "Instructor", meets: "Meets", contact: "Contact",
      legend: "Legend · filter by topic", all: "All sessions", next: "Next class", goWeek: "Go to this session",
      jump: "Jump to", refLink: "Software, books and data", allData: "All course data (zip)",
      weekly: "Sessions", showingAll: "Showing all", showing: "Showing", learn: "You will learn to", before: "Before class",
      materials: "Class materials", soon: "Materials will be posted here before class.", none: "No sessions for this topic yet.",
      download: "Download", tbc: "Date TBC", ref: "Reference", refTitle: "Software, books and data",
      pkgs: "R packages we use", pkgsNote: "Install them as you reach each session, or all at once:",
      kinds: { handout: "Handout", script: "R script", data: "Data", solutions: "Solutions", link: "Link" },
      tracks: { r: "R programming", stat: "Statistics", gis: "GIS & mapping" }, mark: "S" }
  };

  var lang = "es";
  try { var saved = localStorage.getItem("course-lang"); if (saved === "es" || saved === "en") lang = saved; } catch (e) {}
  if (location.hash === "#en") lang = "en"; else if (location.hash === "#es") lang = "es";
  var filter = "all";

  function L(v) { return v && typeof v === "object" && !Array.isArray(v) ? (v[lang] != null ? v[lang] : (v.es || v.en || "")) : (v == null ? "" : v); }
  function esc(s) { return String(s == null ? "" : s).replace(/[&<>"']/g, function (c) { return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]; }); }
  function extOf(n) { var m = /\.([a-z0-9]+)$/i.exec(n || ""); return m ? m[1].toLowerCase() : ""; }
  function fmtDate(d) {
    if (!d) return UI[lang].tbc; var t = new Date(d + "T12:00:00"); if (isNaN(t)) return d;
    return t.toLocaleDateString(lang === "es" ? "es-ES" : "en-GB", { weekday: "short", day: "numeric", month: "short" });
  }
  function today() { var t = new Date(); return t.getFullYear() + "-" + String(t.getMonth() + 1).padStart(2, "0") + "-" + String(t.getDate()).padStart(2, "0"); }
  function wkNo(i) { return UI[lang].mark + String(i + 1).padStart(2, "0"); }
  function wkId(i) { return "session" + String(i + 1).padStart(2, "0"); }
  function nextIndex() {
    var t = today(), ws = state.weeks;
    for (var i = 0; i < ws.length; i++) { if (ws[i].date && ws[i].date >= t) return i; }
    return ws.some(function (w) { return w.date; }) ? -1 : (ws.length ? 0 : -1);
  }

  function matRow(m) {
    var isLink = !!m.url, href = isLink ? m.url : m.file;
    var kind = UI[lang].kinds[m.kind || (isLink ? "link" : "")] || "";
    var ext = isLink ? "link" : (extOf(m.name) || "file");
    var open = '<a href="' + esc(href) + '" target="_blank" rel="noopener">' + esc(m.name) + "</a>";
    var dl = isLink ? "" : '<a class="btn small" href="' + esc(href) + '" download="' + esc(m.name) + '">' + UI[lang].download + "</a>";
    var note = L(m.note);
    return '<li class="mat"><span class="kind">' + esc(kind) + '</span><span class="ext">' + esc(ext) + '</span><span class="nm">' + open +
      (note ? '<br><span class="hint">' + esc(note) + "</span>" : "") + "</span>" + dl + "</li>";
  }

  function weekHTML(w, i, nextI) {
    var u = UI[lang], tracks = w.tracks || [], goals = L(w.goals) || [], prep = L(w.prep);
    var mats = (w.materials || []).filter(function (m) { return !m.lang || m.lang === lang; });
    var chips = '<div class="chips">' + (i === nextI ? '<span class="chip now">' + u.next + "</span>" : "") +
      tracks.map(function (t) { return '<span class="chip ' + t + '">' + esc(u.tracks[t] || t) + "</span>"; }).join("") + "</div>";
    var body = "<h3>" + esc(L(w.title)) + "</h3>" + chips + (L(w.summary) ? '<p class="summary">' + esc(L(w.summary)) + "</p>" : "") +
      '<div class="cols">' + (goals.length ? '<div><div class="label">' + u.learn + "</div><ul>" + goals.map(function (g) { return "<li>" + esc(g) + "</li>"; }).join("") + "</ul></div>" : "") +
      (prep ? '<div><div class="label">' + u.before + "</div><p>" + esc(prep) + "</p></div>" : "") + "</div>";
    var m = '<div class="materials"><div class="label">' + u.materials + "</div>" +
      (mats.length ? '<ul class="mat-list">' + mats.map(matRow).join("") + "</ul>" : '<p class="empty">' + u.soon + "</p>") + "</div>";
    return '<article class="week" id="' + wkId(i) + '"><div class="wk-no"><span class="n">' + wkNo(i) + '</span><span class="d">' + esc(fmtDate(w.date)) +
      '</span></div><div class="wk-body">' + body + m + "</div></article>";
  }

  var REF = {
    es: [
      ["Software", [["R", "https://cran.r-project.org/", "El lenguaje del análisis"], ["RStudio Desktop", "https://posit.co/download/rstudio-desktop/", "Editor gratuito para R"], ["QGIS (versión LTR)", "https://qgis.org/download/", "SIG de escritorio libre"], ["ArcGIS Pro", "https://pro.arcgis.com/", "Requiere licencia de la universidad"]]],
      ["Libros gratuitos", [["Geocomputation with R", "https://r.geocompx.org/", "sf, terra y mapas"], ["Spatial Data Science", "https://r-spatial.org/book/", "Pebesma y Bivand"], ["R para Ciencia de Datos", "https://es.r4ds.hadley.nz/", "Traducción al castellano de R4DS"], ["Manual de formación de QGIS", "https://docs.qgis.org/latest/es/docs/training_manual/", "Ejercicios de SIG paso a paso"]]],
      ["Datos abiertos", [["GBIF", "https://www.gbif.org/", "Registros de presencia de especies"], ["WorldClim", "https://www.worldclim.org/", "Clima y variables bioclimáticas"], ["Copernicus Land", "https://land.copernicus.eu/", "Usos y coberturas del suelo"], ["Centro de Descargas del CNIG", "https://centrodedescargas.cnig.es/", "MDT, ortofotos y cartografía de España"], ["Movebank", "https://www.movebank.org/", "Datos de seguimiento animal"]]]
    ],
    en: [
      ["Software", [["R", "https://cran.r-project.org/", "The language we use for analysis"], ["RStudio Desktop", "https://posit.co/download/rstudio-desktop/", "Free editor for R"], ["QGIS (Long Term Release)", "https://qgis.org/download/", "Free, open-source desktop GIS"], ["ArcGIS Pro", "https://pro.arcgis.com/", "Needs a university licence"]]],
      ["Free books", [["Geocomputation with R", "https://r.geocompx.org/", "sf, terra and mapping"], ["Spatial Data Science", "https://r-spatial.org/book/", "Pebesma & Bivand"], ["R for Data Science", "https://r4ds.hadley.nz/", "tidyverse foundations"], ["QGIS Training Manual", "https://docs.qgis.org/latest/en/docs/training_manual/", "Step-by-step GIS exercises"]]],
      ["Open data", [["GBIF", "https://www.gbif.org/", "Species occurrence records"], ["WorldClim", "https://www.worldclim.org/", "Climate and bioclimatic rasters"], ["Copernicus Land", "https://land.copernicus.eu/", "Land cover across Europe and the globe"], ["CNIG download centre", "https://centrodedescargas.cnig.es/", "DEMs, orthophotos and maps of Spain"], ["Movebank", "https://www.movebank.org/", "Animal tracking data"]]]
    ]
  };
  var PKGS = "tidyverse sf terra tmap MASS DHARMa lme4 rgbif CoordinateCleaner spdep gstat spatstat maxnet adehabitatHR landscapemetrics";

  function render() {
    var u = UI[lang], c = state.course, ws = state.weeks, nextI = nextIndex();
    document.documentElement.lang = lang;
    document.title = L(c.title);
    var counts = { all: ws.length, r: 0, stat: 0, gis: 0 };
    ws.forEach(function (w) { (w.tracks || []).forEach(function (t) { counts[t] = (counts[t] || 0) + 1; }); });
    var shown = ws.map(function (w, i) { return { w: w, i: i }; }).filter(function (x) { return filter === "all" || (x.w.tracks || []).indexOf(filter) > -1; });
    var sw = '<div class="lang-switch" role="group" aria-label="Idioma / Language">' +
      '<button data-lang="es" aria-pressed="' + (lang === "es") + '">ES</button><button data-lang="en" aria-pressed="' + (lang === "en") + '">EN</button></div>';
    var h = '<header class="hero"><canvas id="topo" aria-hidden="true"></canvas><div class="wrap">' +
      '<div class="topbar"><span class="label">' + u.course + " · " + ws.length + " " + u.sessions + "</span>" + sw + "</div>" +
      "<h1>" + esc(L(c.title)) + '</h1><p class="tagline" style="margin:0">' + esc(L(c.tagline)) + "</p>" +
      '<div class="meta">' + (L(c.instructor) ? '<div><span class="label">' + u.instructor + '</span><span class="v">' + esc(L(c.instructor)) + "</span></div>" : "") +
      (L(c.when) ? '<div><span class="label">' + u.meets + '</span><span class="v">' + esc(L(c.when)) + "</span></div>" : "") +
      (L(c.contact) ? '<div><span class="label">' + u.contact + '</span><span class="v mono" style="user-select:all">' + esc(L(c.contact)) + "</span></div>" : "") +
      "</div></div></header>";
    h += '<main><div class="wrap"><aside><div class="legend"><div class="label" style="margin-bottom:4px">' + u.legend + "</div>" +
      ["all", "r", "stat", "gis"].map(function (t) { return '<button data-filter="' + t + '" aria-pressed="' + (filter === t) + '"><span class="sw ' + t + '"></span>' + (t === "all" ? u.all : u.tracks[t]) + '<span class="count">' + counts[t] + "</span></button>"; }).join("") + "</div>";
    if (nextI > -1) {
      var nw = ws[nextI];
      h += '<div class="next"><span class="label">' + u.next + " · " + esc(fmtDate(nw.date)) + "</span><h3>" + wkNo(nextI) + " " + esc(L(nw.title)) + "</h3>" +
        (L(nw.prep) ? '<p class="hint" style="font-size:14px">' + esc(L(nw.prep)) + "</p>" : "") + '<a href="#' + wkId(nextI) + '">' + u.goWeek + "</a></div>";
    }
    if (L(c.intro)) h += '<p class="hint" style="font-size:14.5px;margin:0">' + esc(L(c.intro)) + "</p>";
    h += '<div class="side-links"><span class="label">' + u.jump + '</span><a href="#reference">' + u.refLink + "</a>" +
      (c.all_data ? '<a href="' + esc(c.all_data) + '" download>' + u.allData + "</a>" : "") + "</div></aside>";
    h += '<section aria-labelledby="weeks-h"><div class="section-head"><h2 id="weeks-h">' + u.weekly + '</h2><span class="label">' +
      (filter === "all" ? u.showingAll : u.showing + " " + esc(u.tracks[filter])) + " · " + shown.length + "</span></div>" +
      '<div class="weeks">' + shown.map(function (x) { return weekHTML(x.w, x.i, nextI); }).join("") + "</div>" +
      (shown.length ? "" : '<p class="empty">' + u.none + "</p>") + "</section></div></main>";
    h += '<section class="ref" id="reference" aria-labelledby="ref-h"><div class="wrap"><div><span class="label">' + u.ref + '</span><h2 id="ref-h" style="font-size:32px">' + u.refTitle + '</h2></div><div class="ref-grid">' +
      REF[lang].map(function (g) { return "<div><h3>" + g[0] + "</h3><ul>" + g[1].map(function (l) { return '<li><a href="' + l[1] + '" target="_blank" rel="noopener">' + l[0] + "</a><span>" + l[2] + "</span></li>"; }).join("") + "</ul></div>"; }).join("") +
      "<div><h3>" + u.pkgs + '</h3><p class="hint" style="font-size:14px;margin:0 0 8px">' + u.pkgsNote + '</p><code style="display:block;white-space:pre-wrap;overflow-wrap:anywhere;padding:10px">install.packages(c(' +
      PKGS.split(" ").map(function (p) { return '"' + p + '"'; }).join(", ") + "))</code></div></div></div></section>";
    h += '<footer><div class="wrap">' + esc(L(c.title)) + (L(c.instructor) ? " · " + esc(L(c.instructor)) : "") + "</div></footer>";
    app.innerHTML = h;
    drawTopo();
  }

  function drawTopo() {
    var cv = document.getElementById("topo"); if (!cv) return;
    var r = cv.getBoundingClientRect(), dpr = Math.min(window.devicePixelRatio || 1, 2);
    if (!r.width) return; cv.width = r.width * dpr; cv.height = r.height * dpr;
    var ctx = cv.getContext("2d"); ctx.scale(dpr, dpr);
    var W = r.width, H = r.height, col = getComputedStyle(document.documentElement).getPropertyValue("--contour").trim() || "#A87A4E";
    var hills = [[.82, .35, .22, 1], [.62, .85, .18, .8], [.97, .9, .15, .7], [.45, .1, .12, .5], [.2, 1.05, .2, .6]];
    function f(x, y) {
      var v = 0, nx = x / W, ny = y / H * (H / W) * 1.6;
      for (var k = 0; k < hills.length; k++) { var hh = hills[k], dx = nx - hh[0], dy = ny - hh[1] * (H / W) * 1.6; v += hh[3] * Math.exp(-(dx * dx + dy * dy) / (2 * hh[2] * hh[2])); }
      return v + 0.03 * Math.sin(nx * 17 + ny * 9) + 0.025 * Math.cos(nx * 7 - ny * 13);
    }
    var s = 7, cols = Math.ceil(W / s) + 1, rows = Math.ceil(H / s) + 1, g = new Float32Array(cols * rows);
    for (var j = 0; j < rows; j++) for (var i = 0; i < cols; i++) g[j * cols + i] = f(i * s, j * s);
    ctx.strokeStyle = col;
    for (var lv = 0.08, idx = 0; lv < 1.3; lv += 0.07, idx++) {
      ctx.globalAlpha = idx % 5 === 0 ? 0.55 : 0.28; ctx.lineWidth = idx % 5 === 0 ? 1.3 : 0.8; ctx.beginPath();
      for (var y = 0; y < rows - 1; y++) for (var x = 0; x < cols - 1; x++) {
        var a = g[y * cols + x], b = g[y * cols + x + 1], c2 = g[(y + 1) * cols + x + 1], d = g[(y + 1) * cols + x];
        var code = (a > lv ? 8 : 0) | (b > lv ? 4 : 0) | (c2 > lv ? 2 : 0) | (d > lv ? 1 : 0); if (code === 0 || code === 15) continue;
        var px = x * s, py = y * s, t = function (p, q) { return (lv - p) / (q - p); };
        var T = [px + s * t(a, b), py], R = [px + s, py + s * t(b, c2)], B = [px + s * t(d, c2), py + s], Lf = [px, py + s * t(a, d)];
        var segs = { 1: [Lf, B], 2: [B, R], 3: [Lf, R], 4: [T, R], 5: [T, Lf, B, R], 6: [T, B], 7: [T, Lf], 8: [T, Lf], 9: [T, B], 10: [T, R, Lf, B], 11: [T, R], 12: [Lf, R], 13: [B, R], 14: [Lf, B] }[code];
        for (var k = 0; k < segs.length; k += 2) { ctx.moveTo(segs[k][0], segs[k][1]); ctx.lineTo(segs[k + 1][0], segs[k + 1][1]); }
      }
      ctx.stroke();
    }
    ctx.globalAlpha = 1;
  }

  document.addEventListener("click", function (e) {
    var fb = e.target.closest("[data-filter]");
    if (fb) { filter = fb.getAttribute("data-filter"); render(); return; }
    var lb = e.target.closest("[data-lang]");
    if (lb) { lang = lb.getAttribute("data-lang"); try { localStorage.setItem("course-lang", lang); } catch (x) {} render(); }
  });
  var rt; window.addEventListener("resize", function () { clearTimeout(rt); rt = setTimeout(drawTopo, 150); });
  try { window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", drawTopo); } catch (e) {}
  render();
  if (/^#session\d+$/.test(location.hash)) { var el = document.getElementById(location.hash.slice(1)); if (el) el.scrollIntoView(); }
})();
