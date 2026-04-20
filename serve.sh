#!/bin/bash
# Shadow Realm — Lokaler Webserver
# Starte dieses Script im build/web Verzeichnis und öffne http://localhost:8080 im Browser.
# Godot WASM benötigt spezielle CORS-Header (SharedArrayBuffer).

cd "$(dirname "$0")"

if command -v node &>/dev/null; then
  node -e "
const http = require('http');
const fs = require('fs');
const path = require('path');
const mimeTypes = {
  '.html': 'text/html', '.js': 'application/javascript',
  '.wasm': 'application/wasm', '.pck': 'application/octet-stream',
  '.png': 'image/png',
};
const server = http.createServer((req, res) => {
  let filePath = '.' + (req.url === '/' ? '/index.html' : req.url);
  const ext = path.extname(filePath);
  res.setHeader('Cross-Origin-Opener-Policy', 'same-origin');
  res.setHeader('Cross-Origin-Embedder-Policy', 'require-corp');
  fs.readFile(filePath, (err, content) => {
    if (err) { res.writeHead(404); res.end('Not found'); }
    else { res.writeHead(200, {'Content-Type': mimeTypes[ext] || 'application/octet-stream'}); res.end(content); }
  });
});
server.listen(8080, () => console.log('Shadow Realm läuft auf http://localhost:8080'));
"
else
  echo "Node.js wird benötigt. Installiere es via: brew install node"
  exit 1
fi
