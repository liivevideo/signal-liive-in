
class RTCChannel
    pc = null
    pcPeers = []
    localStream = null
    getUserMedia = navigator.getUserMedia || navigator.mozGetUserMedia || navigator.webkitGetUserMedia || navigator.msGetUserMedia;

    # observers = {
    #    foundLocalVideoChannel: foundLocalVideoChannel,
    #    addedVideoChannel: (socketId, event) ->
    #    removedVideoChannel: (socketId) ->
    #    addedTextChannel: (dataChannel) ->
    # reactions = {
    #    exchangeDescription: (socketId, localDescription) ->
    #    exchangeCandidate: (socketid, candidate)
    # }
    configuration = null
    observers = null
    reactions = null
    constructor: (_configuration, _observers, _reactions) ->
        configuration = _configuration
        observers = _observers
        reactions = _reactions

    getMedia: (types, callback) ->
        getUserMedia(types, (stream) ->
            localStream = stream
            foundLocalVideoChannel(localStream)
            callback(stream)
        , (error) -> console.log(error) )

    createTextChannel: (socketId)  ->
        return if (pc.textDataChannel?)
        dataChannel = pc.createDataChannel("text")
        pc.textDataChannel = observers.addedTextChannel(socketId, dataChannel)

    createListener: (socketId, isOffer) ->
        pc = new RTCPeerConnection(configuration)
        pcPeers[socketId] = pc
        pc.onicecandidate = (event) ->
            console.log('onicecandidate', event)
            if (event.candidate)
                reactions.exchangeCandidate(socketId, event.candidate)
        pc.onnegotiationneeded = () ->
            console.log('onnegotiationneeded')
            if (isOffer)
                pc.createOffer((desc) ->
                    console.log('createOffer', desc)
                    pc.setLocalDescription(desc, () ->
                        console.log('setLocalDescription', pc.localDescription)
                        reactions.exchangeDescription(socketId, pc.localDescription)
                    , (error) -> console.log(error) )
                , (error) -> console.log(error) )
        pc.oniceconnectionstatechange = (event) ->
            console.log('oniceconnectionstatechange', event)
            if (event.target.iceConnectionState == 'connected')
                @createTextChannel(socketId)
        pc.onsignalingstatechange = (event) -> console.log('onsignalingstatechange', event)
        pc.onaddstream = (event) ->
            observers.addedVideoChannel(socketId, event.stream)
        pc.addStream(localStream)
        return pc

    deleteListener: (socketId, callback) ->
        pc = pcPeers[socketId]
        if (pc)
            pc.close(); delete pcPeers[socketId]
        observers.removedVideoChannel(socketId)
        callback(null, socketId)

    send: (text) ->
        for pc in pcPeers
            pc.textDataChannel.send(text)

    exchange: (data, callback) ->
        fromId = data.from
        if (fromId in pcPeers) then pc = pcPeers[fromId] else pc = createListener(fromId, false)

        if (data.sdp)
            console.log('exchange sdp', data)
            pc.setRemoteDescription(new RTCSessionDescription(data.sdp), () ->
                if (pc.remoteDescription.type == "offer")
                    pc.createAnswer((desc) ->
                        console.log('createAnswer', desc)
                        pc.setLocalDescription(desc, () ->
                            console.log('setLocalDescription', pc.localDescription)
                            callback(null, {id: fromId, description: pc.localDescription})
                        , (error) -> callback(error, null)
                        )
                    , (error) -> callback(error, null)
                    )
            , (error) -> callback(error, null)
            )
        else
            console.log('exchange candidate', data)
            pc.addIceCandidate(new RTCIceCandidate(data.candidate))
            callback(null, null)

module.exports = RTCChannel