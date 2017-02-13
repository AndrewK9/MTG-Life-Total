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
			
		}
		private function handleClose(e:Event):void {
			Game.showScene(new GSMain());
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
					break;
				case 2:
					trace("Username was too long");
					break;
				case 3:
					trace("Username was invalid");
					break;
				default:
					trace("Unknown username error");
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
					break;
				default:
					trace("Unknown match code error");
					break;
			}
		}
		private function readPacketJoinResponce():void{
			//TODO: Send user to the lobby screen and check to see if they're a sepctator
			if(buffer.length < 5) return;
			var responceType = buffer.readUInt8(4);

			buffer.trim(5);

			switch(responceType){
				case 0:
					trace("We're a player in the match");
					Game.showScene(new GSLobby());
					break;
				case 1:
					trace("We're a sepctator");
					Game.showScene(new GSLobby());
					break;
				default:
					trace("Unknown responce type");
					break;
			}
		}
		private function readPacketHostResponce():void{
			//TODO: Send user to the lobby screen
			if(buffer.length < 4) return;
			buffer.trim(4);
			Game.showScene(new GSLobby());
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
	}
}
