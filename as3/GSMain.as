package as3 {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.utils.*;//Needed for time
	
	public class GSMain extends GameScene {

		private var usIP:String = "75.135.157.91";
		private var usPort:String = "2231";

		private var time:Number = 0;
		private var waitTime:Number = 10;
		private var timesWaited:Number = 0;

		public function GSMain(reason:Number) {
			bttnConnect.addEventListener(MouseEvent.CLICK, handleConnectClick);
			host.addEventListener(MouseEvent.CLICK, handleWebsite);
			bttnServerOptions.addEventListener(MouseEvent.CLICK, handleGear);
			serverOptions.visible = false;
			ip.visible = false;
			port.visible = false;
			switch(reason){
				case 0: //This is a normal switch
					txtMessages.htmlText = "<FONT COLOR='#fffd66'>Attempting to connect to your desired server.</FONT>";
					txtMessages.visible = false;
					break;
				case 1: //There was an unknown issue
					txtMessages.htmlText = "<FONT COLOR='#ff6666'>An unknown error occurred. Sorry.</FONT>";
					txtMessages.visible = true;
					break;
			}
			trace("=============[Loaded Main Menu Events]==============");
		}
		function handleWebsite(e:MouseEvent):void {
			//TODO: Send client to the GitHub page
		}
		function handleGear(e:MouseEvent):void {
			//TODO: Show server switch popup, let the client switch to a custom server
			if(!serverOptions.visible){
				serverOptions.visible = true;
				trace(">Loaded server selection menu events");
				serverOptions.bttnUS.addEventListener(MouseEvent.CLICK, handleSwitchUS);
				serverOptions.bttnCustom.addEventListener(MouseEvent.CLICK, handleSwitchCustom);
				serverOptions.bttnExitOptions.addEventListener(MouseEvent.CLICK, handleInvisibleButton);
				return;
			}else{
				hideServerOptions();
			}
		}
		function hideServerOptions():void{
			serverOptions.visible = false;
			trace(">Unloaded server selection menu events");
			serverOptions.bttnUS.removeEventListener(MouseEvent.CLICK, handleSwitchUS);
			serverOptions.bttnCustom.removeEventListener(MouseEvent.CLICK, handleSwitchCustom);
			serverOptions.bttnExitOptions.removeEventListener(MouseEvent.CLICK, handleInvisibleButton);
			return;
		}
		function handleInvisibleButton(e:MouseEvent):void{
			hideServerOptions();
		}
		function handleSwitchUS(e:MouseEvent):void{
			//TODO: Load US server info for connection
			hideServerOptions();
			trace(">User switched to the US based server");
			ip.visible = false;
			port.visible = false;
			server.text = "US-East";
		}
		function handleSwitchCustom(e:MouseEvent):void{
			//TODO: Load custom server input for connection
			hideServerOptions();
			trace(">User wanted to connect to a custom server");
			ip.visible = true;
			port.visible = true;
			server.text = "Custom";
		}
		function handleConnectClick(e:MouseEvent):void {
			//TODO: Check what server is selected and handle the connection
			txtMessages.visible = true;
			txtMessages.htmlText = "<FONT COLOR='#fffd66'>Attempting to connect to your desired server.</FONT>";
			addEventListener(Event.ENTER_FRAME, connectionTimer);
			trace(">Added Connection Timer Event Listener");
			if(ip.visible){
				connect(ip.inputIPAddress.text, int(port.inputPortNumber.text));
			}else{
				connect(usIP, int(usPort));
			}
		}
		function connectionTimer(e:Event):void{
			var timeNew:int = getTimer();//Gets timer
			var deltaTime:Number = (timeNew - time)/1000;//Does math to see how much time has passed
			time = timeNew;//Keeps time updated
			waitTime -= deltaTime;
			trace("Time Till Error: " + waitTime);
			if (timesWaited >= 4){
				txtMessages.htmlText = "<FONT COLOR='#ff6666'>We were not able to connect to the server. Sorry.</FONT>";
				removeEventListener(Event.ENTER_FRAME, connectionTimer);
				trace(">Removed Connection Timer Event Listener");
				waitTime = 10;
				timesWaited = 0;
			}
			else if(waitTime <= 0){
				timesWaited++;
				waitTime = 10;
			}
		}
		function connect(address:String, port:Number):void {
			Game.socket.connect(address, port);
		}		
		public override function dispose():void {
			bttnConnect.removeEventListener(MouseEvent.CLICK, handleConnectClick);
			host.removeEventListener(MouseEvent.CLICK, handleWebsite);
			bttnServerOptions.removeEventListener(MouseEvent.CLICK, handleGear);
			removeEventListener(Event.ENTER_FRAME, connectionTimer);
			trace("=============[Unloaded Main Menu Events]==============");
		}
	}
	
}
