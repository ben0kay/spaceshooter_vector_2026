/// @description Draws one baked Shard spear-shaped central hull state.
function sc_ship_shard_hull_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    var _p = _visual.palette;

    // Long narrow primary silhouette.
    sc_visual_triangle(_x, _y, _radius, _angle, 1.78, 0, 0.34, -0.34, -1.18, -0.25, _p.hull_dark, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 1.78, 0, -1.18, -0.25, -1.32, 0, _p.hull_dark, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 1.78, 0, -1.32, 0, -1.18, 0.25, _p.hull_dark, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 1.78, 0, -1.18, 0.25, 0.34, 0.34, _p.hull_dark, false);

    // Broad central machinery block.
    sc_visual_quad(_x, _y, _radius, _angle,
        0.43, -0.31,
        -0.38, -0.35,
        -0.92, -0.21,
        0.1, -0.18,
        _p.hull_mid
    );

    sc_visual_quad(_x, _y, _radius, _angle,
        0.1, 0.18,
        -0.92, 0.21,
        -0.38, 0.35,
        0.43, 0.31,
        _p.hull_mid
    );

    // Long raised spear armour.
    sc_visual_triangle(_x, _y, _radius, _angle, 1.63, 0, 0.28, -0.18, -0.75, 0, _p.hull_light, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 1.63, 0, -0.75, 0, 0.28, 0.18, _p.hull_light, false);

    // Dark recessed cockpit/nose cavity.
    sc_visual_triangle(_x, _y, _radius, _angle, 1.48, 0, 0.62, -0.115, 0.34, 0, _p.void, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 1.48, 0, 0.34, 0, 0.62, 0.115, _p.void, false);

    // Mechanical spine.
    sc_visual_line(_x, _y, _radius, _angle, -1.05, 0, 1.67, 0, 2, _p.metal);

    // Centreline weapon housing.
    sc_visual_line(_x, _y, _radius, _angle, 0.92, 0, 1.67, 0, _radius * 0.13, _p.void);
    sc_visual_line(_x, _y, _radius, _angle, 0.92, 0, 1.69, 0, 3, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, 1.02, 0, 1.71, 0, 1, _p.energy);

    // Rear engine cavity.
    sc_visual_quad(_x, _y, _radius, _angle,
        -0.72, -0.17,
        -1.2, -0.14,
        -1.29, 0,
        -0.72, 0,
        _p.void
    );

    sc_visual_quad(_x, _y, _radius, _angle,
        -0.72, 0,
        -1.29, 0,
        -1.2, 0.14,
        -0.72, 0.17,
        _p.void
    );

    // Reactor assembly.
    sc_visual_circle(_x, _y, _radius, _angle, -0.18, 0, 0.24, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, -0.18, 0, 0.24, _p.metal, true);
    sc_visual_circle(_x, _y, _radius, _angle, -0.18, 0, 0.135, _p.energy, false);
    sc_visual_circle(_x, _y, _radius, _angle, -0.18, 0, 0.05, _p.core, false);

    // Restrained energy channels.
    sc_visual_line(_x, _y, _radius, _angle, 0.52, -0.22, 0.03, -0.25, 3, _p.accent);
    sc_visual_line(_x, _y, _radius, _angle, 0.52, 0.22, 0.03, 0.25, 3, _p.accent);
    sc_visual_line(_x, _y, _radius, _angle, -0.5, 0, -0.94, 0, 3, _p.energy);

    // Fine panel seams.
    sc_visual_line(_x, _y, _radius, _angle, 0.35, -0.32, -0.36, -0.34, 1, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, 0.35, 0.32, -0.36, 0.34, 1, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, -0.37, -0.34, -0.9, -0.21, 1, _p.hull_light);
    sc_visual_line(_x, _y, _radius, _angle, -0.37, 0.34, -0.9, 0.21, 1, _p.hull_light);

    if (_stage >= 1)
    {
        sc_visual_line(_x, _y, _radius, _angle, 0.48, -0.18, 0.2, -0.31, 3, _p.void);
        sc_visual_line(_x, _y, _radius, _angle, 0.35, -0.22, 0.29, -0.08, 2, _p.void);
    }

    if (_stage >= 2)
    {
        sc_visual_circle(_x, _y, _radius, _angle, -0.48, 0.24, 0.15, _p.void, false);
        sc_visual_line(_x, _y, _radius, _angle, -0.48, 0.24, -0.72, 0.38, 2, _p.accent);
    }

    if (_stage >= 3)
    {
        sc_visual_circle(_x, _y, _radius, _angle, -0.91, -0.12, 0.19, _p.void, false);
        sc_visual_line(_x, _y, _radius, _angle, -0.91, -0.12, -1.14, -0.31, 2, _p.energy);
    }
}

