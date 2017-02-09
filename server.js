const MTGP = {
	NAME_SHORT: 1,
	NAME_LONG: 2,
	NAME_INVALID: 3,
	GOOD: 0,
	MATCH_FULL: 1,
	MATCH_INVALID: 2,
	buildNameError: (err) =>{
		const packet = Buffer.alloc(4);
		packet.write("ERR");
		packet.writeUInt8(err, 3);
		return packet;
	},
	buildMatchError: (err) =>{
		const packet = Buffer.alloc(4);
		packet.write("ERR");
		packet.writeUInt8(err, 3);
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
		console.log("[SERVER] A client disconnected (IP:" + client.sock.remoteAddress + ")");
		this.clients.splice(this.clients.indexOf(client), 1);
	}
	isNameOkay(username){
		if(username.length < 2) return MTGP.NAME_SHORT;
		if(username.length > 8) return MTGP.NAME_LONG;
		if(!name.match(/^[a-zA-Z0-9\s\.\-\_]+$/)) return TTTP.NAME_INVALID;

		return MTGP.GOOD;
	}
	checkForMatch(matchCode, client){
		this.matches.map((match) => {
			if(matchCode == match.code) {
				if(match.currentPlayers < match.maxPlayers) {
					match.currentPlayers++;
					match.players.push(client.playerid);
					return MTGP.GOOD;
				}else{
					return MTGP.MATCH_FULL;
				}
			}
		});

		return MTGP.MATCH_INVALID;
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
		else { this.sock.write(MTGP.buildNameError(errorCode)); }

		//Check to see if the match exist
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
		else { this.sock.write(MTGP.buildNameError(errorCode)); }

		//Check for match
		let matchResponce = this.server.checkForMatch(matchCode, this);
		if(matchResponce === 0) { this.matchCode = matchCode; }
		else { this.sock.write(MTGP.buildMatchError(matchResponce)); }
	}
}

class Match{
	constructor(matchCode){
		this.code = matchCode;
		this.currentPlayers = 1;
		this.maxPlayers = 8;
		this.players = [];
	}
}

new Server();