package as3 {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
  import flash.media.*;//Needed for sound
	
	public class GameScreen extends MovieClip {

		var buffer:String = "";
		var charSplit:String = "\n";
		var players:Array = new Array();
		var ourHealth:Number = 20;
		var ourInfect:Number = 0;

    //SFX Info
    var LPopNoise:LPop = new LPop();
    var HPopNoise:HPop = new HPop();
    var myChannel2:SoundChannel = new SoundChannel();
    var myTransform = new SoundTransform(1, 0);

		//Player box positions
		var newPlayerNumber = -1;
		var playerPos0:Object = {x:18,y:52};
		var playerPos1:Object = {x:250,y:52};
		var playerPos2:Object = {x:18,y:164};
		var playerPos3:Object = {x:250,y:164};
		var playerPos4:Object = {x:18,y:276};
		var playerPos5:Object = {x:250,y:276};
		var playerPos6:Object = {x:18,y:388};
		var playerPos7:Object = {x:250,y:388};
		
		public function GameScreen() {
      NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
			bttn_hp_MINUS.addEventListener(MouseEvent.CLICK, handleClick("MHP"));
			bttn_hp_PLUS.addEventListener(MouseEvent.CLICK, handleClick("PHP"));
			bttn_infect_MINUS.addEventListener(MouseEvent.CLICK, handleClick("MI"));
			bttn_infect_PLUS.addEventListener(MouseEvent.CLICK, handleClick("PI"));
			MainApp.socket.addEventListener(ProgressEvent.SOCKET_DATA, handleData);
			trace("=============[Loaded Game Events]==============");
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
            var playerLife:Number = 0;
            var playerInfect:Number = 0;
			
			for(var i = 0; i < messages.length; i++){
				var msg:String = messages[i];

            	if(msg.indexOf("PINIT:") == 0){//Used whe the game starts
            	    playerInit = msg.substr(6);
            	 }
            	if(msg.indexOf("PNAME:") == 0){//Used whe the game starts
            	    playerName = msg.substr(6);
              	 }
            	 if(msg.indexOf("PLIFE:") == 0){//Used whe the game starts
            	    var info = msg.substr(6);
            	    playerLife = info;
            	 }
            	 if(msg.indexOf("PINFT:") == 0){//Used whe the game starts
            	    var info2 = msg.substr(6);
            	    playerInfect = info2;
            	 }
                   if(msg.indexOf("FIN:") == 0){//Used whe the game starts
                        newPlayerNumber++;
                      var newPlayer:PlayerObj = new PlayerObj(newPlayerNumber, playerInit, playerName, playerLife, playerInfect);
                      addChild(newPlayer);
                      players.push(newPlayer);
                      trace(">New Player Loaded");
                      trace("Initials: "+newPlayer.initials+" Name: "+newPlayer.pname+" Life: "+newPlayer.life+" Infect: "+newPlayer.infect);

                      switch(newPlayerNumber){
                        case 0:
                              newPlayer.x = playerPos0.x;
                              newPlayer.y = playerPos0.y;
                              break;
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

            	if(msg.indexOf("LP:") == 0){
                    for each(var p in players){
                      removeChild(p);
                    }
            		    players.length = 0;
                    newPlayerNumber = -1;
            	}
            	if(msg.indexOf("EXIT:") == 0){//Server crashed, stopped, or something...
            		clearScreen();
            		dispose();
            		addChild(new MainApp());
            	}
            	if(msg.indexOf("HEALTH:") == 0){
            		var incomingHealth = msg.substr(7);
            		txt_player_HEALTH.text = incomingHealth;
            		txt_player_INFECT.text = "0";
            		ourHealth = parseInt(incomingHealth);
            		trace("I set the starting life to " + incomingHealth);
            	}

           		//updates other players
            	if(msg.indexOf("U:")==0){
            		for(var j = 0; j < players.length; j++){
            			if(playerInit == players[j].initials && playerName == players[j].pname){
            				players[j].update(playerLife, playerInfect);
            			}
            		}
            	}
            	//updates yourself
            	if(msg.indexOf("UU:")==0){
                if(playerLife <= 0 || playerInfect >= 10){
                  txt_player_HEALTH.text = "RIP";
                  txt_player_INFECT.text = "RIP";
                }else{
            		  txt_player_HEALTH.text = playerLife.toString();
            		  txt_player_INFECT.text = playerInfect.toString();
                }
            	}
              if(msg.indexOf("GMOV:")==0){
                trace(">Someone won the game!");
                clearScreen();
                dispose();
                addChild(new WinScreen());
              }
			}		
		}
		function handleClick(type:String):Function {
			return function(e:MouseEvent):void{
				var msg = "";
					switch(type){
						case "PHP":
							msg = "U:PHP";
              HPopNoise.play(0, 1, myTransform);
							break;
						case "MHP":
							msg = "U:MHP";
              LPopNoise.play(0, 1, myTransform);
							break;
						case "MI":
							msg = "U:MI";
              LPopNoise.play(0, 1, myTransform);
							break;
						case "PI":
							msg = "U:PI";
              HPopNoise.play(0, 1, myTransform);
							break;
					}
	
				MainApp.socket.writeUTFBytes(msg + charSplit);
				MainApp.socket.flush();
				trace(">Sent an update to the server: " + msg);
			};
		}	
		public function dispose():void {
		   	bttn_hp_MINUS.removeEventListener(MouseEvent.CLICK, handleClick);
			  bttn_hp_PLUS.removeEventListener(MouseEvent.CLICK, handleClick);
	   		bttn_infect_MINUS.removeEventListener(MouseEvent.CLICK, handleClick);
			   bttn_infect_PLUS.removeEventListener(MouseEvent.CLICK, handleClick);
		  	MainApp.socket.removeEventListener(ProgressEvent.SOCKET_DATA, handleData);
			trace("=============[Unloaded Game Events]==============");
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
