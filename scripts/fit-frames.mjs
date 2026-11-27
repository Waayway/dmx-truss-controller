// Builds the two fit-test frames: solves the cable layout and the MAX485 / TMC6300 piece positions, then renders cad/fit-frame.scad.
// usage: nix shell nixpkgs#openscad -c node scripts/fit-frames.mjs
import { spawnSync } from 'child_process';
import path from 'path';
import fs from 'fs';
import { bestLayout, placeModules, wallSlack } from './lib-cable.mjs';

const root = path.resolve(path.dirname(new URL(import.meta.url).pathname), '..');
const specs = [
  { name: 'fit-170-90', size: 170, phi: 90, flex: 72, clr: 3 },
  { name: 'fit-140-145', size: 140, phi: 145, flex: 75, clr: 2 },
];
fs.mkdirSync(path.join(root, 'cad/stl/fit'), { recursive: true });
for (const sp of specs) {
  const L = bestLayout(sp.size, sp.phi, sp.flex, sp.clr);
  if (!L) { console.log(sp.name + ': no cable layout'); continue; }
  const P = placeModules(sp.size, L, sp.clr);
  if (!P) { console.log(sp.name + ': cable fits, but no room for the MAX485 and TMC6300 pieces'); continue; }
  const args = ['-D', `size=${sp.size}`, '-D', `phi=${sp.phi}`, '-D', `flex=${sp.flex}`, '-D', `jack_x=${L.jx}`, '-D', `a_str=${L.a}`, '-D', `r_bend=${L.R}`, '-D', `side=${L.s}`,
    '-D', `mx_cx=${P.mx.x}`, '-D', `mx_cy=${P.mx.y}`, '-D', `mx_rot=${P.mx.rot}`, '-D', `tm_cx=${P.tm.x}`, '-D', `tm_cy=${P.tm.y}`, '-D', `tm_rot=${P.tm.rot}`,
    '-o', path.join(root, `cad/stl/fit/${sp.name}.stl`), path.join(root, 'cad/fit-frame.scad')];
  const r = spawnSync('openscad', args, { encoding: 'utf8' });
  const out = (r.stdout || '') + (r.stderr || '');
  const vol = (out.match(/Volumes:\s+(\d+)/) || [])[1];
  console.log(`${sp.name}: ${r.status === 0 ? 'ok' : 'FAILED'}  Nano slack ${wallSlack(sp.size, [...L.nano, ...L.plug]).toFixed(1)} mm, jack x=${L.jx}, a=${L.a}, b=${L.b.toFixed(1)}, R=${L.R}; MAX485 ${P.mx.rot === 90 ? 'along x' : 'along y'} at (${P.mx.x},${P.mx.y}), TMC6300 ${P.tm.rot === 90 ? 'along y' : 'along x'} at (${P.tm.x},${P.tm.y}); Volumes ${vol} (2 = one connected solid)`);
  if (r.status !== 0) console.log(out.split('\n').filter(l => /ERROR|ssert|WARNING/.test(l)).join('\n'));
}
