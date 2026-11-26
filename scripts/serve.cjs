// Tiny static file server for the STL preview page.  Usage: node scripts/serve.cjs [root=cad] [port=8765]
// then open http://127.0.0.1:8765/preview/view.html?f=base&v=iso
const http = require("http"), fs = require("fs"), path = require("path");
const root = path.resolve(process.argv[2] || path.join(__dirname, "..", "cad"));
const port = +(process.argv[3] || 8765);
http.createServer((q, r) => {
  const u = decodeURIComponent(q.url.split("?")[0]);
  const f = path.join(root, u);
  if (!f.startsWith(root)) { r.writeHead(403); r.end(); return; }
  fs.readFile(f, (e, d) => {
    if (e) { r.writeHead(404); r.end(); return; }
    const t = u.endsWith(".html") ? "text/html" : u.endsWith(".stl") ? "model/stl" : "application/octet-stream";
    r.writeHead(200, { "Content-Type": t, "Access-Control-Allow-Origin": "*" });
    r.end(d);
  });
}).listen(port, "127.0.0.1", () => console.log("serving", root, "on", port));
