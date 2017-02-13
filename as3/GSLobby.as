package as3 {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class GSLobby extends GameScene {
		
		public function GSLobby(matchCode:String, numOfPlayers:Number, isPlayer:Boolean) {
			trace("=============[Loaded Lobby Events]==============");
			txtMatchCode.text = matchCode.toUpperCase();
			txtLobby.text = numOfPlayers.toString() + "/8 players in the lobby.";
			if(isPlayer){
				bttnStartGame.visible = true;
				bttnStartGame.addEventListener(MouseEvent.CLICK, handleStartGame);
			}else{
				bttnStartGame.visible = false;
			}
		}
		private function handleStartGame(e:MouseEvent):void{
			//TODO: Send packet to the server saying that the game can start
			Game.socket.sendStartRequest();
			trace(">Sent a Start Request packet");
		}
		public override function dispose():void {
			trace("=============[Unloaded Lobby Events]==============");
			bttnStartGame.removeEventListener(MouseEvent.CLICK, handleStartGame);
		}
	}
}
