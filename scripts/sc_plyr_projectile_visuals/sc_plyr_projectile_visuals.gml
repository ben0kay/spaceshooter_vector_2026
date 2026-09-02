/// @description Draws one animated Shard aqua pulse frame for startup baking.
function sc_projectile_shard_pulse_draw(_x, _y, _angle, _visual, _frame, _frame_count)
{
    var _p = _visual.palette;
    var _radius = _visual.radius;
    var _length = _visual.length;
    var _phase = (_frame / _frame_count) * pi * 2;
    var _pulse = 0.88 + sin(_phase) * 0.12;

    var _front_x = _x + lengthdir_x(_radius * 1.2, _angle);
    var _front_y = _y + lengthdir_y(_radius * 1.2, _angle);
    var _tail_x = _x - lengthdir_x(_length, _angle);
    var _tail_y = _y - lengthdir_y(_length, _angle);
    var _wing_x = _x - lengthdir_x(_length * 0.32, _angle);
    var _wing_y = _y - lengthdir_y(_length * 0.32, _angle);
    var _glow_width = _radius * 1.9 * _pulse;
    var _energy_width = _radius * 1.05 * _pulse;

    draw_set_alpha(0.22);
    draw_set_colour(_p.glow);
    draw_triangle(
        _front_x, _front_y,
        _tail_x + lengthdir_x(-_glow_width, _angle + 90), _tail_y + lengthdir_y(-_glow_width, _angle + 90),
        _tail_x + lengthdir_x(_glow_width, _angle + 90), _tail_y + lengthdir_y(_glow_width, _angle + 90),
        false
    );

    draw_set_alpha(0.7);
    draw_set_colour(_p.energy);
    draw_triangle(
        _front_x, _front_y,
        _wing_x + lengthdir_x(-_energy_width, _angle + 90), _wing_y + lengthdir_y(-_energy_width, _angle + 90),
        _tail_x, _tail_y,
        false
    );
    draw_triangle(
        _front_x, _front_y,
        _tail_x, _tail_y,
        _wing_x + lengthdir_x(_energy_width, _angle + 90), _wing_y + lengthdir_y(_energy_width, _angle + 90),
        false
    );

    draw_set_alpha(1);
    draw_set_colour(_p.core);
    draw_line_width(_tail_x, _tail_y, _front_x, _front_y, max(2, _radius * 0.55));
    draw_circle(_x, _y, _radius * 0.62 * _pulse, false);

    draw_set_colour(c_white);
    draw_circle(_front_x, _front_y, max(1, _radius * 0.28), false);
    draw_set_alpha(1);
}