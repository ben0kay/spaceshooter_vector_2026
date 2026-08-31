#macro GAME_TICK global.game.tick
#macro GAMEPLAY_ACTIVE (global.GameState == GameState.PLAYING && global.LevelState == LevelState.PLAYING)
#macro UPDATE_2 (((GAME_TICK + real(id)) mod 2) == 0)
#macro UPDATE_4 (((GAME_TICK + real(id)) mod 4) == 0)
#macro UPDATE_8 (((GAME_TICK + real(id)) mod 8) == 0)