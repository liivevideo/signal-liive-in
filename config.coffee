pjson = require('./package.json')
fs = require('fs')

config =
    env: process.env.NODE_ENV || 'local'
    version: pjson.version
    httpsPort: process.env.HTTPSPORT || '8443'
    httpPort: process.env.HTTPPORT || '8080'
sslOptions =
    key: process.env.KEY || fs.readFileSync('/etc/letsencrypt/live/liive.io/privkey.pem')
    cert: process.env.CERT || fs.readFileSync('/etc/letsencrypt/live/liive.io/fullchain.pem')
    ca: process.env.CA || fs.readFileSync('/etc/letsencrypt/live/liive.io/chain.pem')
    requestCert: false
    rejectUnauthorized: false

module.exports = [config, sslOptions]
