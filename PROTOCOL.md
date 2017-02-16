# MTGP v2.0

# Packets from the Server

| Name | Length | Offset | Type | Desc |
|------|--------|--------|------|------|
| _NERR_ | 4 | 0 | ascii | Name Error (_NERR_) |
| _NERR_ | 1 | 4 | uint8 | Error type (1: short, 2: long, 3: invalid, 0: good) |
| _MERR_ | 4 | 0 | ascii | Match Error (_MERR_) |
| _MERR_ | 1 | 4 | uint8 | Error type (1: full, 2: invalid 0: good) |
| _MJRS_ | 4 | 0 | ascii | Match Join Responce (_MJRS_) |
| _MJRS_ | 1 | 4 | uint8 | Responce type (2: invalid, 0: good) |
| _MJRS_ | 1 | 5 | uint8 | Number of players in the lobby |
| _MJRS_ | 6 | 6 | ascii | Match code ex:AABBCC |
| _MHRS_ | 4 | 0 | ascii | Host Responce (_MHRS_) |
| _MHRS_ | 6 | 4 | ascii | Match code ex:AABBCC |
| _PSTG_ | 4 | 0 | ascii | Start Packet (_PSTG_) |
| _PSTG_ | 1 | 4 | uint8 | If the client is a player (1:ture or 0:false) |
| _LUPD_ | 4 | 0 | ascii | Lobby Update packet (_LUPD_) |
| _LUPD_ | 1 | 4 | uint8 | Number of players |
| _UPDT_ | 4 | 0 | ascii | Update packet (_UPDT_) |
| _UPDT_ | 1 | 4 | uint8 | Client ID |
| _UPDT_ | 1 | 5 | uint8 | New health value |
| _UPDT_ | 1 | 6 | uint8 | New infect value |
| _PUDT_ | 4 | 0 | ascii | Private Update packet (_PUDT_) |
| _PUDT_ | 1 | 4 | uint8 | New health value |
| _PUDT_ | 1 | 5 | uint8 | New infect value |
| _GSUD_ | 4 | 0 | ascii | Start Update packet (_GSUD_) |
| _GSUD_ | 1 | 4 | uint8 | Player ID |
| _GSUD_ | 1 | 5 | uint8 | Starting health value |
| _GSUD_ | 1 | 6 | uint8 | Starting infect value |
| _GSUD_ | 1 | 7 | uint8 | Max infect value |
| _GSUD_ | 8 | 8 | ascii | Players username |
| _GMOV_ | 4 | 0 | ascii | Game Over packet (_GMOV_) |
| _GMOV_ | 8 | 4 | ascii | Winners username |
| _BMSG_ | 4 | 0 | ascii | Chat packet (_BMSG_) |
| _BMSG_ | 8 | 4 | ascii | Players username |
| _BMSG_ | 120 | 12 | ascii | Players message |
| _UNLK_ | 4 | 0 | ascii | Unlock packet (_UNLK_) |

---

# Packets from the Client

| Name | Length | Offset | Type | Desc |
|------|--------|--------|------|------|
| _JOIN_ | 4 | 0 | ascii | Join Request packet (_JOIN_) |
| _JOIN_ | 6 | 4 | ascii | Match code ex:AABBCC |
| _JOIN_ | 1 | 10 | uint8 | Username length |
| _JOIN_ | 8 | 11 | ascii | Players username |
| _HOST_ | 4 | 0 | ascii | Host Request packet (_HOST_) |
| _HOST_ | 1 | 4 | uint8 | Username length |
| _HOST_ | 8 | 5 | ascii | Players username |
| _UMSR_ | 4 | 0 | ascii | Start Request packet (_UMSR_) |
| _UIUP_ | 4 | 0 | ascii | User input packet (_UIUP_) |
| _UIUP_ | 1 | 4 | uint8 | Input event type |
| _REST_ | 4 | 0 | ascii | Restart packet (_REST_) |
| _UMSG_ | 4 | 0 | ascii | Send Chat Message packet (_UMSG_) |
| _UMSG_ | 1 | 4 | uint8 | Message length |
| _UMSG_ | message length | 5 | ascii | Players message |