/// @description Draws the Twin Fighter's layered static gunmetal body.
function sc_enemy_twin_fighter_body_draw(_x, _y, _radius, _angle, _visual)
{
    var _palette = _visual.palette;
    var _nose_x = _x + lengthdir_x(_radius * 1.16, _angle);
    var _nose_y = _y + lengthdir_y(_radius * 1.16, _angle);
    var _tail_x = _x + lengthdir_x(-_radius * 1.02, _angle);
    var _tail_y = _y + lengthdir_y(-_radius * 1.02, _angle);

    // Main central armoured hull.
    var _front_top_x = _x + lengthdir_x(_radius * 0.52, _angle) + lengthdir_x(-_radius * 0.31, _angle + 90);
    var _front_top_y = _y + lengthdir_y(_radius * 0.52, _angle) + lengthdir_y(-_radius * 0.31, _angle + 90);
    var _front_bottom_x = _x + lengthdir_x(_radius * 0.52, _angle) + lengthdir_x(_radius * 0.31, _angle + 90);
    var _front_bottom_y = _y + lengthdir_y(_radius * 0.52, _angle) + lengthdir_y(_radius * 0.31, _angle + 90);
    var _rear_top_x = _x + lengthdir_x(-_radius * 0.72, _angle) + lengthdir_x(-_radius * 0.38, _angle + 90);
    var _rear_top_y = _y + lengthdir_y(-_radius * 0.72, _angle) + lengthdir_y(-_radius * 0.38, _angle + 90);
    var _rear_bottom_x = _x + lengthdir_x(-_radius * 0.72, _angle) + lengthdir_x(_radius * 0.38, _angle + 90);
    var _rear_bottom_y = _y + lengthdir_y(-_radius * 0.72, _angle) + lengthdir_y(_radius * 0.38, _angle + 90);

    draw_set_colour(_palette.hull_dark);
    draw_triangle(_nose_x, _nose_y, _front_top_x, _front_top_y, _rear_top_x, _rear_top_y, false);
    draw_triangle(_nose_x, _nose_y, _rear_top_x, _rear_top_y, _tail_x, _tail_y, false);
    draw_triangle(_nose_x, _nose_y, _tail_x, _tail_y, _rear_bottom_x, _rear_bottom_y, false);
    draw_triangle(_nose_x, _nose_y, _rear_bottom_x, _rear_bottom_y, _front_bottom_x, _front_bottom_y, false);

    // Central raised armour plates.
    var _plate_front_x = _x + lengthdir_x(_radius * 0.67, _angle);
    var _plate_front_y = _y + lengthdir_y(_radius * 0.67, _angle);
    var _plate_rear_x = _x + lengthdir_x(-_radius * 0.58, _angle);
    var _plate_rear_y = _y + lengthdir_y(-_radius * 0.58, _angle);
    var _plate_top_x = _x + lengthdir_x(-_radius * 0.08, _angle) + lengthdir_x(-_radius * 0.24, _angle + 90);
    var _plate_top_y = _y + lengthdir_y(-_radius * 0.08, _angle) + lengthdir_y(-_radius * 0.24, _angle + 90);
    var _plate_bottom_x = _x + lengthdir_x(-_radius * 0.08, _angle) + lengthdir_x(_radius * 0.24, _angle + 90);
    var _plate_bottom_y = _y + lengthdir_y(-_radius * 0.08, _angle) + lengthdir_y(_radius * 0.24, _angle + 90);

    draw_set_colour(_palette.hull_mid);
    draw_triangle(_plate_front_x, _plate_front_y, _plate_top_x, _plate_top_y, _plate_rear_x, _plate_rear_y, false);
    draw_triangle(_plate_front_x, _plate_front_y, _plate_rear_x, _plate_rear_y, _plate_bottom_x, _plate_bottom_y, false);

    draw_set_colour(_palette.hull_light);
    draw_line_width(_plate_front_x, _plate_front_y, _plate_top_x, _plate_top_y, 2);
    draw_line_width(_plate_top_x, _plate_top_y, _plate_rear_x, _plate_rear_y, 2);
    draw_line_width(_plate_rear_x, _plate_rear_y, _plate_bottom_x, _plate_bottom_y, 2);
    draw_line_width(_plate_bottom_x, _plate_bottom_y, _plate_front_x, _plate_front_y, 2);

    // Mirrored segmented wings and cannon housings.
    for (var _side_sign = -1; _side_sign <= 1; _side_sign += 2)
    {
        var _wing_front_x = _x + lengthdir_x(_radius * 0.52, _angle) + lengthdir_x(_radius * 0.42 * _side_sign, _angle + 90);
        var _wing_front_y = _y + lengthdir_y(_radius * 0.52, _angle) + lengthdir_y(_radius * 0.42 * _side_sign, _angle + 90);
        var _wing_tip_x = _x + lengthdir_x(_radius * 0.03, _angle) + lengthdir_x(_radius * 1.07 * _side_sign, _angle + 90);
        var _wing_tip_y = _y + lengthdir_y(_radius * 0.03, _angle) + lengthdir_y(_radius * 1.07 * _side_sign, _angle + 90);
        var _wing_rear_x = _x + lengthdir_x(-_radius * 0.86, _angle) + lengthdir_x(_radius * 0.78 * _side_sign, _angle + 90);
        var _wing_rear_y = _y + lengthdir_y(-_radius * 0.86, _angle) + lengthdir_y(_radius * 0.78 * _side_sign, _angle + 90);
        var _wing_inner_x = _x + lengthdir_x(-_radius * 0.56, _angle) + lengthdir_x(_radius * 0.37 * _side_sign, _angle + 90);
        var _wing_inner_y = _y + lengthdir_y(-_radius * 0.56, _angle) + lengthdir_y(_radius * 0.37 * _side_sign, _angle + 90);

        draw_set_colour(_palette.hull_dark);
        draw_triangle(_wing_front_x, _wing_front_y, _wing_tip_x, _wing_tip_y, _wing_inner_x, _wing_inner_y, false);
        draw_triangle(_wing_tip_x, _wing_tip_y, _wing_rear_x, _wing_rear_y, _wing_inner_x, _wing_inner_y, false);

        // Raised wing armour.
        var _panel_front_x = _x + lengthdir_x(_radius * 0.35, _angle) + lengthdir_x(_radius * 0.48 * _side_sign, _angle + 90);
        var _panel_front_y = _y + lengthdir_y(_radius * 0.35, _angle) + lengthdir_y(_radius * 0.48 * _side_sign, _angle + 90);
        var _panel_outer_x = _x + lengthdir_x(-_radius * 0.03, _angle) + lengthdir_x(_radius * 0.87 * _side_sign, _angle + 90);
        var _panel_outer_y = _y + lengthdir_y(-_radius * 0.03, _angle) + lengthdir_y(_radius * 0.87 * _side_sign, _angle + 90);
        var _panel_rear_x = _x + lengthdir_x(-_radius * 0.66, _angle) + lengthdir_x(_radius * 0.66 * _side_sign, _angle + 90);
        var _panel_rear_y = _y + lengthdir_y(-_radius * 0.66, _angle) + lengthdir_y(_radius * 0.66 * _side_sign, _angle + 90);
        var _panel_inner_x = _x + lengthdir_x(-_radius * 0.38, _angle) + lengthdir_x(_radius * 0.42 * _side_sign, _angle + 90);
        var _panel_inner_y = _y + lengthdir_y(-_radius * 0.38, _angle) + lengthdir_y(_radius * 0.42 * _side_sign, _angle + 90);

        draw_set_colour(_palette.hull_mid);
        draw_triangle(_panel_front_x, _panel_front_y, _panel_outer_x, _panel_outer_y, _panel_inner_x, _panel_inner_y, false);
        draw_triangle(_panel_outer_x, _panel_outer_y, _panel_rear_x, _panel_rear_y, _panel_inner_x, _panel_inner_y, false);

        draw_set_colour(_palette.hull_light);
        draw_line_width(_wing_front_x, _wing_front_y, _wing_tip_x, _wing_tip_y, 2);
        draw_line_width(_wing_tip_x, _wing_tip_y, _wing_rear_x, _wing_rear_y, 2);
        draw_line_width(_panel_front_x, _panel_front_y, _panel_outer_x, _panel_outer_y, 2);
        draw_line_width(_panel_outer_x, _panel_outer_y, _panel_rear_x, _panel_rear_y, 2);

        // Thin recessed Simulant energy trenches.
        var _energy_front_x = _x + lengthdir_x(_radius * 0.27, _angle) + lengthdir_x(_radius * 0.53 * _side_sign, _angle + 90);
        var _energy_front_y = _y + lengthdir_y(_radius * 0.27, _angle) + lengthdir_y(_radius * 0.53 * _side_sign, _angle + 90);
        var _energy_rear_x = _x + lengthdir_x(-_radius * 0.48, _angle) + lengthdir_x(_radius * 0.58 * _side_sign, _angle + 90);
        var _energy_rear_y = _y + lengthdir_y(-_radius * 0.48, _angle) + lengthdir_y(_radius * 0.58 * _side_sign, _angle + 90);

        draw_set_colour(_palette.accent);
        draw_line_width(_energy_front_x, _energy_front_y, _energy_rear_x, _energy_rear_y, 3);

        // Mechanical cannon mount.
        var _mount_x = _x + lengthdir_x(_radius * 0.73, _angle) + lengthdir_x(_radius * 0.48 * _side_sign, _angle + 90);
        var _mount_y = _y + lengthdir_y(_radius * 0.73, _angle) + lengthdir_y(_radius * 0.48 * _side_sign, _angle + 90);

        draw_set_colour(_palette.void);
        draw_circle(_mount_x, _mount_y, _radius * 0.2, false);
        draw_set_colour(_palette.metal);
        draw_circle(_mount_x, _mount_y, _radius * 0.2, true);
        draw_set_colour(_palette.energy);
        draw_circle(_mount_x, _mount_y, _radius * 0.09, true);
    }

    // Central mechanical spine.
    var _spine_front_x = _x + lengthdir_x(_radius * 0.86, _angle);
    var _spine_front_y = _y + lengthdir_y(_radius * 0.86, _angle);
    var _spine_rear_x = _x + lengthdir_x(-_radius * 0.82, _angle);
    var _spine_rear_y = _y + lengthdir_y(-_radius * 0.82, _angle);

    draw_set_colour(_palette.metal);
    draw_line_width(_spine_rear_x, _spine_rear_y, _spine_front_x, _spine_front_y, 2);

    draw_set_colour(_palette.accent);
    draw_line_width(
        _x + lengthdir_x(-_radius * 0.62, _angle),
        _y + lengthdir_y(-_radius * 0.62, _angle),
        _x + lengthdir_x(-_radius * 0.31, _angle),
        _y + lengthdir_y(-_radius * 0.31, _angle),
        3
    );

    // Nose armour highlight.
    draw_set_colour(_palette.metal);
    draw_line_width(_nose_x, _nose_y, _front_top_x, _front_top_y, 2);
    draw_line_width(_nose_x, _nose_y, _front_bottom_x, _front_bottom_y, 2);
}

