pjson = require('./package.json')
fs = require('fs')

if !process.env.NODE_ENV? or process.env.NODE_ENV == 'local'
    config =
        env: 'local'
        version: pjson.version
        httpsPort: process.env.HTTPSPORT || '8443'
        httpPort: process.env.HTTPPORT || '8080'
    sslOptions =
        key: process.env.KEY || fs.readFileSync('/etc/letsencrypt/live/liive.io/privkey.pem')
        cert: process.env.CERT || fs.readFileSync('/etc/letsencrypt/live/liive.io/fullchain.pem')
        ca: process.env.CA || fs.readFileSync('/etc/letsencrypt/live/liive.io/chain.pem')
        requestCert: false
        rejectUnauthorized: false
else if process.env.HEROKU?
    config =
        env: process.env.NODE_ENV || 'develop'
        version: pjson.version
        httpPort: process.env.PORT || '' # must be set.
    sslOptions = null
else
    config =
        env: process.env.NODE_ENV || 'develop'
        version: pjson.version
        httpPort: process.env.OPENSHIFT_NODEJS_PORT || '' # must be set.
        httpIp: process.env.OPENSHIFT_NODEJS_IP
module.exports = [config, sslOptions]
