var port = 1234;
var clients = [];
var charSplit = "\n";
var net = require("net");

net.createServer(function(client){

	client.IP = client.remoteAddress;
	clients.push(client);
	console.log(client.IP + " has connected!");//pushing new clients into the client array

	var buffer = "";

	client.on('data' function(data){//clients are sending data to the server
		buffer += data;//loads data into the buffer
		var messsages = buffer.split(charSplit);//spliting the messages based on the charSplit(\n)
		buffer = messsages.pop();

		for(var i = 0; i < messsages.length; i++){
			var msg = messages[i];

			if(msg.indexOf("NAME:") == 0){
				var name = msg.substr(5);
				client.name = name;
			}

			if(msg.indexOf("INIT:") == 0){
				var initials = msg.substr(5);
				client.initials = initials;
			}
		}
	});
	client.on('error', function(e){
		console.log("error with " + client.name + ": " + e);
	});
	client.on('close', function(b){
		console.log(client.name + " has disconnected!");
        var index = clients.indexOf(client);
        clients.splice(index, 1);
	});
});