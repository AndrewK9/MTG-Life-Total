const MTGP = {
	NAME_SHORT: 1,
	NAME_LONG: 2,
	NAME_INVALID: 3,
	GOOD: 0,
	MATCH_FULL: 1,
	MATCH_INVALID: 2,
	buildNameError: (err) =>{
		const packet = Buffer.alloc(5);
		packet.write("NERR");
		packet.writeUInt8(err, 4);
		return packet;
	},
	buildMatchError: (err) =>{
		const packet = Buffer.alloc(5);
		packet.write("MERR");
		packet.writeUInt8(err, 4);
		return packet;
	},
	buildJoinResponce: (responce, matchCode, numOfPlayers) =>{
		const packet = Buffer.alloc(12);
		packet.write("MJRS");
		packet.writeUInt8(responce, 4);
		packet.writeUInt8(numOfPlayers, 5);
		packet.write(matchCode, 6);
		return packet;
	},
	buildHostResponce: (matchCode) =>{
		const packet = Buffer.alloc(10);
		packet.write("MHRS");
		packet.write(matchCode.toUpperCase(), 4);
		return packet;
	},
	buildStartPacket: (isPlayer) =>{
		const packet = Buffer.alloc(5);
		packet.write("PSTG");
		packet.writeUInt8(isPlayer ? 1 : 0, 4);
		return packet;
	},
	buildLobbyUpdate: (numOfPlayers) =>{
		const packet = Buffer.alloc(5);
		packet.write("LUPD");
		packet.writeUInt8(numOfPlayers, 4);
		return packet;
	},
	buildUpdate: (client)=>{
		const packet = Buffer.alloc(7);
		packet.write("UPDT");
		packet.writeUInt8(client.playerid, 4);
		packet.writeUInt8(client.health, 5);
		packet.writeUInt8(client.infect, 6);
		return packet;
	},
	buildPrivateUpdate: (client)=>{
		const packet = Buffer.alloc(6);
		packet.write("PUDT");
		packet.writeUInt8(client.health, 4);
		packet.writeUInt8(client.infect, 5);
		return packet;
	},
	buildStartUpdatePacket: (player, match) => {
		const packet = Buffer.alloc(16);
		packet.write("GSUD");
		packet.writeUInt8(player.playerid, 4);
		packet.writeUInt8(player.health, 5);
		packet.writeUInt8(player.infect, 6);
		packet.writeUInt8(match.maxInfect, 7)
		packet.write(player.username, 8);
		return packet;
	},
};

