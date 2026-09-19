/// @description Advances game time and updates centralized input and audio.
if (global.game.initialized
&& global.LevelState != LevelState.PAUSED)
    global.game.tick++;

if (global.GameState == GameState.PLAYING)
    sc_input_update();

if (global.input.action.fullscreen_pressed)
    window_set_fullscreen(!window_get_fullscreen());

sc_audio_update();