if (!variable_global_exists("game") || !global.game.initialized)
{
    show_debug_message("LEVEL INITIALIZATION ERROR - main controller runtime missing");
    instance_destroy();
    exit;
}

global.LevelState = LevelState.INITIALIZING;
global.PlayerState = PlayerState.INITIALIZING;

global.level =
{
    controller: id,
    player: noone,
    enemies_alive: 0,
    initialized: false
};

var _player = instance_create_layer(room_width * 0.5, room_height * 0.5, "Instances", o_player,
{
    ship_key: global.profile.selected_ship_key
});

if (!instance_exists(_player) || !_player.initialized)
{
    show_debug_message("LEVEL INITIALIZATION ERROR - player creation failed");
    global.LevelState = LevelState.FAILED;
    exit;
}

global.level.player = _player;
global.level.initialized = true;
global.LevelState = LevelState.PLAYING;

show_debug_message("COMBAT TEST LEVEL INITIALIZED");
