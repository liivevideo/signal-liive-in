
RTCChannel = require('./RTCChannel')
Handshake = require ('./Handshake')
class Room
    handshake = null
    channel = null

    constructor: (configuration, _observers) ->
        channel = new RTCChannel(configuration, _observers,
            {
                exchangeDescription: exchangeDescription
                exchangeCandidate: exchangeCandidate
            }
        )
        handshake = new HandShake(configuration,
            {
                didConnect: didConnect,
                didExchange: didExchange,
                didLeave: didLeave
            }
        )

    join: (roomId, callback) ->
        handshake.join('join', roomID, (error, ids) ->
            console.log('join', ids);
            for id in ids
                channel.createListener(id, true)
            callback(null, ids) if callback?
        )

    leave: (roomId, callback) ->
        handshake.leave(roomId, callback)

    say: (text) ->
        channel.send(text)

    exchangeDescription = (id, description) ->
        handshake.description(id,description) if (id != null)

    exchangeCandidate = (id, candidate) ->
        handshake.candidate(id, candidate) if (id != null)

    didConnect = (data) ->
        console.log("connect: data is -->" +data)
        channel.getMedia({ "audio": true, "video": true }, (stream) ->
            console.log("did Connect: "+stream)
        )

    didExchange = (data) ->
        channel.exchange(data, (error, result) ->
            console.log(error) if error?
            if result? && reactions.didExchange?
                console.log("did Exchange: "+result.id+ " desc: "+
                        result.description)
                handshake.candidate(result.id, result.description)
        )

    didLeave = (id) ->
        channel.deleteListener(id, (error, id) ->
            console.log("did Leave: "+id)
        )

#    didConnect = (stream) ->
#        console.log("did Connect: "+id)
#        view.src = URL.createObjectURL(stream)
#        view.muted = true
#
#    didExchange = (id, description) ->
#        console.log("did Exchange: "+id+ " desc: "+description)
#
#    didLeave = (id) ->
#        console.log("did Leave: "+id)





