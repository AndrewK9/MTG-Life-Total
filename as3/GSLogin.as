package as3 {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class GSLogin extends GameScene {
		
		public function GSLogin() {
			bttnJoinOptions.addEventListener(MouseEvent.CLICK, handleShowOptions);
			bttnLoginContinue.addEventListener(MouseEvent.CLICK, handleLoginSubmit);
			joinOptionsMenu.visible = false;
			txtErrorMessage.visible = false;
			trace("=============[Loaded Login Events]==============");
		}
		private function handleShowOptions(e:MouseEvent):void{
			//TODO: Show the options menu and enable it's event listeners
			if(joinOptionsMenu.visible){
				removeOptionsMenu();
				return;
			}else{
				joinOptionsMenu.visible = true;
				joinOptionsMenu.bttnHostMatch.addEventListener(MouseEvent.CLICK, handleSwitchHost);
				joinOptionsMenu.bttnJoinMatch.addEventListener(MouseEvent.CLICK, handleSwitchJoin);
				trace(">Loaded Options Events");
				return;
			}
		}
		private function removeOptionsMenu():void{
			joinOptionsMenu.visible = false;
			joinOptionsMenu.bttnHostMatch.removeEventListener(MouseEvent.CLICK, handleSwitchHost);
			joinOptionsMenu.bttnJoinMatch.removeEventListener(MouseEvent.CLICK, handleSwitchJoin);
			trace(">Unloaded Options Events");
		}
		private function handleSwitchHost(e:MouseEvent):void{
			//TODO: Hide match code input, switch to host mode
			matchCodeInput.visible = false;
			removeOptionsMenu();
		}
		private function handleSwitchJoin(e:MouseEvent):void{
			//TODO: Show match code input, siwtch to join mode
			matchCodeInput.visible = true;
			removeOptionsMenu();
		}
		private function handleLoginSubmit(e:MouseEvent):void{
			//TODO: Send info to sever and wait for responce
			if(matchCodeInput.visible){
				//TODO: User is trying to join a match
				Game.socket.sendJoinRequest(matchCodeInput.inputMatchCode.text, nameInput.inputName.text);
				trace(">Sent a Join Request packet");
			}else{
				//TODO: User is trying to host a match
				Game.socket.sendHostRequest(nameInput.inputName.text);
				trace(">Sent a Host Request packet");
			}
		}
		public override function dispose():void {
			bttnJoinOptions.removeEventListener(MouseEvent.CLICK, handleShowOptions);
			bttnLoginContinue.removeEventListener(MouseEvent.CLICK, handleLoginSubmit);
			trace("=============[Unloaded Login Events]==============");
		}
	}
}
