#macro GAME_TICK global.game.tick
#macro GAMEPLAY_ACTIVE (global.GameState == GameState.PLAYING && global.LevelState == LevelState.PLAYING)
#macro UPDATE_2 (((GAME_TICK + real(id)) mod 2) == 0)
#macro UPDATE_4 (((GAME_TICK + real(id)) mod 4) == 0)
#macro UPDATE_8 (((GAME_TICK + real(id)) mod 8) == 0)

/// @description Returns whether an instance's staggered update is due.
function sc_update_due(_instance, _interval)
{
    _interval = max(1, round(_interval));
    return ((GAME_TICK + real(_instance)) mod _interval) == 0;
}

/// @description Returns a future GAME_TICK deadline.
function sc_timer_after(_steps)
{
    return GAME_TICK + max(0, round(_steps));
}

/// @description Returns whether a GAME_TICK deadline has passed.
function sc_timer_ready(_deadline)
{
    return GAME_TICK >= _deadline;
}

/// @description Converts seconds into game Steps.
function sc_seconds(_seconds)
{
    return round(_seconds * game_get_speed(gamespeed_fps));
}