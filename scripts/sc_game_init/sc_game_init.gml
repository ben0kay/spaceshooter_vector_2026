/// @description Initializes top-level game, profile and data runtime once.
function sc_game_init()
{
    global.GameState = GameState.BOOT;
    global.LevelState = LevelState.NONE;
    global.PlayerState = PlayerState.INITIALIZING;

    global.game =
    {
        initialized: false,
        tick: 0
    };

    global.profile =
    {
        selected_ship_key: "ship_fighter",
        persistent_modifiers: []
    };

    global.level = undefined;
    global.player_id = noone;

    if (!sc_data_init())
        return false;

    global.game.initialized = true;
    show_debug_message("SPACE SHOOTER VECTOR 2026 - GAME INITIALIZED");
    return true;
}
