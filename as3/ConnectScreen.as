package as3 {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.net.navigateToURL;//Needed for URL
	import flash.net.URLRequest;//More URL stuff
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	
	public class ConnectScreen extends MovieClip {

		var buffer:String = "";
		var charSplit:String = "\n";
		
		public function ConnectScreen() {
			input_IP.addEventListener(KeyboardEvent.KEY_DOWN, handleKey);
			input_PORT.addEventListener(KeyboardEvent.KEY_DOWN, handleKey);
			bttn_JOIN.addEventListener(MouseEvent.CLICK, handleClick);
			MainApp.socket.addEventListener(ProgressEvent.SOCKET_DATA, handleData);
			trace("=============[Loaded Connection Events]==============");
		}
		function handleData(e:ProgressEvent):void {
			buffer += MainApp.socket.readUTFBytes(MainApp.socket.bytesAvailable);
			trace(buffer);
			var messages:Array = buffer.split(charSplit);
			buffer = messages.pop();

			for(var i = 0; i < messages.length; i++){
				var msg:String = messages[i];
     			trace(messages[i]);
            	if(msg.indexOf("EXIT:") == 0){
            	    clearScreen();
            	    dispose();
            	    addChild(new MainApp());
            	}
            	if(msg.indexOf("GOOD:") == 0){
            	    clearScreen();
            	    dispose();
            	    addChild(new NameScreen());
            	}
			}		
		}
		function handleKey(e:KeyboardEvent):void {
			if(e.keyCode == 13) connect();
		}
		function handleClick(e:MouseEvent):void {
			connect();
		}
		function connect():void {
			MainApp.socket.connect(input_IP.text, int(input_PORT.text));
		}		
		public function dispose():void {
			input_IP.removeEventListener(KeyboardEvent.KEY_DOWN, handleKey);
			input_PORT.removeEventListener(KeyboardEvent.KEY_DOWN, handleKey);
			bttn_JOIN.removeEventListener(MouseEvent.CLICK, handleClick);
			MainApp.socket.removeEventListener(ProgressEvent.SOCKET_DATA, handleData);
			trace("=============[Unoaded Connection Events]==============");
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
