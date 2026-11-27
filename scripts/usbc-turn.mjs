// How small can the base be for a given turn angle of the USB-C cable? (90 = one quarter bend, 180 = the old U-turn)
// usage: node scripts/usbc-turn.mjs [flex=72] [clear=3]       Cable + Nano piece only (no MAX485 / TMC6300), octagon, jack on the bottom facet.
const FLEX = +(process.argv[2] || 72), CLR = +(process.argv[3] || 3);
const WALL = 2.5, EDGE = 2.5, BODY = 54, BODY_LEN = 29.4, JACK_D = 23, RELIEF_D = 14, FLANGE_HALF = 15.5, CAB_R = 2.3, PLUG = 30, PLUG_W = 13, NANO_L = 43.18, A_W = 17.78 + 2.2;
const inside = (F, x, y, extra) => { const h = F / 2 - WALL - extra; return Math.abs(x) <= h && Math.abs(y) <= h && Math.abs(x) + Math.abs(y) <= h * Math.SQRT2; };
// convex polygon helpers
const rectPoly = (x0, y0, x1, y1) => [[x0, y0], [x1, y0], [x1, y1], [x0, y1]];
const boxAlong = (p, h, len, w, from = 0) => { const n = [-h[1], h[0]]; const a = [p[0] + h[0] * from, p[1] + h[1] * from], b = [a[0] + h[0] * len, a[1] + h[1] * len]; return [[a[0] + n[0] * w / 2, a[1] + n[1] * w / 2], [b[0] + n[0] * w / 2, b[1] + n[1] * w / 2], [b[0] - n[0] * w / 2, b[1] - n[1] * w / 2], [a[0] - n[0] * w / 2, a[1] - n[1] * w / 2]]; };
const proj = (poly, ax) => { const d = poly.map(p => p[0] * ax[0] + p[1] * ax[1]); return [Math.min(...d), Math.max(...d)]; };
const sat = (A, B, gap) => { for (const P of [A, B]) for (let i = 0; i < P.length; i++) { const e = [P[(i + 1) % P.length][0] - P[i][0], P[(i + 1) % P.length][1] - P[i][1]]; const l = Math.hypot(...e); const ax = [-e[1] / l, e[0] / l]; const [a0, a1] = proj(A, ax), [b0, b1] = proj(B, ax); if (a1 + gap <= b0 || b1 + gap <= a0) return false; } return true; };   // true = overlap
const distPtPoly = (pt, poly) => { let best = 1e9; for (let i = 0; i < poly.length; i++) { const a = poly[i], b = poly[(i + 1) % poly.length]; const ab = [b[0] - a[0], b[1] - a[1]], ap = [pt[0] - a[0], pt[1] - a[1]]; const t = Math.max(0, Math.min(1, (ap[0] * ab[0] + ap[1] * ab[1]) / (ab[0] ** 2 + ab[1] ** 2))); best = Math.min(best, Math.hypot(pt[0] - a[0] - t * ab[0], pt[1] - a[1] - t * ab[1])); } return best; };

