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
			//Game.showScene();
		}
		private function handleError(e:IOErrorEvent):void {
			
		}
		private function handleClose(e:Event):void {
			//Game.showScene();
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
				case "": break;
				default:
					return false;
					break;
			}
			return true;
		}
		private function destroyStreamData():void {
			buffer.trim();
		}
		private function getNextPacketType():String {
			if(buffer.length < 4) return "";
			return buffer.slice(0, 4).toString();
		}
		
		//////////////////////// HANDLING PACKETS: ///////////////////////////////
		private function readPacketJoin():void {
			
			if(buffer.length < 6) return; // not enough data in the stream; packet incomplete
			var playerid:int = buffer.readUInt8(4);
			var errcode:int = buffer.readUInt8(5);
			
			buffer.trim(6);
			
			if(playerid == 0){
				switch(errcode){
					case 1: trace("username too short"); break;
					case 2: trace("username too long"); break;
					case 3: trace("username uses invalid characters"); break;
					case 4: trace("username is already taken"); break;
					case 5: trace("The game session is full"); break;
					default: trace("unknown error"); break;
				}
			} else {
				// you are now in the game!
				//GameState.playerid = playerid;
				//Game.showScene();
			}
		}
		private function readPacketUpdt():void {
			if(buffer.length < 15) return; // not eough data in the stream; packet incomplete
			//GameState.update(buffer); // this feels like cheating
			
			buffer.trim(15);
		}
		private function readPacketWait():void {
			buffer.trim(4);
			//if(GameState.playerid != 0) Game.showScene(new GSWait());
		}
		
		//////////////////////// BUILDING PACKETS: ///////////////////////////////
		// Use ONLY this method for sending.
		// This will ensure that everything you send will use the LegitBuffer class
		public function write(buffer:LegitBuffer):void {
			writeBytes(buffer.byteArray);
			flush();
		}
		
		public function sendJoinRequest(playMode:Boolean, username:String):void {
			var buffer:LegitBuffer = new LegitBuffer();
			buffer.write("JOIN");
			buffer.writeUInt8(playMode ? 1 : 2, 4);
			buffer.writeUInt8(username.length, 5);
			buffer.write(username, 6);
			
			write(buffer);
		}
		public function sendMove(cell:int):void {
			var buffer:LegitBuffer = new LegitBuffer();
			buffer.write("MOVE");
			buffer.writeUInt8(cell, 4);
			
			write(buffer);
		}
		
	}
}
