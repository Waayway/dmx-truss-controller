// Joint solver: smallest base that holds the Neutrik USB-C U-turn WITH cable slack, plus the MAX485 and TMC6300 boards.
// Usage: node scripts/place-all.mjs [minSlack=4]
// All estimates; see docs/open-questions.md. Modules stand 13 mm on the board, same z band as the cable, so everything is a 2D keepout.
const MIN_B = +(process.argv[2] || 4);
const WALL = 2.5, MARGIN = 1.5, PAD = 1.5;
const MAXM = { w: 14.1, l: 43.9 }, TMC = { w: 15.24, l: 20.32 };
const CAB_R = 2.3, R = 12, FLEX = 75, BODY = 54, PLUG = 30, NANO_L = 43.18, NANO_W = 17.78;

function geom(F, xj, pull) {
  const yb = -F / 2 + BODY, yEnd = -F / 2 + WALL + MARGIN + pull, yp = yEnd + NANO_L, yc = yp + PLUG;
  const amb = yc - yb, apb = FLEX - Math.PI * R;
  const a = (amb + apb) / 2, b = (apb - amb) / 2;
  return { yb, yEnd, yp, yc, a, b, nanoX: xj - 2 * R, cy: yb + a };
}
const mk = F => { const H = F / 2 - WALL - MARGIN;
  const inside = (x, y) => Math.abs(x) <= H && Math.abs(y) <= H && Math.abs(x) + Math.abs(y) <= H * Math.SQRT2;
  const wallSlack = (x, y) => Math.min(H - Math.abs(x), H - Math.abs(y), (H * Math.SQRT2 - Math.abs(x) - Math.abs(y)) / Math.SQRT2);
  return { H, inside, wallSlack }; };

function cableOK(F, xj, pull) {
  const { inside, wallSlack } = mk(F), g = geom(F, xj, pull);
  if (g.b < MIN_B) return null;
  const pts = [];
  for (const sx of [-1, 1]) for (const y of [g.yEnd - 1.5, g.yp]) pts.push([g.nanoX + sx * 10, y]);   // board A outline (20 wide)
  for (const sx of [-1, 1]) for (const y of [g.yp, g.yc]) pts.push([g.nanoX + sx * 6.5, y]);
  const cx = xj - R;
  for (let t = 0; t <= 180; t += 10) pts.push([cx + (R + CAB_R) * Math.cos(t * Math.PI / 180), g.cy + (R + CAB_R) * Math.sin(t * Math.PI / 180)]);
  // board A has its far corner sawn off by 4 mm: ignore that corner point's worst 4 mm
  let worst = 1e9;
  for (const [x, y] of pts) { if (!inside(x, y)) { worst = -1; break; } worst = Math.min(worst, wallSlack(x, y)); }
  return worst >= 0 ? { worst, g } : null;
}

