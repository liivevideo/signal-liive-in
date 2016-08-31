var RTCPeerConnection = window.RTCPeerConnection || window.mozRTCPeerConnection ||
    window.webkitRTCPeerConnection || window.msRTCPeerConnection;

var RTCSessionDescription = window.RTCSessionDescription || window.mozRTCSessionDescription ||
    window.webkitRTCSessionDescription || window.msRTCSessionDescription;

var selfView = document.getElementById("selfView");
var remoteViewContainer = document.getElementById("remoteViewContainer");

// rtc observers.
addedTextChannel = function (dataChannel) {
    dataChannel.onerror = function (error) { console.log("dataChannel.onerror", error)
    }
    dataChannel.onmessage = function (event) { console.log("dataChannel.onmessage:", event.data)
        var content = document.getElementById('textRoomContent')
        content.innerHTML = content.innerHTML + '<p>' + socketId +
            ': ' + event.data + '</p>'
    }
    dataChannel.onopen = function () { console.log('dataChannel.onopen')
        var textRoom = document.getElementById('textRoom')
        textRoom.style.display = "block";
    }
    dataChannel.onclose = function () { console.log("dataChannel.onclose")
    }
    return dataChannel
}
removedVideoChannel = function (id) {
    video = document.getElementById("remoteView" + id);
    if (video) video.remove();
}
addedVideoChannel = function(id, stream) { console.log('onaddstream', event);
    var element = document.createElement('video');
    element.id = "remoteView" + id;
    element.autoplay = 'autoplay';
    element.src = URL.createObjectURL(stream);
    remoteViewContainer.appendChild(element);
}
foundLocalVideoChannel = function(stream) {
    selfView.src = URL.createObjectURL(stream)
    selfView.muted = true
}

var configuration = {"iceServers":
    [{"url": "stun:stun.l.google.com:19302"}]};

var Room = require('../Room')
var room = new Room(
    configuration,
    {
        foundLocalVideoChannel: foundLocalVideoChannel,
        addedVideoChannel: addedTextChannel,
        removedVideoChannel: removedVideoChannel,
        addedTextChannel: addedTextChannel
    },
    selfView
)

function press() {
    var roomID = document.getElementById('roomID').value;
    if (roomID == "") {
        alert('Please enter room ID');
    } else {
        var roomIDContainer = document.getElementById('roomIDContainer');
        roomIDContainer.parentElement.removeChild(roomIDContainer);
        room.join(roomID)
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
        room.say(text)
    }
}

