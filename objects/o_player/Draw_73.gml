event_inherited();

/// @description Draws player world-space interface elements.
if (!initialized) exit;

sc_health_bar_draw(
    x,
    y,
    ship.collision.radius_side,
    defence,
    health_bar
);

sc_player_module_install_world_draw(id);
// sc_entity_collision_debug_draw(id);
sc_player_draw_aim_line();
sc_player_radial_draw(id);