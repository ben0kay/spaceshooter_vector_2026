/// @description Initializes top-level game content and identifies failed startup stages.
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

    if (!sc_config_init()) { show_debug_message("GAME INIT FAILED - CONFIG"); return false; }
    if (!sc_audio_init()) { show_debug_message("GAME INIT FAILED - AUDIO"); return false; }
    if (!sc_optimization_init()) { show_debug_message("GAME INIT FAILED - OPTIMIZATION"); return false; }
    if (!sc_data_init()) { show_debug_message("GAME INIT FAILED - DATA"); return false; }
    if (!sc_particles_init()) { show_debug_message("GAME INIT FAILED - PARTICLES"); return false; }
    if (!sc_ship_visual_cache_init()) { show_debug_message("GAME INIT FAILED - SHIP VISUAL CACHE"); return false; }
    if (!sc_enemy_visual_cache_init()) { show_debug_message("GAME INIT FAILED - ENEMY VISUAL CACHE"); return false; }
    if (!sc_drone_visual_cache_init()) { show_debug_message("GAME INIT FAILED - DRONE VISUAL CACHE"); return false; }
    if (!sc_faction_device_visual_cache_init()) { show_debug_message("GAME INIT FAILED - DEVICE VISUAL CACHE"); return false; }
    if (!sc_projectile_visual_cache_init()) { show_debug_message("GAME INIT FAILED - PROJECTILE VISUAL CACHE"); return false; }
    if (!sc_asteroid_visual_cache_init()) { show_debug_message("GAME INIT FAILED - ASTEROID VISUAL CACHE"); return false; }
    if (!sc_asteroid_modifier_visual_cache_init()) { show_debug_message("GAME INIT FAILED - ASTEROID MODIFIER CACHE"); return false; }
    if (!sc_world_structure_visual_cache_init()) { show_debug_message("GAME INIT FAILED - WORLD STRUCTURE CACHE"); return false; }
    if (!sc_resource_pickup_visual_cache_init()) { show_debug_message("GAME INIT FAILED - RESOURCE PICKUP CACHE"); return false; }
    if (!sc_environment_field_visual_cache_init()) { show_debug_message("GAME INIT FAILED - ENVIRONMENT FIELD CACHE"); return false; }
    if (!sc_input_init()) { show_debug_message("GAME INIT FAILED - INPUT"); return false; }

    global.game.initialized = true;
    show_debug_message("SPACE SHOOTER VECTOR 2026 - GAME INITIALIZED");
    return true;
}

/// @description Releases all generated runtime resources.
function sc_game_cleanup()
{
    sc_audio_cleanup();
    sc_projectile_visual_cache_destroy();
    sc_ship_visual_cache_destroy();
    sc_enemy_visual_cache_destroy();
    sc_drone_visual_cache_destroy();
    sc_asteroid_visual_cache_destroy();
    sc_asteroid_modifier_visual_cache_destroy();
    sc_resource_pickup_visual_cache_destroy();
    sc_environment_field_visual_cache_destroy();
    sc_particles_destroy();
    sc_world_structure_visual_cache_destroy();
    sc_faction_device_visual_cache_destroy();
}