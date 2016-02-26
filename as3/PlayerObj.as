package as3 {
	
	import flash.display.MovieClip;
	import flash.events.*;
	
	public class PlayerObj extends MovieClip {

		public var id:Number;
		public var initials = "";
		public var pname = "";
		public var life = 0;
		public var infect = 0;

		public function PlayerObj(playerID:Number ,playerInit:String, playerName:String, playerLife:Number, playerInfect:Number) {
			id = playerID;
			initials = playerInit;
			pname = playerName;
			life = playerLife;
			infect = playerInfect;

			txt_otherplayers_INITIALS.text = initials;
			txt_otherplayers_NAME.text = pname;
			txt_otherplayers_HEALTH.text = life.toString();
			txt_otherplayers_INFECT.text = infect.toString();
		}

		public function update(playerLife:Number, playerInfect:Number){
			life = playerLife;
			infect = playerInfect;

			if(infect >= 10 || life <= 0) {
				infect = "RIP";
				life = "RIP";
			}

			txt_otherplayers_HEALTH.text = life.toString();
			txt_otherplayers_INFECT.text = infect.toString();
		}
	}
}
