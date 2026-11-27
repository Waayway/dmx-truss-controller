// Layout solver for the 90-degree USB-C cable (one quarter bend, no U-turn) plus the MAX485 and TMC6300 pieces.
// usage: node scripts/usbc-90.mjs [flexDesign=72] [clear=3]
// Frame: octagon centre = origin, +x right, +y up (looking into the open base). USB-C jack on the BOTTOM facet, axis +y.
//   cable: jack end (stiff, 54 mm) -> straight up a -> quarter circle radius R toward side s -> straight b -> stiff plug (30 mm) -> Nano port
//   The Nano lies along x at row y_row = y_b + a + R, port facing the cable. a + pi/2 R + b = flexDesign (the real cable is about 75, so 72 leaves 3 mm of margin).
// Everything is a keepout shape (rect / circle), all in mm; estimates are the ones in cad/params.scad.
const FLEX = +(process.argv[2] || 72), CLR = +(process.argv[3] || 3);
const WALL = 2.5, EDGE = 2.5;                      // board pieces keep 2.5 mm off the inner wall
const BODY = 54, JACK_BODY_LEN = 29.4, JACK_D = 23, RELIEF_D = 14, FLANGE_HALF = 15.5;
const CAB_R = 2.3, PLUG = 30, PLUG_W = 13, NANO_L = 43.18, NANO_W = 17.78;
const A_W = NANO_W + 2.2, A_L = NANO_L + 3;       // perfboard piece A outline (lib.scad)
const MX_W = 14.1 + 3, MX_L = 43.9 + 3, TM_L = 20.32 + 3, TM_W = 15.24 + 3;
const XLR_D = 23.5, XLR_DEPTH = 29;

const inside = (F, x, y, extra) => { const h = F / 2 - WALL - extra; return Math.abs(x) <= h && Math.abs(y) <= h && Math.abs(x) + Math.abs(y) <= h * Math.SQRT2; };
const rectIn = (F, r, extra) => [[r.x0, r.y0], [r.x1, r.y0], [r.x0, r.y1], [r.x1, r.y1]].every(([x, y]) => inside(F, x, y, extra));
const rr = (a, b, g = 0) => a.x0 < b.x1 + g && a.x1 > b.x0 - g && a.y0 < b.y1 + g && a.y1 > b.y0 - g;
const cr = (c, r, g = 0) => { const nx = Math.max(r.x0, Math.min(c.x, r.x1)), ny = Math.max(r.y0, Math.min(c.y, r.y1)); return Math.hypot(nx - c.x, ny - c.y) < c.r + g; };
const mkRect = (cx, cy, w, l) => ({ x0: cx - w / 2, x1: cx + w / 2, y0: cy - l / 2, y1: cy + l / 2 });

