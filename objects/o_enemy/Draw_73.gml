if (!initialized || !enemy.optimization.render_active) exit;

event_inherited();
sc_health_bar_draw(x, y, enemy.visual.radius, enemy.defence, health_bar);
//sc_enemy_wander_debug_draw(id);