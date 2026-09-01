/// @description Draws one baked Shard central hull-damage state.
function sc_ship_shard_hull_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    var _p = _visual.palette;

    var _nose_x = _x + lengthdir_x(_radius * 1.5, _angle);
    var _nose_y = _y + lengthdir_y(_radius * 1.5, _angle);
    var _rear_x = _x + lengthdir_x(-_radius * 1.02, _angle);
    var _rear_y = _y + lengthdir_y(-_radius * 1.02, _angle);

    var _front_top_x = _x + lengthdir_x(_radius * 0.62, _angle) + lengthdir_x(-_radius * 0.27, _angle + 90);
    var _front_top_y = _y + lengthdir_y(_radius * 0.62, _angle) + lengthdir_y(-_radius * 0.27, _angle + 90);
    var _front_bottom_x = _x + lengthdir_x(_radius * 0.62, _angle) + lengthdir_x(_radius * 0.27, _angle + 90);
    var _front_bottom_y = _y + lengthdir_y(_radius * 0.62, _angle) + lengthdir_y(_radius * 0.27, _angle + 90);

    var _mid_top_x = _x + lengthdir_x(-_radius * 0.14, _angle) + lengthdir_x(-_radius * 0.39, _angle + 90);
    var _mid_top_y = _y + lengthdir_y(-_radius * 0.14, _angle) + lengthdir_y(-_radius * 0.39, _angle + 90);
    var _mid_bottom_x = _x + lengthdir_x(-_radius * 0.14, _angle) + lengthdir_x(_radius * 0.39, _angle + 90);
    var _mid_bottom_y = _y + lengthdir_y(-_radius * 0.14, _angle) + lengthdir_y(_radius * 0.39, _angle + 90);

    var _rear_top_x = _x + lengthdir_x(-_radius * 0.77, _angle) + lengthdir_x(-_radius * 0.25, _angle + 90);
    var _rear_top_y = _y + lengthdir_y(-_radius * 0.77, _angle) + lengthdir_y(-_radius * 0.25, _angle + 90);
    var _rear_bottom_x = _x + lengthdir_x(-_radius * 0.77, _angle) + lengthdir_x(_radius * 0.25, _angle + 90);
    var _rear_bottom_y = _y + lengthdir_y(-_radius * 0.77, _angle) + lengthdir_y(_radius * 0.25, _angle + 90);

    // Long dark central silhouette.
    draw_set_colour(_p.hull_dark);
    draw_triangle(_nose_x, _nose_y, _front_top_x, _front_top_y, _mid_top_x, _mid_top_y, false);
    draw_triangle(_nose_x, _nose_y, _mid_top_x, _mid_top_y, _rear_top_x, _rear_top_y, false);
    draw_triangle(_nose_x, _nose_y, _rear_top_x, _rear_top_y, _rear_x, _rear_y, false);
    draw_triangle(_nose_x, _nose_y, _rear_x, _rear_y, _rear_bottom_x, _rear_bottom_y, false);
    draw_triangle(_nose_x, _nose_y, _rear_bottom_x, _rear_bottom_y, _mid_bottom_x, _mid_bottom_y, false);
    draw_triangle(_nose_x, _nose_y, _mid_bottom_x, _mid_bottom_y, _front_bottom_x, _front_bottom_y, false);

    // Raised central fuselage.
    var _spine_front_x = _x + lengthdir_x(_radius * 1.22, _angle);
    var _spine_front_y = _y + lengthdir_y(_radius * 1.22, _angle);
    var _spine_rear_x = _x + lengthdir_x(-_radius * 0.78, _angle);
    var _spine_rear_y = _y + lengthdir_y(-_radius * 0.78, _angle);
    var _spine_top_x = _x + lengthdir_x(_radius * 0.1, _angle) + lengthdir_x(-_radius * 0.2, _angle + 90);
    var _spine_top_y = _y + lengthdir_y(_radius * 0.1, _angle) + lengthdir_y(-_radius * 0.2, _angle + 90);
    var _spine_bottom_x = _x + lengthdir_x(_radius * 0.1, _angle) + lengthdir_x(_radius * 0.2, _angle + 90);
    var _spine_bottom_y = _y + lengthdir_y(_radius * 0.1, _angle) + lengthdir_y(_radius * 0.2, _angle + 90);

    draw_set_colour(_p.hull_mid);
    draw_triangle(_spine_front_x, _spine_front_y, _spine_top_x, _spine_top_y, _spine_rear_x, _spine_rear_y, false);
    draw_triangle(_spine_front_x, _spine_front_y, _spine_rear_x, _spine_rear_y, _spine_bottom_x, _spine_bottom_y, false);

    draw_set_colour(_p.hull_light);
    draw_line_width(_spine_front_x, _spine_front_y, _spine_top_x, _spine_top_y, 2);
    draw_line_width(_spine_front_x, _spine_front_y, _spine_bottom_x, _spine_bottom_y, 2);

    // Centreline gun housing.
    var _gun_rear_x = _x + lengthdir_x(_radius * 0.68, _angle);
    var _gun_rear_y = _y + lengthdir_y(_radius * 0.68, _angle);
    var _gun_front_x = _x + lengthdir_x(_radius * 1.37, _angle);
    var _gun_front_y = _y + lengthdir_y(_radius * 1.37, _angle);

    draw_set_colour(_p.void);
    draw_line_width(_gun_rear_x, _gun_rear_y, _gun_front_x, _gun_front_y, _radius * 0.14);
    draw_set_colour(_p.metal);
    draw_line_width(_gun_rear_x, _gun_rear_y, _gun_front_x, _gun_front_y, 3);
    draw_set_colour(_p.energy);
    draw_line_width(_gun_rear_x, _gun_rear_y, _gun_front_x, _gun_front_y, 1);

    // Reactor and longitudinal energy channel.
    draw_set_colour(_p.void);
    draw_circle(_x, _y, _radius * 0.22, false);
    draw_set_colour(_p.metal);
    draw_circle(_x, _y, _radius * 0.22, true);
    draw_set_colour(_p.energy);
    draw_circle(_x, _y, _radius * 0.12, false);
    draw_set_colour(_p.core);
    draw_circle(_x, _y, _radius * 0.045, false);

    draw_set_colour(_p.accent);
    draw_line_width(
        _x + lengthdir_x(-_radius * 0.64, _angle),
        _y + lengthdir_y(-_radius * 0.64, _angle),
        _x + lengthdir_x(-_radius * 0.27, _angle),
        _y + lengthdir_y(-_radius * 0.27, _angle),
        3
    );

    if (_stage >= 1)
    {
        draw_set_colour(_p.void);
        draw_line_width(
            _x + lengthdir_x(_radius * 0.45, _angle) + lengthdir_x(-_radius * 0.18, _angle + 90),
            _y + lengthdir_y(_radius * 0.45, _angle) + lengthdir_y(-_radius * 0.18, _angle + 90),
            _x + lengthdir_x(_radius * 0.2, _angle) + lengthdir_x(-_radius * 0.3, _angle + 90),
            _y + lengthdir_y(_radius * 0.2, _angle) + lengthdir_y(-_radius * 0.3, _angle + 90),
            3
        );
    }

    if (_stage >= 2)
    {
        var _damage_x = _x + lengthdir_x(-_radius * 0.31, _angle) + lengthdir_x(_radius * 0.23, _angle + 90);
        var _damage_y = _y + lengthdir_y(-_radius * 0.31, _angle) + lengthdir_y(_radius * 0.23, _angle + 90);

        draw_set_colour(_p.void);
        draw_circle(_damage_x, _damage_y, _radius * 0.15, false);
        draw_set_colour(_p.accent);
        draw_line_width(_damage_x, _damage_y, _damage_x + lengthdir_x(_radius * 0.25, _angle + 155), _damage_y + lengthdir_y(_radius * 0.25, _angle + 155), 2);
    }

    if (_stage >= 3)
    {
        var _failure_x = _x + lengthdir_x(-_radius * 0.68, _angle) + lengthdir_x(-_radius * 0.16, _angle + 90);
        var _failure_y = _y + lengthdir_y(-_radius * 0.68, _angle) + lengthdir_y(-_radius * 0.16, _angle + 90);

        draw_set_colour(_p.void);
        draw_circle(_failure_x, _failure_y, _radius * 0.19, false);
        draw_set_colour(_p.energy);
        draw_line_width(_failure_x, _failure_y, _failure_x + lengthdir_x(_radius * 0.28, _angle + 205), _failure_y + lengthdir_y(_radius * 0.28, _angle + 205), 2);
    }
}

