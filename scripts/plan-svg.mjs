// Labelled top-down plan of the base, drawn from the CAD numbers (nothing typed by hand except labels).
// usage: nix shell nixpkgs#openscad nixpkgs#librsvg -c node scripts/plan-svg.mjs      -> docs/images/base-plan.svg + .png
import fs from 'fs';
import os from 'os';
import path from 'path';
import { spawnSync } from 'child_process';

const root = path.resolve(path.dirname(new URL(import.meta.url).pathname), '..');
const names = ['base_flat', 'base_wall', 'usbc_x', 'xlr_along', 'xlr_angle', 'key_y', 'key_dx', 'boss_r', 'cab_dir', 'cab_a', 'cab_b', 'cab_row', 'cab_bend_r', 'cab_r',
  'nano_port_x', 'nano_far_x', 'usb_yb', 'usbj_body_len', 'usbj_body_d', 'usbj_relief_d', 'xlr_depth', 'xlr_body_d', 'plug_w', 'plug_exposed', 'nano_w', 'nano_l',
  'max485_cx', 'max485_cy', 'max485_w', 'max485_l', 'max485_rot', 'tmc_cx', 'tmc_cy', 'tmc_l', 'tmc_w', 'tmc_rot', 'mt_board', 'motor_od', 'key_head', 'key_slot', 'key_slot_len', 'motor_lead_angle', 'boss_angles'];
const tmp = fs.mkdtempSync(path.join(process.env.TMPDIR || os.tmpdir(), 'plan-'));
fs.writeFileSync(path.join(tmp, 'd.scad'), `include <${root}/cad/params.scad>
include <${root}/cad/lib.scad>
echo(J = [${names.join(', ')}]);
echo(A = pieceA()); echo(B1 = pieceB1()); echo(B2 = pieceB2());
cube(1);`);
const r = spawnSync('openscad', ['-o', path.join(tmp, 'x.stl'), path.join(tmp, 'd.scad')], { encoding: 'utf8' });
const txt = (r.stdout || '') + (r.stderr || '');
const get = k => { const m = txt.match(new RegExp('ECHO: ' + k + ' = (\\[.*\\])')); if (!m) throw new Error('no ' + k + ' in openscad output:\n' + txt.slice(0, 600)); return JSON.parse(m[1].replace(/\bundef\b/g, 'null')); };
const V = Object.fromEntries(get('J').map((v, i) => [names[i], v])), A = get('A'), B1 = get('B1'), B2 = get('B2');
const { base_flat: F, base_wall: wall } = V;

// ---- drawing helpers: 1 mm = S px, y flipped ----
const S = 7, W = 1500, H = 1950, CX = W / 2, CY = 800;
const X = x => (CX + x * S).toFixed(1), Y = y => (CY - y * S).toFixed(1);
const FONT = 'font-family="DejaVu Sans, Arial, sans-serif"';
const rect = (x0, y0, x1, y1, st) => `<rect x="${X(x0)}" y="${Y(y1)}" width="${((x1 - x0) * S).toFixed(1)}" height="${((y1 - y0) * S).toFixed(1)}" ${st}/>`;
const circ = (x, y, rad, st) => `<circle cx="${X(x)}" cy="${Y(y)}" r="${(rad * S).toFixed(1)}" ${st}/>`;
const text = (x, y, s, o = {}) => `<text ${o.halo ? 'paint-order="stroke" stroke="#fff" stroke-width="6" stroke-linejoin="round"' : ''} x="${X(x)}" y="${Y(y)}" ${FONT} font-size="${o.size || 22}" font-weight="${o.bold ? 700 : 400}" fill="${o.fill || '#111'}" text-anchor="${o.anchor || 'middle'}">${s}</text>`;
const poly = (pts, st) => `<polygon points="${pts.map(p => X(p[0]) + ',' + Y(p[1])).join(' ')}" ${st}/>`;
const octo = af => { const rr = af / 2 / Math.cos(Math.PI / 8); return [...Array(8)].map((_, k) => { const a = (22.5 + 45 * k) * Math.PI / 180; return [rr * Math.cos(a), rr * Math.sin(a)]; }); };
const board = (p, fill) => {
  const [cx, cy, w, l, c] = p, x0 = cx - w / 2, x1 = cx + w / 2, y0 = cy - l / 2, y1 = cy + l / 2;
  const pts = [[x0 + c[0], y0], [x1 - c[1], y0], ...(c[1] ? [[x1, y0 + c[1]]] : []), ...(c[2] ? [[x1, y1 - c[2]], [x1 - c[2], y1]] : [[x1, y1]]), ...(c[3] ? [[x0 + c[3], y1], [x0, y1 - c[3]]] : [[x0, y1]]), ...(c[0] ? [[x0, y0 + c[0]]] : [])];
  return poly(pts, `fill="${fill}" stroke="#1d5c36" stroke-width="3"`);
};
const badge = (x, y, n) => circ(x, y, 2.6, 'fill="#fff" stroke="#111" stroke-width="3"') + text(x, y - 1, String(n), { size: 24, bold: true });

