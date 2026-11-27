// Diamond knurl for the ring: a lattice of raised diamond (pyramid-frustum) bumps on the ring's outside.
// Written as its own STL because it is the ACCENT-COLOUR part of the two-colour print (see make-3mf.mjs); the ring body is cad/ring.scad.
// The bumps are 200 separate closed solids (5 staggered rows x 40), so no boolean operations are needed and it runs in milliseconds.
// usage: node scripts/knurl.mjs            writes cad/stl/ring-ribs.stl and merges body + ribs into cad/stl/ring.stl
import fs from 'fs';
import path from 'path';

const root = path.resolve(path.dirname(new URL(import.meta.url).pathname), '..');
const params = fs.readFileSync(path.join(root, 'cad/params.scad'), 'utf8');
const num = name => { const m = params.match(new RegExp('^' + name + '\\s*=\\s*([0-9.]+)', 'm')); if (!m) throw new Error('params.scad: ' + name + ' not found'); return +m[1]; };
const R = num('ring_od') / 2;       // ring outside radius = floor of the grooves
const H = num('ring_h');            // ring height

// ---- knurl design (PROPOSALS, untested) ----
const N      = 40;                  // diamonds around the ring
const ROWS   = 5;                   // rows of diamonds, every other row shifted half a diamond sideways
const BUMP_H = 0.8;                 // how far a diamond stands proud
const FILL   = 0.88;                // base size as a fraction of the lattice cell: 12 % of the cell stays as a groove (about 0.5 mm)
const TOP    = 0.3;                 // flat top as a fraction of the base: sides lean about 32 degrees from vertical, so they print without supports
const pu = 2 * Math.PI * R / N;     // lattice pitch around the ring, mm at the surface
const pz = H / (ROWS + 1);          // row spacing along the axis: ROWS rows leave half a row of margin at both ends... see zc below
const au = FILL * pu / 2;           // half-width of a diamond base
const az = FILL * pz;               // half-height of a diamond base (cells are pu wide and 2*pz tall in the same row; rows interlock)
// rows centred on z = pz, 2 pz, ... ROWS*pz, with the half cell as margin: bump tops reach z = H - (pz - az)
const pt = (u, z, h) => { const a = u / R, r = R + h; return [r * Math.cos(a), r * Math.sin(a), z]; };

const tris = [];
let solids = 0, flipped = 0;
for (let row = 0; row < ROWS; row++) {
  const zc = (row + 1) * pz;
  for (let i = 0; i < N; i++) {
    const uc = (i + (row % 2) * 0.5) * pu;
    const ring = (s, h) => [[uc - s * au, zc], [uc, zc - s * az], [uc + s * au, zc], [uc, zc + s * az]].map(([u, z]) => pt(u, z, h));
    const b = ring(1, 0), t = ring(TOP, BUMP_H);
    const f = [];
    f.push([b[0], b[3], b[2]], [b[0], b[2], b[1]]);            // base (faces inward)
    f.push([t[0], t[1], t[2]], [t[0], t[2], t[3]]);            // top (faces outward)
    for (let k = 0; k < 4; k++) { const k1 = (k + 1) % 4; f.push([b[k], b[k1], t[k1]], [b[k], t[k1], t[k]]); }
    let vol = 0;
    for (const [p, q, r] of f) vol += (p[0] * (q[1] * r[2] - q[2] * r[1]) - p[1] * (q[0] * r[2] - q[2] * r[0]) + p[2] * (q[0] * r[1] - q[1] * r[0])) / 6;
    if (vol < 0) { flipped++; for (const tr of f) { const x = tr[1]; tr[1] = tr[2]; tr[2] = x; } }
    tris.push(...f); solids++;
  }
}

const stl = (name, list) => {
  let s = 'solid ' + name + '\n';
  for (const [p, q, r] of list) {
    const u = [q[0] - p[0], q[1] - p[1], q[2] - p[2]], v = [r[0] - p[0], r[1] - p[1], r[2] - p[2]];
    let n = [u[1] * v[2] - u[2] * v[1], u[2] * v[0] - u[0] * v[2], u[0] * v[1] - u[1] * v[0]];
    const l = Math.hypot(...n) || 1; n = n.map(x => x / l);
    s += `  facet normal ${n.map(x => x.toFixed(6)).join(' ')}\n    outer loop\n` + [p, q, r].map(x => `      vertex ${x.map(y => y.toFixed(5)).join(' ')}\n`).join('') + '    endloop\n  endfacet\n';
  }
  return s + 'endsolid ' + name + '\n';
};
const out = path.join(root, 'cad/stl');
fs.mkdirSync(out, { recursive: true });
fs.writeFileSync(path.join(out, 'ring-ribs.stl'), stl('ring_knurl', tris));
console.log(`knurl: ${solids} diamonds, ${tris.length} triangles (${flipped} shells flipped), pitch ${pu.toFixed(2)} mm around, row spacing ${pz.toFixed(2)} mm, base ${(2 * au).toFixed(2)} x ${(2 * az).toFixed(2)} mm, ${BUMP_H} mm high, outer radius ${(R + BUMP_H).toFixed(2)}`);

// one-colour ring: body and bumps as two shells in one STL (they touch, never overlap)
const bodyFile = path.join(out, 'ring-body.stl');
if (fs.existsSync(bodyFile)) {
  const body = fs.readFileSync(bodyFile, 'utf8').replace(/^\s*solid[^\n]*\n/, '').replace(/endsolid[^\n]*\s*$/, '');
  const ribs = fs.readFileSync(path.join(out, 'ring-ribs.stl'), 'utf8').replace(/^\s*solid[^\n]*\n/, '').replace(/endsolid[^\n]*\s*$/, '');
  fs.writeFileSync(path.join(out, 'ring.stl'), 'solid ring\n' + body + ribs + 'endsolid ring\n');
  console.log('merged cad/stl/ring.stl');
}
