package as3 {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.utils.*;//Needed for time
	import flash.media.*;//Needed for sound
	
	public class WinScreen extends MovieClip {

		var buffer:String = "";
		var charSplit:String = "\n";
		var particles:Array = new Array();

		//SFX Info
		var LPopNoise:LPop = new LPop();
		var HPopNoise:HPop = new HPop();
		var myChannel2:SoundChannel = new SoundChannel();
		var myTransform = new SoundTransform(1, 0);
		
		public function WinScreen() {
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
			bttn_rematch.addEventListener(MouseEvent.CLICK, handleClick);
			addEventListener(Event.ENTER_FRAME, gameLoop);
      		MainApp.socket.addEventListener(ProgressEvent.SOCKET_DATA, handleData);
			trace("=============[Loaded Win Screen Events]==============");
		}
		function handleData(e:ProgressEvent):void {
			buffer += MainApp.socket.readUTFBytes(MainApp.socket.bytesAvailable);
			var messages:Array = buffer.split(charSplit);
			buffer = messages.pop();

			trace(">Incoming Game Messages:");
			trace(">" + messages);
			trace(">End of Incoming Game Messages");

			var playerName:String = "";
	    var playerInit:String = "";
			
			for(var i = 0; i < messages.length; i++){
				var msg:String = messages[i];

            	if(msg.indexOf("PINIT:") == 0){//Used whe the game starts
            	    playerInit = msg.substr(6);
            	 }
            	if(msg.indexOf("PNAME:") == 0){//Used whe the game starts
            	    playerName = msg.substr(6);
              	 }
              if(msg.indexOf("WIN:")==0){
                txt_WINNER.text = "";
                txt_WINNER.appendText(playerName+" Wins!");
                makeConfettie();
              }
              if(msg.indexOf("BEGIN:") == 0){
                trace(">Someone hit the restart button");
                  clearScreen();
                  dispose();
                  addChild(new GameScreen());
              }
			}		
		}
		var time:Number = 0;
		var waitTime:Number = 3;
		function gameLoop(e:Event):void{
			var timeNew:int = getTimer();//Gets timer
			var deltaTime:Number = (timeNew - time)/1000;//Does math to see how much time has passed
			time = timeNew;//Keeps time updated
			waitTime -= deltaTime;
			trace("Time Till Next Pop: " + waitTime);
			if (waitTime <= 0) makeConfettie();

			for each (var k in particles) k.update();
		}
		function makeConfettie(){
			waitTime = randomRange(1, 3);
			var dotsX = randomRange(40, 430);
			var dotsY = randomRange(300, 340);
			for(var i = 10; i > 0; i--){
				var dot2:GDot = new GDot(dotsX, dotsY);
				particles.push(dot2);
				addChildAt(dot2, 1);
			}
			for(var u = 10; u > 0; u--){
				var dot:PDot = new PDot(dotsX, dotsY);
				particles.push(dot);
				addChildAt(dot, 1);
			}
			trace(">Number of particles: "+particles.length);
		}
		function randomRange(minNum:Number, maxNum:Number):Number 
		{
		    return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
		}
		function handleClick(e:Event){
			LPopNoise.play(0, 1, myTransform);
	    	var msg = "RE:";
		  		MainApp.socket.writeUTFBytes(msg + charSplit);
		  		MainApp.socket.flush();
		  		trace(">Sent an update to the server: " + msg);
			}	
		public function dispose():void {
		  bttn_rematch.removeEventListener(MouseEvent.CLICK, handleClick);
		  removeEventListener(Event.ENTER_FRAME, gameLoop);
      MainApp.socket.removeEventListener(ProgressEvent.SOCKET_DATA, handleData);
			trace("=============[Unloaded Winner Events]==============");
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