class Server {
	constructor(){
		this.port = 1234;
		this.clients = [];
		this.matches = [];
		this.id = 0;

		this.sock = require("net").createServer((sock) => {
			this.clients.push(new Client(this, sock, this.id));
			this.id++;
		});
		this.sock.listen(this.port, () => {
			console.log("++[STARTRING SERVER]++");
			console.log("[SERVER] The server is running on port " + this.port);
		});
	}
	handleDisconnect(client){
		console.log("[SERVER] "+client.username+" disconnected (IP:" + client.sock.remoteAddress + ")");
		//Check to see if they were in a match
		if(client.matchCode != ""){
			//Remove them from the match
			this.removeFromMatch(client);
		}
		this.clients.splice(this.clients.indexOf(client), 1);
	}
	removeFromMatch(client){
		//We will loop though all the matches looking for one that matches the clients match code
		this.matches.map((match) => {
			if(match.code.toUpperCase() == client.matchCode.toUpperCase()){
				if(client.isPlayer){
					//The player is a client, we should update the lobby
					match.players.splice(match.players.indexOf(client), 1);
					console.log("["+match.code.toUpperCase()+"] Has " + match.players.length + "/" + match.maxPlayers + " players");
					if(!match.hasStarted) this.broadcastNewGSLobbyPlayer(match.code, match.players.length);
					else match.broadcastRageQuit(client);
					if(match.players.length <= 0) {
						//The match is now empty, let's remove it
						console.log("["+match.code.toUpperCase()+"] Is empty and has been removed");
						this.matches.splice(this.matches.indexOf(match), 1);
						//console.log(this.matches.length);
					}
				}else{
					//The client is a spectator, we will siently remove them
					match.spectators.splice(match.spectators.indexOf(client), 1);
					console.log("["+match.code.toUpperCase()+"] " + client.username + " has stopped spectating the match");
				}
			}
		});
	}
	isNameOkay(username){
		if(username.length < 2) return MTGP.NAME_SHORT;
		if(username.length > 8) return MTGP.NAME_LONG;
		if(!username.match(/^[a-zA-Z0-9\s\.\-\_]+$/)) return MTGP.NAME_INVALID;

		return MTGP.GOOD;
	}
	checkForMatch(matchCode, client){
		//console.log(">"+matchCode+"<");
		//console.log(this.matches.length);
		let foundMatch = false;
		let isPlayer = false;
		if(!matchCode.match(/^[a-zA-Z]+$/)) return MTGP.MATCH_INVALID;
		this.matches.map((match) => {
			if(matchCode.toUpperCase() == match.code.toUpperCase()) {
				if(match.players.length < match.maxPlayers && !match.hasStarted) {
					match.players.push(client);
					client.isPlayer = true;
					client.match = match;
					console.log("["+match.code.toUpperCase()+"] " + client.username + " joined the match");
					console.log("["+match.code.toUpperCase()+"] Has " + match.players.length + "/" + match.maxPlayers + " players");
					foundMatch = true;
					isPlayer = true;
					//console.log(match.players.length);
					if(match.players.length > 1) this.broadcastNewGSLobbyPlayer(matchCode, match.players.length);
				}else{
					//The new player is a spectator
					match.spectators.push(client);
					console.log("["+match.code.toUpperCase()+"] " + client.username + " is spectating the match");
					foundMatch = true;
				}
			}
		});

		if(!foundMatch) { return MTGP.MATCH_INVALID; } //We couldn't find a match
		else if(!isPlayer) { return MTGP.MATCH_FULL; } //The match was full so the client is a spectator
		else { return MTGP.GOOD; } //We found the match and there was space for another player
	}
	broadcastNewGSLobbyPlayer(code, numOfPlayers){
		this.clients.map((client)=>{
			if(client.matchCode.toUpperCase() == code.toUpperCase()){
				//This client is in the match, tell them it started
				client.sock.write(MTGP.buildLobbyUpdate(numOfPlayers));
			}
		});
	}
	createMatch(){
		const matchCode = this.generateMatchCode();
		this.matches.push(new Match(matchCode));
		return matchCode;
	}
	generateMatchCode(){
		const letter1 = this.getRandomInt(1,26);
		const letter2 = this.getRandomInt(1,26);
		const letter3 = this.getRandomInt(1,26);
		const letter4 = this.getRandomInt(1,26);
		const letter5 = this.getRandomInt(1,26);
		const letter6 = this.getRandomInt(1,26);

		var matchCode = "";
		matchCode = this.getLetterFromInt(letter1)+
		this.getLetterFromInt(letter2)+
		this.getLetterFromInt(letter3)+
		this.getLetterFromInt(letter4)+
		this.getLetterFromInt(letter5)+
		this.getLetterFromInt(letter6);

		console.log("[SERVER] New host generated match code: " + matchCode.toUpperCase());

		return matchCode;
	}
	getRandomInt(min, max){
		return Math.floor(Math.random() * (max - min + 1)) + min;
	}
	getLetterFromInt(number){
		switch(number){
        	case 1:
        	    return "a";
        	case 2:
        	    return "b";
        	case 3:
        	    return "c";
        	case 4:
        	    return "d";
        	case 5:
        	    return "e";
        	case 6:
        	    return "f";
        	case 7:
        	    return "g";
        	case 8:
        	    return "h";
        	case 9:
        	    return "i";
        	case 10:
        	    return "j";
        	case 11:
        	    return "k";
        	case 12:
        	    return "l";
        	case 13:
        	    return "m";
        	case 14:
        	    return "n";
        	case 15:
        	    return "o";
        	case 16:
        	    return "p";
        	case 17:
        	    return "q";
        	case 18:
        	    return "r";
        	case 19:
        	    return "s";
        	case 20:
        	    return "t";
        	case 21:
        	    return "u";
        	case 22:
        	    return "v";
        	case 23:
        	    return "w";
        	case 24:
        	    return "x";
        	case 25:
        	    return "y";
        	case 26:
        	    return "z";
    	}
	}
	attemptMatchStart(code, client){
		this.matches.map((match)=>{
			if(code.toUpperCase() == match.code.toUpperCase()){
				//We found the match, we need to check if there are enough players
				if(match.players.length >= 2){
					//The match can start
					match.hasStarted = true;
					console.log("["+match.code.toUpperCase()+"] " + client.username + " has started the match");
					//TODO: Send clients a start packet
					match.broadcastStartMatch();
					match.calculateMatch();
					//We have to set a timeout because not all clients are loading into the match before we start sending them the other clients.
					setTimeout(()=>{
						match.releaseTheClients();
					}, 3000);
				}else{
					//The match can't start
					console.log("["+match.code.toUpperCase()+"] Not enough players to start a match");
				}
			}
		});
	}
	getLobbyNumber(code){
		let numOfPlayers = 0;
		this.matches.map((match)=>{
			if(match.code.toUpperCase() == code.toUpperCase()){
				//We found the match, return the number
				numOfPlayers =  match.players.length;
				return;
			}
		});

		return numOfPlayers;
	}
}

