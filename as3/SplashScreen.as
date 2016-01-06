package as3{
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.utils.*;//Needed for time
	import flash.net.navigateToURL;//Needed for URL
	import flash.net.URLRequest;//More URL stuff
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	
	public class SplashScreen extends MovieClip {
		
		public function SplashScreen() {
			
			addEventListener(Event.ENTER_FRAME, gameLoop);
			link_GBK.addEventListener(MouseEvent.CLICK, handleClick);

			trace("=============[Loaded Splash Events]==============");
			trace("Time Info Begins:");

		}

		var time:Number = 0;
		var waitTime:Number = 3;
		function gameLoop(e:Event):void{
			var timeNew:int = getTimer();//Gets timer
			var deltaTime:Number = (timeNew - time)/1000;//Does math to see how much time has passed
			time = timeNew;//Keeps time updated
			waitTime -= deltaTime;
			trace("Time Till Next Screen: " + waitTime);
			if (waitTime <= 0) showConnectScreen();

		}
		public function handleClick(e:MouseEvent){
			navigateToURL(new URLRequest("http://www.gamesbykyle.com/"), "_blank");
			trace(">URL Was Clicked");
		}
		public function showConnectScreen(){
			trace(">Switched To Main Screen");
			clearScreen();
			removeEventListener(Event.ENTER_FRAME, gameLoop);
			link_GBK.removeEventListener(MouseEvent.CLICK, handleClick);
			trace("=============[Unloaded Splash Events]==============");
			addChild(new ConnectScreen());
		}
		public function clearScreen(){
			
			trace(">Clearing Stage Children");
			for(var i = numChildren - 1; i >= 0; i--){
				var child = getChildAt(i);
				if(child.hasOwnProperty("dispose")) child.dispose();
				removeChildAt(i);
			}
		}
	}
}