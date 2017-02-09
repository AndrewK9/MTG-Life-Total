package as3 {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class GSMain extends GameScene {

		private var usIP:String = "127.0.0.1";
		private var usPort:String = "1234";
		
		public function GSMain() {
			bttnConnect.addEventListener(MouseEvent.CLICK, handleConnectClick);
			host.addEventListener(MouseEvent.CLICK, handleWebsite);
			bttnServerOptions.addEventListener(MouseEvent.CLICK, handleGear);
			serverOptions.visible = false;
			ip.visible = false;
			port.visible = false;
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
			return;
		}
		function handleSwitchUS(e:MouseEvent):void{
			//TODO: Load US server info for connection
			hideServerOptions();
			trace(">User switched to the US based server");
			ip.visible = false;
			port.visible = false;
		}
		function handleSwitchCustom(e:MouseEvent):void{
			//TODO: Load custom server input for connection
			hideServerOptions();
			trace(">User wanted to connect to a custom server");
			ip.visible = true;
			port.visible = true;
		}
		function handleConnectClick(e:MouseEvent):void {
			//TODO: Check what server is selected and handle the connection
			if(ip.visible){
				connect(ip.inputIPAddress.text, int(port.inputPortNumber.text));
			}else{
				connect(usIP, int(usPort));
			}
		}

		function connect(address:String, port:Number):void {
			Game.socket.connect(address, port);
		}		
		public override function dispose():void {
			bttnConnect.removeEventListener(MouseEvent.CLICK, handleConnectClick);
			host.removeEventListener(MouseEvent.CLICK, handleWebsite);
			bttnServerOptions.removeEventListener(MouseEvent.CLICK, handleGear);
			trace("=============[Unloaded Main Menu Events]==============");
		}
	}
	
}
