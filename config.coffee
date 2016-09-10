pjson = require('./package.json')
fs = require('fs')

config =
    env: process.env.NODE_ENV || 'local'
    version: pjson.version
    httpsPort: process.env.HTTPSPORT || '8443'
    httpPort: process.env.HTTPPORT || '8080'

if config.env == 'local'
    sslOptions =
        key: process.env.KEY || config.env == 'local' && fs.readFileSync('/etc/letsencrypt/live/liive.io/privkey.pem')
        cert: process.env.CERT || fs.readFileSync('/etc/letsencrypt/live/liive.io/fullchain.pem')
        ca: process.env.CA || fs.readFileSync('/etc/letsencrypt/live/liive.io/chain.pem')
        requestCert: false
        rejectUnauthorized: false
else
    sslOptions =
        key: process.env.KEY || ''
        cert: process.env.CERT || ''
        ca: process.env.CA || ''
        requestCert: false
        rejectUnauthorized: false

module.exports = [config, sslOptions]
