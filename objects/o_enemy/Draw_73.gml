if (!initialized || !enemy.optimization.render_active) exit;

event_inherited();
sc_health_bar_draw(x, y, enemy.visual.radius, enemy.defence, health_bar);

// enemy debug visuals. keep this section commented out
// sc_enemy_utility_asteroid_debug_draw(id);
// sc_enemy_wander_debug_draw(id);