/// @description Draws one baked Shard central armour overlay.
function sc_ship_shard_armour_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    var _p = _visual.palette;

    if (_stage <= 2)
    {
        var _nose_x = _x + lengthdir_x(_radius * 1.44, _angle);
        var _nose_y = _y + lengthdir_y(_radius * 1.44, _angle);
        var _top_x = _x + lengthdir_x(_radius * 0.48, _angle) + lengthdir_x(-_radius * 0.19, _angle + 90);
        var _top_y = _y + lengthdir_y(_radius * 0.48, _angle) + lengthdir_y(-_radius * 0.19, _angle + 90);
        var _bottom_x = _x + lengthdir_x(_radius * 0.48, _angle) + lengthdir_x(_radius * 0.19, _angle + 90);
        var _bottom_y = _y + lengthdir_y(_radius * 0.48, _angle) + lengthdir_y(_radius * 0.19, _angle + 90);

        draw_set_colour(_stage == 2 ? _p.hull_mid : _p.hull_light);
        draw_triangle(_nose_x, _nose_y, _top_x, _top_y, _bottom_x, _bottom_y, false);

        draw_set_colour(_p.metal);
        draw_line_width(_nose_x, _nose_y, _top_x, _top_y, 2);
        draw_line_width(_nose_x, _nose_y, _bottom_x, _bottom_y, 2);
    }

    if (_stage <= 1)
    {
        for (var _side = -1; _side <= 1; _side += 2)
        {
            var _front_x = _x + lengthdir_x(_radius * 0.38, _angle) + lengthdir_x(_radius * 0.25 * _side, _angle + 90);
            var _front_y = _y + lengthdir_y(_radius * 0.38, _angle) + lengthdir_y(_radius * 0.25 * _side, _angle + 90);
            var _rear_x = _x + lengthdir_x(-_radius * 0.48, _angle) + lengthdir_x(_radius * 0.28 * _side, _angle + 90);
            var _rear_y = _y + lengthdir_y(-_radius * 0.48, _angle) + lengthdir_y(_radius * 0.28 * _side, _angle + 90);

            draw_set_colour(_stage == 0 ? _p.hull_light : _p.hull_mid);
            draw_line_width(_front_x, _front_y, _rear_x, _rear_y, _radius * 0.12);
            draw_set_colour(_p.accent);
            draw_line_width(_front_x, _front_y, _rear_x, _rear_y, 2);
        }
    }
}

