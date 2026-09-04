/// @description Draws sleek glowing world feedback.
var _progress = 1 - feedback.remaining / feedback.life;
var _alpha = sin(_progress * pi);
var _scale = feedback.scale * lerp(1.12, 0.92, _progress);
var _width = string_width(feedback.text) * _scale;
var _edge = _width * 0.5 + 8 * _scale;

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

gpu_set_blendmode(bm_add);
draw_set_colour(feedback.colour);
draw_set_alpha(_alpha * 0.25);
draw_text_transformed(x, y, feedback.text, _scale * 1.08, _scale * 1.08, 0);
draw_line_width(x - _edge, y - 5 * _scale, x - _edge, y + 5 * _scale, 2);
draw_line_width(x + _edge, y - 5 * _scale, x + _edge, y + 5 * _scale, 2);
gpu_set_blendmode(bm_normal);

draw_set_alpha(_alpha);
draw_set_colour(c_white);
draw_text_transformed(x, y, feedback.text, _scale, _scale, 0);

draw_set_alpha(1);
draw_set_colour(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);