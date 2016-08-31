class SignalClient
    pc = null
    socket = null
    pcPeers = []
    isOffer = false

    constructor: (configuration, _socket, _socketId, _isOffer) ->
        socket = _socket
        isOffer = _isOffer
        pc = new RTCPeerConnection(configuration);
        pcPeers[_socketId] = pc;
        @register(_socketId)

    createOffer = (socketId) ->
        pc.createOffer((desc) ->
            console.log('createOffer', desc)
            pc.setLocalDescription(desc, () ->
                console.log('setLocalDescription', pc.localDescription)
                socket.emit('exchange', {'to': socketId, 'sdp': pc.localDescription })
            , logError)
        , logError)

    createDataChannel = ()  ->
        if (pc.textDataChannel)
            return;
        dataChannel = pc.createDataChannel("text")

        dataChannel.onerror = (error) ->
            console.log("dataChannel.onerror", error)

        dataChannel.onmessage = (event) ->
            console.log("dataChannel.onmessage:", event.data)
            showSocketData(socketId, event) #TODO: DOM Manipulation

        dataChannel.onopen = () ->
            console.log('dataChannel.onopen')
            showTextRoom() #TODO: DOM Manipulation

        dataChannel.onclose = () ->
            console.log("dataChannel.onclose")

        pc.textDataChannel = dataChannel

    register: (socketId) ->
        pc.onicecandidate = (event) ->
            console.log('onicecandidate', event)
            if (event.candidate)
                socket.emit('exchange', {'to': socketId, 'candidate': event.candidate })

        pc.onnegotiationneeded = () ->
            console.log('onnegotiationneeded')
            if (isOffer)
                createOffer(socketId);

        pc.oniceconnectionstatechange = (event) ->
            console.log('oniceconnectionstatechange', event)
            if (event.target.iceConnectionState == 'connected')
                createDataChannel()

        pc.onsignalingstatechange = (event) ->
            console.log('onsignalingstatechange', event)

        pc.onaddstream = (event) ->
            addStream(event,socketId)

        pc.addStream(localStream)

        return pc
