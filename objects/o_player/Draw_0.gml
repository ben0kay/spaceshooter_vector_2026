if (!initialized)
    exit;

var _colour = ship.visual.colour_primary;
var _scale = ship.visual.scale;

draw_set_colour(make_colour_rgb(5, 12, 24));
draw_circle(x, y, 30 * _scale, false);

draw_set_colour(_colour);
draw_triangle(x + 34 * _scale, y, x - 25 * _scale, y - 21 * _scale, x - 13 * _scale, y, false);
draw_triangle(x + 34 * _scale, y, x - 13 * _scale, y, x - 25 * _scale, y + 21 * _scale, false);

draw_set_colour(c_white);
draw_circle(x, y, 7 * _scale, false);
