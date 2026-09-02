/// @description Draws one animated Simulant violet pulse frame for startup baking.
function sc_projectile_simulant_pulse_draw(_x, _y, _angle, _visual, _frame, _frame_count)
{
    var _p = _visual.palette;
    var _radius = _visual.radius;
    var _length = _visual.length;
    var _phase = (_frame / _frame_count) * pi * 2;
    var _pulse = 0.86 + sin(_phase) * 0.14;
    var _rotation = _angle + (_frame / _frame_count) * 360;

    var _front_x = _x + lengthdir_x(_radius, _angle);
    var _front_y = _y + lengthdir_y(_radius, _angle);
    var _tail_x = _x - lengthdir_x(_length, _angle);
    var _tail_y = _y - lengthdir_y(_length, _angle);

    draw_set_alpha(0.24);
    draw_set_colour(_p.glow);
    draw_line_width(_tail_x, _tail_y, _front_x, _front_y, _radius * 2.5 * _pulse);

    draw_set_alpha(0.7);
    draw_set_colour(_p.energy);
    draw_line_width(_tail_x, _tail_y, _front_x, _front_y, _radius * 1.2 * _pulse);

    draw_set_alpha(1);
    draw_set_colour(_p.core);
    draw_line_width(_tail_x, _tail_y, _front_x, _front_y, max(2, _radius * 0.45));

    draw_set_colour(_p.void);
    draw_circle(_x, _y, _radius * 0.95, false);

    draw_set_colour(_p.energy);
    draw_circle(_x, _y, _radius * 1.15 * _pulse, true);

    for (var _i = 0; _i < 4; _i++)
    {
        var _direction = _rotation + _i * 90;
        var _inner_x = _x + lengthdir_x(_radius * 0.7, _direction);
        var _inner_y = _y + lengthdir_y(_radius * 0.7, _direction);
        var _outer_x = _x + lengthdir_x(_radius * 1.45, _direction);
        var _outer_y = _y + lengthdir_y(_radius * 1.45, _direction);

        draw_set_colour((_i mod 2) == 0 ? _p.energy : _p.accent);
        draw_line_width(_inner_x, _inner_y, _outer_x, _outer_y, 2);
    }

    draw_set_colour(_p.core);
    draw_circle(_x, _y, _radius * 0.45 * _pulse, false);
    draw_set_alpha(1);
}