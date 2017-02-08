const MTGP = {

};

class Server {
	constructor(){
		this.port = 1234;
		this.clients = [];
		this.player1 = null;
		this.player2 = null;

		this.sock = require("net").createServer((sock) => {
			this.clients.push(new Client(this, sock));
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
}

class Client {
	constructor(server, sock){
		
		this.playerid = 0;
		this.server = server;
		this.sock = sock;
		this.buffer = Buffer.alloc(0);
		this.username = "";

		this.sock.on('error', (msg) => {});
		this.sock.on('close', () => { this.server.handleDisconnect(this); });
		this.sock.on('data', (data) => this.onData(data));

		console.log("[SERVER] A new client connected (IP:" + sock.remoteAddress + ")");
	}
	onData(data){
	}
}

new Server();