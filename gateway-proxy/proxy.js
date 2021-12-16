const https = require('https');
const http = require('http');
const httpProxy = require('http-proxy');
const fs = require('fs');
const crypto = require('crypto');

const HOSTNAME = process.env['HOSTNAME'];
const PORT = process.env['PORT'];
const KEY_DIRECTORY = process.env['KEY_DIRECTORY'];
const CERT_DIRECTORY = process.env['CERT_DIRECTORY'];
const TARGET = process.env['TARGET'];
//
// Proxy server options
//
const options = {
    hostname: HOSTNAME,
    port: PORT,
    key: fs.readFileSync(KEY_DIRECTORY),
    cert: fs.readFileSync(CERT_DIRECTORY),
    requestCert: true,
    rejectUnauthorized: false,
    secure: false
};
const proxy = httpProxy.createProxyServer();



// Set gateway headers using client certificates
proxy.on('proxyReq', function(proxyReq, req, res, options) {
    const certificate = req.socket.getPeerCertificate();
    // const certificate = {};
    // console.log(certificate);
    if (certificate && certificate.raw) {
        const hash = crypto.createHash('sha256').update(certificate.raw).digest('hex');
        console.log(hash);
        proxyReq.setHeader('X-SSL-Client-SHA256', hash);
        proxyReq.setHeader('X-SSL-Client-DN', `C=${certificate.subject.C}`);
    }
});

proxy.on('error', function (err, req, res) {
   console.log("[error]");
   console.error(err);
});

proxy.on('open', function (proxySocket) {
	console.log("[open]");
});

proxy.on('close', function (res, socket, head) {
	console.log("[close]");
});

proxy.on('proxyRes', function (proxyRes, req, res) {
	console.log("[proxyRes]");
});


const server = https.createServer(options, function(req, res) {
    // You can define here your custom logic to handle the request
    // and then proxy the request.
    proxy.web(req, res, {
        target: TARGET
    });
});

console.log(`Listening on port ${PORT}`)
server.listen(PORT);
