event_inherited();

/// @description Draws the player health bar and temporary collision debug ellipse.
if (!initialized) exit;

sc_health_bar_draw(x, y, ship.collision.radius_side, defence, health_bar);
sc_entity_collision_debug_draw(id);
	
