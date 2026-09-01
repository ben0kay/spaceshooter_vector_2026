if (!variable_global_exists("game") || !global.game.initialized)
{
    show_debug_message("LEVEL INITIALIZATION ERROR - main controller runtime missing");
    instance_destroy();
    exit;
}

if (!is_struct(global.profile))
{
    show_debug_message("LEVEL INITIALIZATION ERROR - active profile missing");
    global.GameState = GameState.BOOT;
    room_goto(r_boot);
    exit;
}

global.LevelState = LevelState.INITIALIZING;
global.PlayerState = PlayerState.INITIALIZING;
global.player_id = noone;

global.level = {
    controller: id,
    player: noone,
    ship_selector: noone,
    selected_ship_key: undefined,
    enemies_alive: 0,
    initialized: false
};

var _selector = instance_create_layer(0, 0, "Instances", o_ship_select, {
    spawn_x: room_width * 0.5,
    spawn_y: room_height * 0.5
});

if (!instance_exists(_selector))
{
    show_debug_message("LEVEL INITIALIZATION ERROR - ship selector creation failed");
    global.LevelState = LevelState.FAILED;
    exit;
}

global.level.ship_selector = _selector;
global.LevelState = LevelState.SHIP_SELECT;

show_debug_message("COMBAT TEST READY - AWAITING SHIP SELECTION");