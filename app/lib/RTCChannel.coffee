
class RTCChannel
    pc = null
    pcPeers = []
    getUserMedia = navigator.getUserMedia || navigator.mozGetUserMedia || navigator.webkitGetUserMedia || navigator.msGetUserMedia;

    # observers = {
    #    addedVideoChannel: (socketId, event) ->
    #    removedVideoChannel: (socketId) ->
    #    addedTextChannel: (dataChannel) ->
    # }

    localStream = null
    observers = null
    configuration = null

    constructor: (_configuration, _observers) ->
        configuration = _configuration
        observers = _observers

    createTextChannel: ()  ->
        if (pc.textDataChannel?)
            return

        dataChannel = pc.createDataChannel("text")
        pc.textDataChannel = observers.addedTextChannel(dataChannel)

    createListener: (socketId, isOffer, handshaker) ->
        pc = new RTCPeerConnection(configuration)

        pcPeers[socketId] = pc
        pc.onicecandidate = (event) ->
            console.log('onicecandidate', event)
            if (event.candidate)
                handshaker.candidate(socketId, event.candidate)

        pc.onnegotiationneeded = () ->
            console.log('onnegotiationneeded')
            if (isOffer)
                pc.createOffer((desc) ->
                    console.log('createOffer', desc)
                    pc.setLocalDescription(desc, () ->
                        console.log('setLocalDescription', pc.localDescription)
                        handshaker.description(socketId, pc.localDescription)
                    , (error) -> console.log(error) )
                , (error) -> console.log(error) )

        pc.oniceconnectionstatechange = (event) ->
            console.log('oniceconnectionstatechange', event)
            if (event.target.iceConnectionState == 'connected')
                @createTextChannel(socketId, event)

        pc.onsignalingstatechange = (event) ->
            console.log('onsignalingstatechange', event)

        pc.onaddstream = (event) ->
            observers.addedVideoChannel(socketId, event.stream)

        pc.addStream(localStream)

    # types: { "audio": true, "video": true }
    getMedia: (types, callback) ->
        getUserMedia(types, (stream) ->
            localStream = stream
            callback(stream)
        , (error) -> console.log(error) )

    deleteListener: (socketId, callback) ->
        pc = pcPeers[socketId]
        if (pc)
            pc.close()
            delete pcPeers[socketId]
        observers.removedVideoChannel(socketId)
        callback(socketId)

    send: (text) ->
        for pc in pcPeers
            pc.textDataChannel.send(text)

    exchange: (data, callback) ->
        fromId = data.from
        pc
        if (fromId in pcPeers)
            pc = pcPeers[fromId]
        else
            pc = createPC(fromId, false)

        if (data.sdp)
            console.log('exchange sdp', data)
            pc.setRemoteDescription(new RTCSessionDescription(data.sdp), () ->
                if (pc.remoteDescription.type == "offer")
                    pc.createAnswer((desc) ->
                        console.log('createAnswer', desc)
                        pc.setLocalDescription(desc, () ->
                            console.log('setLocalDescription', pc.localDescription)
                            callback(fromId, pc.localDescription)

                        , (error) -> console.log(error) )
                    , (error) -> console.log(error) )
            , (error) -> console.log(error) )
        else
            console.log('exchange candidate', data)
            pc.addIceCandidate(new RTCIceCandidate(data.candidate))
            callback(null, null)

module.exports = RTCChannel