// Usage: node scripts/usbc-layout.mjs   (prints, for several base sizes F, whether the Neutrik fly-lead U-turn fits; uses estimates from the photo)
// Feasibility of the Neutrik USB-C fly-lead U-turn inside a regular octagon base.
// Frame: origin = octagon centre, jack on the BOTTOM facet (outer face y = -F/2), jack axis +y (inward).
// All numbers in mm. Estimates from the user's photo and measurements (see docs/open-questions.md).
const WALL = 2.5, MARGIN = 1.5;
const BODY = 54;            // flange front face -> end of jack strain relief
const FLEX = 75;            // flexible cable
const PLUG_EXPOSED = 30;    // plug end beyond the Nano port edge (overmold + strain relief), 37 minus 7 mm inside the port
const NANO_L = 43.18, NANO_W = 17.78;
const JACK_HALF = 12;       // jack body radius over the first 29 mm
const FLANGE_HALF = 15.5;   // flange 31 mm along the facet
const CABLE_R = 2.3;
const PLUG_HALF = 6.5;      // plug overmold half-width

function inside(F, x, y, extra = 0) {
  const h = F / 2 - WALL - MARGIN - extra;             // usable half across flats
  return Math.abs(x) <= h && Math.abs(y) <= h && (Math.abs(x) + Math.abs(y)) <= h * Math.SQRT2;
}

function check(F, xj, R, side, nanoOffset) {
  const yb = -F / 2 + BODY;                             // end of the jack body
  const yEndMin = -F / 2 + WALL + MARGIN;               // Nano far end may not go closer to the wall than this
  const yEnd = yEndMin + nanoOffset;                    // Nano far end (antenna end)
  const yp = yEnd + NANO_L;                             // Nano port edge
  const yCableEnd = yp + PLUG_EXPOSED;                  // where the plain cable meets the plug
  const amb = yCableEnd - yb;                           // a - b
  const apb = FLEX - Math.PI * R;                       // a + b
  const a = (amb + apb) / 2, b = (apb - amb) / 2;
  if (b < 0 || a < 0) return { ok: false, why: 'cable too short for this layout (b=' + b.toFixed(1) + ')' };
  const xn = xj + side * 2 * R;
  const pts = [];
  // jack flange corners on the outer face and body outline
  // (flange sits on the OUTER face by design; its fit on the facet is the separate flangeOK test)
  // Nano rectangle corners
  for (const sx of [-1, 1]) for (const y of [yEnd, yp]) pts.push([xn + sx * NANO_W / 2, y]);
  // plug rectangle
  for (const sx of [-1, 1]) for (const y of [yp, yCableEnd]) pts.push([xn + sx * PLUG_HALF, y]);
  // cable centreline: leg a, semicircle, leg b (sampled, offset by cable radius outward)
  const cx = xj + side * R, cy = yb + a;
  for (let t = 0; t <= 1.0001; t += 0.05) {
    const ang = Math.PI * t;                            // 0..pi around the arc
    pts.push([cx - side * (R + CABLE_R) * Math.cos(ang), cy + (R + CABLE_R) * Math.sin(ang)]);
  }
  pts.push([xj, yb + a], [xn, yb + a - b]);
  let worst = 1e9, bad = [];
  for (const [x, y] of pts) {
    const h = F / 2 - WALL - MARGIN;
    const slack = Math.min(h - Math.abs(x), h - Math.abs(y), (h * Math.SQRT2 - Math.abs(x) - Math.abs(y)) / Math.SQRT2);
    worst = Math.min(worst, slack);
    if (slack < 0) bad.push([x.toFixed(1), y.toFixed(1)]);
  }
  // Nano must clear the jack body laterally while they overlap in y (jack body radius JACK_HALF over y < yb)
  const gap = Math.abs(xn - xj) - NANO_W / 2 - JACK_HALF;
  const overlapY = yEnd < -F / 2 + 29.4;
  const clearJack = !overlapY || gap >= 1;
  return { ok: worst >= 0 && clearJack, worst, bad, a, b, apex: cy + R, xn, yEnd, gap: +gap.toFixed(1), clearJack, flangeOK: Math.abs(xj) <= F * Math.tan(Math.PI / 8) / 2 - FLANGE_HALF + 0 };
}

for (const F of [105, 110, 115, 120, 125, 130]) {
  let best = null;
  for (const R of [10, 12, 14, 16])
    for (const side of [-1, 1])
      for (let xj = -8; xj <= 8; xj += 2)
        for (let off = 0; off <= 40; off += 2) {
          const r = check(F, xj, R, side, off);
          if (r.ok && r.flangeOK && (!best || r.worst > best.r.worst)) best = { R, side, xj, off, r };
        }
  if (best) console.log('F=' + F, 'FEASIBLE: R=' + best.R, 'side=' + best.side, 'xj=' + best.xj, 'Nano pulled in by ' + best.off + ' mm', 'xn=' + best.r.xn.toFixed(1), 'slack to wall ' + best.r.worst.toFixed(1), 'legs a=' + best.r.a.toFixed(1) + ' b=' + best.r.b.toFixed(1), 'gap to jack body ' + best.r.gap);
  else console.log('F=' + F, 'no feasible layout');
}
