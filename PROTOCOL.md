# MTGP v2.1

---

## Packets from the Server

### Name Error
The Name Error packet is sent to the client when their name is invalid, too long, or too short. It is triggered by a client sending a Join or Host packet.

| Name | Length | Offset | Type | Desc |
|------|--------|--------|------|------|
| _NERR_ | 4 | 0 | ascii | Name Error (_NERR_) |
| _NERR_ | 1 | 4 | uint8 | Error type (1: short, 2: long, 3: invalid, 0: good) |

### Match Error
The Match Error packet is sent to the client when their match code is invalid. It is triggered by a client sending a Join packet.

| Name | Length | Offset | Type | Desc |
|------|--------|--------|------|------|
| _MERR_ | 4 | 0 | ascii | Match Error (_MERR_) |
| _MERR_ | 1 | 4 | uint8 | Error type (1: full, 2: invalid 0: good) |

### Match Join Responce
The Match Join Responce packet is sent to the client when they are accepted into the match. It is triggered by a client sending a Join packet. If we send 0 the client is a spectator, and a 0 is a player. We send the number of players in the lobby and the match code.

| Name | Length | Offset | Type | Desc |
|------|--------|--------|------|------|
| _MJRS_ | 4 | 0 | ascii | Match Join Responce (_MJRS_) |
| _MJRS_ | 1 | 4 | uint8 | Responce type (1: spectator, 0: good) |
| _MJRS_ | 1 | 5 | uint8 | Number of players in the lobby |
| _MJRS_ | 6 | 6 | ascii | Match code ex:AABBCC |

### Host Responce
The Host Respocne packet is sent to the client when they host a match. It is triggered by a client sending a Host packet. We also send the generated match code so other players can join.

| Name | Length | Offset | Type | Desc |
|------|--------|--------|------|------|
| _MHRS_ | 4 | 0 | ascii | Host Responce (_MHRS_) |
| _MHRS_ | 6 | 4 | ascii | Match code ex:AABBCC |

### Start Packet
The Start Packet is sent to the client when a client in the lobby presses the start button. This packet will switch the players over to the match screen if there are at least 2 players in the lobby. We tell the client if they are a player so they know if we should hide parts of the UI.

| Name | Length | Offset | Type | Desc |
|------|--------|--------|------|------|
| _PSTG_ | 4 | 0 | ascii | Start Packet (_PSTG_) |
| _PSTG_ | 1 | 4 | uint8 | If the client is a player (1:ture or 0:false) |

### Lobby Update
The Lobby Update packet is sent to the client when a new client joins the lobby. This packet will contain the current number of players in the lobby.

| Name | Length | Offset | Type | Desc |
|------|--------|--------|------|------|
| _LUPD_ | 4 | 0 | ascii | Lobby Update packet (_LUPD_) |
| _LUPD_ | 1 | 4 | uint8 | Number of players |

### Update
The Update packet is sent to the client whenever a client sends an input to the server. This packet will contain the ID of the client to change along with the new health and infect values.

| Name | Length | Offset | Type | Desc |
|------|--------|--------|------|------|
| _UPDT_ | 4 | 0 | ascii | Update packet (_UPDT_) |
| _UPDT_ | 1 | 4 | uint8 | Client ID |
| _UPDT_ | 1 | 5 | uint8 | New health value |
| _UPDT_ | 1 | 6 | uint8 | New infect value |

### Private Update
The Private Update packet is sent to the client when they send an input to the server. This packet will contain the new health and infect values.

| Name | Length | Offset | Type | Desc |
|------|--------|--------|------|------|
| _PUDT_ | 4 | 0 | ascii | Private Update packet (_PUDT_) |
| _PUDT_ | 1 | 4 | uint8 | New health value |
| _PUDT_ | 1 | 5 | uint8 | New infect value |

### Start Update
The Start Update packet is sent to the clients when the game begins. This packet will contain an individual players starting info. We send the players ID, starting health, starting infect, max infect, and username. The client will user this info to spawn the player objects.

| Name | Length | Offset | Type | Desc |
|------|--------|--------|------|------|
| _GSUD_ | 4 | 0 | ascii | Start Update packet (_GSUD_) |
| _GSUD_ | 1 | 4 | uint8 | Player ID |
| _GSUD_ | 1 | 5 | uint8 | Starting health value |
| _GSUD_ | 1 | 6 | uint8 | Starting infect value |
| _GSUD_ | 1 | 7 | uint8 | Max infect value |
| _GSUD_ | 8 | 8 | ascii | Players username |

