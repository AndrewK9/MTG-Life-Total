package as3{
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.utils.*;//Needed for time
	import flash.net.navigateToURL;//Needed for URL
	import flash.net.URLRequest;//More URL stuff
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	
	public class GSSplash extends GameScene {

		private var saidToSwitch:Boolean = false;
		
		public function GSSplash() {
			
			addEventListener(Event.ENTER_FRAME, gameLoop);
			link.addEventListener(MouseEvent.CLICK, handleClick);

			trace("=============[Loaded Splash Events]==============");
			trace("Time Info Begins:");

		}

		private var time:Number = 0;
		private var waitTime:Number = 3;

		function gameLoop(e:Event):void{
			var timeNew:int = getTimer();//Gets timer
			var deltaTime:Number = (timeNew - time)/1000;//Does math to see how much time has passed
			time = timeNew;//Keeps time updated
			waitTime -= deltaTime;
			trace("Time Till Next Screen: " + waitTime);
			if (waitTime <= 0 && !saidToSwitch) showConnectScreen();
		}
		public function handleClick(e:MouseEvent){
			navigateToURL(new URLRequest("http://www.gamesbykyle.com/"), "_blank");
			trace(">URL Was Clicked");
		}
		public function showConnectScreen():void{
			Game.showScene(new GSMain(0));
			saidToSwitch = true;
		}
		public override function dispose():void {
			removeEventListener(Event.ENTER_FRAME, gameLoop);
			link.removeEventListener(MouseEvent.CLICK, handleClick);
			trace("=============[Unloaded Splash Events]==============");
		}
	}
}