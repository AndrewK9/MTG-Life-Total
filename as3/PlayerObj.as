package as3 {
	
	import flash.display.MovieClip;
	import flash.events.*;
	
	public class PlayerObj extends MovieClip {

		public var initials = "";
		public var pname = "";
		public var life = 0;
		public var infect = 0;

		public function PlayerObj(playerInit:String, playerName:String, playerLife:Number, playerInfect:Number) {
			initials = playerInit;
			pname = playerName;
			life = playerLife;
			infect = playerInfect;
		}
	}
}
