package as3 {
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.DataEvent;
	
	public class Connection extends Socket {

		var buffer:LegitBuffer = new LegitBuffer();
		
		public function Connection() {
			addEventListener(Event.CONNECT, handleConnect);
			addEventListener(IOErrorEvent.IO_ERROR, handleError);
			addEventListener(Event.CLOSE, handleClose);
			addEventListener(ProgressEvent.SOCKET_DATA, handleData);
		}
		private function handleConnect(e:Event):void {
			Game.showScene(new GSLogin());
		}
		private function handleError(e:IOErrorEvent):void {
			Game.showScene(new GSMain(1));
		}
		private function handleClose(e:Event):void {
			Game.showScene(new GSMain(1));
		}
		private function handleData(e:ProgressEvent):void {
			readBytes(buffer.byteArray, buffer.length);
			while(buffer.length > 0){
				if(tryReadingPacket()) break;
				destroyStreamData();
			}
		}
		private function tryReadingPacket():Boolean {
			//trace(buffer.length);
			if(buffer.length < 4) return false;
			switch(getNextPacketType()){
				case "":
					trace("Buffers too short");
					break;
				case "NERR":
					readPacketNameError();
					break;
				case "MERR":
					readPacketMatchError();
					break;
				case "MJRS":
					readPacketJoinResponce();
					break;
				case "MHRS":
					readPacketHostResponce();
					break;
				case "LUPD":
					readPacketLobbyUpdate();
					break;
				case "PSTG":
					readPacketStart();
					break;
				case "GSUD":
					readPacketStartUpdate();
					break;
				case "UPDT":
					readPacketUpdate();
					break;
				case "PUDT":
					readPacketPrivateUpdate();
					break;
				default:
					trace("I don't have this packet");
					return false;
					break;
			}
			return true;
		}
		private function destroyStreamData():void {
			buffer.trim(buffer.length);
		}
		private function getNextPacketType():String {
			if(buffer.length < 4) return "";
			var bufferType = buffer.slice(0, 4).toString();
			trace(">"+bufferType+"<");
			return bufferType;
		}
		
		//////////////////////// HANDLING PACKETS: ///////////////////////////////
		private function readPacketNameError():void{
			if(buffer.length < 5) return;
			var errCode = buffer.readUInt8(4);

			buffer.trim(5);

			switch(errCode){
				case 1:
					trace(">Username was too short");
					Game.updateLoginErrorMessage("Username is too short.");
					break;
				case 2:
					trace(">Username was too long");
					Game.updateLoginErrorMessage("Username is too long.");
					break;
				case 3:
					trace(">Username was invalid");
					Game.updateLoginErrorMessage("Username was invalid.");
					break;
				default:
					trace(">Unknown username error");
					Game.updateLoginErrorMessage("An unknown error occurred.");
					break;
			}
		}
		private function readPacketMatchError():void{
			if(buffer.length < 5) return;
			var errCode = buffer.readUInt8(4);

			buffer.trim(5);

			switch(errCode){
				case 2:
					trace(">Match code was invalid");
					Game.updateLoginErrorMessage("Your match code was invalid.");
					break;
				default:
					trace(">Unknown match code error");
					Game.updateLoginErrorMessage("An unknown error occurred.");
					break;
			}
		}
		private function readPacketJoinResponce():void{
			//TODO: Send user to the lobby screen and check to see if they're a sepctator
			if(buffer.length < 12) return;
			var responceType = buffer.readUInt8(4);
			var numOfPlayer = buffer.readUInt8(5);
			buffer.trim(6);
			var matchCode = buffer.toString();
			buffer.trim(6);

			switch(responceType){
				case 0:
					trace(">We're a player in the match");
					Game.showScene(new GSLobby(matchCode, numOfPlayer, true));
					break;
				case 1:
					trace(">We're a sepctator");
					Game.showScene(new GSLobby(matchCode, numOfPlayer, false));
					break;
				default:
					trace(">Unknown responce type");
					break;
			}
		}
		private function readPacketHostResponce():void{
			//trace("I recieved a host responce packet");
			//TODO: Send user to the lobby screen
			if(buffer.length < 10) return;
			buffer.trim(4);
			var matchCode = buffer.toString();
			trace(matchCode);
			buffer.trim(6);
			Game.showScene(new GSLobby(matchCode, 1, true));
		}
		private function readPacketLobbyUpdate():void{
			//trace("I recieved a lobby update packet");
			if(buffer.length < 5) return;
			var numOfPlayer = buffer.readUInt8(4);
			buffer.trim(5);
			trace(numOfPlayer);
			Game.updateLobbyStatus(numOfPlayer);
		}
		private function readPacketStart():void{
			//trace("I recieved a start packet");
			if(buffer.length < 5) return;
			var isPlayer = buffer.readUInt8(4) ? true : false;
			buffer.trim(5);
			Game.showScene(new GSMatch(isPlayer));
		}
		private function readPacketStartUpdate():void{
			//trace("I shold be reading start update packets");
			if(buffer.length < 10) return;
			var playerID = buffer.readUInt8(4);
			var health = buffer.readUInt8(5);
			var infect = buffer.readUInt8(6);
			var maxInfect = buffer.readUInt8(7);
			buffer.trim(8);
			var username = buffer.toString();
			buffer.trim(8);
			trace(">"+playerID + "<>" + health+"<>"+infect+"<>"+username+"<");
			Game.startUpdate(playerID, health, infect, username, maxInfect);
			tryReadingPacket();
		}
		private function readPacketUpdate():void{
			if(buffer.length < 7) return;
			var id = buffer.readUInt8(4);
			var health = buffer.readUInt8(5);
			var infect = buffer.readUInt8(6);
			buffer.trim(7);
			trace(">"+id+"<>"+health+"<>"+infect+"<");
			Game.update(id, health, infect);
			tryReadingPacket();
		}
		private function readPacketPrivateUpdate():void{
			if(buffer.length < 6) return;
			var health = buffer.readUInt8(4);
			var infect = buffer.readUInt8(5);
			buffer.trim(6);
			Game.privateUpdate(health, infect);
			tryReadingPacket();
		}
		//////////////////////// BUILDING PACKETS: ///////////////////////////////
		public function write(buffer:LegitBuffer):void {
			writeBytes(buffer.byteArray);
			flush();
			trace(">Flushed buffer");
		}
		
		public function sendJoinRequest(matchCode:String, username:String):void {
			var buffer:LegitBuffer = new LegitBuffer();
			buffer.write("JOIN");
			buffer.write(matchCode, 4);
			buffer.writeUInt8(username.length, 10);
			buffer.write(username, 11);
			write(buffer);
		}
		public function sendHostRequest(username:String):void {
			var buffer:LegitBuffer = new LegitBuffer();
			buffer.write("HOST");
			buffer.writeUInt8(username.length, 4);
			buffer.write(username, 5);
			write(buffer);
		}
		public function sendStartRequest():void{
			//trace("I sent a start request");
			var buffer:LegitBuffer = new LegitBuffer();
			buffer.write("UMSR");
			write(buffer);
		}
		public function sendInput(eventType:Number):void{
			trace("I sent a input to the server: " + eventType);
			var buffer:LegitBuffer = new LegitBuffer();
			buffer.write("UIUP");
			buffer.writeUInt8(eventType, 4);
			write(buffer);
		}
	}
}
