package as3 {

	import flash.events.*;
	import flash.display.MovieClip;
	
	public class Game extends MovieClip {
		
		public static var socket:Connection = new Connection();
		private static var main:Game;
		public var scene;

		static var hideScene:Boolean = false;
		static var showNewScene:Boolean = false;
		static var newScene:GameScene;
		static var startingScene:GameScene = new GSSplash();
		static var transitionSpeed:Number = 75;
		
		public function Game() {
			main = this;
			addEventListener(Event.ENTER_FRAME, gameLoop);
			main.addChild(startingScene);
			main.scene = startingScene;
		}
		private function gameLoop(e:Event):void{
			if(hideScene){
				if(scene != null){
					scene.x -= transitionSpeed;

					if(scene.x <= -480){
						trace(">Spawning new scene");
						hideScene = false;
						scene.x = 0;
						clearScreen();
					}
				}
			}

			if(showNewScene){
				if(scene != null){
					scene.x -= transitionSpeed;

					if(scene.x <= 0){
						trace(">New scene is positioned correctly");
						showNewScene = false;
						scene.x = 0;
					}
				}
			}
		}
		private function clearScreen():void {
			if(scene){
				scene.dispose();
				removeChild(scene);
			}
			spawnScene();
		}
		private function spawnScene():void {
			main.addChild(newScene);
			main.scene = newScene;
			scene.x = 480;
			showNewScene = true;
		}
		public static function updateLoginErrorMessage(newError:String):void{
			if(main.scene == as3.GSLogin){
				main.scene.txtErrorMessage.visible = true;
				main.scene.txtErrorMessage.text = newError;
			}
		}
		public static function updateLobbyStatus(numOfPlayers:Number):void{
			if(main.scene == as3.GSLobby) main.scene.txtLobby.text = numOfPlayers.toString() + "/8 players in the lobby.";
		}
		public static function showScene(scene:GameScene):void {
			hideScene = true;
			scene.x = 0;
			newScene = scene;
		}
	}
}
