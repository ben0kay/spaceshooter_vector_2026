/// @description Initializes top-level game and registered content once.
function sc_game_init()
{
    global.GameState = GameState.BOOT;
    global.LevelState = LevelState.NONE;
    global.PlayerState = PlayerState.INITIALIZING;

    global.game = {
        initialized: false,
        tick: 0
    };

    global.profile = undefined;
    global.level = undefined;
    global.player_id = noone;

    if (!sc_config_init()) return false;
    if (!sc_optimization_init()) return false;
    if (!sc_data_init()) return false;
    if (!sc_particles_init()) return false;
    if (!sc_ship_visual_cache_init()) return false;
    if (!sc_enemy_visual_cache_init()) return false;
    if (!sc_faction_device_visual_cache_init()) return false;
    if (!sc_projectile_visual_cache_init()) return false;
    if (!sc_asteroid_visual_cache_init()) return false;
	if (!sc_asteroid_modifier_visual_cache_init()) return false;
    if (!sc_world_structure_visual_cache_init()) return false;
    if (!sc_resource_pickup_visual_cache_init()) return false;
    if (!sc_environment_field_visual_cache_init()) return false;
    if (!sc_input_init()) return false;

    global.game.initialized = true;
    show_debug_message("SPACE SHOOTER VECTOR 2026 - GAME INITIALIZED");
    return true;
}

function sc_game_cleanup(){
	sc_projectile_visual_cache_destroy();
	sc_ship_visual_cache_destroy();
	sc_enemy_visual_cache_destroy();
	sc_asteroid_visual_cache_destroy();
	sc_asteroid_modifier_visual_cache_destroy();
	sc_resource_pickup_visual_cache_destroy();
	sc_environment_field_visual_cache_destroy();
	sc_particles_destroy();
	sc_world_structure_visual_cache_destroy();
	sc_faction_device_visual_cache_destroy();

}