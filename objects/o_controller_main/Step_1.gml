if (global.game.initialized)
    global.game.tick++;

/// @description Samples all centralized player input before gameplay objects update.
if (global.GameState == GameState.PLAYING)
    sc_input_update();
	
if (global.input.action.fullscreen_pressed)
{
    window_set_fullscreen(!window_get_fullscreen());
}