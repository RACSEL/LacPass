const https = require('https');
const http = require('http');
const httpProxy = require('http-proxy');
const fs = require('fs');
const crypto = require('crypto');

const PORT = process.env['PORT'];
const TARGET = process.env['TARGET'];
const CERT = process.env['CERT'];
const PASSPHRASE = process.env['PASSPHRASE'];

const server = httpProxy.createProxyServer({
  target: {
    protocol: 'https:',
    host: TARGET,
    port: 443,
    pfx: fs.readFileSync(CERT),
    passphrase: PASSPHRASE,
  },
  changeOrigin: true,
  secure: false
});

console.log(`Listening on port ${PORT}`)
server.listen(PORT);
