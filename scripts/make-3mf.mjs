// Packs cad/stl/ring-body.stl + cad/stl/ring-ribs.stl into ONE object with TWO parts, each with its own filament (extruder 1 / 2),
// for Bambu Studio. Plain 3MF core elements (mesh, components, basematerials) plus Bambu's Metadata/model_settings.config.
// usage: node scripts/make-3mf.mjs   (needs `zip`)
import fs from 'fs';
import { execFileSync } from 'child_process';
import path from 'path';
import os from 'os';

const root = path.resolve(path.dirname(new URL(import.meta.url).pathname), '..');
const parts = [
  { name: 'ring body', file: 'cad/stl/ring-body.stl', extruder: 1, color: '#3A3E44' },
  { name: 'knurl ribs', file: 'cad/stl/ring-ribs.stl', extruder: 2, color: '#E0A030' },
];
const out = process.argv[2] || path.join(root, 'cad/3mf/ring-two-colour.3mf');
const place = [100, 100];          // where the object sits on the plate, mm (inside any Bambu bed)

function readAsciiStl(f) {
  const txt = fs.readFileSync(f, 'utf8');
  if (!/^\s*solid/.test(txt)) throw new Error(f + ': not an ASCII STL');
  const idx = new Map(), verts = [], tris = [];
  const vid = (x, y, z) => { const k = x.toFixed(5) + ',' + y.toFixed(5) + ',' + z.toFixed(5); if (!idx.has(k)) { idx.set(k, verts.length); verts.push([x, y, z]); } return idx.get(k); };
  let cur = [];
  for (const m of txt.matchAll(/vertex\s+(\S+)\s+(\S+)\s+(\S+)/g)) {
    cur.push(vid(+m[1], +m[2], +m[3]));
    if (cur.length === 3) { if (cur[0] !== cur[1] && cur[1] !== cur[2] && cur[0] !== cur[2]) tris.push(cur); cur = []; }
  }
  return { verts, tris };
}
function checkMesh(m, name) {
  const e = new Map();
  for (const t of m.tris) for (let i = 0; i < 3; i++) { const a = t[i], b = t[(i + 1) % 3]; const k = a + '>' + b; e.set(k, (e.get(k) || 0) + 1); }
  let bad = 0; for (const [k, n] of e) { const [a, b] = k.split('>'); if (n !== 1 || e.get(b + '>' + a) !== 1) bad++; }
  let vol = 0; for (const t of m.tris) { const [a, b, c] = t.map(i => m.verts[i]); vol += (a[0] * (b[1] * c[2] - b[2] * c[1]) - a[1] * (b[0] * c[2] - b[2] * c[0]) + a[2] * (b[0] * c[1] - b[1] * c[0])) / 6; }
  console.log(`${name}: ${m.verts.length} vertices, ${m.tris.length} triangles, open/non-manifold edges ${bad}, volume ${vol.toFixed(1)} mm3`);
  if (bad || vol <= 0) throw new Error(name + ' is not a closed, outward-facing mesh');
  return vol;
}

const meshes = parts.map(p => ({ ...p, mesh: readAsciiStl(path.join(root, p.file)) }));
let total = 0; for (const p of meshes) total += checkMesh(p.mesh, p.name);
console.log('total volume', total.toFixed(1), 'mm3');

const objXml = meshes.map((p, i) => {
  const id = i + 2;
  return `  <object id="${id}" name="${p.name}" type="model" pid="10" pindex="${i}">
   <mesh>
    <vertices>
${p.mesh.verts.map(v => `     <vertex x="${v[0].toFixed(5)}" y="${v[1].toFixed(5)}" z="${v[2].toFixed(5)}"/>`).join('\n')}
    </vertices>
    <triangles>
${p.mesh.tris.map(t => `     <triangle v1="${t[0]}" v2="${t[1]}" v3="${t[2]}"/>`).join('\n')}
    </triangles>
   </mesh>
  </object>`;
}).join('\n');

const model = `<?xml version="1.0" encoding="UTF-8"?>
<model unit="millimeter" xml:lang="en-US" xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02">
 <metadata name="Title">Knurled ring, two colours</metadata>
 <metadata name="Designer">dmx-truss-controller</metadata>
 <resources>
  <basematerials id="10">
${meshes.map(p => `   <base name="${p.name}" displaycolor="${p.color}"/>`).join('\n')}
  </basematerials>
${objXml}
  <object id="1" name="Knurled ring" type="model">
   <components>
${meshes.map((p, i) => `    <component objectid="${i + 2}"/>`).join('\n')}
   </components>
  </object>
 </resources>
 <build>
  <item objectid="1" transform="1 0 0 0 1 0 0 0 1 ${place[0]} ${place[1]} 0"/>
 </build>
</model>
`;
const settings = `<?xml version="1.0" encoding="UTF-8"?>
<config>
  <object id="1">
    <metadata key="name" value="Knurled ring"/>
    <metadata key="extruder" value="1"/>
${meshes.map((p, i) => `    <part id="${i + 2}" subtype="normal_part">
      <metadata key="name" value="${p.name}"/>
      <metadata key="extruder" value="${p.extruder}"/>
    </part>`).join('\n')}
  </object>
</config>
`;
const ct = `<?xml version="1.0" encoding="UTF-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
 <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
 <Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/>
 <Default Extension="config" ContentType="text/xml"/>
</Types>
`;
const rels = `<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
 <Relationship Target="/3D/3dmodel.model" Id="rel0" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/>
</Relationships>
`;
const tmp = fs.mkdtempSync(path.join(process.env.TMPDIR || os.tmpdir(), '3mf-'));
fs.mkdirSync(path.join(tmp, '3D')); fs.mkdirSync(path.join(tmp, '_rels')); fs.mkdirSync(path.join(tmp, 'Metadata'));
fs.writeFileSync(path.join(tmp, '[Content_Types].xml'), ct);
fs.writeFileSync(path.join(tmp, '_rels/.rels'), rels);
fs.writeFileSync(path.join(tmp, '3D/3dmodel.model'), model);
fs.writeFileSync(path.join(tmp, 'Metadata/model_settings.config'), settings);
fs.mkdirSync(path.dirname(out), { recursive: true }); fs.rmSync(out, { force: true });
execFileSync('zip', ['-X', '-D', '-q', '-r', out, '[Content_Types].xml', '_rels', '3D', 'Metadata'], { cwd: tmp });
fs.rmSync(tmp, { recursive: true });
console.log('wrote', out, fs.statSync(out).size, 'bytes');
