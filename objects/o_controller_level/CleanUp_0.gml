if (is_struct(global.level) && global.level.controller == id)
{
    global.LevelState = LevelState.NONE;
    global.PlayerState = PlayerState.INITIALIZING;
    global.player_id = noone;
    global.level = undefined;
}
