/// @description Draws one baked Shard hull-damage state.
function sc_ship_shard_hull_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    var _palette = _visual.palette;

    var _nose_x = _x + lengthdir_x(_radius * 1.18, _angle);
    var _nose_y = _y + lengthdir_y(_radius * 1.18, _angle);
    var _rear_x = _x + lengthdir_x(-_radius * 0.92, _angle);
    var _rear_y = _y + lengthdir_y(-_radius * 0.92, _angle);

    var _front_top_x = _x + lengthdir_x(_radius * 0.42, _angle) + lengthdir_x(-_radius * 0.45, _angle + 90);
    var _front_top_y = _y + lengthdir_y(_radius * 0.42, _angle) + lengthdir_y(-_radius * 0.45, _angle + 90);
    var _front_bottom_x = _x + lengthdir_x(_radius * 0.42, _angle) + lengthdir_x(_radius * 0.45, _angle + 90);
    var _front_bottom_y = _y + lengthdir_y(_radius * 0.42, _angle) + lengthdir_y(_radius * 0.45, _angle + 90);

    var _rear_top_x = _x + lengthdir_x(-_radius * 0.63, _angle) + lengthdir_x(-_radius * 0.52, _angle + 90);
    var _rear_top_y = _y + lengthdir_y(-_radius * 0.63, _angle) + lengthdir_y(-_radius * 0.52, _angle + 90);
    var _rear_bottom_x = _x + lengthdir_x(-_radius * 0.63, _angle) + lengthdir_x(_radius * 0.52, _angle + 90);
    var _rear_bottom_y = _y + lengthdir_y(-_radius * 0.63, _angle) + lengthdir_y(_radius * 0.52, _angle + 90);

    draw_set_colour(_palette.hull_dark);
    draw_triangle(_nose_x, _nose_y, _front_top_x, _front_top_y, _rear_top_x, _rear_top_y, false);
    draw_triangle(_nose_x, _nose_y, _rear_top_x, _rear_top_y, _rear_x, _rear_y, false);
    draw_triangle(_nose_x, _nose_y, _rear_x, _rear_y, _rear_bottom_x, _rear_bottom_y, false);
    draw_triangle(_nose_x, _nose_y, _rear_bottom_x, _rear_bottom_y, _front_bottom_x, _front_bottom_y, false);

    // Central silver structural spine.
    draw_set_colour(_palette.metal);
    draw_line_width(
        _x + lengthdir_x(-_radius * 0.72, _angle),
        _y + lengthdir_y(-_radius * 0.72, _angle),
        _x + lengthdir_x(_radius * 0.94, _angle),
        _y + lengthdir_y(_radius * 0.94, _angle),
        2
    );

    // Main reactor cavity.
    draw_set_colour(_palette.void);
    draw_circle(_x, _y, _radius * 0.25, false);

    draw_set_colour(_palette.hull_light);
    draw_circle(_x, _y, _radius * 0.25, true);

    draw_set_colour(_palette.energy);
    draw_circle(_x, _y, _radius * 0.14, false);

    draw_set_colour(_palette.core);
    draw_circle(_x, _y, _radius * 0.06, false);

    // Light hull damage.
    if (_stage >= 1)
    {
        draw_set_colour(_palette.void);

        draw_line_width(
            _x + lengthdir_x(_radius * 0.42, _angle) + lengthdir_x(-_radius * 0.18, _angle + 90),
            _y + lengthdir_y(_radius * 0.42, _angle) + lengthdir_y(-_radius * 0.18, _angle + 90),
            _x + lengthdir_x(_radius * 0.18, _angle) + lengthdir_x(-_radius * 0.34, _angle + 90),
            _y + lengthdir_y(_radius * 0.18, _angle) + lengthdir_y(-_radius * 0.34, _angle + 90),
            3
        );
    }

    // Heavy exposed damage.
    if (_stage >= 2)
    {
        var _damage_x = _x + lengthdir_x(-_radius * 0.28, _angle) + lengthdir_x(_radius * 0.34, _angle + 90);
        var _damage_y = _y + lengthdir_y(-_radius * 0.28, _angle) + lengthdir_y(_radius * 0.34, _angle + 90);

        draw_set_colour(_palette.void);
        draw_circle(_damage_x, _damage_y, _radius * 0.16, false);

        draw_set_colour(_palette.accent);
        draw_line_width(
            _damage_x,
            _damage_y,
            _damage_x + lengthdir_x(_radius * 0.26, _angle + 150),
            _damage_y + lengthdir_y(_radius * 0.26, _angle + 150),
            2
        );
    }

    // Critical structural failure.
    if (_stage >= 3)
    {
        var _failure_x = _x + lengthdir_x(-_radius * 0.58, _angle) + lengthdir_x(-_radius * 0.3, _angle + 90);
        var _failure_y = _y + lengthdir_y(-_radius * 0.58, _angle) + lengthdir_y(-_radius * 0.3, _angle + 90);

        draw_set_colour(_palette.void);
        draw_circle(_failure_x, _failure_y, _radius * 0.2, false);

        draw_set_colour(_palette.energy);
        draw_line_width(
            _failure_x,
            _failure_y,
            _failure_x + lengthdir_x(_radius * 0.3, _angle + 205),
            _failure_y + lengthdir_y(_radius * 0.3, _angle + 205),
            2
        );
    }
}