function layout(F, jx, s, a, R, phiDeg) {
  const phi = phiDeg * Math.PI / 180, yb = -F / 2 + BODY, b = FLEX - a - R * phi;
  if (b < 3) return null;
  const c = [jx + s * R, yb + a];
  const pts = [];                                                           // centreline samples
  for (let y = yb; y <= yb + a; y += 3) pts.push([jx, y]);
  for (let t = 0; t <= phi + 1e-9; t += 0.1) pts.push([c[0] - s * R * Math.cos(t), c[1] + R * Math.sin(t)]);
  const P1 = [c[0] - s * R * Math.cos(phi), c[1] + R * Math.sin(phi)], h = [s * Math.sin(phi), Math.cos(phi)];
  for (let d = 0; d <= b; d += 3) pts.push([P1[0] + h[0] * d, P1[1] + h[1] * d]);
  const P2 = [P1[0] + h[0] * b, P1[1] + h[1] * b];
  const plug = boxAlong(P2, h, PLUG, PLUG_W), nano = boxAlong(P2, h, PLUG + NANO_L + 3, A_W, 0).map((p, i) => p);
  const nanoOnly = boxAlong(P2, h, NANO_L + 3, A_W, PLUG);
  return { pts, plug, nano: nanoOnly, P2, h, yb };
}
function fits(F, L, jx) {
  for (const p of L.pts) if (!inside(F, p[0], p[1], CAB_R + CLR)) return false;
  for (const p of [...L.nano, ...L.plug]) if (!inside(F, p[0], p[1], EDGE)) return false;
  const body = rectPoly(jx - JACK_D / 2, -F / 2, jx + JACK_D / 2, -F / 2 + BODY_LEN), relief = rectPoly(jx - RELIEF_D / 2, -F / 2, jx + RELIEF_D / 2, L.yb);
  for (const poly of [L.nano, L.plug]) if (sat(poly, body, CLR) || sat(poly, relief, CLR)) return false;
  // the Nano piece must stay away from the earlier cable (everything except the last 40 mm before the plug)
  const keep = L.pts.slice(0, Math.max(0, L.pts.length - 14));
  for (const p of keep) if (distPtPoly(p, L.nano) < CAB_R + CLR || distPtPoly(p, L.plug) < CAB_R + CLR) return false;
  return true;
}
const rows = [];
for (const phiDeg of [90, 105, 120, 135, 150, 165, 180]) {
  let min = null;
  for (let F = 100; F <= 200 && !min; F += 2) {
    const jxMax = F * Math.tan(Math.PI / 8) / 2 - FLANGE_HALF; if (jxMax < 0) continue;
    for (const R of [12, 14, 16]) { for (const s of [-1, 1]) for (let jx = -jxMax; jx <= jxMax + 0.01; jx += 2) for (let a = 0; a <= FLEX; a += 2) {
      const L = layout(F, jx, s, a, R, phiDeg); if (L && fits(F, L, jx)) { min = { F, R, s, jx, a, b: FLEX - a - R * phiDeg * Math.PI / 180 }; break; }
    } if (min) break; }
  }
  console.log(`turn ${phiDeg} deg: ` + (min ? `min base ${min.F} mm (R=${min.R}, jack x=${min.jx.toFixed(0)}, a=${min.a}, b=${min.b.toFixed(0)})` : 'no layout up to 200 mm'));
  rows.push({ phiDeg, min });
}

// ---- detail mode: node scripts/usbc-turn.mjs 72 3 140   -> every turn angle that fits that base size, with the layout with the most room
if (process.argv[4]) {
  const F = +process.argv[4], jxMax = F * Math.tan(Math.PI / 8) / 2 - FLANGE_HALF;
  const slackOf = L => Math.min(...[...L.nano, ...L.plug].map(([x, y]) => { const h = F / 2 - WALL - EDGE; return Math.min(h - Math.abs(x), h - Math.abs(y), (h * Math.SQRT2 - Math.abs(x) - Math.abs(y)) / Math.SQRT2); }));
  for (let phiDeg = 90; phiDeg <= 200; phiDeg += 5) {
    let best = null;
    for (const R of [12, 13, 14, 15, 16]) for (const s of [-1, 1]) for (let jx = -jxMax; jx <= jxMax + 0.01; jx += 1) for (let a = 0; a <= FLEX; a += 1) {
      const L = layout(F, jx, s, a, R, phiDeg); if (!L || !fits(F, L, jx)) continue;
      const sc = slackOf(L); if (!best || sc > best.sc) best = { sc, R, s, jx, a, b: FLEX - a - R * phiDeg * Math.PI / 180, row: L.P2, h: L.h };
    }
    if (best) console.log(`F=${F} turn ${phiDeg}: fits. R=${best.R} side=${best.s > 0 ? '+x' : '-x'} jack x=${best.jx} a=${best.a} b=${best.b.toFixed(1)} wall slack ${best.sc.toFixed(1)}`);
  }
}
