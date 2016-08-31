
RTCChannel = require('../lib/RTCChannel')
Handshake = require ('../lib/Handshake')
class Room
    handshake = null
    channel = null

    constructor: (configuration, _observers, _reactions, _listeners) ->
        channel = new RTCChannel(configuration, _listeners)
        handshake = new HandShake(configuration, _observers, _reactions)

    join: (roomId, callback) ->
        handshake.requestJoin('join', roomID, (ids) ->
            console.log('join', ids);
            for id in ids
                rtcChannel.createListener(id, true)
        )

    leave: (roomId, callback) ->

    say: (text) ->



