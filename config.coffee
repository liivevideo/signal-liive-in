pjson = require('./package.json')
fs = require('fs')

if !process.env.NODE_ENV? or process.env.NODE_ENV == 'local'
    config =
        env: 'local'
        httpsPort: process.env.HTTPSPORT || '8443'
        httpPort: process.env.HTTPPORT || '8080'
        cdn: '/build/bundle.js'
    sslOptions =
        key: process.env.KEY || fs.readFileSync('/etc/letsencrypt/live/liive.in/privkey.pem')
        cert: process.env.CERT || fs.readFileSync('/etc/letsencrypt/live/liive.in/fullchain.pem')
        ca: process.env.CA || fs.readFileSync('/etc/letsencrypt/live/liive.in/chain.pem')
        requestCert: false
        rejectUnauthorized: false

else if process.env.OPENSHIFT?
    config =
        env: process.env.NODE_ENV || 'develop'
        httpPort: process.env.OPENSHIFT_NODEJS_PORT || '' # must be set.
        httpIp: process.env.OPENSHIFT_NODEJS_IP
        cdn: '/build/bundle.js'      # todo:: setup cloudflare cdn.

    sslOptions = null
    if process.env.KEY? and process.env.CERT? and process.env.CA?
        sslOptions =
            key: process.env.KEY
            cert: process.env.CERT
            ca: process.env.CA
            requestCert: false
            rejectUnauthorized: false
        config.httpsPort = process.env.PORT || '' # must be set.
else  # default deployment :Heroku for now.
    config =
        env: process.env.NODE_ENV || 'develop'
        httpPort: process.env.PORT || '' # must be set.
        cdn: '/build/bundle.js'      # todo:: setup cloudflare cdn.
        heroku: true

    sslOptions = null
    if process.env.KEY? and process.env.CERT? and process.env.CA?
        sslOptions =
            key: process.env.KEY
            cert: process.env.CERT
            ca: process.env.CA
            requestCert: false
            rejectUnauthorized: false
        config.httpsPort = process.env.PORT || '' # must be set.
config.title = pjson.title
config.version = pjson.version

module.exports = [config, sslOptions]
