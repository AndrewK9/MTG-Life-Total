package as3 {
	
	import flash.display.MovieClip;
	
	public class Player extends GameScene {
		
		public var id:Number;
		public var pname = "";
		public var life = 0;
		public var infect = 0;
		
		public function Player(playerID:Number, playerName:String, playerLife:Number, playerInfect:Number) {
			id = playerID;
			pname = playerName;
			life = playerLife;
			infect = playerInfect;

			
			trace("=============[Loaded Player Events]==============");
		}	
		public override function dispose():void {
			trace("=============[Unloaded Player Events]==============");
		}
	}
	
}
