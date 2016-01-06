package as3 {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	
	public class LobbyScreen extends MovieClip {

		var buffer:String = "";
		var charSplit:String = "\n";
		
		public function LobbyScreen() {
			bttn_START.addEventListener(MouseEvent.CLICK, handleClick);
			MainApp.socket.addEventListener(ProgressEvent.SOCKET_DATA, handleData);
			trace("=============[Loaded Lobby Events]==============");
			txt_LOBBY.text = "";
		}
		function handleData(e:ProgressEvent):void {
			buffer += MainApp.socket.readUTFBytes(MainApp.socket.bytesAvailable);
			var messages:Array = buffer.split(charSplit);
			buffer = messages.pop();
			
			for(var i = 0; i < messages.length; i++){
				var msg:String = messages[i];
            
            	if(msg.indexOf("NP:") == 0){
            	    var player = msg.substr(3);
            	    txt_LOBBY.appendText(player + charSplit);
            	}
            	if(msg.indexOf("LP:") == 0){
            	    txt_LOBBY.text = "";
            	}
            	if(msg.indexOf("EXIT:") == 0){
            	    clearScreen();
            	    dispose();
            	    addChild(new MainApp());
            	}
            	if(msg.indexOf("START:") == 0){
            	    clearScreen();
            	    dispose();
            	    addChild(new GameScreen());
            	}
			}		
		}
		function handleClick(e:MouseEvent):void {
			startMatch();
		}
		function startMatch():void {
			MainApp.socket.writeUTFBytes("START:" + charSplit);
			MainApp.socket.flush();
			clearScreen();
			//addChild(new MatchScreen());
		}		
		public function dispose():void {
			bttn_START.removeEventListener(MouseEvent.CLICK, handleClick);
			trace("=============[Unloaded Lobby Events]==============");
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
