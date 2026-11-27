// Labelled top-down plan of the base, drawn from the CAD numbers (nothing typed by hand except labels).
// usage: nix shell nixpkgs#openscad nixpkgs#librsvg -c node scripts/plan-svg.mjs      -> docs/images/base-plan.svg + .png
import fs from 'fs';
import os from 'os';
import path from 'path';
import { spawnSync } from 'child_process';

const root = path.resolve(path.dirname(new URL(import.meta.url).pathname), '..');
// ---- pull derived numbers out of the CAD ----
const tmp = fs.mkdtempSync(path.join(process.env.TMPDIR || os.tmpdir(), 'plan-'));
fs.writeFileSync(path.join(tmp, 'd.scad'), `include <${root}/cad/params.scad>
include <${root}/cad/lib.scad>
echo(J = [base_flat, base_wall, usbc_x, xlr_along, key_y, key_dx, boss_r, nano_x, nano_y_end, nano_y_port, cab_a, usb_yb, cab_bend_r, cab_r, usbj_body_len, usbj_body_d, usbj_relief_d, xlr_depth, xlr_body_d, plug_w, nano_w, nano_l, max485_cx, max485_cy, max485_w, max485_l, tmc_cx, tmc_cy, tmc_l, tmc_w, mt_board, motor_od, motor_boss_d, key_head, key_slot, key_slot_len, plug_exposed, motor_lead_angle]);
echo(A = pieceA()); echo(B1 = pieceB1()); echo(B2 = pieceB2());
cube(1);`);
const r = spawnSync('openscad', ['-o', path.join(tmp, 'x.stl'), path.join(tmp, 'd.scad')], { encoding: 'utf8' });
const txt = (r.stdout || '') + (r.stderr || '');
const get = k => { const m = txt.match(new RegExp('ECHO: ' + k + ' = (\\[.*\\])')); if (!m) throw new Error('no ' + k + ' in openscad output:\n' + txt.slice(0, 500)); return JSON.parse(m[1].replace(/(\d)e/g, '$1e')); };
const J = get('J'), A = get('A'), B1 = get('B1'), B2 = get('B2');
const [F, wall, usbcX, xlrAlong, keyY, keyDx, bossR, nanoX, nanoY0, nanoY1, cabA, usbYb, bendR, cabR, bodyLen, bodyD, reliefD, xlrDepth, xlrD, plugW, nanoW, nanoL, mxX, mxY, mxW, mxL, tmX, tmY, tmL, tmW, mtB, motorD, bossD, keyHead, keySlot, keySlotLen, plugLen, leadAng] = J;

// ---- drawing helpers: 1 mm = S px, y flipped ----
const S = 10, W = 1500, H = 1900, CX = W / 2, CY = 790;
const X = x => (CX + x * S).toFixed(1), Y = y => (CY - y * S).toFixed(1);
const rect = (x0, y0, x1, y1, st) => `<rect x="${X(x0)}" y="${Y(y1)}" width="${((x1 - x0) * S).toFixed(1)}" height="${((y1 - y0) * S).toFixed(1)}" ${st}/>`;
const circ = (x, y, rad, st) => `<circle cx="${X(x)}" cy="${Y(y)}" r="${(rad * S).toFixed(1)}" ${st}/>`;
const text = (x, y, s, o = {}) => `<text ${o.halo ? 'paint-order="stroke" stroke="#fff" stroke-width="6" stroke-linejoin="round"' : ''} x="${X(x)}" y="${Y(y)}" font-family="DejaVu Sans, Arial, sans-serif" font-size="${o.size || 22}" font-weight="${o.bold ? 700 : 400}" fill="${o.fill || '#111'}" text-anchor="${o.anchor || 'middle'}">${s}</text>`;
const label = (x, y, lines, o = {}) => lines.map((l, i) => text(x, y - i * (o.lh || 2.6), l, { ...o, bold: o.bold && i === 0 })).join('');
const poly = (pts, st) => `<polygon points="${pts.map(p => X(p[0]) + ',' + Y(p[1])).join(' ')}" ${st}/>`;
const octo = af => { const rr = af / 2 / Math.cos(Math.PI / 8); return [...Array(8)].map((_, k) => { const a = (22.5 + 45 * k) * Math.PI / 180; return [rr * Math.cos(a), rr * Math.sin(a)]; }); };
const board = (p, fill) => { // [cx, cy, w, l, [bl, br, tr, tl chamfers]]
  const [cx, cy, w, l, c] = p, x0 = cx - w / 2, x1 = cx + w / 2, y0 = cy - l / 2, y1 = cy + l / 2;
  const pts = [[x0 + c[0], y0], [x1 - c[1], y0], ...(c[1] ? [[x1, y0 + c[1]]] : []), ...(c[2] ? [[x1, y1 - c[2]], [x1 - c[2], y1]] : [[x1, y1]]), ...(c[3] ? [[x0 + c[3], y1], [x0, y1 - c[3]]] : [[x0, y1]]), ...(c[0] ? [[x0, y0 + c[0]]] : [])];
  return poly(pts, `fill="${fill}" stroke="#1d5c36" stroke-width="3"`);
};