let s = `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}"><rect width="${W}" height="${H}" fill="#fff"/>`;
s += text(0, 108, 'LOOKING DOWN INTO THE OPEN BASE (before the front plate goes on). Grid squares = 10 mm.', { size: 26, bold: true });
for (let g = -90; g <= 90; g += 10) s += `<line x1="${X(g)}" y1="${Y(-95)}" x2="${X(g)}" y2="${Y(95)}" stroke="#eee"/><line x1="${X(-95)}" y1="${Y(g)}" x2="${X(95)}" y2="${Y(g)}" stroke="#eee"/>`;
s += poly(octo(F), 'fill="#e9ecef" stroke="#555" stroke-width="3"') + poly(octo(F - 2 * wall), 'fill="#fff" stroke="#999" stroke-width="2"');

// USB-C jack (bottom wall)
const wb = -F / 2, jx = V.usbc_x, dir = V.cab_dir, R = V.cab_bend_r;
s += rect(jx - V.usbj_body_d / 2, wb, jx + V.usbj_body_d / 2, wb + V.usbj_body_len, 'fill="#b9bec6" stroke="#555" stroke-width="2"');
s += rect(jx - V.usbj_relief_d / 2, wb + V.usbj_body_len, jx + V.usbj_relief_d / 2, V.usb_yb, 'fill="#9aa0a8" stroke="#555" stroke-width="2"');
// XLR on its facet: draw in a rotated frame (origin on the outer face, +y into the base)
const xa = V.xlr_angle * Math.PI / 180;
const rotXY = (x, y) => [x * Math.cos(xa) - y * Math.sin(xa), x * Math.sin(xa) + y * Math.cos(xa)];
{
  const pt = (lx, ly) => rotXY(V.xlr_along + lx, -F / 2 + ly);
  s += poly([pt(-V.xlr_body_d / 2, 0), pt(V.xlr_body_d / 2, 0), pt(V.xlr_body_d / 2, V.xlr_depth), pt(-V.xlr_body_d / 2, V.xlr_depth)], 'fill="#b9bec6" stroke="#555" stroke-width="2"');
}
// USB-C cable: jack -> straight up -> ONE quarter bend -> straight -> plug into the Nano port
const cy0 = V.usb_yb + V.cab_a, row = V.cab_row;
s += `<path d="M ${X(jx)} ${Y(V.usb_yb)} L ${X(jx)} ${Y(cy0)} A ${R * S} ${R * S} 0 0 ${dir > 0 ? 1 : 0} ${X(jx + dir * R)} ${Y(row)} L ${X(jx + dir * (R + V.cab_b))} ${Y(row)}" fill="none" stroke="#222" stroke-width="${V.cab_r * 2 * S}" stroke-linecap="butt"/>`;
const pxa = jx + dir * (R + V.cab_b);
s += rect(Math.min(pxa, V.nano_port_x), row - V.plug_w / 2, Math.max(pxa, V.nano_port_x), row + V.plug_w / 2, 'fill="#444" stroke="#111" stroke-width="2"');

