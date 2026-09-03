/// @description Draws one substantial baked Simulant energy flame.
function sc_enemy_simulant_thrust_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _palette = _visual.palette;

    var _outer_length = _radius * 0.82;
    var _outer_width = _radius * 0.25;
    var _outer_tip_x = _x + lengthdir_x(_outer_length, _angle);
    var _outer_tip_y = _y + lengthdir_y(_outer_length, _angle);
    var _outer_top_x = _x + lengthdir_x(-_outer_width, _angle + 90);
    var _outer_top_y = _y + lengthdir_y(-_outer_width, _angle + 90);
    var _outer_bottom_x = _x + lengthdir_x(_outer_width, _angle + 90);
    var _outer_bottom_y = _y + lengthdir_y(_outer_width, _angle + 90);

    var _energy_length = _radius * 0.66;
    var _energy_width = _radius * 0.17;
    var _energy_tip_x = _x + lengthdir_x(_energy_length, _angle);
    var _energy_tip_y = _y + lengthdir_y(_energy_length, _angle);
    var _energy_top_x = _x + lengthdir_x(-_energy_width, _angle + 90);
    var _energy_top_y = _y + lengthdir_y(-_energy_width, _angle + 90);
    var _energy_bottom_x = _x + lengthdir_x(_energy_width, _angle + 90);
    var _energy_bottom_y = _y + lengthdir_y(_energy_width, _angle + 90);

    var _core_length = _radius * 0.46;
    var _core_width = _radius * 0.075;
    var _core_tip_x = _x + lengthdir_x(_core_length, _angle);
    var _core_tip_y = _y + lengthdir_y(_core_length, _angle);
    var _core_top_x = _x + lengthdir_x(-_core_width, _angle + 90);
    var _core_top_y = _y + lengthdir_y(-_core_width, _angle + 90);
    var _core_bottom_x = _x + lengthdir_x(_core_width, _angle + 90);
    var _core_bottom_y = _y + lengthdir_y(_core_width, _angle + 90);

    draw_set_alpha(_alpha * 0.38);
    draw_set_colour(_palette.glow);
    draw_triangle(_outer_top_x, _outer_top_y, _outer_tip_x, _outer_tip_y, _outer_bottom_x, _outer_bottom_y, false);

    draw_set_alpha(_alpha * 0.78);
    draw_set_colour(_palette.energy);
    draw_triangle(_energy_top_x, _energy_top_y, _energy_tip_x, _energy_tip_y, _energy_bottom_x, _energy_bottom_y, false);

    draw_set_alpha(_alpha);
    draw_set_colour(_palette.core);
    draw_triangle(_core_top_x, _core_top_y, _core_tip_x, _core_tip_y, _core_bottom_x, _core_bottom_y, false);

    draw_set_alpha(_alpha);
    draw_set_colour(_palette.accent);
    draw_line_width(_x, _y, _outer_tip_x, _outer_tip_y, 2);

    draw_set_alpha(1);
}