/// @description Draws one layered mechanical Twin Fighter cannon.
function sc_enemy_twin_fighter_cannon_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _palette = _visual.palette;
    var _length = _radius * 0.48;
    var _half_width = _radius * 0.115;
    var _front_x = _x + lengthdir_x(_length, _angle);
    var _front_y = _y + lengthdir_y(_length, _angle);
    var _rear_x = _x + lengthdir_x(-_length * 0.22, _angle);
    var _rear_y = _y + lengthdir_y(-_length * 0.22, _angle);
    var _front_top_x = _front_x + lengthdir_x(-_half_width, _angle + 90);
    var _front_top_y = _front_y + lengthdir_y(-_half_width, _angle + 90);
    var _front_bottom_x = _front_x + lengthdir_x(_half_width, _angle + 90);
    var _front_bottom_y = _front_y + lengthdir_y(_half_width, _angle + 90);
    var _rear_top_x = _rear_x + lengthdir_x(-_half_width * 1.15, _angle + 90);
    var _rear_top_y = _rear_y + lengthdir_y(-_half_width * 1.15, _angle + 90);
    var _rear_bottom_x = _rear_x + lengthdir_x(_half_width * 1.15, _angle + 90);
    var _rear_bottom_y = _rear_y + lengthdir_y(_half_width * 1.15, _angle + 90);

    draw_set_alpha(_alpha);
    draw_set_colour(_palette.hull_dark);
    draw_triangle(_rear_top_x, _rear_top_y, _front_top_x, _front_top_y, _front_bottom_x, _front_bottom_y, false);
    draw_triangle(_rear_top_x, _rear_top_y, _front_bottom_x, _front_bottom_y, _rear_bottom_x, _rear_bottom_y, false);

    draw_set_colour(_palette.hull_light);
    draw_line_width(_rear_top_x, _rear_top_y, _front_top_x, _front_top_y, 2);
    draw_line_width(_rear_bottom_x, _rear_bottom_y, _front_bottom_x, _front_bottom_y, 2);

    // Twin metallic barrel rails.
    var _rail_offset = _half_width * 0.62;

    draw_set_colour(_palette.metal);
    draw_line_width(
        _rear_x + lengthdir_x(-_rail_offset, _angle + 90),
        _rear_y + lengthdir_y(-_rail_offset, _angle + 90),
        _front_x + lengthdir_x(-_rail_offset, _angle + 90),
        _front_y + lengthdir_y(-_rail_offset, _angle + 90),
        2
    );
    draw_line_width(
        _rear_x + lengthdir_x(_rail_offset, _angle + 90),
        _rear_y + lengthdir_y(_rail_offset, _angle + 90),
        _front_x + lengthdir_x(_rail_offset, _angle + 90),
        _front_y + lengthdir_y(_rail_offset, _angle + 90),
        2
    );

    // Central active conduit.
    draw_set_colour(_palette.energy);
    draw_line_width(_rear_x, _rear_y, _front_x, _front_y, 3);

    // Segmented barrel rings.
    for (var _i = 1; _i <= 3; _i++)
    {
        var _segment_distance = _length * (_i * 0.22);
        var _segment_x = _x + lengthdir_x(_segment_distance, _angle);
        var _segment_y = _y + lengthdir_y(_segment_distance, _angle);

        draw_set_colour(_i == 2 ? _palette.accent : _palette.outline);
        draw_line_width(
            _segment_x + lengthdir_x(-_half_width, _angle + 90),
            _segment_y + lengthdir_y(-_half_width, _angle + 90),
            _segment_x + lengthdir_x(_half_width, _angle + 90),
            _segment_y + lengthdir_y(_half_width, _angle + 90),
            2
        );
    }

    // Bright muzzle aperture.
    draw_set_colour(_palette.void);
    draw_circle(_front_x, _front_y, _radius * 0.105, false);
    draw_set_colour(_palette.metal);
    draw_circle(_front_x, _front_y, _radius * 0.105, true);
    draw_set_colour(_palette.core);
    draw_circle(_front_x, _front_y, _radius * 0.045, false);

    draw_set_alpha(1);
}