// perfboard pieces and modules
s += board(A, '#9fd8b0') + board(B1, '#9fd8b0') + board(B2, '#9fd8b0');
const nx0 = Math.min(V.nano_port_x, V.nano_far_x), nx1 = Math.max(V.nano_port_x, V.nano_far_x);
s += rect(nx0, row - V.nano_w / 2, nx1, row + V.nano_w / 2, 'fill="#3b5fb0" stroke="#17306b" stroke-width="3"');
const mw = V.max485_rot === 0 ? V.max485_w : V.max485_l, ml = V.max485_rot === 0 ? V.max485_l : V.max485_w;
s += rect(V.max485_cx - mw / 2, V.max485_cy - ml / 2, V.max485_cx + mw / 2, V.max485_cy + ml / 2, 'fill="#4aa3df" stroke="#17506f" stroke-width="3"');
const tw = V.tmc_rot === 0 ? V.tmc_l : V.tmc_w, tl = V.tmc_rot === 0 ? V.tmc_w : V.tmc_l;
s += rect(V.tmc_cx - tw / 2, V.tmc_cy - tl / 2, V.tmc_cx + tw / 2, V.tmc_cy + tl / 2, 'fill="#e04a4a" stroke="#7a1f1f" stroke-width="3"');

// posts, keyholes, motor, sensor board
for (const ad of V.boss_angles) { const a = ad * Math.PI / 180; s += circ(V.boss_r * Math.cos(a), V.boss_r * Math.sin(a), 3.5, 'fill="#c9ced4" stroke="#555" stroke-width="2"'); }
for (const sx of [-1, 1]) { s += circ(sx * V.key_dx / 2, V.key_y, V.key_head / 2, 'fill="#fff" stroke="#555" stroke-width="2"'); s += rect(sx * V.key_dx / 2 - V.key_slot / 2, V.key_y - V.key_slot_len, sx * V.key_dx / 2 + V.key_slot / 2, V.key_y, 'fill="#fff" stroke="#555" stroke-width="2"'); }
s += circ(0, 0, V.motor_od / 2, 'fill="rgba(245,150,40,0.20)" stroke="#d07a10" stroke-width="4" stroke-dasharray="14 8"');
s += rect(-V.mt_board / 2, -V.mt_board / 2, V.mt_board / 2, V.mt_board / 2, 'fill="rgba(30,130,70,0.30)" stroke="#1d6b3a" stroke-width="3" stroke-dasharray="8 6"');
s += circ(0, 0, 2.75, 'fill="#fff" stroke="#333" stroke-width="2"');
const sa = V.motor_lead_angle * Math.PI / 180, sx0 = 17 * Math.cos(sa), sy0 = 17 * Math.sin(sa), sx1 = 24 * Math.cos(sa), sy1 = 24 * Math.sin(sa);
s += `<line x1="${X(sx0)}" y1="${Y(sy0)}" x2="${X(sx1)}" y2="${Y(sy1)}" stroke="#d07a10" stroke-width="${8 * S}" stroke-linecap="butt" opacity="0.9"/>`;

// wires (dashed)
const dash = (x0, y0, x1, y1, col) => `<line x1="${X(x0)}" y1="${Y(y0)}" x2="${X(x1)}" y2="${Y(y1)}" stroke="${col}" stroke-width="5" stroke-dasharray="3 9" stroke-linecap="round"/>`;
s += dash((sx0 + sx1) / 2, (sy0 + sy1) / 2, V.tmc_cx, V.tmc_cy + tl / 2 - 2, '#d07a10');                              // motor lead -> TMC6300
const xlrPt = rotXY(V.xlr_along, -F / 2 + 12);
s += dash(V.max485_cx - mw / 2 + 4, V.max485_cy + 2, xlrPt[0], xlrPt[1] - 4, '#8e44ad');                              // MAX485 -> XLR
s += dash(3, -9, V.nano_port_x + dir * 6, row - 7, '#1d6b3a');                                                          // display wires -> Nano

