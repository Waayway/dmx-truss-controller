#!/usr/bin/env node
// Generates bom/BOM.md from bom/bom.csv (the CSV is the single source of truth).
// Usage: node scripts/gen-bom-md.mjs
import fs from 'fs';
const lines = fs.readFileSync('bom/bom.csv', 'utf8').trim().split('\n');
const head = lines.shift().split(',');
const rows = lines.map(l => { const f = l.split(','); if (f.length !== head.length) throw new Error('bad field count: ' + l); return Object.fromEntries(head.map((h, i) => [h, f[i]])); });

const final_only = new Set(['J1', 'J2', 'T1']);          // not needed for the first test
let total = 0, first = 0;
const byShop = {};
for (const r of rows) {
  const v = parseFloat(r.line_eur); if (isNaN(v)) continue;
  total += v; byShop[r.shop] = (byShop[r.shop] || 0) + v;
  if (!final_only.has(r.ref)) first += v;
}

let md = '# Bill of materials\n\nGenerated from `bom.csv` by `scripts/gen-bom-md.mjs`. Prices are EUR including VAT, **shipping not included**.\nStock was read from each shop\'s own product page on 2026-11-24 unless noted. Re-check before ordering.\n\n';
md += '| Ref | Part | Qty | Shop | EUR | Stock basis | Link |\n|---|---|---|---|---|---|---|\n';
for (const r of rows) {
  const link = r.url.startsWith('http') ? `<${r.url}>` : '-';
  md += `| ${r.ref} | ${r.part} | ${r.qty} | ${r.shop} | ${r.line_eur} | ${r.stock_basis} | ${link} |\n`;
}
md += `\n## Totals\n\n- **Everything on the list:** EUR ${total.toFixed(2)}\n- **First test only** (no XLR panel jack, no USB-C panel jack, no terminator; USB-C cable straight into the Nano): EUR ${first.toFixed(2)}\n\n### By shop\n\n`;
for (const [k, v] of Object.entries(byShop)) if (v > 0) md += `- ${k}: EUR ${v.toFixed(2)}\n`;
md += '\n## Notes\n\n';
for (const r of rows) if (r.notes && r.notes !== '-') md += `- **${r.ref}** ${r.notes}\n`;
md += '\n## Shipping (Kiwi only, from its help page)\n\nLetterbox EUR 4.22, parcel EUR 7.20, free from EUR 150. Other shops: not checked.\n';
fs.writeFileSync('bom/BOM.md', md);
console.log('wrote bom/BOM.md', total.toFixed(2), first.toFixed(2));
