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
	buildJoinResponce: (responce) =>{
		const packet = Buffer.alloc(5);
		packet.write("MJRS");
		packet.writeUInt8(responce, 4);
		return packet;
	},
	buildHostResponce: () =>{
		const packet = Buffer.alloc(4);
		packet.write("MHRS");
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
			console.log("++[STARTRING SERVER]++")
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
		this.matches.map((match) => {
			if(match.code.toUpperCase() == client.matchCode.toUpperCase()){
				if(client.isPlayer){
					match.players.splice(match.players.indexOf(client), 1);
					console.log("["+match.code.toUpperCase()+"] Has " + match.players.length + "/" + match.maxPlayers + " players");
					if(match.players.length <= 0) {
						console.log("["+match.code.toUpperCase()+"] Is empty and has been removed");
						this.matches.splice(this.matches.indexOf(match), 1);
						//console.log(this.matches.length);
					}

				}else{
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
				if(match.players.length < match.maxPlayers) {
					match.players.push(client);
					client.isPlayer = true;
					console.log("["+match.code.toUpperCase()+"] " + client.username + " joined the match");
					console.log("["+match.code.toUpperCase()+"] Has " + match.players.length + "/" + match.maxPlayers + " players");
					foundMatch = true;
					isPlayer = true;
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
		this.sock.write(MTGP.buildJoinResponce(matchResponce));
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
		this.sock.write(MTGP.buildHostResponce());
	}
}

class Match{
	constructor(matchCode){
		this.code = matchCode;
		this.maxPlayers = 8;
		this.players = [];
		this.spectators = [];
	}
}

new Server();