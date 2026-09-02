if (initialized)
    sc_health_bar_draw(x, y, ship.collision.radius, defence, health_bar);
	
	//debug
draw_set_alpha(0.9);
draw_set_colour(c_lime);
draw_circle(x, y, entity.collision_radius, true);

draw_set_alpha(1);
draw_set_colour(c_white);