let s = `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}"><rect width="${W}" height="${H}" fill="#fff"/>`;
s += text(0, 66, 'LOOKING DOWN INTO THE OPEN BASE (before the front plate goes on). Grid squares = 10 mm.', { size: 26, bold: true });
for (let g = -50; g <= 50; g += 10) s += `<line x1="${X(g)}" y1="${Y(-60)}" x2="${X(g)}" y2="${Y(60)}" stroke="#eee"/><line x1="${X(-60)}" y1="${Y(g)}" x2="${X(60)}" y2="${Y(g)}" stroke="#eee"/>`;
s += poly(octo(F), 'fill="#e9ecef" stroke="#555" stroke-width="3"') + poly(octo(F - 2 * wall), 'fill="#fff" stroke="#999" stroke-width="2"');

// jacks (what is in the walls)
const wallBottom = -F / 2, wallRight = F / 2;
s += rect(usbcX - bodyD / 2, wallBottom, usbcX + bodyD / 2, wallBottom + bodyLen, 'fill="#b9bec6" stroke="#555" stroke-width="2"');
s += rect(usbcX - reliefD / 2, wallBottom + bodyLen, usbcX + reliefD / 2, usbYb, 'fill="#9aa0a8" stroke="#555" stroke-width="2"');
s += rect(wallRight - xlrDepth, xlrAlong - xlrD / 2, wallRight, xlrAlong + xlrD / 2, 'fill="#b9bec6" stroke="#555" stroke-width="2"');
// USB-C cable: jack -> straight up -> U-turn -> down into the Nano's port
const cy = usbYb + cabA, ccx = usbcX - bendR;
s += `<path d="M ${X(usbcX)} ${Y(usbYb)} L ${X(usbcX)} ${Y(cy)} A ${bendR * S} ${bendR * S} 0 0 0 ${X(usbcX - 2 * bendR)} ${Y(cy)} L ${X(usbcX - 2 * bendR)} ${Y(nanoY1 + plugLen)}" fill="none" stroke="#222" stroke-width="${cabR * 2 * S}" stroke-linecap="butt"/>`;
s += rect(nanoX - plugW / 2, nanoY1, nanoX + plugW / 2, nanoY1 + plugLen, 'fill="#444" stroke="#111" stroke-width="2"');

// perfboard pieces (green) and the modules on them
s += board(A, '#9fd8b0') + board(B1, '#9fd8b0') + board(B2, '#9fd8b0');
s += rect(nanoX - nanoW / 2, nanoY0, nanoX + nanoW / 2, nanoY1, 'fill="#3b5fb0" stroke="#17306b" stroke-width="3"');
s += rect(mxX - mxW / 2, mxY - mxL / 2, mxX + mxW / 2, mxY + mxL / 2, 'fill="#4aa3df" stroke="#17506f" stroke-width="3"');
s += rect(tmX - tmL / 2, tmY - tmW / 2, tmX + tmL / 2, tmY + tmW / 2, 'fill="#e04a4a" stroke="#7a1f1f" stroke-width="3"');

// things above: motor (dashed), plate hole, sensor board, screw posts, keyholes
for (let i = 0; i < 4; i++) { const a = (67.5 + 90 * i) * Math.PI / 180; s += circ(bossR * Math.cos(a), bossR * Math.sin(a), 3.5, 'fill="#c9ced4" stroke="#555" stroke-width="2"'); }
for (const sx of [-1, 1]) { s += circ(sx * keyDx / 2, keyY, keyHead / 2, 'fill="#fff" stroke="#555" stroke-width="2"'); s += rect(sx * keyDx / 2 - keySlot / 2, keyY - keySlotLen, sx * keyDx / 2 + keySlot / 2, keyY, 'fill="#fff" stroke="#555" stroke-width="2"'); }
s += circ(0, 0, motorD / 2, 'fill="rgba(245,150,40,0.20)" stroke="#d07a10" stroke-width="4" stroke-dasharray="14 8"');
s += rect(-mtB / 2, -mtB / 2, mtB / 2, mtB / 2, 'fill="rgba(30,130,70,0.30)" stroke="#1d6b3a" stroke-width="3" stroke-dasharray="8 6"');
s += circ(0, 0, 2.75, 'fill="#fff" stroke="#333" stroke-width="2"');
// motor lead slot at 30 degrees, r 17..24
const sa = leadAng * Math.PI / 180, sx0 = 17 * Math.cos(sa), sy0 = 17 * Math.sin(sa), sx1 = 24 * Math.cos(sa), sy1 = 24 * Math.sin(sa);
s += `<line x1="${X(sx0)}" y1="${Y(sy0)}" x2="${X(sx1)}" y2="${Y(sy1)}" stroke="#d07a10" stroke-width="${8 * S}" stroke-linecap="butt" opacity="0.9"/>`;