/// @description Draws one lower-facing baked Shard wing hull.
function sc_ship_shard_wing_hull_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    var _p = _visual.palette;

    var _root_front_x = _x + lengthdir_x(_radius * 0.25, _angle) + lengthdir_x(_radius * 0.02, _angle + 90);
    var _root_front_y = _y + lengthdir_y(_radius * 0.25, _angle) + lengthdir_y(_radius * 0.02, _angle + 90);
    var _tip_front_x = _x + lengthdir_x(_radius * 0.12, _angle) + lengthdir_x(_radius * 1.04, _angle + 90);
    var _tip_front_y = _y + lengthdir_y(_radius * 0.12, _angle) + lengthdir_y(_radius * 1.04, _angle + 90);
    var _tip_rear_x = _x + lengthdir_x(-_radius * 0.74, _angle) + lengthdir_x(_radius * 1.12, _angle + 90);
    var _tip_rear_y = _y + lengthdir_y(-_radius * 0.74, _angle) + lengthdir_y(_radius * 1.12, _angle + 90);
    var _rear_x = _x + lengthdir_x(-_radius * 1.08, _angle) + lengthdir_x(_radius * 0.28, _angle + 90);
    var _rear_y = _y + lengthdir_y(-_radius * 1.08, _angle) + lengthdir_y(_radius * 0.28, _angle + 90);

    draw_set_colour(_p.hull_dark);
    draw_triangle(_root_front_x, _root_front_y, _tip_front_x, _tip_front_y, _rear_x, _rear_y, false);
    draw_triangle(_tip_front_x, _tip_front_y, _tip_rear_x, _tip_rear_y, _rear_x, _rear_y, false);

    draw_set_colour(_p.hull_mid);
    draw_triangle(
        _x + lengthdir_x(_radius * 0.09, _angle) + lengthdir_x(_radius * 0.16, _angle + 90),
        _y + lengthdir_y(_radius * 0.09, _angle) + lengthdir_y(_radius * 0.16, _angle + 90),
        _x + lengthdir_x(-_radius * 0.04, _angle) + lengthdir_x(_radius * 0.83, _angle + 90),
        _y + lengthdir_y(-_radius * 0.04, _angle) + lengthdir_y(_radius * 0.83, _angle + 90),
        _x + lengthdir_x(-_radius * 0.72, _angle) + lengthdir_x(_radius * 0.42, _angle + 90),
        _y + lengthdir_y(-_radius * 0.72, _angle) + lengthdir_y(_radius * 0.42, _angle + 90),
        false
    );

    draw_set_colour(_p.hull_light);
    draw_line_width(_root_front_x, _root_front_y, _tip_front_x, _tip_front_y, 2);
    draw_set_colour(_p.metal);
    draw_line_width(_tip_front_x, _tip_front_y, _tip_rear_x, _tip_rear_y, 2);

    draw_set_colour(_p.accent);
    draw_line_width(
        _x + lengthdir_x(-_radius * 0.03, _angle) + lengthdir_x(_radius * 0.25, _angle + 90),
        _y + lengthdir_y(-_radius * 0.03, _angle) + lengthdir_y(_radius * 0.25, _angle + 90),
        _x + lengthdir_x(-_radius * 0.3, _angle) + lengthdir_x(_radius * 0.79, _angle + 90),
        _y + lengthdir_y(-_radius * 0.3, _angle) + lengthdir_y(_radius * 0.79, _angle + 90),
        3
    );

    if (_stage >= 2)
    {
        var _damage_x = _x + lengthdir_x(-_radius * 0.38, _angle) + lengthdir_x(_radius * 0.72, _angle + 90);
        var _damage_y = _y + lengthdir_y(-_radius * 0.38, _angle) + lengthdir_y(_radius * 0.72, _angle + 90);

        draw_set_colour(_p.void);
        draw_circle(_damage_x, _damage_y, _radius * (_stage >= 3 ? 0.2 : 0.13), false);
    }
}