/// @description Draws one baked Shard armour-condition overlay.
function sc_ship_shard_armour_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    var _palette = _visual.palette;

    // Forward armour plate.
    if (_stage <= 2)
    {
        var _nose_x = _x + lengthdir_x(_radius * 1.08, _angle);
        var _nose_y = _y + lengthdir_y(_radius * 1.08, _angle);
        var _top_x = _x + lengthdir_x(_radius * 0.18, _angle) + lengthdir_x(-_radius * 0.26, _angle + 90);
        var _top_y = _y + lengthdir_y(_radius * 0.18, _angle) + lengthdir_y(-_radius * 0.26, _angle + 90);
        var _bottom_x = _x + lengthdir_x(_radius * 0.18, _angle) + lengthdir_x(_radius * 0.26, _angle + 90);
        var _bottom_y = _y + lengthdir_y(_radius * 0.18, _angle) + lengthdir_y(_radius * 0.26, _angle + 90);

        draw_set_colour(_stage == 2 ? _palette.hull_mid : _palette.hull_light);
        draw_triangle(_nose_x, _nose_y, _top_x, _top_y, _bottom_x, _bottom_y, false);

        draw_set_colour(_palette.metal);
        draw_line_width(_nose_x, _nose_y, _top_x, _top_y, 2);
        draw_line_width(_nose_x, _nose_y, _bottom_x, _bottom_y, 2);
    }

    // Mirrored side armour.
    for (var _side_sign = -1; _side_sign <= 1; _side_sign += 2)
    {
        if (_stage >= 2 && _side_sign > 0)
            continue;

        if (_stage >= 3 && _side_sign < 0)
            continue;

        var _front_x = _x + lengthdir_x(_radius * 0.35, _angle) + lengthdir_x(_radius * 0.36 * _side_sign, _angle + 90);
        var _front_y = _y + lengthdir_y(_radius * 0.35, _angle) + lengthdir_y(_radius * 0.36 * _side_sign, _angle + 90);
        var _outer_x = _x + lengthdir_x(-_radius * 0.22, _angle) + lengthdir_x(_radius * 0.5 * _side_sign, _angle + 90);
        var _outer_y = _y + lengthdir_y(-_radius * 0.22, _angle) + lengthdir_y(_radius * 0.5 * _side_sign, _angle + 90);
        var _rear_x = _x + lengthdir_x(-_radius * 0.56, _angle) + lengthdir_x(_radius * 0.37 * _side_sign, _angle + 90);
        var _rear_y = _y + lengthdir_y(-_radius * 0.56, _angle) + lengthdir_y(_radius * 0.37 * _side_sign, _angle + 90);

        draw_set_colour(_stage >= 1 ? _palette.hull_mid : _palette.hull_light);
        draw_triangle(_front_x, _front_y, _outer_x, _outer_y, _rear_x, _rear_y, false);

        draw_set_colour(_palette.metal);
        draw_line_width(_front_x, _front_y, _outer_x, _outer_y, 2);
        draw_line_width(_outer_x, _outer_y, _rear_x, _rear_y, 2);

        draw_set_colour(_palette.accent);
        draw_line_width(_front_x, _front_y, _rear_x, _rear_y, 2);
    }

    // Critical armour leaves only small reactor guards.
    if (_stage >= 3)
    {
        draw_set_colour(_palette.hull_light);
        draw_circle(_x, _y, _radius * 0.29, true);

        draw_set_colour(_palette.accent);
        draw_circle(_x, _y, _radius * 0.23, true);
    }
}

