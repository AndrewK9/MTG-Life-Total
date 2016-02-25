package as3 {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	
	public class WinScreen extends MovieClip {

		var buffer:String = "";
		var charSplit:String = "\n";
		
		public function WinScreen() {
			bttn_rematch.addEventListener(MouseEvent.CLICK, handleClick);
      MainApp.socket.addEventListener(ProgressEvent.SOCKET_DATA, handleData);
			trace("=============[Loaded Win Screen Events]==============");
		}
		function handleData(e:ProgressEvent):void {
			buffer += MainApp.socket.readUTFBytes(MainApp.socket.bytesAvailable);
			var messages:Array = buffer.split(charSplit);
			buffer = messages.pop();

			trace(">Incoming Game Messages:");
			trace(">" + messages);
			trace(">End of Incoming Game Messages");

			var playerName:String = "";
	    var playerInit:String = "";
			
			for(var i = 0; i < messages.length; i++){
				var msg:String = messages[i];

            	if(msg.indexOf("PINIT:") == 0){//Used whe the game starts
            	    playerInit = msg.substr(6);
            	 }
            	if(msg.indexOf("PNAME:") == 0){//Used whe the game starts
            	    playerName = msg.substr(6);
              	 }
              if(msg.indexOf("WIN:")==0){
                txt_WINNER.text = "";
                txt_WINNER.appendText(playerInit+" - "+playerName+" Wins!");
              }
              if(msg.indexOf("BEGIN:") == 0){
                trace(">Someone hit the restart button")
                  clearScreen();
                  dispose();
                  addChild(new GameScreen());
              }
			}		
		}
		function handleClick(e:Event){
	    var msg = "RE:";
		  MainApp.socket.writeUTFBytes(msg + charSplit);
		  MainApp.socket.flush();
		  trace(">Sent an update to the server: " + msg);
		}	
		public function dispose():void {
		  bttn_rematch.removeEventListener(MouseEvent.CLICK, handleClick);
      MainApp.socket.removeEventListener(ProgressEvent.SOCKET_DATA, handleData);
			trace("=============[Unloaded Winner Events]==============");
		}
		public function clearScreen(){
			trace(">Clearing Stage Children");
			for(var i = numChildren - 1; i >= 0; i--){
				var child = getChildAt(i);
				if(child.hasOwnProperty("dispose")) child.dispose();
				removeChildAt(i);
			}
		}
	}
}
