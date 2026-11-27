// Size comparison: base octagons vs the knob (ring 58 mm), with the cable turn angle that fits each size (scripts/usbc-turn.mjs, flex designed at 72 mm).
// usage: nix shell nixpkgs#librsvg -c node scripts/size-compare-svg.mjs     -> docs/images/size-compare.svg + .png
import fs from 'fs';
import path from 'path';
import { spawnSync } from 'child_process';
const root = path.resolve(path.dirname(new URL(import.meta.url).pathname), '..');
const S = 4.6, W = 1750, H = 1280, CX = 470, CY = 600, F = 'font-family="DejaVu Sans, Arial, sans-serif"';
const oct = (af, st) => { const r = af / 2 / Math.cos(Math.PI / 8); return `<polygon points="${[...Array(8)].map((_, k) => { const a = (22.5 + 45 * k) * Math.PI / 180; return (CX + r * S * Math.cos(a)).toFixed(1) + ',' + (CY - r * S * Math.sin(a)).toFixed(1); }).join(' ')}" ${st}/>`; };
const circ = (d, st) => `<circle cx="${CX}" cy="${CY}" r="${(d / 2 * S).toFixed(1)}" ${st}/>`;
const t = (x, y, s, sz = 24, o = {}) => `<text x="${x}" y="${y}" ${F} font-size="${sz}" fill="${o.fill || '#111'}" font-weight="${o.b ? 700 : 400}" text-anchor="${o.a || 'start'}">${s}</text>`;
let s = `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}"><rect width="${W}" height="${H}" fill="#fff"/>`;
s += t(40, 55, 'How big is the base, compared with the knob?', 36, { b: 1 });
// outlines, biggest first. Each is the base size (across flats) and the USB-C cable turn it can hold.
s += oct(180, 'fill="#e8edf5" stroke="#2563eb" stroke-width="4"');
s += oct(148, 'fill="#eaf5ea" stroke="#16a34a" stroke-width="4"');
s += oct(140, 'fill="none" stroke="#d97706" stroke-width="3" stroke-dasharray="14 8"');
s += oct(130, 'fill="none" stroke="#9ca3af" stroke-width="3" stroke-dasharray="6 8"');
s += oct(115, 'fill="#fdf1e3" stroke="#dc2626" stroke-width="4"');
// the knob
s += circ(58, 'fill="#3a3e44" stroke="#111" stroke-width="3"') + circ(43, 'fill="#17191c"') + circ(38.5, 'fill="#2b6cb0"') + circ(32, 'fill="none" stroke="#e0a030" stroke-width="3" stroke-dasharray="8 6"');
s += t(CX, CY + 6, 'KNOB', 18, { fill: '#fff', b: 1, a: 'middle' }) + t(CX, CY + 28, '58 mm', 16, { fill: '#fff', a: 'middle' });
// scale bar
s += `<line x1="${CX - 25 * S}" y1="${CY + 100 * S}" x2="${CX + 25 * S}" y2="${CY + 100 * S}" stroke="#111" stroke-width="5"/>` + t(CX, CY + 100 * S + 34, '50 mm', 24, { a: 'middle' });
// labels on the right
const rows = [
  ['#2563eb', '180 mm  (now)', 'USB-C cable turns 90 degrees', 'Easiest on the cable. 195 mm corner to corner.'],
  ['#16a34a', '148 mm', 'cable turns 135 degrees', 'Smallest base that still avoids the full wrap-around.'],
  ['#d97706', '140 mm  (dashed)', 'cable turns about 165 to 180 degrees', 'Close to the old wrap-around. 90 degrees does NOT fit.'],
  ['#9ca3af', '130 mm  (dashed)', 'wrap-around (180 degrees) only', '90 degrees does NOT fit.'],
  ['#dc2626', '115 mm  (first design)', 'full wrap-around, 180 degrees', 'About 1 mm of spare cable. Most stress on the cable.'],
];
rows.forEach((r, i) => {
  const y = 190 + i * 150;
  s += `<rect x="960" y="${y - 30}" width="36" height="36" fill="${r[0]}"/>`;
  s += t(1012, y - 2, r[1], 28, { b: 1 }) + t(1012, y + 32, r[2], 23) + t(1012, y + 62, r[3], 20, { fill: '#555' });
});
s += t(40, H - 60, 'Why not smaller with a 90 degree bend: the Neutrik cable has a 54 mm stiff end and a 37 mm stiff plug end that cannot bend.', 21, { fill: '#444' });
s += t(40, H - 30, 'Together with the Nano (43 mm) they form an L about 85 mm long, and the octagon corners cut it off. Cable sizes are +-3 mm (photos).', 21, { fill: '#444' });
s += '</svg>';
const svg = path.join(root, 'docs/images/size-compare.svg');
fs.writeFileSync(svg, s);
const r = spawnSync('rsvg-convert', ['-o', path.join(root, 'docs/images/size-compare.png'), svg], { encoding: 'utf8' });
console.log(r.status === 0 ? 'wrote docs/images/size-compare.png' : r.stderr);
