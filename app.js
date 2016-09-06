var express = require('express');
var app = express();
var fs = require('fs');
var open = require('open');
var path = require('path')

var ssl = {
    key: fs.readFileSync('/etc/letsencrypt/live/liive.io/privkey.pem'),
    cert: fs.readFileSync('/etc/letsencrypt/live/liive.io/fullchain.pem'),
    ca: fs.readFileSync('/etc/letsencrypt/live/liive.io/chain.pem')
}
var serverPort1 = (process.env.PORT  || 4443);
var serverPort2 = 8080
var serverPort3 = 8443

var https = require('https');
var http = require('http');
var server1, server2, server3;

server1 = https.createServer(ssl, app);
server2 = http.createServer(app);
server3 = https.createServer(ssl, app);

var io = require('socket.io')(server1);

var roomList = {};

function socketIdsInRoom(name) {
    var socketIds = io.nsps['/'].adapter.rooms[name];
    if (socketIds) {
        var collection = [];
        for (var key in socketIds) {
            collection.push(key);
        }
        return collection;
    } else {
        return [];
    }
}

io.on('connection', function(socket){
    console.log('connection');
    socket.on('disconnect', function(){
        console.log('disconnect');
        if (socket.room) {
            var room = socket.room;
            io.to(room).emit('leave', socket.id);
            socket.leave(room);
        }
    });

    socket.on('join', function(name, callback){
        console.log('join', name);
        var socketIds = socketIdsInRoom(name);
        callback(socketIds);
        socket.join(name);
        socket.room = name;
    });


    socket.on('exchange', function(data){
        console.log('exchange', data);
        data.from = socket.id;
        var to = io.sockets.connected[data.to];
        to.emit('exchange', data);
    });
});

app.use('/.well-known', express.static(path.join(__dirname, '.well-known')))

app.get('/', function(req, res){
    console.log('get /');
    res.sendFile(__dirname + '/index.html');
});
server1.listen(serverPort1, function(){
    console.log('server up and running at %s port', serverPort1);
    if (process.env.LOCAL) {
        open('https://liive.io:' + serverPort1)
    }
});

server2.listen(serverPort2, function(){
    console.log('server up and running at %s port', serverPort2);
    if (process.env.LOCAL) {
        open('http://liive.io/.well-known/thing.txt')
    }
});

server3.listen(serverPort3, function(){
    console.log('server up and running at %s port', serverPort3);
    if (process.env.LOCAL) {
        open('https://liive.io/.well-known/thing.txt')
    }
});

