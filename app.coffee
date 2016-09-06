express = require('express')
app = express()
fs = require('fs')
open = require('open')
path = require('path')

serverPortHttp = (process.env.PORT || 80)
http = require('http')
serverHttp = http.createServer(app)

options = {
  key: fs.readFileSync('/etc/letsencrypt/live/liive.io/privkey.pem'),
  cert: fs.readFileSync('/etc/letsencrypt/live/liive.io/fullchain.pem'),
  ca: fs.readFileSync('/etc/letsencrypt/live/liive.io/chain.pem'),
  requestCert: false,
  rejectUnauthorized: false,
}

serverPortHttps = (process.env.PORT || 443)
https = require('https')
serverHttps = https.createServer(options, app)
io = require('socket.io').listen(serverHttps)

socketIdsInRoom = (name) ->
  console.log("ids in room...")
  socketIds = io.nsps['/'].adapter.rooms[name]
  if (socketIds)
    collection = []
    for key in socketIds
      collection.push(key)

    return collection
  else
    return []

io.on('connection', (socket) ->
  console.log('connection')
  socket.on('disconnect', () ->
    console.log('disconnect')
    if (socket.room)
      room = socket.room
      io.to(room).emit('leave', socket.id)
      socket.leave(room)
  )
  socket.on('join', (name, callback) ->
    console.log('join', name)
    socketIds = socketIdsInRoom(name)
    callback(socketIds)
    socket.join(name)
    socket.room = name
  )
  socket.on('exchange', (data) ->
    console.log('exchange', data)
    data.from = socket.id
    to = io.sockets.connected[data.to]
    to.emit('exchange', data)
  )
)

app.use('/.well-known', express.static(path.join(__dirname, '.well-known')))
app.use('/', express.static(path.join(__dirname, 'public')))

serverHttps.listen(serverPortHttps, () ->
  console.log('server up and running at %s port', serverPortHttps)
  if (process.env.LOCAL)
    open('https://liive.io')
)
serverHttp.listen(serverPortHttp, () ->
  console.log('server up and running at %s port', serverPortHttp)
#  if (process.env.LOCAL)
#    open('http://liive.io/warning.html')
)
