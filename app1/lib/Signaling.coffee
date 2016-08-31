class Signaling

    constructor: (@io=null) ->

    register: (@io) =>
        @io.on('connection', @connect)

    connect: (socket) =>
        console.log('connection')
        @socket = socket
        @socket.on('disconnect',  @disconnect)
        @socket.on('join', @join)
        @socket.on('exchange', @exchange)

    disconnect: () =>
        console.log('disconnect')
        if (@socket.room?)
            room = @socket.room
            @io.to(room).emit('leave', @socket.id)
            @socket.leave(room)
        return

    join: (name, callback) =>
        console.log('join', name)
        socketIds = @socketIdsInRoom(name)
        callback(socketIds)
        @socket.join(name)
        @socket.room = name
        return

    exchange: (data) =>
        console.log('exchange', data)
        data.from = @socket.id
        to = @io.sockets.connected[data.to]
        to.emit('exchange', data)
        return

    socketIdsInRoom:(name) =>
        socketIds = @io.nsps['/'].adapter.rooms[name]
        if (socketIds?)
            collection = []
            for key, value of socketIds
                collection.push(key)

            return collection
        else
            return []

module.exports = Signaling