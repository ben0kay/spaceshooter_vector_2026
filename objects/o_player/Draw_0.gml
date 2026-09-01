if (!initialized) exit;

var _scale = ship.visual.scale;
var _primary = ship.visual.colour_primary;
var _secondary = ship.visual.colour_secondary;
var _angle = draw_angle;

var _nose_x = x + lengthdir_x(34 * _scale, _angle);
var _nose_y = y + lengthdir_y(34 * _scale, _angle);

var _back_top_x = x + lengthdir_x(33 * _scale, _angle + 140);
var _back_top_y = y + lengthdir_y(33 * _scale, _angle + 140);

var _back_mid_x = x + lengthdir_x(13 * _scale, _angle + 180);
var _back_mid_y = y + lengthdir_y(13 * _scale, _angle + 180);

var _back_bottom_x = x + lengthdir_x(33 * _scale, _angle + 220);
var _back_bottom_y = y + lengthdir_y(33 * _scale, _angle + 220);

draw_set_colour(make_colour_rgb(5, 12, 24));
draw_circle(x, y, 30 * _scale, false);

draw_set_colour(_primary);
draw_triangle(_nose_x, _nose_y, _back_top_x, _back_top_y, _back_mid_x, _back_mid_y, false);
draw_triangle(_nose_x, _nose_y, _back_mid_x, _back_mid_y, _back_bottom_x, _back_bottom_y, false);

draw_set_colour(_secondary);
draw_line_width(x, y, _nose_x, _nose_y, 2);

draw_set_colour(c_white);
draw_circle(x, y, 7 * _scale, false);