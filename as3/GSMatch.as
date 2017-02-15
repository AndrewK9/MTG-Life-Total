package as3 {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	
	public class GSMatch extends GameScene {

		var playerPos1:Object = {x:31.5,y:33.85};
		var playerPos2:Object = {x:255.7,y:33.85};
		var playerPos3:Object = {x:31.5,y:141.55};
		var playerPos4:Object = {x:255.7,y:141.55};
		var playerPos5:Object = {x:31.5,y:247.1};
		var playerPos6:Object = {x:255.7,y:247.1};
		var playerPos7:Object = {x:144.1,y:359.05};

		var players:Array = new Array();

		var ourHealth = 0;
		var ourInfect = 0;
		var isDead = true;

		public function GSMatch(isPlayer:Boolean) {
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
			if(isPlayer){
				bttnMinusHealth.addEventListener(MouseEvent.CLICK, handleInput(1));
				bttnPlusHealth.addEventListener(MouseEvent.CLICK, handleInput(2));
				bttnMinusInfect.addEventListener(MouseEvent.CLICK, handleInput(3));
				bttnPlusInfect.addEventListener(MouseEvent.CLICK, handleInput(4));
			}else{
				bttnMinusHealth.visible = false;
				bttnPlusHealth.visible = false;
				bttnMinusInfect.visible = false;
				bttnPlusInfect.visible = false;
				txtHealth.visible = false;
				txtInfect.visible = false;
				bgInfect.visible = false;
				bgHealth.visible = false;
			}
			trace("=============[Loaded Match Events]==============");
		}
		private function handleInput(eventType:Number):Function{
			return function(e:MouseEvent):void{
				//TODO: Check what type of input we are handling and tell the server
				Game.socket.sendInput(eventType);
			}
		}
		public function startUpdate(playerID, health, infect, username, maxInfect):void{
			//TODO: This will run every time we get a new player from the servers players array
			//We need to spawn a Player object and position it and store it in an array
			var newPlayer:Player = new Player(playerID, username, health, infect, maxInfect);
			addChild(newPlayer);
			players.push(newPlayer);
			trace(">Loaded new player: " + username);
			newPlayer.txtName.text = username;
			newPlayer.update(health, infect)
			positionNewPlayer(newPlayer);
		}
		private function positionNewPlayer(newPlayer):void{
			//trace("Player had their position set");
			switch(players.length){
				case 1:
				    newPlayer.x = playerPos1.x;
				    newPlayer.y = playerPos1.y;
				    break;
				case 2:
				    newPlayer.x = playerPos2.x;
				    newPlayer.y = playerPos2.y;
				    break;
				case 3:
				    newPlayer.x = playerPos3.x;
				    newPlayer.y = playerPos3.y;
				    break;
				case 4:
				    newPlayer.x = playerPos4.x;
				    newPlayer.y = playerPos4.y;
				    break;
				case 5:
				    newPlayer.x = playerPos5.x;
				    newPlayer.y = playerPos5.y;
				    break;
				case 6:
				    newPlayer.x = playerPos6.x;
				    newPlayer.y = playerPos6.y;
				    break;
				case 7:
				    newPlayer.x = playerPos7.x;
				    newPlayer.y = playerPos7.y;
				    break;
			}
		}
		public override function dispose():void {
			bttnMinusHealth.removeEventListener(MouseEvent.CLICK, handleInput);
			bttnPlusHealth.removeEventListener(MouseEvent.CLICK, handleInput);
			bttnMinusInfect.removeEventListener(MouseEvent.CLICK, handleInput);
			bttnPlusInfect.removeEventListener(MouseEvent.CLICK, handleInput);
			trace("=============[Unloaded Match Events]==============");
		}
	}
}
