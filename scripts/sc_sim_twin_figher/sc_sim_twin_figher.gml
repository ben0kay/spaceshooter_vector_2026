/// @description Draws the Twin Fighter's static primitive body.
function sc_enemy_twin_fighter_body_draw(_x, _y, _radius, _angle, _visual)
{
    var _palette = _visual.palette;
    var _nose_x = _x + lengthdir_x(_radius * 1.15, _angle);
    var _nose_y = _y + lengthdir_y(_radius * 1.15, _angle);
    var _wing_top_x = _x + lengthdir_x(_radius * 0.2, _angle) + lengthdir_x(_radius * -0.95, _angle + 90);
    var _wing_top_y = _y + lengthdir_y(_radius * 0.2, _angle) + lengthdir_y(_radius * -0.95, _angle + 90);
    var _wing_bottom_x = _x + lengthdir_x(_radius * 0.2, _angle) + lengthdir_x(_radius * 0.95, _angle + 90);
    var _wing_bottom_y = _y + lengthdir_y(_radius * 0.2, _angle) + lengthdir_y(_radius * 0.95, _angle + 90);
    var _tail_top_x = _x + lengthdir_x(_radius * -0.9, _angle) + lengthdir_x(_radius * -0.52, _angle + 90);
    var _tail_top_y = _y + lengthdir_y(_radius * -0.9, _angle) + lengthdir_y(_radius * -0.52, _angle + 90);
    var _tail_bottom_x = _x + lengthdir_x(_radius * -0.9, _angle) + lengthdir_x(_radius * 0.52, _angle + 90);
    var _tail_bottom_y = _y + lengthdir_y(_radius * -0.9, _angle) + lengthdir_y(_radius * 0.52, _angle + 90);

    draw_set_colour(_palette.hull_dark);
    draw_triangle(_nose_x, _nose_y, _wing_top_x, _wing_top_y, _tail_top_x, _tail_top_y, false);
    draw_triangle(_nose_x, _nose_y, _tail_bottom_x, _tail_bottom_y, _wing_bottom_x, _wing_bottom_y, false);

    draw_set_colour(_palette.outline);
    draw_triangle(_nose_x, _nose_y, _wing_top_x, _wing_top_y, _x, _y, true);
    draw_triangle(_nose_x, _nose_y, _x, _y, _wing_bottom_x, _wing_bottom_y, true);

    draw_set_colour(_palette.accent);
    draw_line_width(_tail_top_x, _tail_top_y, _nose_x, _nose_y, 3);
    draw_line_width(_tail_bottom_x, _tail_bottom_y, _nose_x, _nose_y, 3);

    var _mount_forward = _radius * 0.73;
    var _mount_side = _radius * 0.48;

    for (var _side_sign = -1; _side_sign <= 1; _side_sign += 2)
    {
        var _mount_x = _x + lengthdir_x(_mount_forward, _angle) + lengthdir_x(_mount_side * _side_sign, _angle + 90);
        var _mount_y = _y + lengthdir_y(_mount_forward, _angle) + lengthdir_y(_mount_side * _side_sign, _angle + 90);

        draw_set_colour(_palette.hull_mid);
        draw_circle(_mount_x, _mount_y, _radius * 0.19, false);

        draw_set_colour(_palette.outline);
        draw_circle(_mount_x, _mount_y, _radius * 0.19, true);
    }
}

/// @description Draws one reusable primitive Twin Fighter cannon.
function sc_enemy_twin_fighter_cannon_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _palette = _visual.palette;
    var _length = _radius * 0.48;
    var _half_width = _radius * 0.1;
    var _front_top_x = _x + lengthdir_x(_length, _angle) + lengthdir_x(-_half_width, _angle + 90);
    var _front_top_y = _y + lengthdir_y(_length, _angle) + lengthdir_y(-_half_width, _angle + 90);
    var _front_bottom_x = _x + lengthdir_x(_length, _angle) + lengthdir_x(_half_width, _angle + 90);
    var _front_bottom_y = _y + lengthdir_y(_length, _angle) + lengthdir_y(_half_width, _angle + 90);
    var _rear_top_x = _x + lengthdir_x(-_length * 0.2, _angle) + lengthdir_x(-_half_width, _angle + 90);
    var _rear_top_y = _y + lengthdir_y(-_length * 0.2, _angle) + lengthdir_y(-_half_width, _angle + 90);
    var _rear_bottom_x = _x + lengthdir_x(-_length * 0.2, _angle) + lengthdir_x(_half_width, _angle + 90);
    var _rear_bottom_y = _y + lengthdir_y(-_length * 0.2, _angle) + lengthdir_y(_half_width, _angle + 90);

    draw_set_alpha(_alpha);
    draw_set_colour(_palette.void);
    draw_triangle(_rear_top_x, _rear_top_y, _front_top_x, _front_top_y, _front_bottom_x, _front_bottom_y, false);
    draw_triangle(_rear_top_x, _rear_top_y, _front_bottom_x, _front_bottom_y, _rear_bottom_x, _rear_bottom_y, false);

    draw_set_colour(_palette.energy);
    draw_line_width(_x, _y, _x + lengthdir_x(_length, _angle), _y + lengthdir_y(_length, _angle), 3);
    draw_set_alpha(1);
}

/// @description Draws the Twin Fighter's rotating primitive core.
function sc_enemy_twin_fighter_core_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _palette = _visual.palette;
    var _ring_radius = _radius * 0.32;

    draw_set_alpha(_alpha);
    draw_set_colour(_palette.outline);
    draw_circle(_x, _y, _ring_radius, true);

    draw_set_colour(_palette.energy);

    for (var _i = 0; _i < 4; _i++)
    {
        var _direction = _angle + _i * 90;

        draw_line_width(
            _x + lengthdir_x(_ring_radius * 0.55, _direction),
            _y + lengthdir_y(_ring_radius * 0.55, _direction),
            _x + lengthdir_x(_ring_radius * 1.25, _direction),
            _y + lengthdir_y(_ring_radius * 1.25, _direction),
            3
        );
    }

    draw_set_colour(_palette.core);
    draw_circle(_x, _y, _radius * 0.11, false);
    draw_set_alpha(1);
}