### Game Over
The Game Over packet is sent to the clients when the game is over. This packet is triggered when there are 1 to 0 players alive. The packet will contain the winners username, if there are no winners it will return "No one".

| Name | Length | Offset | Type | Desc |
|------|--------|--------|------|------|
| _GMOV_ | 4 | 0 | ascii | Game Over packet (_GMOV_) |
| _GMOV_ | 8 | 4 | ascii | Winners username |

### Chat
The Chat packet is sent to the client when a client sends a chat message. This packet contains the chatting clients username and their message.

| Name | Length | Offset | Type | Desc |
|------|--------|--------|------|------|
| _BMSG_ | 4 | 0 | ascii | Chat packet (_BMSG_) |
| _BMSG_ | 8 | 4 | ascii | Players username |
| _BMSG_ | 120 | 12 | ascii | Players message |

### Unlock
The Unlock packet is sent to the client when the server has finished sending all the Start Update packets. It will unlock the clients buttons to allow input.

| Name | Length | Offset | Type | Desc |
|------|--------|--------|------|------|
| _UNLK_ | 4 | 0 | ascii | Unlock packet (_UNLK_) |

### Join Mid Match Responce
The Join Mid Match Responce packet is sent to the server when a player wants to spectate a match that has already begun.

| Name | Length | Offset | Type | Desc |
|------|--------|--------|------|------|
| _JMMR_ | 4 | 0 | ascii | Join Mid Match Responce packet (_JMMR_) |

---

## Packets from the Client

### Join Request
The Join Request packet is sent to the server when a player is tyring to join a match. The packet will contain the match code that the client wants to join, the username length, and the clients username. The client will be waiting for a a Name Error, Match Error, or Match Join Responce packet from the server.

| Name | Length | Offset | Type | Desc |
|------|--------|--------|------|------|
| _JOIN_ | 4 | 0 | ascii | Join Request packet (_JOIN_) |
| _JOIN_ | 6 | 4 | ascii | Match code ex:AABBCC |
| _JOIN_ | 1 | 10 | uint8 | Username length |
| _JOIN_ | 8 | 11 | ascii | Players username |

### Host Request
The Host Request packet is sent to the server when a client is trying to host a match. The packet will contain the clients username and the username length. The client will be waiting for a Name Error or Host Responce packet from the server.

| Name | Length | Offset | Type | Desc |
|------|--------|--------|------|------|
| _HOST_ | 4 | 0 | ascii | Host Request packet (_HOST_) |
| _HOST_ | 1 | 4 | uint8 | Username length |
| _HOST_ | 8 | 5 | ascii | Players username |

### Start Request
The Start Request packet will be sent to the server requesting that the match begins.

| Name | Length | Offset | Type | Desc |
|------|--------|--------|------|------|
| _UMSR_ | 4 | 0 | ascii | Start Request packet (_UMSR_) |

### User Input
The User Input packet is sent to the server when the client presses a button on the match screen. The packet will contain a input type that the server will process. The server will respond to this client with a Private Update and will send an Update packet to everyone else.

| Name | Length | Offset | Type | Desc |
|------|--------|--------|------|------|
| _UIUP_ | 4 | 0 | ascii | User input packet (_UIUP_) |
| _UIUP_ | 1 | 4 | uint8 | Input event type |

### Restart
The Restart packet is sent to the server when the client presses the restart button after the match has ended. The server will respond with a Start packet.

| Name | Length | Offset | Type | Desc |
|------|--------|--------|------|------|
| _REST_ | 4 | 0 | ascii | Restart packet (_REST_) |

### User Message
The User Message packet is sent to the server when the spectator client sends a message to the chat. The packet will contain the messages length and the message. The server will broadcast this message to all the spectator clients with a Chat packet.

| Name | Length | Offset | Type | Desc |
|------|--------|--------|------|------|
| _UMSG_ | 4 | 0 | ascii | Send Chat Message packet (_UMSG_) |
| _UMSG_ | 1 | 4 | uint8 | Message length |
| _UMSG_ | message length | 5 | ascii | Players message |

### Mid Match Info Request
The Mid Match Info Request packet is sent to the server when a client wants to become a spectator mid match. The server will respond with a Join Mid Match Responce packet.

| Name | Length | Offset | Type | Desc |
|------|--------|--------|------|------|
| _MMIR_ | 4 | 0 | ascii | Mid Match Info Request packet (_MMIR_) |