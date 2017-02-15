# Change Log
All notable chagnes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) 
and this project adheres to [Semantic Versioning](http://semver.org/).

---

## [1.2.1] - 2017-02-15
### Added
- Designed the spectator chatroom.
- The chat button will toggle the chatroom into position.

## [1.1.18] - 2017-02-15
### Added
- broadcastRageQuit sends an update packet to everyone, the player symbol won't go away but it will say they are dead.
- After handling input the Match class checks for death. If someone dies we run the checkForWin function.
- checkForWin loops through all the players and counts the deaths, if 0 to 1 player is alive we declare a winner.
- The broadcastGameOver function loops through everyone connected to the match and sends a _GMOV_ packet.
- The Game Over packet contains the name of the winner.
- Connection.as handels _GMOV_ packets by sending the winner to Game.as and then to GSMatch.
- GSMatch clears the screen with the gameOver function.
- We spawn a Winner symbol and pass the winners name into it.
- Winner has two buttons, players can quit the app or restart the match.
- gameOver hides the buttons if they're a spectator.

## [1.1.17] - 2017-02-15
### Chagned
- The readPacketUpdate, readPacketPrivateUpdate, and readPacketStartUpdate all call the tryReadingPacket function when they are done. Mobile devices had lag and a major buffer backlog and becuase the tryReadingPacket function doesn't endlessly loop the player would get behind on updates.
- tryReadingPacket now checks the length of the buffer, if it's less than 4 we return out of the function.

## [1.1.16] - 2017-02-15
### Added
- Connection.as handles update packets and passes the parsed info to Game.as who trys to send it to the update function in GSMatch.
- When loading players we now assign the txtHealth and txtInfect text boxes to the correct values.
- GSMatch now has an update function that loops through all the players and finds the matching ID. We when call that players update function and pass in the new health and infect numbers.
- When broadcasting update we send a private update to the player who sent the input.
- Connection.as now handles private update packets.
- We display the update to the players health/infect text boxes with a privateUpdate function.

### Changed
- When building update packets we were using client.id not client.playerId. This bug has been fixed.

## [1.1.15] - 2017-02-14
### Changed
- Forgot to use this.splitBufferAt to remove the packets from the buffer after we handle them for the start message, it was getting called over and over again when a new packet was being sent.
- Uncommented the update message to the players and spectators, the client doesn't handle these messages yet.
- Fixed an issue on Game.as where error messages were not appearing on GSLogin. Same reason as before, used same fix.

## [1.1.15] - 2017-02-14
### Changed
- Fixed removeFromMatch function, it now checks to see if the match is running. Before it was trying to update the GSLobby screen but if a player left during the match it would crash the app. Now we have a broadcastRageQuit function in the Match class that kills the player. They still get removed from the players array and the clients array. I will have to figure out how to deal with this, maybe send an update to the players to kill the player and ignore them?

## [1.1.14] - 2017-02-14
### Added
- We now set the Player symbols name to the username the server gives us.
- Adjusted the position of the player symbols.
- We call the Player symbols update function after we spawn it so the lift/infect doesn't say RIP anymore.

### Changed
- Fixed some issues with the calculate function in the Match class, moved the console.log down below the math and fixed the maxInfect calc, we now user this.startingHealth instead of startinghealth.

## [1.1.13] - 2017-02-14
### Added
- An update function in Player.as. It requires an incoming life and infect number, if the infect is over the max infect or the life is below or equal to 0 we set the values to "RIP". We then set the dynamic text boxes to match the values.

### Changed
- When sending the players to each client we include the maxInfect value.
- Cleaned the servers console.logs by removing them or making them match the style.
- Cleaned the clients traces by removing them or making them match the style.

## [1.1.12] - 2017-02-14
### Added
- GSMatch's handleInput function now calls sendInput in the Connection script.
- sendInput writes the input type to the buffer and sends it to the server.
- The server now handles _UIUP_ (User Input Update) packets by passing them to the Match class' handlePlayerInput function.
- Added the following properties to Clients:
	- Health
	- Infect
	- Match
	- isDead
- We broadcast an Update packet when players send input.
- The Match class now has a function that caluclates the starting values and assigns them to each player.
- There is a releaseTheClients function in the Match class that sends buildStartUpdatePacket packets to all the player and spectators. When the client recieves this packet they will parse it and hand the info over to the GSMatch screen were it will spawn the Player object and assign its position and values.

### Changed
- Pushed buttons on GSMatch up due to issues on mobile devices.
- Adjusted the invisible buttons position.
- Set max Match players to 2, should return to 8 after testing.
- Clients are now assigned a match when they join/spectate.
- When calling the releaseTheClients function we first wait 3 seconds so the clients can switch to the match screen, this should be updated later so the clients send a _IRDY_ Im Ready packet to the server. Once everyone is ready we can release the clients.
- In Game.as we now run a try/catch on startUpdate.
- Also in Game.as we check to see if main.scene.txtLobby isn't null before we set its .text value. This was causing issues where players we not recieving updates becuase main.scene was [gameObject GSLobby] but as3.GSLobby was class GSLobby.
- In the Servers checkForMaatch function we now only call the broadcastNewGSLobbyPlayer when players after the host are entering. For some reason the host was getting this packet before the Host Responce packet and it was causing the host to get suck on GSLobby.

## [1.1.11] - 2017-02-14
### Added
- Designed the player object and the GSMatch screen.
- Created GSMatch script, it currently stores the player objects positions and adds/removes event listeners. It requires a boolean, based on what is passed in the player is a player or a spectator.
- Created Player script, it will store the incoming players data. We will need to add an Update function that adjust its health/infect values.

## [1.1.10] - 2017-02-13
### Added
- GSMain and GSLogin now have invisibile buttons that will force them to exit the option popup menus when they click outside the menu.
- When attempting to connect we now try to connect every 10 seconds for a total of 50 seconds instead of just once.

## [1.1.9] - 2017-02-13
### Added
- When the player presses the start button we send a Start Request Packet to the server.
- The server now handles Start Request Packets, if there are more than 2 players in the lobby we start the match.
- The following are new functions on Server.js:
	- attemptMatchStart will try to start the match if there are enough players.
	- broadcastStartMatch will loop though all the clients and write a Start Packet.
	- getLobbyNumber will retrun the number of players in the lobby.
	- broadcastNewGSLobbyPlayer loops through all the clients and informs them what the current number of players are in their lobby.
- Generated the first APK version for testing.

### Changed
- The broadcastJoinResponce now passes along the match code and current number of players in the lobby.
- Server now has a new function _getLobbyNumber_ and it gets the current number of players in the lobby.
- The update functions in the game class now check what scene is currently active in order to avoid getting null reference errors.

## [1.1.8] - 2017-02-13
### Added
- Connection now handles errors by passing them to a static function in the Game class.
- Game class has a new function _updateLoginErrorMessage_ that displays the errors message on the login screen.

## [1.1.7] - 2017-02-13
### Added
- Players now handle incoming packets from the server.
- Players can switch to the GSLobby scene when the server says they can.
- We now remove empty matches when all the players disconnect.
- The following functions to the Connection class:
	- readPacketNameError traces the error, doesn't yet display it.
	- readPacketMatchError traces the error, doesn't yet display it.
	- readPacjetJoinResponce sends the player to the GSLobby screen.
	- readPacketHostResponce sends the player to the GSLobby screen.

### Changed
- The destroyStreamData function now trims the entire buffer, not sure if this will cause problems but when the .trim() was empty there were "end of file" errors.

## [1.1.6] - 2017-02-10
### Added
- Designed the GSLobby screen.

## [1.1.5] - 2017-02-10
### Changed
- Fixed the Connection Failed error message bug where it wasn't being reset when the player attempted another connection.

## [1.1.4] - 2017-02-10
### Added
- The GSMain now tells the user when it's trying to connect to their desired server. If no connection is made within 60 seconds we warn the user that their server didn't respond.

## [1.1.3] - 2017-02-10
### Added
- Added the font .ttf file to the main folder.
- Matches now hold all its spectators in an array.
- Matche codes will be rejected if they have illegal characters.
- Clients are removed from matches when they disconnect.

### Changed
- Switched the first 1.1.2 to 1.1.1.
- Fixed protocol mismatch for the name invalid code.
- We no longer track currentPlayers, instead we check to see what match.players.length is when checking to see if the match is full.
- When we log the new match code to the console it is foced to uppercase.

## [1.1.2] - 2017-02-09
### Added
- The following functions to the server:
	- createMatch creates a new match in the matches array based on a code generated by generateMatchCode.
	- generateMatchCode generates 6 letters from a random int using getRandomInt.
	- getRandomInt generates a int between the min and max numbers that are passed in.
	- getLetterFromInt takes a number and finds its corresponding letter.
- Added the ability for host clients to generate new matches.

### Chagned
- When generating a new Match the currentPlayers value is now 0 instead of 1, this is becuase when a host creates a match we run the checkForMatch function in the server class and the host gets added as if they were a player.
- Fixed some issues with the _this_ keyword with the match generation functions.
- Switched name.match to username.match in the isNameOkay function.

## [1.1.1] - 2017-02-09
### Added
- The server assigns players a ID number.
- We created the following functions:
	- destroyStreamData destroys the stream data.
	- tryReadingPacket uses get next packet to try and figure out what type of packet we are handling.
	- getNextpacket parses the packet for the packet type.
	- splitBufferAt splits the buffer at a specific point.
	- readPacketJoin parses the packet and gets a username and match code, we then check if the name is allowed and if the match exist.
	- readPacketHost parses the packet adn gets a username and creates a match.
	- isNameOkay checks to see if a name is legal, returns 1, 2, 3 as errors and 0 as approved.
	- checkForMatch checks to see if the match code a player input is legit, if it is and there is space it adds the player to the match. Returns 1, 2 as errors and 0 as approved.
- Added a Match class, it stores the match code, current players, max players, and the IDs of all current players.
- Connection.as now has a sendHostRequest function, it now sends a HOST packet  along with the players username.
- The GSLogin script:
	- Players can select to join or host a match using the options menu via the gears button. Join is the default setting.
	- We submit the packet based on the visibility of the matchCodeInput object.
- There is now a GSLogin symbol in the project, it is displayed when the user connects.

### Chagned
- The sendJoinRequest in Connection.as now sends a match code instead of a player type.
- In Connection.as the handleConnection function sends the client to the GSLogin screen.
- Also in Connection.as the handleClose function returns the client to the GSMain screen. This should be updated so we can tell the player why they were forced back to the main menu.


## [1.0.7] - 2017-02-08
### Added
- The server exist.
- A Client and Server class to the server.js script.
- Clients can now connect and disconnect from the server.

## [1.0.6] - 2017-02-08
### Added
- Custom server IP and port input symbols.
- The connect function now uses the US-East or custom IP and ports based on what the client chooses, the default is US-East.

## [1.0.5] - 2017-02-08
### Added
- A server options popup menu for switching between the US based server and entering a custom IP address.
- Event listeners for the server options buttons.
- Clients can now toggle the servers options menu on and off.

### Changed
- Updated the design for GSMain:
	- New options icon.
	- Moved the options icon to the left.
	- Added a drop shadow to the title text.
	- Changed the options icons drop shadow from 4px to 6px.

## [1.0.4] - 2017-02-06
### Changed
- Reworked the logo to match the logo used on the Google Play page.

### Removed
- The white drop shadows from the text on the splash screen and main menu.
- The logo from the main menu screen.

## [1.0.3] - 2017-02-06
### Added
- Recreated the splash screen.
- Updated old splash screen code.
- Created a Server Connection screen (GSMain), it's currently the acting main menu screen.

### Changed
- Added a tick event to the Game.as file.
- Reworked the Game.as file to make the scenes it spawns slide from right to left instead of just "hard cuts" to the next scene.

## [1.0.2] - 2017-02-06
### Added
- Base AS3 files based on Nick's Tic Tac Toe game.
	- Connection.as
	- Game.as
	- LegitBuffer.as
	- GameScene.as

## [1.0.1] - 2017-02-06
### Added
- This CHANGELOG file.
- The README file.
- The PROTOCOL file.
- The empty server script.

### Changed
- Replaced the old .fla file with an empty new one.

### Removed
- The Design Doc files and folder.
- All but the icon from the images folder.