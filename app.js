// Renders the course website from course-data.js. You don't need to edit this file.
(function () {
  "use strict";
  var state = window.COURSE;
  var app = document.getElementById("app");
  if (!state) {
    app.innerHTML = '<div class="wrap" style="padding-block:40px"><h2>The course content could not be loaded</h2>' +
      '<p>There is probably a typing error (often a missing comma or quote) in <code>course-data.js</code>. ' +
      'Check the last change you made to that file.</p></div>';
    return;
  }
  var TRACKS = { r: "R programming", stat: "Statistics", gis: "GIS & mapping" };
  var filter = "all";

  function esc(s) { return String(s == null ? "" : s).replace(/[&<>"']/g, function (c) { return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]; }); }
  function extOf(n) { var m = /\.([a-z0-9]+)$/i.exec(n || ""); return m ? m[1].toLowerCase() : ""; }
  function fmtDate(d) { if (!d) return "Date TBC"; var t = new Date(d + "T12:00:00"); if (isNaN(t)) return d; return t.toLocaleDateString(undefined, { weekday: "short", day: "numeric", month: "short" }); }
  function today() { var t = new Date(); return t.getFullYear() + "-" + String(t.getMonth() + 1).padStart(2, "0") + "-" + String(t.getDate()).padStart(2, "0"); }
  function wkNo(i) { return "W" + String(i + 1).padStart(2, "0"); }
  function wkId(i) { return "week" + String(i + 1).padStart(2, "0"); }
  function nextIndex() {
    var t = today(), ws = state.weeks;
    for (var i = 0; i < ws.length; i++) { if (ws[i].date && ws[i].date >= t) return i; }
    return ws.some(function (w) { return w.date; }) ? -1 : (ws.length ? 0 : -1);
  }
  function isLink(m) { return !!m.url; }

  function matRow(m) {
    var href = isLink(m) ? m.url : m.file;
    var ext = isLink(m) ? "link" : (extOf(m.name) || "file");
    var open = '<a href="' + esc(href) + '" target="_blank" rel="noopener">' + esc(m.name) + "</a>";
    var dl = isLink(m) ? "" : '<a class="btn small" href="' + esc(href) + '" download="' + esc(m.name) + '">Download</a>';
    return '<li class="mat"><span class="ext">' + esc(ext) + '</span><span class="nm">' + open +
      (m.note ? '<br><span class="hint">' + esc(m.note) + "</span>" : "") + "</span>" + dl + "</li>";
  }

  function weekHTML(w, i, nextI) {
    var tracks = w.tracks || [], goals = w.goals || [], mats = w.materials || [];
    var chips = '<div class="chips">' + (i === nextI ? '<span class="chip now">Next class</span>' : "") +
      tracks.map(function (t) { return '<span class="chip ' + t + '">' + esc(TRACKS[t] || t) + "</span>"; }).join("") + "</div>";
    var body = "<h3>" + esc(w.title) + "</h3>" + chips + (w.summary ? '<p class="summary">' + esc(w.summary) + "</p>" : "") +
      '<div class="cols">' + (goals.length ? '<div><div class="label">You will learn to</div><ul>' + goals.map(function (g) { return "<li>" + esc(g) + "</li>"; }).join("") + "</ul></div>" : "") +
      (w.prep ? '<div><div class="label">Before class</div><p>' + esc(w.prep) + "</p></div>" : "") + "</div>";
    var m = '<div class="materials"><div class="label">Class materials</div>' +
      (mats.length ? '<ul class="mat-list">' + mats.map(matRow).join("") + "</ul>" : '<p class="empty">Materials will be posted here before class.</p>') + "</div>";
    return '<article class="week" id="' + wkId(i) + '"><div class="wk-no"><span class="n">' + wkNo(i) + '</span><span class="d">' + esc(fmtDate(w.date)) +
      '</span></div><div class="wk-body">' + body + m + "</div></article>";
  }

  var REF = [
    ["Software", [["R", "https://cran.r-project.org/", "The language we use for analysis"], ["RStudio Desktop", "https://posit.co/download/rstudio-desktop/", "Free editor for R"], ["QGIS (Long Term Release)", "https://qgis.org/download/", "Free, open-source desktop GIS"], ["ArcGIS Pro", "https://pro.arcgis.com/", "Needs a university licence"]]],
    ["Free books", [["Geocomputation with R", "https://r.geocompx.org/", "sf, terra and mapping"], ["Spatial Data Science", "https://r-spatial.org/book/", "Pebesma & Bivand"], ["R for Data Science", "https://r4ds.hadley.nz/", "tidyverse foundations"], ["QGIS Training Manual", "https://docs.qgis.org/latest/en/docs/training_manual/", "Step-by-step GIS exercises"]]],
    ["Open data", [["GBIF", "https://www.gbif.org/", "Species occurrence records"], ["WorldClim", "https://www.worldclim.org/", "Climate and bioclimatic rasters"], ["Copernicus Land", "https://land.copernicus.eu/", "Land cover across Europe and the globe"], ["Natural Earth", "https://www.naturalearthdata.com/", "Base map boundaries"], ["Movebank", "https://www.movebank.org/", "Animal tracking data"]]]
  ];
  var PKGS = "tidyverse sf terra tmap gstat spdep spatstat lme4 DHARMa rgbif CoordinateCleaner adehabitatHR amt landscapemetrics";

  function render() {
    var c = state.course, ws = state.weeks, nextI = nextIndex();
    var counts = { all: ws.length, r: 0, stat: 0, gis: 0 };
    ws.forEach(function (w) { (w.tracks || []).forEach(function (t) { counts[t] = (counts[t] || 0) + 1; }); });
    var shown = ws.map(function (w, i) { return { w: w, i: i }; }).filter(function (x) { return filter === "all" || (x.w.tracks || []).indexOf(filter) > -1; });
    var h = '<header class="hero"><canvas id="topo" aria-hidden="true"></canvas><div class="wrap">' +
      '<div class="topbar"><span class="label">Course · ' + ws.length + " weekly sessions</span></div>" +
      "<h1>" + esc(c.title) + '</h1><p class="tagline" style="margin:0">' + esc(c.tagline) + "</p>" +
      '<div class="meta">' + (c.instructor ? '<div><span class="label">Instructor</span><span class="v">' + esc(c.instructor) + "</span></div>" : "") +
      (c.when ? '<div><span class="label">Meets</span><span class="v">' + esc(c.when) + "</span></div>" : "") +
      (c.contact ? '<div><span class="label">Contact</span><span class="v mono" style="user-select:all">' + esc(c.contact) + "</span></div>" : "") +
      "</div></div></header>";
    h += '<main><div class="wrap"><aside><div class="legend"><div class="label" style="margin-bottom:4px">Legend · filter by topic</div>' +
      ["all", "r", "stat", "gis"].map(function (t) { return '<button data-filter="' + t + '" aria-pressed="' + (filter === t) + '"><span class="sw ' + t + '"></span>' + (t === "all" ? "All sessions" : TRACKS[t]) + '<span class="count">' + counts[t] + "</span></button>"; }).join("") + "</div>";
    if (nextI > -1) {
      var nw = ws[nextI];
      h += '<div class="next"><span class="label">Next class · ' + esc(fmtDate(nw.date)) + "</span><h3>" + wkNo(nextI) + " " + esc(nw.title) + "</h3>" +
        (nw.prep ? '<p class="hint" style="font-size:14px">' + esc(nw.prep) + "</p>" : "") + '<a href="#' + wkId(nextI) + '">Go to this week</a></div>';
    }
    if (c.intro) h += '<p class="hint" style="font-size:14.5px;margin:0">' + esc(c.intro) + "</p>";
    h += '<div class="side-links"><span class="label">Jump to</span><a href="#reference">Software, books and data</a></div></aside>';
    h += '<section aria-labelledby="weeks-h"><div class="section-head"><h2 id="weeks-h">Weekly sessions</h2><span class="label">' +
      (filter === "all" ? "Showing all" : "Showing " + esc(TRACKS[filter])) + " · " + shown.length + "</span></div>" +
      '<div class="weeks">' + shown.map(function (x) { return weekHTML(x.w, x.i, nextI); }).join("") + "</div>" +
      (shown.length ? "" : '<p class="empty">No sessions for this topic yet.</p>') + "</section></div></main>";
    h += '<section class="ref" id="reference" aria-labelledby="ref-h"><div class="wrap"><div><span class="label">Reference</span><h2 id="ref-h" style="font-size:32px">Software, books and data</h2></div><div class="ref-grid">' +
      REF.map(function (g) { return "<div><h3>" + g[0] + "</h3><ul>" + g[1].map(function (l) { return '<li><a href="' + l[1] + '" target="_blank" rel="noopener">' + l[0] + "</a><span>" + l[2] + "</span></li>"; }).join("") + "</ul></div>"; }).join("") +
      '<div><h3>R packages we use</h3><p class="hint" style="font-size:14px;margin:0 0 8px">Install as you reach each week, or all at once:</p><code style="display:block;white-space:pre-wrap;overflow-wrap:anywhere;padding:10px">install.packages(c(' +
      PKGS.split(" ").map(function (p) { return '"' + p + '"'; }).join(", ") + "))</code></div></div></div></section>";
    h += '<footer><div class="wrap">' + esc(c.title) + (c.instructor ? " · " + esc(c.instructor) : "") + "</div></footer>";
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
        var T = [px + s * t(a, b), py], R = [px + s, py + s * t(b, c2)], B = [px + s * t(d, c2), py + s], L = [px, py + s * t(a, d)];
        var segs = { 1: [L, B], 2: [B, R], 3: [L, R], 4: [T, R], 5: [T, L, B, R], 6: [T, B], 7: [T, L], 8: [T, L], 9: [T, B], 10: [T, R, L, B], 11: [T, R], 12: [L, R], 13: [B, R], 14: [L, B] }[code];
        for (var k = 0; k < segs.length; k += 2) { ctx.moveTo(segs[k][0], segs[k][1]); ctx.lineTo(segs[k + 1][0], segs[k + 1][1]); }
      }
      ctx.stroke();
    }
    ctx.globalAlpha = 1;
  }

  document.addEventListener("click", function (e) {
    var fb = e.target.closest("[data-filter]");
    if (fb) { filter = fb.getAttribute("data-filter"); render(); }
  });
  var rt; window.addEventListener("resize", function () { clearTimeout(rt); rt = setTimeout(drawTopo, 150); });
  try { window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", drawTopo); } catch (e) {}
  render();
  if (location.hash) { var el = document.getElementById(location.hash.slice(1)); if (el) el.scrollIntoView(); }
})();