/// @description Draws one baked Shard central armour state.
function sc_ship_shard_armour_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    var _p = _visual.palette;

    // Sharp layered nose plating.
    if (_stage <= 2)
    {
        var _colour = _stage == 0 ? _p.metal : (_stage == 1 ? _p.hull_light : _p.hull_mid);

        sc_visual_triangle(_x, _y, _radius, _angle, 1.7, 0, 0.68, -0.14, 0.92, 0, _colour, false);
        sc_visual_triangle(_x, _y, _radius, _angle, 1.7, 0, 0.92, 0, 0.68, 0.14, _colour, false);

        sc_visual_line(_x, _y, _radius, _angle, 1.7, 0, 0.68, -0.14, 2, _p.metal);
        sc_visual_line(_x, _y, _radius, _angle, 1.7, 0, 0.68, 0.14, 2, _p.metal);
    }

    // Central layered armour shoulders.
    if (_stage <= 1)
    {
        var _colour = _stage == 0 ? _p.hull_light : _p.hull_mid;

        for (var _side = -1; _side <= 1; _side += 2)
        {
            sc_visual_quad(_x, _y, _radius, _angle,
                0.54, 0.17 * _side,
                0.2, 0.31 * _side,
                -0.57, 0.3 * _side,
                -0.76, 0.17 * _side,
                _colour
            );

            sc_visual_line(_x, _y, _radius, _angle, 0.54, 0.17 * _side, 0.2, 0.31 * _side, 2, _p.metal);
            sc_visual_line(_x, _y, _radius, _angle, 0.13, 0.245 * _side, -0.5, 0.235 * _side, 2, _p.accent);
        }
    }

    if (_stage >= 3)
    {
        sc_visual_circle(_x, _y, _radius, _angle, -0.18, 0, 0.29, _p.hull_light, true);
        sc_visual_circle(_x, _y, _radius, _angle, -0.18, 0, 0.22, _p.accent, true);
    }
}

/// @description Draws one lower-facing baked Shard swept-wing hull.
function sc_ship_shard_wing_hull_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    var _p = _visual.palette;

    // Long swept blade silhouette.
    sc_visual_quad(_x, _y, _radius, _angle,
        0.48, 0.04,
        0.34, 0.48,
        -0.37, 0.84,
        -1.13, 0.22,
        _p.hull_dark
    );

    sc_visual_triangle(_x, _y, _radius, _angle,
        0.34, 0.48,
        -0.12, 0.93,
        -0.37, 0.84,
        _p.hull_dark,
        false
    );

    // Blue-grey inset panel following the sweep.
    sc_visual_quad(_x, _y, _radius, _angle,
        0.3, 0.15,
        0.17, 0.43,
        -0.34, 0.7,
        -0.83, 0.27,
        _p.hull_mid
    );

    // Dark mechanical root.
    sc_visual_quad(_x, _y, _radius, _angle,
        0.39, 0.06,
        0.26, 0.2,
        -0.73, 0.29,
        -1.03, 0.18,
        _p.void
    );

    // Silver leading edge and rear structural edge.
    sc_visual_line(_x, _y, _radius, _angle, 0.48, 0.04, 0.34, 0.48, 2, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, 0.34, 0.48, -0.12, 0.93, 2, _p.hull_light);
    sc_visual_line(_x, _y, _radius, _angle, -0.12, 0.93, -0.37, 0.84, 2, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, -0.37, 0.84, -1.13, 0.22, 2, _p.hull_light);

    // Long illuminated wing channel.
    sc_visual_line(_x, _y, _radius, _angle, 0.17, 0.34, -0.43, 0.63, 4, _p.void);
    sc_visual_line(_x, _y, _radius, _angle, 0.14, 0.34, -0.4, 0.6, 2, _p.accent);
    sc_visual_circle(_x, _y, _radius, _angle, -0.42, 0.61, 0.035, _p.core, false);

    // Panel divisions.
    sc_visual_line(_x, _y, _radius, _angle, -0.05, 0.27, -0.17, 0.55, 1, _p.hull_light);
    sc_visual_line(_x, _y, _radius, _angle, -0.39, 0.42, -0.59, 0.58, 1, _p.hull_light);
    sc_visual_line(_x, _y, _radius, _angle, -0.68, 0.29, -0.8, 0.4, 1, _p.metal);

    if (_stage >= 2)
    {
        sc_visual_circle(_x, _y, _radius, _angle, -0.38, 0.68, 0.13, _p.void, false);
        sc_visual_line(_x, _y, _radius, _angle, -0.38, 0.68, -0.58, 0.8, 2, _p.accent);
    }

    if (_stage >= 3)
    {
        sc_visual_circle(_x, _y, _radius, _angle, -0.78, 0.31, 0.18, _p.void, false);
        sc_visual_line(_x, _y, _radius, _angle, -0.78, 0.31, -1.01, 0.17, 2, _p.energy);
    }
}

/// @description Draws one lower-facing baked Shard swept-wing armour state.
function sc_ship_shard_wing_armour_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    if (_stage >= 3) return;

    var _p = _visual.palette;
    var _colour = _stage == 0 ? _p.hull_light : (_stage == 1 ? _p.hull_mid : _p.hull_dark);

    // Long narrow armour blade.
    sc_visual_quad(_x, _y, _radius, _angle,
        0.38, 0.09,
        0.25, 0.37,
        -0.3, 0.72,
        -0.79, 0.29,
        _colour
    );

    sc_visual_line(_x, _y, _radius, _angle, 0.38, 0.09, 0.25, 0.37, 2, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, 0.25, 0.37, -0.3, 0.72, 2, _p.metal);

    if (_stage <= 1)
    {
        sc_visual_line(_x, _y, _radius, _angle, 0.1, 0.32, -0.36, 0.57, 3, _p.void);
        sc_visual_line(_x, _y, _radius, _angle, 0.08, 0.32, -0.34, 0.55, 2, _p.energy);
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