// wires (dashed)
const dash = (x0, y0, x1, y1, col) => `<line x1="${X(x0)}" y1="${Y(y0)}" x2="${X(x1)}" y2="${Y(y1)}" stroke="${col}" stroke-width="5" stroke-dasharray="3 9" stroke-linecap="round"/>`;
s += dash((sx0 + sx1) / 2, (sy0 + sy1) / 2, tmX - tmL / 2 + 3, tmY + tmW / 2 - 1, '#d07a10');                  // motor lead
s += dash(mxX + 1, mxY - mxL / 2, wallRight - xlrDepth, xlrAlong + 3, '#8e44ad');                   // MAX485 -> XLR
s += dash(-1, -6, nanoX + nanoW / 2 - 1, nanoY0 + 25, '#1d6b3a');                                    // display wires -> Nano

// labels: short names inside the shapes, numbered badges for the rest (key below the drawing)
const badge = (x, y, n) => circ(x, y, 1.9, 'fill="#fff" stroke="#111" stroke-width="3"') + text(x, y - 0.75, String(n), { size: 24, bold: true });
s += label(nanoX, nanoY1 - 4.5, ['NANO', 'USB-C port end \u25B2'], { size: 21, fill: '#fff', bold: true, lh: 2.7, halo: false });
s += text(nanoX, nanoY0 + 4, 'antenna end', { size: 19, fill: '#fff' });
s += text(mxX, mxY + 1, 'MAX485', { size: 24, fill: '#06304a', bold: true });
s += text(mxX, mxY + mxL / 2 - 3.6, 'DI DE RE RO', { size: 19, fill: '#06304a' });
s += text(mxX, mxY - mxL / 2 + 2.6, 'GND A B VCC', { size: 19, fill: '#06304a' });
s += text(tmX, tmY - 1, 'TMC6300', { size: 22, fill: '#fff', bold: true });
s += label(usbcX, wallBottom + 10, ['USB-C', 'jack'], { size: 22, bold: true, lh: 2.6 });
s += label(wallRight - 14, xlrAlong + 1.5, ['XLR', 'DMX out'], { size: 22, bold: true, lh: 2.6 });
s += text(usbcX - bendR, cy + bendR + 4.2, 'USB-C cable', { size: 21, halo: true });
s += text(nanoX, nanoY1 + 16, 'plug end', { size: 17, fill: '#fff' });
s += badge(-11.5, 11.5, 1);                                   // motor
s += badge(10.5, -10.5, 2);                                   // sensor board
s += badge(0, 0, 3);                                          // centre hole
s += badge((sx0 + sx1) / 2 - 4.2, (sy0 + sy1) / 2, 4);        // lead slot
s += badge(-keyDx / 2, keyY + 6, 5);                          // keyhole
const b0 = (67.5 + 180) * Math.PI / 180; s += badge(bossR * Math.cos(b0) + 5.5, bossR * Math.sin(b0) + 3, 6);   // screw post
s += badge(wallRight - 13, 14, 7);                            // XLR wires
// key
const key = [
  [1, 'MOTOR: sits on TOP of the front plate (dashed circle)'],
  [2, 'MT6701 sensor board: under the motor (column foot)'],
  [3, 'Middle hole: display wires go DOWN here, then to the Nano'],
  [4, 'Motor lead: drops through the plate slot (orange bar)'],
  [5, 'Wall-hanging keyholes (hang the box on two screws)'],
  [6, 'Front-plate screw posts (4)'],
  [7, 'MAX485 to XLR: 3 wires (A, B, GND), purple dashed'],
];
key.forEach(([n, t], i) => { s += badge(-66, -62 - i * 4.4, n) + text(-62.5, -62.8 - i * 4.4, t, { size: 21, anchor: 'start' }); });

const lg = [['#3b5fb0', 'Nano'], ['#4aa3df', 'MAX485'], ['#e04a4a', 'TMC6300'], ['#9fd8b0', 'perfboard: 3 pieces']];
lg.forEach((e, i) => { s += '<rect x="1060" y="' + (1500 + i * 34) + '" width="24" height="24" fill="' + e[0] + '"/><text x="1094" y="' + (1519 + i * 34) + '" font-family="DejaVu Sans, Arial, sans-serif" font-size="20" fill="#111">' + e[1] + '</text>'; });
s += '<line x1="1060" y1="1655" x2="1084" y2="1655" stroke="#d07a10" stroke-width="5" stroke-dasharray="3 9"/><text x="1094" y="1661" font-family="DejaVu Sans, Arial, sans-serif" font-size="20">motor lead</text>';
s += '<line x1="1060" y1="1689" x2="1084" y2="1689" stroke="#1d6b3a" stroke-width="5" stroke-dasharray="3 9"/><text x="1094" y="1695" font-family="DejaVu Sans, Arial, sans-serif" font-size="20">display wires to the Nano</text>';
s += '</svg>';

const out = path.join(root, 'docs/images/base-plan.svg');
fs.writeFileSync(out, s);
const png = spawnSync('rsvg-convert', ['-o', path.join(root, 'docs/images/base-plan.png'), out], { encoding: 'utf8' });
console.log(png.status === 0 ? 'wrote docs/images/base-plan.svg + .png' : 'rsvg-convert failed: ' + png.stderr);
