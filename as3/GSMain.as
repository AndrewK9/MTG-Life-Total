package as3 {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class GSMain extends GameScene {
		
		public function GSMain() {
			bttnConnect.addEventListener(MouseEvent.CLICK, handleClick);
			host.addEventListener(MouseEvent.CLICK, handleWebsite);
			bttnGear.addEventListener(MouseEvent.CLICK, handleGear);
			trace("=============[Loaded Main Menu Events]==============");
		}
		function handleWebsite(e:MouseEvent):void {
			//TODO: Send client to the GitHub page
		}
		function handleGear(e:MouseEvent):void {
			//TODO: Show server switch popup, let the client switch to a custom server
		}
		function handleClick(e:MouseEvent):void {
			//TODO: Check what server is selected and handle the connection
		}

		function connect(address:String, port:Number):void {
			Game.socket.connect(address, port);
		}		
		public override function dispose():void {
			bttnConnect.removeEventListener(MouseEvent.CLICK, handleClick);
			host.removeEventListener(MouseEvent.CLICK, handleWebsite);
			bttnGear.removeEventListener(MouseEvent.CLICK, handleGear);
			trace("=============[Unloaded Main Menu Events]==============");
		}
	}
	
}
