express = require('express')
app = express()
cors = require('cors')
favicon = require('serve-favicon')
open = require('open')
path = require('path')
#logger = require('morgan')
cookieParser = require('cookie-parser')
bodyParser = require('body-parser')
[config, sslOptions] = require('./config')
console.log("configuration: "+JSON.stringify(config, null, 4))

routes = require('./routes/index')(config)

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

https = require('https')
serverHttps = https.createServer(sslOptions, app)
serverHttps.listen(config.httpsPort, () ->
  console.log("server running on port #{config.httpsPort}", )
  return
)

if (config.env=='local')
  http = require('http')
  serverHttp = http.createServer(app)
  serverHttp.listen(config.httpPort, () ->
    console.log("server running on port #{config.httpPort}")
    return
  )

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


