express = require('express')
app = express()
cors = require('cors')
favicon = require('serve-favicon')
open = require('open')
path = require('path')
#logger = require('morgan')
cookieParser = require('cookie-parser')
bodyParser = require('body-parser')
routes = require('./routes/index')

app.set('views', path.join(__dirname, 'views'))
app.set('view engine', 'jade')
app.use(cors())
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: false }))
app.use(cookieParser())
app.use(require('stylus').middleware(path.join(__dirname, 'public')))
app.use(favicon(path.join(__dirname, 'public', 'favicon.ppm')))
app.use(express.static(path.join(__dirname, 'public')))
app.use('/.well-known', express.static(path.join(__dirname, '.well-known')))
app.use('/', routes)

[config, sslOptions] = require('./config')
console.log("configuration: "+JSON.stringify(config, null, 4))

serverPortHttps = config.httpsPort
serverPortHttp = config.httpPort
https = require('https')
http = require('http')
serverHttps = https.createServer(sslOptions, app)
serverHttp = http.createServer(app)

io = require('socket.io')(serverHttps)

socketIdsInRoom = (name) ->
#  console.log("ids in room..."+name)
  socketIds = io.nsps['/'].adapter.rooms[name]
#  console.log("sockets:"+JSON.stringify(socketIds))
  if (socketIds)
    collection = []
    for key of socketIds
      collection.push(key)

#    console.log("ids: "+JSON.stringify(collection))
    return collection
  else
    return []

io.on('connection', (socket) ->
#  console.log('connection')
  socket.on('disconnect', () ->
#    console.log('disconnect')
    if (socket.room)
      room = socket.room
      io.to(room).emit('leave', socket.id)
      socket.leave(room)
    return
  )
  socket.on('join', (name, callback) ->
#    console.log('join', name)
    socketIds = socketIdsInRoom(name)
    callback(socketIds)
    socket.join(name)
    socket.room = name
    return
  )
  socket.on('exchange', (data) ->
#    console.log('exchange', data)
    data.from = socket.id
    to = io.sockets.connected[data.to]
    to.emit('exchange', data)
    return
  )
)

serverHttps.listen(serverPortHttps, () ->
#  console.log('server up and running at %s port', serverPortHttps)
  return
)
serverHttp.listen(serverPortHttp, () ->
#  console.log('server up and running at %s port', serverPortHttp)
  return
)