/// @description Draws the baked Shard shield field.
function sc_ship_shard_shield_draw(_x, _y, _radius, _angle, _visual)
{
    var _palette = _visual.palette;
    var _front_x = _x + lengthdir_x(_radius * 1.36, _angle);
    var _front_y = _y + lengthdir_y(_radius * 1.36, _angle);
    var _rear_x = _x + lengthdir_x(-_radius * 1.08, _angle);
    var _rear_y = _y + lengthdir_y(-_radius * 1.08, _angle);
    var _top_x = _x + lengthdir_x(-_radius * 0.12, _angle) + lengthdir_x(-_radius * 0.72, _angle + 90);
    var _top_y = _y + lengthdir_y(-_radius * 0.12, _angle) + lengthdir_y(-_radius * 0.72, _angle + 90);
    var _bottom_x = _x + lengthdir_x(-_radius * 0.12, _angle) + lengthdir_x(_radius * 0.72, _angle + 90);
    var _bottom_y = _y + lengthdir_y(-_radius * 0.12, _angle) + lengthdir_y(_radius * 0.72, _angle + 90);

    draw_set_alpha(0.22);
    draw_set_colour(_palette.glow);
    draw_triangle(_front_x, _front_y, _top_x, _top_y, _rear_x, _rear_y, true);
    draw_triangle(_front_x, _front_y, _rear_x, _rear_y, _bottom_x, _bottom_y, true);

    draw_set_alpha(0.75);
    draw_set_colour(_palette.energy);
    draw_line_width(_front_x, _front_y, _top_x, _top_y, 2);
    draw_line_width(_top_x, _top_y, _rear_x, _rear_y, 2);
    draw_line_width(_rear_x, _rear_y, _bottom_x, _bottom_y, 2);
    draw_line_width(_bottom_x, _bottom_y, _front_x, _front_y, 2);

    draw_set_alpha(1);
}

/// @description Draws one substantial baked Shard aqua flame.
function sc_ship_shard_thrust_draw(_x, _y, _radius, _angle, _visual)
{
    var _palette = _visual.palette;

    var _outer_length = _radius * 0.96;
    var _outer_width = _radius * 0.26;
    var _outer_tip_x = _x + lengthdir_x(_outer_length, _angle);
    var _outer_tip_y = _y + lengthdir_y(_outer_length, _angle);
    var _outer_top_x = _x + lengthdir_x(-_outer_width, _angle + 90);
    var _outer_top_y = _y + lengthdir_y(-_outer_width, _angle + 90);
    var _outer_bottom_x = _x + lengthdir_x(_outer_width, _angle + 90);
    var _outer_bottom_y = _y + lengthdir_y(_outer_width, _angle + 90);

    var _energy_length = _radius * 0.76;
    var _energy_width = _radius * 0.17;
    var _energy_tip_x = _x + lengthdir_x(_energy_length, _angle);
    var _energy_tip_y = _y + lengthdir_y(_energy_length, _angle);
    var _energy_top_x = _x + lengthdir_x(-_energy_width, _angle + 90);
    var _energy_top_y = _y + lengthdir_y(-_energy_width, _angle + 90);
    var _energy_bottom_x = _x + lengthdir_x(_energy_width, _angle + 90);
    var _energy_bottom_y = _y + lengthdir_y(_energy_width, _angle + 90);

    var _core_length = _radius * 0.52;
    var _core_width = _radius * 0.07;
    var _core_tip_x = _x + lengthdir_x(_core_length, _angle);
    var _core_tip_y = _y + lengthdir_y(_core_length, _angle);
    var _core_top_x = _x + lengthdir_x(-_core_width, _angle + 90);
    var _core_top_y = _y + lengthdir_y(-_core_width, _angle + 90);
    var _core_bottom_x = _x + lengthdir_x(_core_width, _angle + 90);
    var _core_bottom_y = _y + lengthdir_y(_core_width, _angle + 90);

    draw_set_alpha(0.4);
    draw_set_colour(_palette.glow);
    draw_triangle(_outer_top_x, _outer_top_y, _outer_tip_x, _outer_tip_y, _outer_bottom_x, _outer_bottom_y, false);

    draw_set_alpha(0.82);
    draw_set_colour(_palette.energy);
    draw_triangle(_energy_top_x, _energy_top_y, _energy_tip_x, _energy_tip_y, _energy_bottom_x, _energy_bottom_y, false);

    draw_set_alpha(1);
    draw_set_colour(_palette.core);
    draw_triangle(_core_top_x, _core_top_y, _core_tip_x, _core_tip_y, _core_bottom_x, _core_bottom_y, false);

    draw_set_colour(_palette.metal);
    draw_line_width(_x, _y, _outer_tip_x, _outer_tip_y, 2);

    draw_set_alpha(1);
}