function cableLayout(F, jx, s, a, R) {
  const yb = -F / 2 + BODY, b = FLEX - a - Math.PI / 2 * R;
  if (b < 0) return null;
  const row = yb + a + R;
  const xPortEdge = jx + s * (R + b + PLUG);
  const xFar = xPortEdge + s * NANO_L;
  // shapes
  const rects = [], circles = [];
  const nano = mkRect((xPortEdge + xFar) / 2, row, NANO_L + 3, A_W);              // perfboard piece A
  rects.push(nano);
  rects.push({ x0: Math.min(jx + s * (R + b), xPortEdge), x1: Math.max(jx + s * (R + b), xPortEdge), y0: row - PLUG_W / 2, y1: row + PLUG_W / 2 }); // plug
  const cx = jx + s * R, cy = yb + a;
  for (let y = yb; y <= cy; y += 3) circles.push({ x: jx, y, r: CAB_R });
  for (let t = 0; t <= 90; t += 6) { const th = t * Math.PI / 180; circles.push({ x: cx - s * R * Math.cos(th), y: cy + R * Math.sin(th), r: CAB_R }); }
  for (let d = 0; d <= b; d += 3) circles.push({ x: cx + s * d, y: row, r: CAB_R });
  return { yb, b, row, xPortEdge, xFar, nano, rects, circles, jx, s, a, R };
}
function cableFits(F, L) {
  if (!rectIn(F, L.nano, EDGE)) return false;
  for (const c of L.circles) if (!inside(F, c.x, c.y, c.r + CLR)) return false;
  // jack body and relief must not hit the nano/plug, jack is on the wall: only the relief end (y up to yb) matters
  const jackBody = { x0: L.jx - JACK_D / 2, x1: L.jx + JACK_D / 2, y0: -F / 2, y1: -F / 2 + JACK_BODY_LEN };
  const relief = { x0: L.jx - RELIEF_D / 2, x1: L.jx + RELIEF_D / 2, y0: -F / 2, y1: L.yb };
  if (rr(L.nano, jackBody, CLR) || rr(L.nano, relief, CLR)) return false;
  return true;
}
const fixed = (F, L, xlr) => {
  const k = [];
  k.push({ x0: L.jx - JACK_D / 2, x1: L.jx + JACK_D / 2, y0: -F / 2, y1: -F / 2 + JACK_BODY_LEN });
  k.push({ x0: L.jx - RELIEF_D / 2, x1: L.jx + RELIEF_D / 2, y0: -F / 2, y1: L.yb });
  k.push(...L.rects);
  // XLR body (facet: 'R' right, 'L' left, 'T' top), 2 mm around it
  const h = XLR_D / 2 + 2;
  if (xlr === 'R') k.push({ x0: F / 2 - XLR_DEPTH - 2, x1: F / 2, y0: -h, y1: h });
  if (xlr === 'L') k.push({ x0: -F / 2, x1: -F / 2 + XLR_DEPTH + 2, y0: -h, y1: h });
  if (xlr === 'T') k.push({ x0: -h, x1: h, y0: F / 2 - XLR_DEPTH - 2, y1: F / 2 });
  return k;
};
const circlesFixed = F => {
  const out = [];
  const bossR = (F / 2 - WALL) / Math.cos(22.5 * Math.PI / 180) - 4.5;
  for (const a of [22.5, 157.5, 202.5, 337.5]) out.push({ x: bossR * Math.cos(a * Math.PI / 180), y: bossR * Math.sin(a * Math.PI / 180), r: 5.2 });
  for (const sx of [-1, 1]) out.push({ x: sx * 35, y: 28, r: 5.5 });
  return out;
};
function place(F, L, xlr) {
  const fx = fixed(F, L, xlr), cf = [...circlesFixed(F), ...L.circles.map(c => ({ ...c, r: c.r + CLR - 1 }))];
  const okRect = (r, others) => rectIn(F, r, EDGE) && !fx.some(k => rr(r, k, 2)) && !cf.some(c => cr(c, r, 1)) && !others.some(o => rr(r, o, 2));
  const wallSlack = r => Math.min(...[[r.x0, r.y0], [r.x1, r.y0], [r.x0, r.y1], [r.x1, r.y1]].map(([x, y]) => { const h = F / 2 - WALL - EDGE; return Math.min(h - Math.abs(x), h - Math.abs(y), (h * Math.SQRT2 - Math.abs(x) - Math.abs(y)) / Math.SQRT2); }));
  // lead drop point (motor lead slot at 270 degrees, r 20) and XLR side point, to keep the wires short
  const lead = { x: 0, y: -20 }, xp = xlr === 'R' ? { x: F / 2 - 20, y: 0 } : xlr === 'L' ? { x: -F / 2 + 20, y: 0 } : { x: 0, y: F / 2 - 20 };
  let best = null;
  const step = 3;
  for (const mv of [true, false]) {
    const w = mv ? MX_W : MX_L, l = mv ? MX_L : MX_W;
    for (let x = -F / 2; x <= F / 2; x += step) for (let y = -F / 2; y <= F / 2; y += step) {
      const m = mkRect(x, y, w, l); if (!okRect(m, [])) continue;
      for (const tv of [true, false]) {
        const tw = tv ? TM_W : TM_L, tl = tv ? TM_L : TM_W;
        for (let tx = -F / 2; tx <= F / 2; tx += step) for (let ty = -F / 2; ty <= F / 2; ty += step) {
          const t = mkRect(tx, ty, tw, tl); if (!okRect(t, [m])) continue;
          const dl = Math.hypot(tx - lead.x, ty - lead.y), dx = Math.hypot(x - xp.x, y - xp.y);
          const sc = Math.min(wallSlack(m), wallSlack(t), 12) * 2 - (dl + dx) * 0.1;
          if (!best || sc > best.sc) best = { sc, m, t, mv, tv, dl, dx, ms: wallSlack(m), ts: wallSlack(t) };
        }
      }
    }
  }
  return best;
}