// labels
s += text(V.nano_port_x + dir * V.nano_l / 2, row + 2.2, 'ARDUINO NANO', { size: 22, fill: '#fff', bold: true });
s += text(V.nano_port_x + dir * 6, row - 3.2, 'USB-C port', { size: 17, fill: '#fff' });
s += text(V.nano_far_x - dir * 8, row - 3.2, 'antenna', { size: 17, fill: '#fff' });
s += text(V.max485_cx, V.max485_cy - 1, 'MAX485', { size: 24, fill: '#06304a', bold: true });
s += text(V.max485_cx + mw / 2 - 9, V.max485_cy + 3.5, 'DI DE RE RO', { size: 17, fill: '#06304a' });
s += text(V.max485_cx - mw / 2 + 9, V.max485_cy + 3.5, 'GND A B VCC', { size: 17, fill: '#06304a' });
s += text(V.tmc_cx, V.tmc_cy - 1, 'TMC6300', { size: 20, fill: '#fff', bold: true });
s += text(jx, wb + 12, 'USB-C', { size: 22, bold: true }) + text(jx, wb + 8.8, 'jack', { size: 22, bold: true });
{ const p = rotXY(V.xlr_along, -F / 2 + 12); s += text(p[0], p[1] - 3, 'XLR (DMX out)', { size: 22, bold: true }); }
s += text(jx - 4, V.usb_yb + V.cab_a / 2 + 2, 'USB-C cable', { size: 21, halo: true, anchor: 'end' }) + text(jx - 4, V.usb_yb + V.cab_a / 2 - 1, 'one 90 degree bend', { size: 19, halo: true, anchor: 'end' });
s += badge(-14, 14, 1); s += badge(14, -14, 2); s += badge(0, 0, 3); s += badge((sx0 + sx1) / 2 - 13, (sy0 + sy1) / 2 + 3, 4);
s += badge(-V.key_dx / 2, V.key_y + 6, 5);
const b0 = V.boss_angles[0] * Math.PI / 180; s += badge(V.boss_r * Math.cos(b0) - 8, V.boss_r * Math.sin(b0) + 2, 6);
s += badge(14, F / 2 - 18, 7);
const key = [
  [1, 'MOTOR: sits on TOP of the front plate (dashed circle)'],
  [2, 'MT6701 sensor board: under the motor (column foot)'],
  [3, 'Middle hole: display wires go DOWN here, then to the Nano'],
  [4, 'Motor lead: drops through the plate slot (orange bar) onto the TMC6300'],
  [5, 'Wall-hanging keyholes (hang the box on two screws)'],
  [6, 'Front-plate screw posts (4, in the corners of the left and right walls)'],
  [7, 'MAX485 to XLR: 3 wires (A, B, GND), purple dashed'],
];
key.forEach(([n, t], i) => { s += badge(-69, -102 - i * 5.4, n) + text(-65, -103.2 - i * 5.4, t, { size: 21, anchor: 'start' }); });
const lg = [['#3b5fb0', 'Nano'], ['#4aa3df', 'MAX485'], ['#e04a4a', 'TMC6300'], ['#9fd8b0', 'perfboard: 3 pieces']];
lg.forEach((e, i) => { s += `<rect x="1060" y="${1590 + i * 34}" width="24" height="24" fill="${e[0]}"/><text x="1094" y="${1609 + i * 34}" ${FONT} font-size="20" fill="#111">${e[1]}</text>`; });
s += `<line x1="1060" y1="1745" x2="1084" y2="1745" stroke="#d07a10" stroke-width="5" stroke-dasharray="3 9"/><text x="1094" y="1751" ${FONT} font-size="20">motor lead</text>`;
s += `<line x1="1060" y1="1779" x2="1084" y2="1779" stroke="#1d6b3a" stroke-width="5" stroke-dasharray="3 9"/><text x="1094" y="1785" ${FONT} font-size="20">display wires to the Nano</text>`;
s += '</svg>';

const out = path.join(root, 'docs/images/base-plan.svg');
fs.writeFileSync(out, s);
const png = spawnSync('rsvg-convert', ['-o', path.join(root, 'docs/images/base-plan.png'), out], { encoding: 'utf8' });
console.log(png.status === 0 ? 'wrote docs/images/base-plan.svg + .png' : 'rsvg-convert failed: ' + png.stderr);
