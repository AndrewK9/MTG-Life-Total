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
			
			switch(getNextPacketType()){
				case "":
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
				default:
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
			return buffer.slice(0, 4).toString();
		}
		
		//////////////////////// HANDLING PACKETS: ///////////////////////////////
		private function readPacketNameError():void{
			if(buffer.length < 5) return;
			var errCode = buffer.readUInt8(4);

			buffer.trim(5);

			switch(errCode){
				case 1:
					trace("Username was too short");
					Game.updateLoginErrorMessage("Username is too short.");
					break;
				case 2:
					trace("Username was too long");
					Game.updateLoginErrorMessage("Username is too long.");
					break;
				case 3:
					trace("Username was invalid");
					Game.updateLoginErrorMessage("Username was invalid.");
					break;
				default:
					trace("Unknown username error");
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
					trace("Match code was invalid");
					Game.updateLoginErrorMessage("Your match code was invalid.");
					break;
				default:
					trace("Unknown match code error");
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
					trace("We're a player in the match");
					Game.showScene(new GSLobby(matchCode, numOfPlayer, true));
					break;
				case 1:
					trace("We're a sepctator");
					Game.showScene(new GSLobby(matchCode, numOfPlayer, false));
					break;
				default:
					trace("Unknown responce type");
					break;
			}
		}
		private function readPacketHostResponce():void{
			//TODO: Send user to the lobby screen
			if(buffer.length < 10) return;
			buffer.trim(4);
			var matchCode = buffer.toString();
			trace(matchCode);
			buffer.trim(6);
			Game.showScene(new GSLobby(matchCode, 1, true));
		}
		private function readPacketLobbyUpdate():void{
			if(buffer.length < 5) return;
			var numOfPlayer = buffer.readUInt8(4);
			buffer.trim(5);
			Game.updateLobbyStatus(numOfPlayer);
		}
		private function readPacketStart():void{
			if(buffer.length < 5) return;
			var isPlayer = buffer.readUInt8(4) ? true : false;
			buffer.trim(5);
			Game.showScene(new GSMatch(isPlayer));
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
			var buffer:LegitBuffer = new LegitBuffer();
			buffer.write("UMSR");
			write(buffer);
		}
	}
}