class Client {
	constructor(server, sock, id){
		
		this.playerid = id;
		this.server = server;
		this.sock = sock;
		this.buffer = Buffer.alloc(0);
		this.username = "";
		this.matchCode = "";
		this.isPlayer = false;
		this.match = null;
		this.health = 0;
		this.infect = 0;
		this.isDead = true;

		this.sock.on('error', (msg) => {});
		this.sock.on('close', () => { this.server.handleDisconnect(this); });
		this.sock.on('data', (data) => this.onData(data));

		console.log("[SERVER] A new client connected (IP:" + sock.remoteAddress + ", ID: " + this.playerid + ")");
	}
	onData(data){
		console.log("[SERVER] Handling incoming data");
		this.buffer = Buffer.concat([this.buffer, Buffer.from(data)]);

		while(this.buffer.length > 0){
			if(this.tryReadingPacket()) { break; }
			this.destroyStreamData();
		}
	}
	destroyStreamData(){
		this.buffer = this.buffer.slice(1, this.buffer.length);
		console.log("[SERVER] Destroying stream data");
	}
	tryReadingPacket(){
		console.log("[SERVER] Trying to read the packet");
		switch(this.getNextPacketType()){
			case null:
				break;
			case "JOIN":
				this.readPacketJoin();
				break;
			case "HOST":
				this.readPacketHost();
				break;
			case "UMSR":
				this.readPacketStart();
				break;
			case "UIUP":
				this.readPacketInput();
				break;
			default:
				return false;
				break;
		}
		return true;
	}
	getNextPacketType(){
		console.log("[SERVER] Grabbing packet type");
		if(this.buffer.length < 4) return null;
		console.log("[SERVER] Packet type: " + this.buffer.slice(0, 4).toString());
		return this.buffer.slice(0, 4).toString();
	}
	splitBufferAt(n){
		this.buffer = this.buffer.slice(n, this.buffer.length);
	}
	readPacketJoin(){
		console.log("[SERVER] Parsing the join packet");
		//console.log(this.buffer.length);
		if(this.buffer.length < 11) return;
		const matchCode = this.buffer.slice(4, 10).toString();
		const usernameLength = this.buffer.readUInt8(10);
		const packetLength = 11 + usernameLength;
		//console.log(this.buffer.length + ":" + packetLength);
		if(this.buffer.length < packetLength) return;
		const username = this.buffer.slice(11, 11 + usernameLength).toString();
		this.splitBufferAt(packetLength);
		//console.log(">" + matchCode + "<>" + username + "<");

		//Handle the username
		let errorCode = this.server.isNameOkay(username);
		if(errorCode === 0) { this.username = username; }
		else { 
			this.sock.write(MTGP.buildNameError(errorCode));
			console.log("[ERROR] " + username + " is an invalid username");
			return;
		}

		//Check to see if the match exist
		let matchResponce = this.server.checkForMatch(matchCode, this);
		//console.log(matchResponce);
		if(matchResponce === 0 || matchResponce === 1) {
			this.matchCode = matchCode;
			//console.log(this.matchCode.toUpperCase());
		}
		if(matchResponce === 2) { 
			this.sock.write(MTGP.buildMatchError(matchResponce));
			console.log("[ERROR] " + matchCode.toUpperCase() + " is invalid");
			return;
		}

		//If we make it this far it means the match code and username were good to go
		this.sock.write(MTGP.buildJoinResponce(matchResponce, this.matchCode, this.server.getLobbyNumber(this.matchCode)));
	}
	readPacketHost(){
		if(this.buffer.length < 5) return;
		const usernameLength = this.buffer.readUInt8(4);
		const packetLength = 5 + usernameLength;
		if(this.buffer.length < packetLength) return;
		const username = this.buffer.slice(5, 5 + usernameLength).toString();
		this.splitBufferAt(packetLength);
		console.log(">" + username + "<");

		//Handle the username
		let errorCode = this.server.isNameOkay(username);
		if(errorCode === 0) { this.username = username; }
		else { 
			this.sock.write(MTGP.buildNameError(errorCode));
			console.log("[ERROR] " + username + " is invalid");
			return;
		}
		//If we made it this far it means the username was legit
		//Create match
		this.matchCode = this.server.createMatch();
		let matchResponce = this.server.checkForMatch(this.matchCode, this);
		//Inform the player that they are good to go
		this.sock.write(MTGP.buildHostResponce(this.matchCode));
	}
	readPacketStart(){
		//console.log("A player tried to start, let's see what happens.");
		//A player has pressed the start button, we need to try to start thier match
		this.server.attemptMatchStart(this.matchCode, this);
		this.splitBufferAt(4);
	}
	readPacketInput(){
		//console.log(this.buffer.length);
		if(this.buffer.length < 5) return;
		const inputType = this.buffer.readUInt8(4);
		//console.log("I am reading packet input: " + inputType);
		//Now that we have the input type, we can pass it to the server
		this.match.handlePlayerInput(inputType, this);
		this.splitBufferAt(5);
	}
}

