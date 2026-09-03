/// @description Releases generated HUD sprites.
sc_hud_level_cleanup(hud);

if (is_struct(global.level) && global.level.hud == id)
    global.level.hud = noone;