/// @description Draws one lower-facing baked Shard wing armour overlay.
function sc_ship_shard_wing_armour_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    if (_stage >= 3) return;

    var _p = _visual.palette;
    var _root_x = _x + lengthdir_x(_radius * 0.12, _angle) + lengthdir_x(_radius * 0.14, _angle + 90);
    var _root_y = _y + lengthdir_y(_radius * 0.12, _angle) + lengthdir_y(_radius * 0.14, _angle + 90);
    var _tip_x = _x + lengthdir_x(_radius * 0.03, _angle) + lengthdir_x(_radius * 0.91, _angle + 90);
    var _tip_y = _y + lengthdir_y(_radius * 0.03, _angle) + lengthdir_y(_radius * 0.91, _angle + 90);
    var _rear_x = _x + lengthdir_x(-_radius * 0.65, _angle) + lengthdir_x(_radius * 0.43, _angle + 90);
    var _rear_y = _y + lengthdir_y(-_radius * 0.65, _angle) + lengthdir_y(_radius * 0.43, _angle + 90);

    draw_set_colour(_stage == 0 ? _p.hull_light : (_stage == 1 ? _p.hull_mid : _p.hull_dark));
    draw_triangle(_root_x, _root_y, _tip_x, _tip_y, _rear_x, _rear_y, false);

    draw_set_colour(_p.metal);
    draw_line_width(_root_x, _root_y, _tip_x, _tip_y, 2);

    if (_stage <= 1)
    {
        draw_set_colour(_p.energy);
        draw_line_width(
            _x + lengthdir_x(-_radius * 0.05, _angle) + lengthdir_x(_radius * 0.3, _angle + 90),
            _y + lengthdir_y(-_radius * 0.05, _angle) + lengthdir_y(_radius * 0.3, _angle + 90),
            _x + lengthdir_x(-_radius * 0.27, _angle) + lengthdir_x(_radius * 0.69, _angle + 90),
            _y + lengthdir_y(-_radius * 0.27, _angle) + lengthdir_y(_radius * 0.69, _angle + 90),
            2
        );
    }
}

