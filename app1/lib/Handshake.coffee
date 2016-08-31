io = require('socket.io')

class Handshake
    socket = io()

    # reactions = { // handshake reactions
    #    didExchange: (data) ->
    #    didLeave: (socketId) ->
    #    didConnect: (stream) ->

    reactions = null
    constructor: ( _reactions) ->
        reactions = _reactions
        socket.on('connect', connect)
        socket.on('exchange', exchange)
        socket.on('leave', leave)

    join: (id, callback) ->
        socket.emit('join', id, (socketIds) =>
            console.log('join', socketIds);
            callback(socketIds) # todo: didJoin???
        )

    candidate: (id, candidate) ->
        socket.emit('exchange', {'to': id, 'candidate': candidate })

    description: (id, description) ->
        socket.emit('exchange', {'to': id, 'sdp': description })

    connect = (data) ->
        reactions.didConnect(data) if reactions.didConnect?

    exchange = (data) ->
        reactions.didExchange(data) if reactions.didExchange?

    leave = (id) ->
        reactions.didLeave(id) if reactions.didLeave?

module.exports = Handshake
