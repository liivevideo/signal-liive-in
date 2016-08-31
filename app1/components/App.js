var RTCPeerConnection = window.RTCPeerConnection || window.mozRTCPeerConnection ||
    window.webkitRTCPeerConnection || window.msRTCPeerConnection;

var RTCSessionDescription = window.RTCSessionDescription || window.mozRTCSessionDescription ||
    window.webkitRTCSessionDescription || window.msRTCSessionDescription;


var selfView = document.getElementById("selfView");
var remoteViewContainer = document.getElementById("remoteViewContainer");

// rtc observers.
addedTextChannel = function (id, dataChannel) {
    dataChannel.onerror = function (error) {
        console.log("dataChannel.onerror", error)
    }
    dataChannel.onmessage = function (event) {
        console.log("dataChannel.onmessage:", event.data)
        var content = document.getElementById('textRoomContent')
        content.innerHTML = content.innerHTML + '<p>' +
            id + ': ' + event.data + '</p>'
    }
    dataChannel.onopen = function () {
        console.log('dataChannel.onopen')
        var textRoom = document.getElementById('textRoom')
        textRoom.style.display = "block";
    }
    dataChannel.onclose = function () {
        console.log("dataChannel.onclose")
    }
    return dataChannel
}
removedVideoChannel = function (id) {
    video = document.getElementById("remoteView" + id);
    if (video) video.remove();
}
addedVideoChannel = function(id, stream) {
    console.log('onaddstream', event);
    var element = document.createElement('video');
    element.id = "remoteView" + id;
    element.autoplay = 'autoplay';
    element.src = URL.createObjectURL(stream);
    remoteViewContainer.appendChild(element);
}
// handshaking observers.
didConnect = function(data) {
    rtcChannel.getMedia({ "audio": true, "video": true },
        function (stream) {
            selfView.src = URL.createObjectURL(stream)
            selfView.muted = true
        }
    )
    // selfView.src = URL.createObjectURL(stream)
    // selfView.muted = true
}
didExchange = function(data) {
    rtcChannel.exchange(data, handshaker,
        function (id, description) {
            if (id != null && description != null)
                handshaker.description(id, description)
        }
    )
}
didLeave = function(id) {
    console.log(id)
    rtcChannel.deleteListener(id,
        function (id)
        {
            console.log("deleted: " + id)
        }
    )
}

var RTCChannel = require('../lib/RTCChannel')
var configuration = {"iceServers":
    [{"url": "stun:stun.l.google.com:19302"}]};
var rtcChannel = new RTCChannel(configuration, {
    addedVideoChannel: addedTextChannel,
    removedVideoChannel: removedVideoChannel,
    addedTextChannel: addedTextChannel
})

var Handshake = require ('../lib/Handshake')
var handshaker = new Handshake({
    didConnect:didConnect,
    didExchange: didExchange,
    didLeave: didLeave
})

function press() {
    var roomID = document.getElementById('roomID').value;
    if (roomID == "") {
        alert('Please enter room ID');
    } else {
        var roomIDContainer = document.getElementById('roomIDContainer');
        roomIDContainer.parentElement.removeChild(roomIDContainer);

        handshaker.join(roomID, function (ids) {
            console.log('join', ids);
            for (var i in ids) {
                var id = ids[i];
                rtcChannel.createListener(id, true, handshaker)
            }
            console.log("press join finished")
        });
    }
}
function textRoomPress() {
    var text = document.getElementById('textRoomInput').value;
    if (text == "") {
        alert('Enter something');
    } else {
        document.getElementById('textRoomInput').value = '';
        var content = document.getElementById('textRoomContent');
        content.innerHTML = content.innerHTML + '<p>' + 'Me' + ': ' + text + '</p>';
        rtcChannel.send(text)
    }
}

