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
