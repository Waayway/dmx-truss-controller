// Shared geometry for the fit-test frames: cable path with one bend of phi degrees, the Nano piece at its end, and the MAX485 / TMC6300 piece placement.
// Same model as scripts/usbc-turn.mjs and cad/fit-frame.scad (jack on the bottom facet, +x right, +y up, mm).
export const WALL = 2.5, EDGE = 2.5, BODY = 54, BODY_LEN = 29.4, JACK_D = 23, RELIEF_D = 14, FLANGE_HALF = 15.5, CAB_R = 2.3, PLUG = 30, PLUG_W = 13, NANO_L = 43.18, A_W = 17.78 + 2.2;
export const MX_W = 14.1 + 3, MX_L = 43.9 + 3, TM_L = 20.32 + 3, TM_W = 15.24 + 3, XLR_D = 23.5, XLR_DEPTH = 29;
export const inside = (F, x, y, extra) => { const h = F / 2 - WALL - extra; return Math.abs(x) <= h && Math.abs(y) <= h && Math.abs(x) + Math.abs(y) <= h * Math.SQRT2; };
export const rectPoly = (x0, y0, x1, y1) => [[x0, y0], [x1, y0], [x1, y1], [x0, y1]];
const boxAlong = (p, h, len, w, from = 0) => { const n = [-h[1], h[0]]; const a = [p[0] + h[0] * from, p[1] + h[1] * from], b = [a[0] + h[0] * len, a[1] + h[1] * len]; return [[a[0] + n[0] * w / 2, a[1] + n[1] * w / 2], [b[0] + n[0] * w / 2, b[1] + n[1] * w / 2], [b[0] - n[0] * w / 2, b[1] - n[1] * w / 2], [a[0] - n[0] * w / 2, a[1] - n[1] * w / 2]]; };
const proj = (poly, ax) => { const d = poly.map(p => p[0] * ax[0] + p[1] * ax[1]); return [Math.min(...d), Math.max(...d)]; };
export const sat = (A, B, gap) => { for (const P of [A, B]) for (let i = 0; i < P.length; i++) { const e = [P[(i + 1) % P.length][0] - P[i][0], P[(i + 1) % P.length][1] - P[i][1]]; const l = Math.hypot(...e); const ax = [-e[1] / l, e[0] / l]; const [a0, a1] = proj(A, ax), [b0, b1] = proj(B, ax); if (a1 + gap <= b0 || b1 + gap <= a0) return false; } return true; };
const distPtPoly = (pt, poly) => { let best = 1e9; for (let i = 0; i < poly.length; i++) { const a = poly[i], b = poly[(i + 1) % poly.length]; const ab = [b[0] - a[0], b[1] - a[1]], ap = [pt[0] - a[0], pt[1] - a[1]]; const t = Math.max(0, Math.min(1, (ap[0] * ab[0] + ap[1] * ab[1]) / (ab[0] ** 2 + ab[1] ** 2))); best = Math.min(best, Math.hypot(pt[0] - a[0] - t * ab[0], pt[1] - a[1] - t * ab[1])); } return best; };
export const wallSlack = (F, pts) => Math.min(...pts.map(([x, y]) => { const h = F / 2 - WALL - EDGE; return Math.min(h - Math.abs(x), h - Math.abs(y), (h * Math.SQRT2 - Math.abs(x) - Math.abs(y)) / Math.SQRT2); }));

