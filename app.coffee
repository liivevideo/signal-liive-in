express = require('express')
app = express()
fs = require('fs')
open = require('open')
path = require('path')

options = {
  key: fs.readFileSync('/etc/letsencrypt/live/liive.io/privkey.pem'),
  cert: fs.readFileSync('/etc/letsencrypt/live/liive.io/fullchain.pem'),
  ca: fs.readFileSync('/etc/letsencrypt/live/liive.io/chain.pem'),
  requestCert: false,
  rejectUnauthorized: false,
}

serverPortHttps = (process.env.PORT || 8443)
serverPortHttp = 8080
https = require('https')
http = require('http')
serverHttps = https.createServer(options, app)
serverHttp = http.createServer(app)

io = require('socket.io')(serverHttps)

roomList = {}

socketIdsInRoom = (name) ->
  console.log("ids in room..."+name)
  socketIds = io.nsps['/'].adapter.rooms[name]
  console.log("sockets:"+JSON.stringify(socketIds))
  if (socketIds)
    collection = []
    for key of socketIds
      collection.push(key)

    console.log("ids: "+JSON.stringify(collection))
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

app.use('/.well-known', express.static(path.join(__dirname, '.well-known')))
app.use('/', express.static(path.join(__dirname, 'public')))

serverHttps.listen(serverPortHttps, () ->
  console.log('server up and running at %s port', serverPortHttps)
  if (process.env.LOCAL)
    open('https://liive.io')
  return
)
serverHttp.listen(serverPortHttp, () ->
  console.log('server up and running at %s port', serverPortHttp)
#  if (process.env.LOCAL)
#    open('http://liive.io/warning.html')
  return
)
