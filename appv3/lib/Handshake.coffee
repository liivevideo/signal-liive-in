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
        socket.on('connect', _connect)
        socket.on('exchange', _exchange)
        socket.on('leave', _leave)

    join: (id, callback) ->
        socket.emit('join', id, (socketIds) =>
            console.log('join', socketIds);
            callback(null, socketIds)
        )
    leave: (id, callback) ->

    candidate: (id, _candidate) ->
        socket.emit('exchange', {'to': id, 'candidate': candidate })

    description: (id, _description) ->
        socket.emit('exchange', {'to': id, 'sdp': description })

    _connect = (data) -> # data not used.
        reactions.didConnect(data) if reactions.didConnect?

    _exchange = (data) ->
        reactions.didExchange(data) if reactions.didExchange?

    _leave = (id) ->
        reactions.didLeave(id) if reactions.didLeave?

#    candidate: (id, _candidate) ->
#        candidate_(id, _candidate)
#
#    description: (id, _description) ->
#        description_(id, _description)
#
#    candidate_ = (id, candidate) ->
#        socket.emit('exchange', {'to': id, 'candidate': candidate })
#
#    description_ = (id, description) ->
#        socket.emit('exchange', {'to': id, 'sdp': description })

#    connect = (data) -> # data not used.
#        console.log("connect: data is -->" +data)
#        rtcChannel.getMedia({ "audio": true, "video": true }, (stream) ->
#            reactions.didConnect(stream) if reactions.didConnect?
#        )
#    exchange = (data) =>
#        rtcChannel.exchange(data, (error, result) ->
#            console.log(error) if error?
#            if result? && reactions.didExchange?
#                candidate_(result.id, result.description)
#                reactions.didExchange(result.id, result.description)
#        )
#    leave = (id) ->
#        rtcChannel.deleteListener(id, (error, id) ->
#            reactions.didLeave(id) if reactions.didLeave?
#        )



module.exports = Handshake
