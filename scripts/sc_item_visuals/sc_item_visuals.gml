/*
ITEM FALLBACK VISUALS

Every item may use an authored s_item_[name] sprite.
These primitive functions provide baked fallbacks when it does not exist.
*/

/// @description Draws the existing clustered raw-resource fallback.
function sc_item_raw_primitive_draw(_x, _y, _radius, _variant, _visual)
{
    sc_resource_pickup_primitive_draw(_x, _y, _radius, _variant, _visual);
}

/// @description Draws one refined metal-ingot fallback.
function sc_item_ingot_primitive_draw(_x, _y, _radius, _variant, _visual)
{
    var _dark = merge_colour(_visual.colour, c_black, 0.62);
    var _light = merge_colour(_visual.colour, c_white, 0.28);
    var _offset = (_variant mod 2) * 2 - 1;

    gpu_set_blendmode(bm_add);
    draw_set_colour(_visual.glow);
    draw_set_alpha(0.12);
    draw_circle(_x, _y, _radius * 1.7, false);
    gpu_set_blendmode(bm_normal);

    draw_set_alpha(1);
    draw_set_colour(_dark);
    draw_rectangle(_x - 16, _y - 7, _x + 16, _y + 8, false);

    draw_set_colour(_visual.colour);
    draw_rectangle(_x - 13, _y - 9, _x + 13, _y + 5, false);

    draw_set_colour(_light);
    draw_triangle(_x - 13, _y - 9, _x + 13, _y - 9, _x + 9 + _offset, _y - 3, false);

    draw_set_colour(_visual.glow);
    draw_set_alpha(0.65);
    draw_line_width(_x - 7, _y + 1, _x + 7, _y + 1, 2);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws one standardized construction-plate fallback.
function sc_item_plate_primitive_draw(_x, _y, _radius, _variant, _visual)
{
    var _dark = merge_colour(_visual.colour, c_black, 0.68);
    var _light = merge_colour(_visual.colour, c_white, 0.24);

    gpu_set_blendmode(bm_add);
    draw_set_colour(_visual.glow);
    draw_set_alpha(0.1);
    draw_rectangle(_x - 20, _y - 15, _x + 20, _y + 15, false);
    gpu_set_blendmode(bm_normal);

    draw_set_alpha(1);
    draw_set_colour(_dark);
    draw_rectangle(_x - 19, _y - 13, _x + 19, _y + 13, false);

    draw_set_colour(_visual.colour);
    draw_rectangle(_x - 16, _y - 10, _x + 16, _y + 10, false);

    draw_set_colour(_light);
    draw_line_width(_x - 13, _y - 7, _x + 13, _y - 7, 2);

    draw_set_colour(_visual.glow);
    draw_set_alpha(0.72);
    draw_line_width(_x - 8, _y + 4, _x + 8, _y + 4, 2);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws one reinforced ship-armour module fallback.
function sc_item_armour_primitive_draw(_x, _y, _radius, _variant, _visual)
{
    var _dark = merge_colour(_visual.colour, c_black, 0.72);
    var _mid = merge_colour(_visual.colour, c_black, 0.28);
    var _light = merge_colour(_visual.colour, c_white, 0.34);

    gpu_set_blendmode(bm_add);
    draw_set_colour(_visual.glow);
    draw_set_alpha(0.13);
    draw_circle(_x, _y, 27, false);
    gpu_set_blendmode(bm_normal);

    draw_set_alpha(1);
    draw_set_colour(_dark);
    draw_triangle(_x - 22, _y - 13, _x + 22, _y - 13, _x, _y + 19, false);

    draw_set_colour(_mid);
    draw_triangle(_x - 17, _y - 10, _x + 17, _y - 10, _x, _y + 14, false);

    draw_set_colour(_light);
    draw_line_width(_x - 13, _y - 7, _x + 13, _y - 7, 2);
    draw_line_width(_x - 13, _y - 7, _x, _y + 10, 2);
    draw_line_width(_x + 13, _y - 7, _x, _y + 10, 2);

    draw_set_colour(_visual.glow);
    draw_set_alpha(0.85);
    draw_circle(_x, _y, 4, false);

    draw_set_colour(c_white);
    draw_set_alpha(0.9);
    draw_circle(_x, _y, 1.5, false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}