const results = [];
for (const F of (process.argv[4] ? process.argv[4].split(",").map(Number) : [170, 175, 180, 185, 190])) {
  const facetHalf = F * Math.tan(Math.PI / 8) / 2, jxMax = facetHalf - FLANGE_HALF;
  if (jxMax < 0) continue;
  const cands = [];
  for (const R of [12, 14, 16]) for (const s of [-1, 1]) for (let jx = -jxMax; jx <= jxMax + 0.01; jx += 2) for (let a = 0; a <= FLEX - Math.PI / 2 * R; a += 2) {
    const L = cableLayout(F, jx, s, a, R); if (!L || !cableFits(F, L)) continue;
    cands.push(L);
  }
  // keep a spread: score by how far the Nano piece is from the wall
  const slackOf = L => Math.min(...[[L.nano.x0, L.nano.y0], [L.nano.x1, L.nano.y0], [L.nano.x0, L.nano.y1], [L.nano.x1, L.nano.y1]].map(([x, y]) => { const h = F / 2 - WALL - EDGE; return Math.min(h - Math.abs(x), h - Math.abs(y), (h * Math.SQRT2 - Math.abs(x) - Math.abs(y)) / Math.SQRT2); }));
  cands.sort((p, q) => slackOf(q) - slackOf(p));
  let found = null;
  const tried = new Set();
  for (const L of cands.slice(0, 400)) {
    const key = [L.R, L.s, Math.round(L.jx / 4), Math.round(L.a / 6)].join();
    if (tried.has(key)) continue; tried.add(key); if (tried.size > 10) break;
    for (const xlr of ['R', 'L', 'T']) {
      const p = place(F, L, xlr); if (!p) continue;
      const total = slackOf(L) * 1 + Math.min(p.ms, p.ts) * 1;
      if (!found || total > found.total) found = { total, L, p, xlr, nanoSlack: slackOf(L) };
    }
  }
  if (!found) { console.log(`F=${F}: NO LAYOUT (cable fits: ${cands.length} candidates)`); continue; }
  const { L, p, xlr } = found;
  console.log(`F=${F}: OK  jack x=${L.jx.toFixed(0)} bend toward ${L.s > 0 ? '+x' : '-x'} R=${L.R} a=${L.a.toFixed(0)} b=${L.b.toFixed(1)} Nano row y=${L.row.toFixed(1)} port edge x=${L.xPortEdge.toFixed(1)} far end x=${L.xFar.toFixed(1)}  XLR ${xlr}  Nano-to-wall ${found.nanoSlack.toFixed(1)}  MAX485 ${p.mv ? 'tall' : 'wide'} at (${((p.m.x0 + p.m.x1) / 2).toFixed(0)},${((p.m.y0 + p.m.y1) / 2).toFixed(0)}) wall ${p.ms.toFixed(1)}  TMC ${p.tv ? 'tall' : 'wide'} at (${((p.t.x0 + p.t.x1) / 2).toFixed(0)},${((p.t.y0 + p.t.y1) / 2).toFixed(0)}) wall ${p.ts.toFixed(1)}  lead ${p.dl.toFixed(0)} mm, XLR ${p.dx.toFixed(0)} mm`);
  results.push({ F, found });
}
