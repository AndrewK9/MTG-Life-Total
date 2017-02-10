package as3 {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class GSLobby extends GameScene {
		
		public function GSLobby() {
			trace("=============[Loaded Login Events]==============");
		}
		public override function dispose():void {
			trace("=============[Unloaded Login Events]==============");
		}
	}
}