class Match{
	constructor(matchCode){
		this.code = matchCode;
		this.maxPlayers = 3;
		this.players = [];
		this.spectators = [];
		this.hasStarted = false;
		this.startingHealth = 0;
		this.maxInfect = 0;
	}
	handlePlayerInput(inputType, client){
		//TODO: Check for input type with a switch and handle it
		switch(inputType){
			case 1:
				this.minusHealth(client);
				break;
			case 2:
				this.addHealth(client);
				break;
			case 3:
				this.minusInfect(client);
				break;
			case 4:
				this.addInfect(client);
				break;
			default:
				console.log("["+this.code.toUpperCase()+"] Recieved an unknown input type");
				break;
		}
	}
	minusHealth(client){
		client.health--;
		if(client.health < 0) client.health = 0;
		console.log("["+this.code.toUpperCase()+"] " + client.username + " lost health");
		this.broadcastUpdate(client);
	}
	addHealth(client){
		client.health++;
		console.log("["+this.code.toUpperCase()+"] " + client.username + " gained health");
		this.broadcastUpdate(client);
	}
	minusInfect(client){
		client.infect--;
		if(client.infect < 0) client.infect = 0;
		console.log("["+this.code.toUpperCase()+"] " + client.username + " lost infect");
		this.broadcastUpdate(client);
	}
	addInfect(client){
		client.infect++;
		console.log("["+this.code.toUpperCase()+"] " + client.username + " gained infect");
		this.broadcastUpdate(client);
	}
	broadcastUpdate(client){
		client.sock.write(MTGP.buildPrivateUpdate(client));

		this.players.map((player)=>{
			if(player != client){
				player.sock.write(MTGP.buildUpdate(client));
			}
		});

		this.spectators.map((spec)=>{
			spec.sock.write(MTGP.buildUpdate(client));
		});
	}
	calculateMatch(){
		this.startingHealth = this.players.length * 10;
		this.maxInfect = this.startingHealth/2;
		console.log("["+this.code.toUpperCase()+"] Generated a starting health of: " + this.startingHealth + " and max infect of: " + this.maxInfect);
		this.players.map((player)=>{
			player.health = this.startingHealth;
			player.infect = 0;
			player.isDead = false;
		});
	}
	releaseTheClients(){
		//console.log("Updating all players about each other");
		this.players.map((player1)=>{
			this.players.map((player2)=>{
				if(player1 != player2){
					player1.sock.write(MTGP.buildStartUpdatePacket(player2, this));
				}
			});
		});

		this.spectators.map((spec)=>{
			this.players.map((player)=>{
				spec.sock.write(MTGP.buildStartUpdatePacket(player, this));
			});
		});
	}
	broadcastStartMatch(){
		//console.log("Finding clients in the match and telling them to start");

		this.players.map((player)=>{
			player.sock.write(MTGP.buildStartPacket(player.isPlayer));
		});

		this.spectators.map((spec)=>{
			spec.sock.write(MTGP.buildStartPacket(spec.isPlayer));
		});
	}
	broadcastRageQuit(client){
		client.isDead = true;
		client.health = 0;
	}
}

new Server();