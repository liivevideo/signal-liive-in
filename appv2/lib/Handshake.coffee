io = require('socket.io')

class Handshake
    socket = io()

    # reactions = { // handshake reactions
    #    didExchange: (data) ->
    #    didLeave: (socketId) ->
    #    didConnect: (stream) ->

    reactions = null
    rtcChannel = null
    constructor: (_rtcChannel, _reactions) ->
        reactions = _reactions
        rtcChannel = _rtcChannel
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

    connect = (data) -> # data not used.
        rtcChannel.getMedia({ "audio": true, "video": true }, (stream) ->
            reactions.didConnect(stream) if reactions.didConnect?
        )
    exchange = (data) ->
        rtcChannel.exchange(data, (error, result) ->
            console.log(error) if error?
            if result? && reactions.didExchange?
                reactions.didExchange(result.id, result.description)
        )
    leave = (id) ->
        rtcChannel.deleteListener(id, (id) ->
            reactions.didLeave(id) if reactions.didLeave?
        )

module.exports = Handshake
