express = require('express')
app = express()
fs = require('fs')
open = require('open')
options = {
    key: fs.readFileSync('./fake-keys/privatekey.pem'),
    cert: fs.readFileSync('./fake-keys/certificate.pem')
}
serverAddress = (process.env.ADDRESS || '50.67.201.214')
serverScheme = (process.env.SCHEME || 'https')
serverPort = (process.env.PORT || (if (serverScheme is 'https') then 4443 else 8000))
serverUrl = serverScheme+'://'+serverAddress+':' + serverPort
console.log("server is at: "+serverUrl)

if (serverScheme == 'https')
    server = require(serverScheme).createServer(options, app)
else
    server = require(serverScheme).createServer(app)

io = require('socket.io')(server)


roomList = {}

app.get('/', (req, res) ->
    console.log('get /')
    res.sendFile(__dirname + '/index.html')
)
server.listen(serverPort,  () ->
    console.log('server up and running at %s port', serverPort)
    if (process.env.LOCAL)
        open(serverUrl)
)

socketIdsInRoom = (name) =>
    socketIds = io.nsps['/'].adapter.rooms[name]
    if (socketIds?)
        collection = []
        for key, value of socketIds
            collection.push(key)

        return collection
    else
        return []

io.on('connection', (socket) ->
    console.log('connection')
    socket.on('disconnect',  () ->
        console.log('disconnect')
        if (socket.room?)
            room = socket.room
            io.to(room).emit('leave', socket.id)
            socket.leave(room)
        return

    )

    socket.on('join', (name, callback) ->
        console.log('join', name)
        socketIds = socketIdsInRoom(name)
        callback(socketIds)
        socket.join(name)
        socket.room = name
        return
    )

    socket.on('exchange', (data) ->
        console.log('exchange', data)
        data.from = socket.id
        to = io.sockets.connected[data.to]
        to.emit('exchange', data)
        return
    )
)
