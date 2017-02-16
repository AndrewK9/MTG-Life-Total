package as3 {
	
	import flash.display.MovieClip;
	
	public class Player extends GameScene {
		
		public var id:Number;
		public var pname = "";
		public var life = 0;
		public var infect = 0;
		public var maxInfect = 0;

		public function Player(playerID:Number, playerName:String, playerLife:Number, playerInfect:Number, maximumInfect:Number) {
			id = playerID;
			pname = playerName;
			life = playerLife;
			infect = playerInfect;
			maxInfect = maximumInfect;

			txtName.text = pname;
			txtHealth.text = life.toString();
			txtInfect.text = infect.toString();
		}	
		public function update(incomingLife, incomingInfect){
			life = incomingLife;
			infect = incomingInfect;

			if(infect >= maxInfect || life <= 0){
				infect = "RIP";
				life = "RIP";
			}

			txtHealth.text = life.toString();
			txtInfect.text = infect.toString();
		}
	}
	
}