function modulesFor(F, xj, pull, g) {
  const { inside } = mk(F), H = F / 2 - WALL - MARGIN;
  const rectInside = r => [[r.x0, r.y0], [r.x1, r.y0], [r.x0, r.y1], [r.x1, r.y1]].every(([x, y]) => inside(x, y));
  const overlap = (a, b, gap = 0) => a.x0 < b.x1 + gap && a.x1 > b.x0 - gap && a.y0 < b.y1 + gap && a.y1 > b.y0 - gap;
  const circleHit = (r, cx, cy, rad) => { const nx = Math.max(r.x0, Math.min(cx, r.x1)), ny = Math.max(r.y0, Math.min(cy, r.y1)); return Math.hypot(nx - cx, ny - cy) < rad; };
  const rects = [
    { x0: xj - CAB_R - MARGIN, x1: xj + CAB_R + MARGIN, y0: g.yb - 2, y1: g.cy + R },
    { x0: xj - 7 - MARGIN, x1: xj + 7 + MARGIN, y0: -F / 2, y1: g.yb + MARGIN },
    { x0: xj - 11.5 - MARGIN, x1: xj + 11.5 + MARGIN, y0: -F / 2, y1: -F / 2 + 29.4 + MARGIN },
    { x0: F / 2 - 29 - 3, x1: F / 2, y0: -11.75 - MARGIN, y1: 11.75 + MARGIN },
    { x0: g.nanoX - 12.5, x1: g.nanoX + 10.5, y0: g.yEnd - 4, y1: g.yp + 4 },
    { x0: g.nanoX - 6.5 - MARGIN, x1: g.nanoX + 6.5 + MARGIN, y0: g.yp - 1, y1: g.yc + 2 },
    { x0: g.nanoX - CAB_R - MARGIN, x1: xj + CAB_R + MARGIN, y0: g.cy - 2, y1: g.cy + R + CAB_R + MARGIN },
  ];
  const bossR = (F / 2 - WALL) / Math.cos(22.5 * Math.PI / 180) - 4.5;
  const circles = [67.5, 157.5, 247.5, 337.5].map(a => ({ x: bossR * Math.cos(a * Math.PI / 180), y: bossR * Math.sin(a * Math.PI / 180), r: 5 }));
  for (const sx of [-1, 1]) circles.push({ x: sx * 35, y: 28, r: 5.5 });
  const fits = (r, others) => rectInside(r) && !rects.some(k => overlap(r, k)) && !circles.some(c => circleHit(r, c.x, c.y, c.r)) && !others.some(o => overlap(r, o, 2));
  const clear = r => Math.min(...[[r.x0, r.y0], [r.x1, r.y0], [r.x0, r.y1], [r.x1, r.y1]].map(([x, y]) => Math.min(H - Math.abs(x), H - Math.abs(y), (H * Math.SQRT2 - Math.abs(x) - Math.abs(y)) / Math.SQRT2)));
  let best = null;
  for (const mv of [true]) {                                // MAX485 only vertical is ever possible
    const mw = MAXM.w + 2 * PAD, mh = MAXM.l + 2 * PAD;
    for (let mx = 0; mx <= F / 2; mx += 0.25) for (let my = -F / 2; my <= F / 2; my += 0.5) {
      const m = { x0: mx - mw / 2, x1: mx + mw / 2, y0: my - mh / 2, y1: my + mh / 2 };
      if (!fits(m, [])) continue;
      for (const tv of [true, false]) {
        const tw = (tv ? TMC.w : TMC.l) + 2 * PAD, th = (tv ? TMC.l : TMC.w) + 2 * PAD;
        for (let tx = -F / 2; tx <= F / 2; tx += 1) for (let ty = -F / 2; ty <= F / 2; ty += 1) {
          const t = { x0: tx - tw / 2, x1: tx + tw / 2, y0: ty - th / 2, y1: ty + th / 2 };
          if (!fits(t, [m])) continue;
          const score = Math.min(clear(m), clear(t)) * 3 - Math.hypot(tx - 15, ty - 9) * 0.05;
          if (!best || score > best.score) best = { score, mx, my, tv, tx, ty, cm: clear(m), ct: clear(t) };
        }
      }
    }
  }
  return best;
}

for (const F of [115, 120, 125, 130]) {
  let top = null;
  for (let xj = -4; xj <= 8; xj += 2) for (let pull = 0; pull <= 14; pull += 2) {
    const c = cableOK(F, xj, pull); if (!c) continue;
    const m = modulesFor(F, xj, pull, c.g); if (!m) continue;
    const s = Math.min(c.worst, m.cm, m.ct) + Math.min(c.g.b, 8) * 0.3;
    if (!top || s > top.s) top = { s, xj, pull, b: c.g.b, wall: c.worst, m };
  }
  console.log('F=' + F, top ? 'OK  xj=' + top.xj + ' pull=' + top.pull + ' spare cable b=' + top.b.toFixed(1) + ' cable/Nano-to-wall slack=' + top.wall.toFixed(1) +
    ' | MAX485 vertical @ ' + top.m.mx + ',' + top.m.my + ' wall ' + top.m.cm.toFixed(1) + ' | TMC6300 ' + (top.m.tv ? 'tall' : 'wide') + ' @ ' + top.m.tx + ',' + top.m.ty + ' wall ' + top.m.ct.toFixed(1) : 'NO LAYOUT with b >= ' + MIN_B);
}
