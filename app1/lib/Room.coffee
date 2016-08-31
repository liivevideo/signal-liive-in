class Room

    OUTSIDE = 'outside'
    INSIDE = 'inside'
    room = null
    state = OUTSIDE
    handshake = null

    constructor: (configuration) ->
        state = OUTSIDE
        handshake = new HandShake(configuration, {
            exchange: (data) ->
                console.log('exchange')
            leave: (socketId) ->
                console.log('leave')
            connect: (data) ->
                console.log('connect')
        })

    join: (roomId, callback) ->
        handshake.requestJoin('join', roomID, callback)

    leave: (roomId, callback) ->

    say: (text) ->



