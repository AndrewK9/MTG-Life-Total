package as3 {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	
	public class NameScreen extends MovieClip {

		var charSplit:String = "\n";
		
		public function NameScreen() {
			input_NAME.addEventListener(KeyboardEvent.KEY_DOWN, handleKey);
			input_INITIALS.addEventListener(KeyboardEvent.KEY_DOWN, handleKey);
			bttn_SUBMIT.addEventListener(MouseEvent.CLICK, handleClick);
			trace("=============[Loaded Name Events]==============");
		}
		function handleKey(e:KeyboardEvent):void {
			if(e.keyCode == 13) submit();
		}
		function handleClick(e:MouseEvent):void {
			if(input_NAME.length >= 2 && input_INITIALS.length == 2) submit();
		}
		function submit():void {
			MainApp.socket.writeUTFBytes("NAME:" + input_NAME.text + charSplit + "INIT:" + input_INITIALS.text + charSplit);
			MainApp.socket.flush();
			trace(">Sent name and initials to the server");
			clearScreen();
			dispose();
			addChild(new LobbyScreen());
		}		
		public function dispose():void {
			input_NAME.removeEventListener(KeyboardEvent.KEY_DOWN, handleKey);
			input_INITIALS.removeEventListener(KeyboardEvent.KEY_DOWN, handleKey);
			bttn_SUBMIT.removeEventListener(MouseEvent.CLICK, handleClick);
			trace("=============[Unloaded Name Events]==============");
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
