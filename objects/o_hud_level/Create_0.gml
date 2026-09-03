/// @description Initializes and bakes the permanent level HUD.
if (!sc_hud_level_init(id))
{
    show_debug_message("LEVEL HUD INITIALIZATION ERROR");
    instance_destroy();
    exit;
}

global.level.hud = id;