/// @description Draws the Twin Fighter's rotating mechanical energy core.
function sc_enemy_twin_fighter_core_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _palette = _visual.palette;
    var _outer_radius = _radius * 0.34;
    var _middle_radius = _radius * 0.24;
    var _inner_radius = _radius * 0.12;

    draw_set_alpha(_alpha);

    draw_set_colour(_palette.void);
    draw_circle(_x, _y, _outer_radius, false);

    draw_set_colour(_palette.metal);
    draw_circle(_x, _y, _outer_radius, true);

    draw_set_colour(_palette.hull_light);
    draw_circle(_x, _y, _middle_radius, true);

    // Rotating mechanical-energy spokes.
    for (var _i = 0; _i < 8; _i++)
    {
        var _direction = _angle + _i * 45;
        var _inner_x = _x + lengthdir_x(_middle_radius * 0.65, _direction);
        var _inner_y = _y + lengthdir_y(_middle_radius * 0.65, _direction);
        var _outer_x = _x + lengthdir_x(_outer_radius * 1.15, _direction);
        var _outer_y = _y + lengthdir_y(_outer_radius * 1.15, _direction);

        draw_set_colour((_i mod 2) == 0 ? _palette.energy : _palette.outline);
        draw_line_width(_inner_x, _inner_y, _outer_x, _outer_y, (_i mod 2) == 0 ? 3 : 2);
    }

    draw_set_colour(_palette.accent);
    draw_circle(_x, _y, _inner_radius * 1.45, true);

    draw_set_colour(_palette.energy);
    draw_circle(_x, _y, _inner_radius, false);

    draw_set_colour(_palette.core);
    draw_circle(_x, _y, _inner_radius * 0.48, false);

    draw_set_alpha(1);
}