export function layout(F, jx, s, a, R, phiDeg, flex) {
  const phi = phiDeg * Math.PI / 180, yb = -F / 2 + BODY, b = flex - a - R * phi;
  if (b < 3) return null;
  const c = [jx + s * R, yb + a], pts = [];
  for (let y = yb; y <= yb + a; y += 3) pts.push([jx, y]);
  for (let t = 0; t <= phi + 1e-9; t += 0.1) pts.push([c[0] - s * R * Math.cos(t), c[1] + R * Math.sin(t)]);
  const P1 = [c[0] - s * R * Math.cos(phi), c[1] + R * Math.sin(phi)], h = [s * Math.sin(phi), Math.cos(phi)];
  for (let d = 0; d <= b; d += 3) pts.push([P1[0] + h[0] * d, P1[1] + h[1] * d]);
  const P2 = [P1[0] + h[0] * b, P1[1] + h[1] * b];
  return { pts, plug: boxAlong(P2, h, PLUG, PLUG_W), nano: boxAlong(P2, h, NANO_L + 3, A_W, PLUG), P2, h, yb, jx, s, a, R, b, phiDeg };
}
export function fits(F, L, clr) {
  for (const p of L.pts) if (!inside(F, p[0], p[1], CAB_R + clr)) return false;
  for (const p of [...L.nano, ...L.plug]) if (!inside(F, p[0], p[1], EDGE)) return false;
  const body = rectPoly(L.jx - JACK_D / 2, -F / 2, L.jx + JACK_D / 2, -F / 2 + BODY_LEN), relief = rectPoly(L.jx - RELIEF_D / 2, -F / 2, L.jx + RELIEF_D / 2, L.yb);
  for (const poly of [L.nano, L.plug]) if (sat(poly, body, clr) || sat(poly, relief, clr)) return false;
  const keep = L.pts.slice(0, Math.max(0, L.pts.length - 14));
  for (const p of keep) if (distPtPoly(p, L.nano) < CAB_R + clr || distPtPoly(p, L.plug) < CAB_R + clr) return false;
  return true;
}
export function bestLayout(F, phiDeg, flex, clr) {
  const jxMax = F * Math.tan(Math.PI / 8) / 2 - FLANGE_HALF; let best = null;
  for (const R of [12, 13, 14]) for (const s of [-1, 1]) for (let jx = -jxMax; jx <= jxMax + 0.01; jx += 1) for (let a = 0; a <= flex; a += 1) {
    const L = layout(F, jx, s, a, R, phiDeg, flex); if (!L || !fits(F, L, clr)) continue;
    const sc = wallSlack(F, [...L.nano, ...L.plug]); if (!best || sc > best.sc) best = { sc, ...L };
  }
  return best;
}

// MAX485 and TMC6300 pieces: the best spots that avoid the cable, plug, Nano piece, jack and XLR (top wall) and the plate posts
export function placeModules(F, L, clr) {
  const fixedPolys = [L.nano, L.plug, rectPoly(L.jx - JACK_D / 2, -F / 2, L.jx + JACK_D / 2, -F / 2 + BODY_LEN), rectPoly(L.jx - RELIEF_D / 2, -F / 2, L.jx + RELIEF_D / 2, L.yb), rectPoly(-XLR_D / 2 - 2, F / 2 - XLR_DEPTH - 2, XLR_D / 2 + 2, F / 2)];
  const bossR = (F / 2 - WALL) / Math.cos(22.5 * Math.PI / 180) - 4.5;
  const circles = [...[22.5, 157.5, 202.5, 337.5].map(a => ({ x: bossR * Math.cos(a * Math.PI / 180), y: bossR * Math.sin(a * Math.PI / 180), r: 5.2 })), ...L.pts.map(([x, y]) => ({ x, y, r: CAB_R + clr - 1 }))];
  const ok = r => inside(F, r.x0, r.y0, EDGE) && inside(F, r.x1, r.y0, EDGE) && inside(F, r.x0, r.y1, EDGE) && inside(F, r.x1, r.y1, EDGE)
    && !fixedPolys.some(p => sat(rectPoly(r.x0, r.y0, r.x1, r.y1), p, 2))
    && !circles.some(c => { const nx = Math.max(r.x0, Math.min(c.x, r.x1)), ny = Math.max(r.y0, Math.min(c.y, r.y1)); return Math.hypot(nx - c.x, ny - c.y) < c.r + 1; });
  const lead = [0, -20], xlr = [0, F / 2 - 20], step = 3;
  const cands = (w, l, target) => { const out = []; for (let x = -F / 2; x <= F / 2; x += step) for (let y = -F / 2; y <= F / 2; y += step) { const r = { x0: x - w / 2, x1: x + w / 2, y0: y - l / 2, y1: y + l / 2 }; if (!ok(r)) continue; const sl = wallSlack(F, rectPoly(r.x0, r.y0, r.x1, r.y1)); out.push({ r, x, y, sc: Math.min(sl, 12) * 2 - Math.hypot(x - target[0], y - target[1]) * 0.1 }); } return out.sort((p, q) => q.sc - p.sc).slice(0, 150); };
  const mx = [], tm = [];
  for (const rot of [0, 90]) { const [w, l] = rot === 0 ? [MX_W, MX_L] : [MX_L, MX_W]; for (const c of cands(w, l, xlr)) mx.push({ ...c, rot }); }
  for (const rot of [0, 90]) { const [w, l] = rot === 0 ? [TM_L, TM_W] : [TM_W, TM_L]; for (const c of cands(w, l, lead)) tm.push({ ...c, rot }); }
  let best = null;
  for (const m of mx) for (const t of tm) { if (sat(rectPoly(m.r.x0, m.r.y0, m.r.x1, m.r.y1), rectPoly(t.r.x0, t.r.y0, t.r.x1, t.r.y1), 2)) continue; const sc = m.sc + t.sc; if (!best || sc > best.sc) best = { sc, mx: m, tm: t }; }
  return best;
}
