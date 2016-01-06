package as3{
	
	import flash.display.MovieClip;
	import flash.net.Socket;
	import flash.events.*;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	
	public class MainApp extends MovieClip {
		
		public static var socket:Socket = new Socket();
		
		public function MainApp() {
			
			socket.addEventListener(IOErrorEvent.IO_ERROR, handleError);
			socket.addEventListener(Event.CLOSE, handleClose);
			trace("=============[Loaded MainApp Events]==============");
			showSplashScreen();

		}

		function handleError(e:IOErrorEvent):void {
			trace(e.text);
			showConnectScreen();
		}

		function handleClose(e:Event):void {
			showConnectScreen();
		}
		public function showSplashScreen(){
			addChild(new SplashScreen());
		}
		public function showConnectScreen(){
			clearScreen();
			addChild(new ConnectScreen());
		}
		public function showNameScreen(){
			clearScreen();
			addChild(new NameScreen());
		}
		public function showLobbyScreen(){
			clearScreen();
			addChild(new LobbyScreen());
		}
		function dispose(){
			socket.removeEventListener(IOErrorEvent.IO_ERROR, handleError);
			socket.removeEventListener(Event.CLOSE, handleClose);
			trace("=============[Unloaded MainApp Events]==============");
		}
		public function clearScreen(){
			for(var i = numChildren - 1; i >= 0; i--){
				var child = getChildAt(i);
				if(child.hasOwnProperty("dispose")) child.dispose();
				removeChildAt(i);
			}
		}
	}
	
}
