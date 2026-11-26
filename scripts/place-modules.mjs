// 2D placement search for the MAX485 and TMC6300 boards inside the base (top view, z overlap assumed everywhere:
// modules stand 13 mm on a board whose top is at z=10.9, i.e. they occupy z 10.9..23.9, the same band as the cable/jack at z 4.5..27.5).
// Usage: node scripts/place-modules.mjs
const F = 115, WALL = 2.5, MARGIN = 1.5;
const H = F / 2 - WALL - MARGIN;                       // usable half across flats (inner wall minus margin)
const BOARD_PAD = 1.5;                                 // board outline = module outline + this on each side (frame rim sits under it)
const MAX = { w: 14.1, l: 43.9 }, TMC = { w: 15.24, l: 20.32 };
const CAB_R = 2.3, R = 12, FLEX = 75, BODY = 54, PLUG = 30, NANO_L = 43.18;

function inside(x, y) { return Math.abs(x) <= H && Math.abs(y) <= H && Math.abs(x) + Math.abs(y) <= H * Math.SQRT2; }
function rectInside(r) { return [[r.x0, r.y0], [r.x1, r.y0], [r.x0, r.y1], [r.x1, r.y1]].every(([x, y]) => inside(x, y)); }
function overlap(a, b, gap = 0) { return a.x0 < b.x1 + gap && a.x1 > b.x0 - gap && a.y0 < b.y1 + gap && a.y1 > b.y0 - gap; }
function circleHit(r, cx, cy, rad) {                   // rect vs circle
  const nx = Math.max(r.x0, Math.min(cx, r.x1)), ny = Math.max(r.y0, Math.min(cy, r.y1));
  return Math.hypot(nx - cx, ny - cy) < rad;
}

function keepouts(xj, pull) {
  const yb = -F / 2 + BODY, yEnd = -F / 2 + WALL + 1.5 + pull, yp = yEnd + NANO_L, yc = yp + PLUG;
  const amb = yc - yb, apb = FLEX - Math.PI * R, a = (amb + apb) / 2;
  const nanoX = xj - 2 * R;
  const rects = [
    { n: 'cable leg', x0: xj - CAB_R - MARGIN, x1: xj + CAB_R + MARGIN, y0: yb - 2, y1: yb + a + R },
    { n: 'strain relief', x0: xj - 7 - MARGIN, x1: xj + 7 + MARGIN, y0: -F / 2, y1: yb + MARGIN },
    { n: 'jack body', x0: xj - 11.5 - MARGIN, x1: xj + 11.5 + MARGIN, y0: -F / 2, y1: -F / 2 + 29.4 + MARGIN },
    { n: 'XLR + cups', x0: F / 2 - 29 - 3, x1: F / 2, y0: -11.75 - MARGIN, y1: 11.75 + MARGIN },
    { n: 'Nano strip', x0: nanoX - 12.5, x1: nanoX + 10.5, y0: yEnd - 4, y1: yp + 4 },
    { n: 'plug (stiff end)', x0: nanoX - 6.5 - MARGIN, x1: nanoX + 6.5 + MARGIN, y0: yp - 1, y1: yc + 2 },
    { n: 'cable U-bend', x0: nanoX - CAB_R - MARGIN, x1: xj + CAB_R + MARGIN, y0: yb + a - 2, y1: yb + a + R + CAB_R + MARGIN },
  ];
  const circles = [];
  const bossR = (F / 2 - WALL) / Math.cos(22.5 * Math.PI / 180) - 4.5;
  for (const a of [67.5, 157.5, 247.5, 337.5]) circles.push({ n: 'boss', x: bossR * Math.cos(a * Math.PI / 180), y: bossR * Math.sin(a * Math.PI / 180), r: 3.5 + MARGIN });
  for (const sx of [-1, 1]) circles.push({ n: 'keyhole', x: sx * 35, y: 28, r: 5.5 });   // horizontal pair, 70 mm apart
  return { rects, circles, yb, yEnd, yp, a, nanoX };
}

function fits(r, ko, others) {
  if (!rectInside(r)) return false;
  for (const k of ko.rects) if (overlap(r, k)) return false;
  for (const c of ko.circles) if (circleHit(r, c.x, c.y, c.r)) return false;
  for (const o of others) if (overlap(r, o, 2)) return false;
  return true;
}
function clearance(r, ko) {                           // min distance of the rect to the octagon edge and keepouts (rough)
  let m = 1e9;
  for (const [x, y] of [[r.x0, r.y0], [r.x1, r.y0], [r.x0, r.y1], [r.x1, r.y1]])
    m = Math.min(m, H - Math.abs(x), H - Math.abs(y), (H * Math.SQRT2 - Math.abs(x) - Math.abs(y)) / Math.SQRT2);
  return m;
}

const slot = { x: 15, y: 9 };                          // where the motor leads come down (front-plate slot at 30 degrees)
const results = [];
for (const [xj, pull] of [[2, 14], [4, 14], [6, 14], [8, 12]]) {
  const ko = keepouts(xj, pull);
  let best = null;
  for (const mv of [true, false]) {                    // MAX485 vertical (long side along y) or horizontal
    const mw = (mv ? MAX.w : MAX.l) + 2 * BOARD_PAD, mh = (mv ? MAX.l : MAX.w) + 2 * BOARD_PAD;
    for (let mx = -10; mx <= 60; mx += 0.25) for (let my = -50; my <= 50; my += 0.5) {
      const m = { x0: mx - mw / 2, x1: mx + mw / 2, y0: my - mh / 2, y1: my + mh / 2 };
      if (!fits(m, ko, [])) continue;
      for (const tv of [true, false]) {
        const tw = (tv ? TMC.w : TMC.l) + 2 * BOARD_PAD, th = (tv ? TMC.l : TMC.w) + 2 * BOARD_PAD;
        for (let tx = -10; tx <= 60; tx += 1) for (let ty = -50; ty <= 50; ty += 1) {
          const t = { x0: tx - tw / 2, x1: tx + tw / 2, y0: ty - th / 2, y1: ty + th / 2 };
          if (!fits(t, ko, [m])) continue;
          const score = Math.min(clearance(m, ko), clearance(t, ko)) * 3 - Math.hypot(tx - slot.x, ty - slot.y) * 0.05 - Math.hypot(mx - 20, my) * 0.02;
          if (!best || score > best.score) best = { score, mv, tv, mx, my, tx, ty, cm: clearance(m, ko), ct: clearance(t, ko) };
        }
      }
    }
  }
  console.log('xj=' + xj, 'pull=' + pull, best ? JSON.stringify({ MAX485: (best.mv ? 'vertical' : 'horizontal') + ' @ ' + best.mx + ',' + best.my + ' wall clearance ' + best.cm.toFixed(1), TMC6300: (best.tv ? 'tall' : 'wide') + ' @ ' + best.tx + ',' + best.ty + ' wall clearance ' + best.ct.toFixed(1) }) : 'NO PLACEMENT');
}
