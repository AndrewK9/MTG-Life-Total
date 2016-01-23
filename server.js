var port = 1234;
var clients = [];
var charSplit = "\n";
var net = require("net");
var clientNumb = 0;
var allowNewPlayers = true;
var startingLife = 20;
var readline = require('readline');

var rl = readline.createInterface(process.stdin, process.stdout);

rl.question("What is the starting life total? ", function(life){	 	
 	if(isInt(life)) {
 		startingLife = life;
 		console.log(">Starting life has been set to ", life);
 	}else{
 		console.log(">ERROR! User input for life wasn't a number! Starting life will be 20");
 	}

 	rl.setPrompt("What port should the server use? ");
 	rl.prompt();
 	rl.on('line', function(portNum){
 		if(isInt(portNum)) {
 			port = portNum;
 			console.log(">Server will run on port ", portNum);
 		}else{
 			console.log(">ERROR! User input for port wasn't a number! Server will run on port 1234");
 		}
 		rl.close();
 	});
});

function isInt(value) {
  return !isNaN(value) && 
         parseInt(Number(value)) == value && 
         !isNaN(parseInt(value, 10));
}

rl.on('close', function(){
	net.createServer(function(client){
	
		client.IP = client.remoteAddress;
		clients.push(client);
		console.log(">" + client.IP + " CONNECTED");//pushing new clients into the client array
		clientNumb++;
		client.number = clientNumb;
		if(!allowNewPlayers) {//If the match has started, clients are forced to the main screen
			client.write("EXIT:" + charSplit);
			client.end();
		}
		if(allowNewPlayers){
			client.write("GOOD:" + charSplit);
		}
	
		var buffer = "";
	
		client.on('data', function(data){//clients are sending data to the server
			buffer += data;//loads data into the buffer
			var messages = buffer.split(charSplit);//spliting the messages based on the charSplit(\n)
			buffer = messages.pop();
	
			for(var i = 0; i < messages.length; i++){
				var msg = messages[i];
	
				if(msg.indexOf("NAME:") == 0){
					var name = msg.substr(5);
					client.name = name;
					console.log(">IP: " + client.IP + " set name to " + client.name);
				}
	
				if(msg.indexOf("INIT:") == 0){
					var initials = msg.substr(5);
					client.initials = initials;
					console.log(">IP: " + client.IP + " set initials to " + client.initials);
					newClientBroadcast(client.number, client.name, client.initials);//once the players data is saved, we broadcast to all other clients that someone joined
	
					//if the new client isn't the first, we have to send all the previous clients info to the new client
					if(client.number >= 2){
						for(var i = 0; i < clients.length; i++){
							var msg = "";
							msg += "NP:" + clients[i].initials + " - " + clients[i].name + charSplit;
							if(clients[i].number == client.number) return; //this stops us from sending the new clients info, no need to do that since we did it in newClientBroadcast :)
							client.write(msg);
						}
					}
				}
	
				if(msg.indexOf("START:") == 0){
					launchMatch();
				}
			}
		});
		client.on('error', function(e){
			console.log(">ERROR " + client.name + " | " + client.IP + ": " + e);
		});
		client.on('close', function(b){
			console.log(">" + client.name + " | " + client.IP + " | " + " DISCONNECTED");
	        var index = clients.indexOf(client);
	        clients.splice(index, 1);
	        clientHasLeft();
		});
	}).listen(port);
	console.log("==========[SERVER STARTED]==========");
	console.log(">Listening on port " + port);
	console.log(">Waiting for players to connect");
});

//When a new client joins this funciton sends the name and initials to all players, players add the data to their txt_LOBBY.text
function newClientBroadcast(clientNumb, clientName, clientInit){
	var msg = "";
	msg += "NP:" + clientInit + " - " + clientName + charSplit;
	console.log(">Client lobbies have been updated with a new player");
	for(var i = 0; i < clients.length; i++){
		clients[i].write(msg);
	}
}

//When clients quit or crash we clear all the lobbies and resend the user data
function clientHasLeft(){
	var msg = "";
	msg += "LP:" + charSplit;
	console.log(">Clearing clients lobbies so we can repopulate them");
	for(var i = 0; i < clients.length; i++){
		clients[i].write(msg);
	}
	console.log(">All client lobbies are clear");
	for(var i = 0; i < clients.length; i++){
		var message = "";
		message += "NP:" + clients[i].initials + " - " + clients[i].name + charSplit;
		clients[i].write(message);
	}
	console.log(">Lobbies have been repopulated");
}

function launchMatch(){
	var msg = "BEGIN:" + charSplit;
	for(var i = 0; i < clients.length; i++){
		clients[i].write(msg);
	}
	allowNewPlayers = false;
	loadPlayerData();
	sendStartingHealth();
}

function loadPlayerData(){
	for(var i = 0; i < clients.length; i++){
		clients[i].life = startingLife;
		clients[i].infect = 0;
		sendStartingData(clients[i].number, clients[i].initials, clients[i].name, clients[i].life, clients[i].infect);
	}
	console.log(">All clients have the player information");
	console.log("==========[THE MATCH HAS STARTED]==========");
}

//sends clients the starting info as long as their client.number isn't the number of the current clients info being sent
function sendStartingData(clientToIgnore, clientInit, clientName, clientLife, clientInfect){
	var msg = "";
	msg += "PINIT:"+clientInit+charSplit+"PNAME:"+clientName+charSplit+"PLIFE:"+clientLife+charSplit+"PINFT:"+clientInfect+charSplit+"FIN:"+charSplit;
	for(var i = 0; i < clients.length; i++){
		if(clients[i].number != clientToIgnore) clients[i].write(msg);
	}
}

//sends starting health to the players
function sendStartingHealth(){
	var msg = "HEALTH:" + startingLife + charSplit;
	for(var i = 0; i < clients.length; i++){
		clients[i].write(msg);
	}
}