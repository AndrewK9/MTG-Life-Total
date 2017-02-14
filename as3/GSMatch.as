package as3 {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	
	public class GSMatch extends GameScene {

		var playerPos0:Object = {x:18,y:52};
		var playerPos1:Object = {x:250,y:52};
		var playerPos2:Object = {x:18,y:164};
		var playerPos3:Object = {x:250,y:164};
		var playerPos4:Object = {x:18,y:276};
		var playerPos5:Object = {x:250,y:276};
		var playerPos6:Object = {x:18,y:388};

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
		private function handleInput(eventType:Number){
			//TODO: Check what type of input we are handling and tell the server
			switch(eventType){
				case 1:
					break;
				case 2:
					break;
				case 3:
					break;
				case 4:
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
