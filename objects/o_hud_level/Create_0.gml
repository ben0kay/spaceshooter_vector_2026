/// @description Initializes and bakes the permanent level HUD.
if (!sc_hud_level_init(id))
{
    show_debug_message("LEVEL HUD INITIALIZATION ERROR");
    instance_destroy();
    exit;
}

sc_hud_top_banner_init(hud);
sc_debug_enemy_spawn_init(hud);
sc_debug_weapon_test_init(hud);
sc_derelict_hud_init(hud);

global.level.hud = id;