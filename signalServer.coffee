express = require('express')

fs = require('fs')
open = require('open')

keys_dir = 'fake-keys/'
server_options = {
        key  : fs.readFileSync(keys_dir + 'certificate.key'),
        ca   : fs.readFileSync(keys_dir + 'certificate.csr'),
        cert : fs.readFileSync(keys_dir + 'certificate.crt')
    }
serverAddress = (process.env.ADDRESS || '50.67.201.214')
serverHttpsPort = (process.env.PORT || 4443)
serverUrl = 'https://'+serverAddress+':' + serverHttpsPort

app = express()

app.get('/', (req, res) ->
    console.log('get /')
    res.sendFile(__dirname + '/index.html')
)
https = require('https')
httpsserver = https.createServer(server_options,app)
httpsserver.listen(serverHttpsPort, () ->
    console.log('server up and running at %s port', serverHttpsPort)
    if (process.env.LOCAL)
        console.log("Opening local browser for dev: "+serverUrl)

        open(serverUrl)
)

ios = require('socket.io')(httpsserver)

Signaling = require('./app/lib/Signaling')
signal = new Signaling()
signal.register(ios)
