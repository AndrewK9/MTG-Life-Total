package as3 {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	
	public class GameScreen extends MovieClip {

		var buffer:String = "";
		var charSplit:String = "\n";
		var players:Array = new Array();
		var ourHealth:Number = 20;
		var ourInfect:Number = 0;

		//Player box positions
		var newPlayerNumber = -1;
		var playerPos0:Object = {x:18,y:52};
		var playerPos1:Object = {x:250,y:52};
		var playerPos2:Object = {x:18,y:198};
		var playerPos3:Object = {x:250,y:198};
		var playerPos4:Object = {x:18,y:344};
		var playerPos5:Object = {x:250,y:344};
		
		public function GameScreen() {
			bttn_hp_MINUS.addEventListener(MouseEvent.CLICK, handleClick);
			bttn_hp_PLUS.addEventListener(MouseEvent.CLICK, handleClick);
			bttn_infect_MINUS.addEventListener(MouseEvent.CLICK, handleClick);
			bttn_infect_PLUS.addEventListener(MouseEvent.CLICK, handleClick);
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
            	    var newPlayer:PlayerObj = new PlayerObj(playerInit, playerName, playerLife, playerInfect);
            	    addChild(newPlayer);
            	    players.push(newPlayer);
            	    trace(">New Player Loaded");
            	    trace("Initials: "+newPlayer.initials+" Name: "+newPlayer.pname+" Life: "+newPlayer.life+" Infect: "+newPlayer.infect);
            	    newPlayer.txt_otherplayers_INITIALS.text = newPlayer.initials;
            	    newPlayer.txt_otherplayers_HEALTH.text = newPlayer.life;
            	    newPlayer.txt_otherplayers_INFECT.text = newPlayer.infect;

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
            	    }
            	 }

            	if(msg.indexOf("LP:") == 0){
            		    //TO-DO:Kill off player who left
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
			}		
		}
		function handleClick(e:MouseEvent):void {
			//TO-DO:Take in data and use a switch to send updates to the server
		}	
		public function dispose():void {
		   	bttn_hp_MINUS.removeEventListener(MouseEvent.CLICK, handleClick);
			bttn_hp_PLUS.removeEventListener(MouseEvent.CLICK, handleClick);
	   		bttn_infect_MINUS.removeEventListener(MouseEvent.CLICK, handleClick);
			bttn_infect_PLUS.removeEventListener(MouseEvent.CLICK, handleClick);
		  	MainApp.socket.removeEventListener(ProgressEvent.SOCKET_DATA, handleData);
			trace("=============[Unloaded Lobby Events]==============");
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