/// @description Draws the baked Shard shield field.
function sc_ship_shard_shield_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;
    var _front_x = _x + lengthdir_x(_radius * 1.7, _angle);
    var _front_y = _y + lengthdir_y(_radius * 1.7, _angle);
    var _rear_x = _x + lengthdir_x(-_radius * 1.28, _angle);
    var _rear_y = _y + lengthdir_y(-_radius * 1.28, _angle);
    var _top_x = _x + lengthdir_x(-_radius * 0.16, _angle) + lengthdir_x(-_radius * 1.15, _angle + 90);
    var _top_y = _y + lengthdir_y(-_radius * 0.16, _angle) + lengthdir_y(-_radius * 1.15, _angle + 90);
    var _bottom_x = _x + lengthdir_x(-_radius * 0.16, _angle) + lengthdir_x(_radius * 1.15, _angle + 90);
    var _bottom_y = _y + lengthdir_y(-_radius * 0.16, _angle) + lengthdir_y(_radius * 1.15, _angle + 90);

    draw_set_alpha(0.2);
    draw_set_colour(_p.glow);
    draw_triangle(_front_x, _front_y, _top_x, _top_y, _rear_x, _rear_y, true);
    draw_triangle(_front_x, _front_y, _rear_x, _rear_y, _bottom_x, _bottom_y, true);

    draw_set_alpha(0.72);
    draw_set_colour(_p.energy);
    draw_line_width(_front_x, _front_y, _top_x, _top_y, 2);
    draw_line_width(_top_x, _top_y, _rear_x, _rear_y, 2);
    draw_line_width(_rear_x, _rear_y, _bottom_x, _bottom_y, 2);
    draw_line_width(_bottom_x, _bottom_y, _front_x, _front_y, 2);
    draw_set_alpha(1);
}

/// @description Draws one substantial baked Shard aqua flame.
function sc_ship_shard_thrust_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;
    var _outer_tip_x = _x + lengthdir_x(_radius * 1.08, _angle);
    var _outer_tip_y = _y + lengthdir_y(_radius * 1.08, _angle);
    var _energy_tip_x = _x + lengthdir_x(_radius * 0.82, _angle);
    var _energy_tip_y = _y + lengthdir_y(_radius * 0.82, _angle);
    var _core_tip_x = _x + lengthdir_x(_radius * 0.56, _angle);
    var _core_tip_y = _y + lengthdir_y(_radius * 0.56, _angle);

    draw_set_alpha(0.38);
    draw_set_colour(_p.glow);
    draw_triangle(
        _x + lengthdir_x(-_radius * 0.3, _angle + 90),
        _y + lengthdir_y(-_radius * 0.3, _angle + 90),
        _outer_tip_x, _outer_tip_y,
        _x + lengthdir_x(_radius * 0.3, _angle + 90),
        _y + lengthdir_y(_radius * 0.3, _angle + 90),
        false
    );

    draw_set_alpha(0.84);
    draw_set_colour(_p.energy);
    draw_triangle(
        _x + lengthdir_x(-_radius * 0.19, _angle + 90),
        _y + lengthdir_y(-_radius * 0.19, _angle + 90),
        _energy_tip_x, _energy_tip_y,
        _x + lengthdir_x(_radius * 0.19, _angle + 90),
        _y + lengthdir_y(_radius * 0.19, _angle + 90),
        false
    );

    draw_set_alpha(1);
    draw_set_colour(_p.core);
    draw_triangle(
        _x + lengthdir_x(-_radius * 0.07, _angle + 90),
        _y + lengthdir_y(-_radius * 0.07, _angle + 90),
        _core_tip_x, _core_tip_y,
        _x + lengthdir_x(_radius * 0.07, _angle + 90),
        _y + lengthdir_y(_radius * 0.07, _angle + 90),
        false
    );

    draw_set_alpha(1);
}