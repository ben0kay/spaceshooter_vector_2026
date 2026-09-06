/// @description Initializes a gameplay level using its configured camera.
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
    camera: noone,
    hud: noone,
    player: noone,
    ship_selector: noone,
    selected_ship_key: undefined,
    enemies_alive: 0,
    asteroids_alive: 0,
    initialized: false
};

var _room_name = string_lower(room_get_name(room));
var _camera_object = string_pos("boss", _room_name) > 0
    ? o_camera_boss
    : o_camera;

var _camera = instance_create_layer(
    room_width * 0.5,
    room_height * 0.5,
    "Instances",
    _camera_object
);

if (!instance_exists(_camera))
{
    show_debug_message("LEVEL INITIALIZATION ERROR - camera creation failed");
    global.LevelState = LevelState.FAILED;
    exit;
}

global.level.camera = _camera;

var _hud = instance_create_layer(
    0,
    0,
    "Instances",
    o_hud_level
);

if (!instance_exists(_hud))
{
    show_debug_message("LEVEL INITIALIZATION ERROR - HUD creation failed");
    global.LevelState = LevelState.FAILED;
    exit;
}

global.level.hud = _hud;

var _campaign_player = sc_sector_campaign_active()
    && instance_exists(o_player);

if (_campaign_player)
{
    var _player = instance_find(o_player, 0);

    global.player_id = _player;
    global.level.player = _player;
    global.level.selected_ship_key = _player.ship.key;
    global.level.initialized = true;

    global.PlayerState = PlayerState.ACTIVE;
    global.LevelState = LevelState.PLAYING;

    show_debug_message(
        "LEVEL READY - CAMPAIGN SHIP RESTORED - "
        + _player.ship.key
    );

    exit;
}

var _selector = instance_create_layer(
    0,
    0,
    "Instances",
    o_ship_select,
    {
        spawn_x: room_width * 0.5,
        spawn_y: room_height * 0.5
    }
);

if (!instance_exists(_selector))
{
    show_debug_message("LEVEL INITIALIZATION ERROR - ship selector creation failed");
    global.LevelState = LevelState.FAILED;
    exit;
}

global.level.ship_selector = _selector;
global.LevelState = LevelState.SHIP_SELECT;

show_debug_message("LEVEL READY - AWAITING SHIP SELECTION");