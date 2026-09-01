/// @description Draws one baked wide spear-shaped Shard hull state.
function sc_ship_shard_hull_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    var _p = _visual.palette;

    // Narrow nose, progressively wider middle, tapered rear.
    sc_visual_triangle(_x, _y, _radius, _angle, 1.78, 0, 0.72, -0.25, 0.72, 0.25, _p.hull_dark, false);
    sc_visual_quad(_x, _y, _radius, _angle, 0.72, -0.25, 0.08, -0.47, 0.08, 0.47, 0.72, 0.25, _p.hull_dark);
    sc_visual_quad(_x, _y, _radius, _angle, 0.08, -0.47, -0.58, -0.53, -0.58, 0.53, 0.08, 0.47, _p.hull_dark);
    sc_visual_quad(_x, _y, _radius, _angle, -0.58, -0.53, -1.12, -0.31, -1.12, 0.31, -0.58, 0.53, _p.hull_dark);
    sc_visual_triangle(_x, _y, _radius, _angle, -1.12, -0.31, -1.36, 0, -1.12, 0.31, _p.hull_dark, false);

    // Layered side machinery.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_quad(_x, _y, _radius, _angle, 0.62, 0.22 * _side, 0.04, 0.43 * _side, -0.55, 0.48 * _side, -0.92, 0.29 * _side, _p.hull_mid);
        sc_visual_quad(_x, _y, _radius, _angle, 0.35, 0.27 * _side, -0.03, 0.39 * _side, -0.48, 0.42 * _side, -0.72, 0.28 * _side, _p.hull_light);
        sc_visual_line(_x, _y, _radius, _angle, 0.62, 0.22 * _side, 0.04, 0.43 * _side, 2, _p.metal);
        sc_visual_line(_x, _y, _radius, _angle, 0.04, 0.43 * _side, -0.55, 0.48 * _side, 2, _p.hull_light);
        sc_visual_line(_x, _y, _radius, _angle, -0.55, 0.48 * _side, -0.92, 0.29 * _side, 1, _p.metal);
    }

    // Raised central spear and structural layers.
    sc_visual_triangle(_x, _y, _radius, _angle, 1.68, 0, 0.34, -0.22, -0.83, 0, _p.hull_light, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 1.68, 0, -0.83, 0, 0.34, 0.22, _p.hull_light, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 1.54, 0, 0.48, -0.17, -0.25, -0.12, _p.hull_mid, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 1.54, 0, -0.25, 0.12, 0.48, 0.17, _p.hull_mid, false);

    // Cockpit.
    sc_visual_triangle(_x, _y, _radius, _angle, 1.47, 0, 0.72, -0.135, 0.38, 0, _p.void, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 1.47, 0, 0.38, 0, 0.72, 0.135, _p.void, false);
    sc_visual_line(_x, _y, _radius, _angle, 1.47, 0, 0.72, -0.135, 2, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, 1.47, 0, 0.72, 0.135, 2, _p.metal);

    // Spine and centre channel.
    sc_visual_line(_x, _y, _radius, _angle, -1.11, 0, 1.68, 0, 2, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, 0.94, 0, 1.69, 0, _radius * 0.11, _p.void);
    sc_visual_line(_x, _y, _radius, _angle, 1.04, 0, 1.71, 0, 2, _p.energy);

    // Rear engine cavities.
    sc_visual_quad(_x, _y, _radius, _angle, -0.63, -0.25, -1.14, -0.2, -1.3, 0, -0.63, 0, _p.void);
    sc_visual_quad(_x, _y, _radius, _angle, -0.63, 0, -1.3, 0, -1.14, 0.2, -0.63, 0.25, _p.void);
    sc_visual_line(_x, _y, _radius, _angle, -0.7, -0.18, -1.16, -0.14, 4, _p.glow);
    sc_visual_line(_x, _y, _radius, _angle, -0.7, -0.18, -1.16, -0.14, 2, _p.energy);
    sc_visual_line(_x, _y, _radius, _angle, -0.7, 0.18, -1.16, 0.14, 4, _p.glow);
    sc_visual_line(_x, _y, _radius, _angle, -0.7, 0.18, -1.16, 0.14, 2, _p.energy);

    // Reactor.
    sc_visual_circle(_x, _y, _radius, _angle, -0.18, 0, 0.265, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, -0.18, 0, 0.265, _p.metal, true);
    sc_visual_circle(_x, _y, _radius, _angle, -0.18, 0, 0.15, _p.energy, false);
    sc_visual_circle(_x, _y, _radius, _angle, -0.18, 0, 0.058, _p.core, false);

    // Energy channels and panel divisions.
    sc_visual_line(_x, _y, _radius, _angle, 0.53, -0.31, 0.02, -0.38, 5, _p.void);
    sc_visual_line(_x, _y, _radius, _angle, 0.51, -0.31, 0.04, -0.37, 2, _p.accent);
    sc_visual_line(_x, _y, _radius, _angle, 0.53, 0.31, 0.02, 0.38, 5, _p.void);
    sc_visual_line(_x, _y, _radius, _angle, 0.51, 0.31, 0.04, 0.37, 2, _p.accent);
    sc_visual_line(_x, _y, _radius, _angle, 0.04, -0.43, -0.18, -0.32, 1, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, 0.04, 0.43, -0.18, 0.32, 1, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, -0.51, -0.47, -0.73, -0.3, 1, _p.hull_light);
    sc_visual_line(_x, _y, _radius, _angle, -0.51, 0.47, -0.73, 0.3, 1, _p.hull_light);

    // Shorter twin cannons remain until critical hull damage.
    if (_stage <= 2)
    {
        for (var _side = -1; _side <= 1; _side += 2)
        {
            sc_visual_quad(_x, _y, _radius, _angle, 0.28, 0.39 * _side, 0.15, 0.51 * _side, -0.17, 0.5 * _side, -0.29, 0.38 * _side, _p.hull_dark);
            sc_visual_line(_x, _y, _radius, _angle, 0.24, 0.45 * _side, 0.98, 0.45 * _side, 9, _p.void);
            sc_visual_line(_x, _y, _radius, _angle, 0.24, 0.41 * _side, 0.98, 0.41 * _side, 2, _p.metal);
            sc_visual_line(_x, _y, _radius, _angle, 0.24, 0.49 * _side, 0.98, 0.49 * _side, 2, _p.metal);
            sc_visual_line(_x, _y, _radius, _angle, 0.28, 0.45 * _side, 0.96, 0.45 * _side, 3, _p.hull_light);
            sc_visual_line(_x, _y, _radius, _angle, 0.51, 0.39 * _side, 0.51, 0.51 * _side, 2, _p.accent);
            sc_visual_line(_x, _y, _radius, _angle, 0.7, 0.39 * _side, 0.7, 0.51 * _side, 2, _p.metal);
            sc_visual_line(_x, _y, _radius, _angle, 0.87, 0.39 * _side, 0.87, 0.51 * _side, 2, _p.metal);
            sc_visual_circle(_x, _y, _radius, _angle, 0.98, 0.45 * _side, 0.07, _p.void, false);
            sc_visual_circle(_x, _y, _radius, _angle, 0.98, 0.45 * _side, 0.07, _p.metal, true);
            sc_visual_circle(_x, _y, _radius, _angle, 0.98, 0.45 * _side, 0.024, _p.energy, false);
        }
    }

    // Hull damage.
    if (_stage >= 1)
    {
        sc_visual_line(_x, _y, _radius, _angle, 0.43, -0.25, 0.17, -0.42, 3, _p.void);
        sc_visual_line(_x, _y, _radius, _angle, 0.31, -0.33, 0.23, -0.15, 2, _p.void);
    }

    if (_stage >= 2)
    {
        sc_visual_circle(_x, _y, _radius, _angle, -0.48, 0.34, 0.17, _p.void, false);
        sc_visual_line(_x, _y, _radius, _angle, -0.48, 0.34, -0.72, 0.47, 2, _p.accent);
    }

    if (_stage >= 3)
    {
        sc_visual_circle(_x, _y, _radius, _angle, -0.92, -0.2, 0.21, _p.void, false);
        sc_visual_line(_x, _y, _radius, _angle, -0.92, -0.2, -1.18, -0.37, 2, _p.energy);
    }
}

/// @description Draws Shard armour and fixed inner stabilizer blades.
function sc_ship_shard_armour_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    var _p = _visual.palette;

    if (_stage <= 2)
    {
        var _nose_colour = _stage == 0 ? _p.metal : (_stage == 1 ? _p.hull_light : _p.hull_mid);
        sc_visual_triangle(_x, _y, _radius, _angle, 1.7, 0, 0.69, -0.17, 0.95, 0, _nose_colour, false);
        sc_visual_triangle(_x, _y, _radius, _angle, 1.7, 0, 0.95, 0, 0.69, 0.17, _nose_colour, false);
        sc_visual_line(_x, _y, _radius, _angle, 1.7, 0, 0.69, -0.17, 2, _p.metal);
        sc_visual_line(_x, _y, _radius, _angle, 1.7, 0, 0.69, 0.17, 2, _p.metal);
    }

    if (_stage <= 1)
    {
        var _shoulder_colour = _stage == 0 ? _p.hull_light : _p.hull_mid;

        for (var _side = -1; _side <= 1; _side += 2)
        {
            sc_visual_quad(_x, _y, _radius, _angle, 0.57, 0.19 * _side, 0.21, 0.37 * _side, -0.57, 0.36 * _side, -0.81, 0.19 * _side, _shoulder_colour);
            sc_visual_line(_x, _y, _radius, _angle, 0.57, 0.19 * _side, 0.21, 0.37 * _side, 2, _p.metal);
            sc_visual_line(_x, _y, _radius, _angle, 0.15, 0.3 * _side, -0.51, 0.29 * _side, 2, _p.accent);
        }
    }

    // Fixed secondary blades between the hull and moving wings.
    if (_stage <= 2)
    {
        var _fin_colour = _stage == 0 ? _p.hull_mid : (_stage == 1 ? _p.hull_dark : _p.void);

        for (var _side = -1; _side <= 1; _side += 2)
        {
            sc_visual_triangle(_x, _y, _radius, _angle, 0.27, 0.37 * _side, -0.12, 0.7 * _side, -0.61, 0.42 * _side, _fin_colour, false);
            sc_visual_triangle(_x, _y, _radius, _angle, -0.12, 0.7 * _side, -0.34, 0.72 * _side, -0.61, 0.42 * _side, _p.hull_dark, false);
            sc_visual_line(_x, _y, _radius, _angle, 0.27, 0.37 * _side, -0.12, 0.7 * _side, 2, _p.metal);
            sc_visual_line(_x, _y, _radius, _angle, -0.12, 0.7 * _side, -0.34, 0.72 * _side, 2, _p.hull_light);
            sc_visual_line(_x, _y, _radius, _angle, 0.06, 0.46 * _side, -0.31, 0.63 * _side, 2, _p.energy);
        }
    }

    if (_stage >= 3)
    {
        sc_visual_circle(_x, _y, _radius, _angle, -0.18, 0, 0.31, _p.hull_light, true);
        sc_visual_circle(_x, _y, _radius, _angle, -0.18, 0, 0.24, _p.accent, true);
    }
}

/// @description Draws one thicker Shard blade wing with a visible mechanical root.
function sc_ship_shard_wing_hull_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    var _p = _visual.palette;

    // Broad attachment base remains visible outside the hull.
    sc_visual_quad(_x, _y, _radius, _angle, 0.42, -0.02, 0.2, 0.36, -0.34, 0.43, -0.57, 0.1, _p.void);
    sc_visual_quad(_x, _y, _radius, _angle, 0.34, 0.05, 0.2, 0.29, -0.26, 0.35, -0.43, 0.14, _p.hull_mid);
    sc_visual_circle(_x, _y, _radius, _angle, 0.03, 0.2, 0.105, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, 0.03, 0.2, 0.105, _p.metal, true);
    sc_visual_circle(_x, _y, _radius, _angle, 0.03, 0.2, 0.045, _p.accent, false);

    // Slightly thicker tapered main blade.
    sc_visual_triangle(_x, _y, _radius, _angle, 0.34, 0.05, 0.11, 0.34, -1.27, 0.73, _p.hull_dark, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 0.34, 0.05, -1.27, 0.73, -0.55, 0.13, _p.hull_dark, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 0.25, 0.11, 0.11, 0.29, -1.15, 0.67, _p.hull_mid, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 0.25, 0.11, -1.15, 0.67, -0.5, 0.18, _p.hull_mid, false);

    // Raised root armour.
    sc_visual_quad(_x, _y, _radius, _angle, 0.28, 0.1, 0.12, 0.29, -0.48, 0.45, -0.62, 0.28, _p.hull_light);

    // Blade edges and energy channel.
    sc_visual_line(_x, _y, _radius, _angle, 0.34, 0.05, 0.11, 0.34, 2, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, 0.11, 0.34, -1.27, 0.73, 2, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, -1.27, 0.73, -0.55, 0.13, 2, _p.hull_light);
    sc_visual_line(_x, _y, _radius, _angle, 0.03, 0.28, -0.8, 0.53, 5, _p.void);
    sc_visual_line(_x, _y, _radius, _angle, 0.01, 0.275, -0.79, 0.52, 2, _p.accent);
    sc_visual_circle(_x, _y, _radius, _angle, -0.8, 0.53, 0.035, _p.core, false);

    // Blade segmentation.
    sc_visual_line(_x, _y, _radius, _angle, -0.19, 0.34, -0.28, 0.43, 1, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, -0.53, 0.43, -0.61, 0.52, 1, _p.hull_light);
    sc_visual_line(_x, _y, _radius, _angle, -0.85, 0.54, -0.92, 0.62, 1, _p.metal);

    if (_stage >= 1) sc_visual_line(_x, _y, _radius, _angle, -0.16, 0.3, -0.37, 0.46, 3, _p.void);

    if (_stage >= 2)
    {
        sc_visual_circle(_x, _y, _radius, _angle, -0.59, 0.48, 0.13, _p.void, false);
        sc_visual_line(_x, _y, _radius, _angle, -0.59, 0.48, -0.76, 0.61, 2, _p.accent);
    }

    if (_stage >= 3) sc_visual_triangle(_x, _y, _radius, _angle, -0.83, 0.55, -1.27, 0.73, -1.02, 0.56, _p.void, false);
}

/// @description Draws the armour cap for one Shard blade wing.
function sc_ship_shard_wing_armour_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    if (_stage >= 3) return;

    var _p = _visual.palette;
    var _colour = _stage == 0 ? _p.hull_light : (_stage == 1 ? _p.hull_mid : _p.hull_dark);

    sc_visual_triangle(_x, _y, _radius, _angle, 0.3, 0.07, 0.13, 0.3, -0.91, 0.6, _colour, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 0.3, 0.07, -0.91, 0.6, -0.5, 0.19, _colour, false);
    sc_visual_line(_x, _y, _radius, _angle, 0.3, 0.07, 0.13, 0.3, 2, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, 0.13, 0.3, -0.91, 0.6, 2, _p.hull_light);

    if (_stage <= 1)
    {
        sc_visual_line(_x, _y, _radius, _angle, 0.03, 0.27, -0.57, 0.46, 4, _p.void);
        sc_visual_line(_x, _y, _radius, _angle, 0.02, 0.27, -0.56, 0.455, 2, _p.energy);
    }

    if (_stage == 2) sc_visual_line(_x, _y, _radius, _angle, -0.3, 0.36, -0.52, 0.49, 2, _p.void);
}

/// @description Draws the Shard's filled circular shield bubble.
function sc_ship_shard_shield_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;
    var _shield_radius = _radius * 1.86;
    var _field_centre = merge_colour(_p.void, _p.glow, 0.72);
    var _field_edge = merge_colour(_p.glow, _p.energy, 0.28);

    // Clearly visible filled shield field.
    draw_set_alpha(0.62);
    draw_circle_colour(_x, _y, _shield_radius, _field_centre, _field_edge, false);

    // Subtle internal energy layer.
    draw_set_alpha(0.18);
    draw_circle_colour(_x, _y, _shield_radius * 0.93, _p.glow, _p.energy, false);

    // Soft outer glow.
    draw_set_alpha(0.16);
    draw_set_colour(_p.glow);
    draw_circle(_x, _y, _shield_radius + 4, true);
    draw_circle(_x, _y, _shield_radius + 3, true);
    draw_circle(_x, _y, _shield_radius + 2, true);

    // Defined bright shield boundary.
    draw_set_alpha(0.88);
    draw_set_colour(_p.energy);
    draw_circle(_x, _y, _shield_radius, true);

    draw_set_alpha(0.5);
    draw_set_colour(_p.core);
    draw_circle(_x, _y, _shield_radius - 2, true);

    draw_set_alpha(1);
    draw_set_colour(c_white);
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
    draw_triangle(_x + lengthdir_x(-_radius * 0.3, _angle + 90), _y + lengthdir_y(-_radius * 0.3, _angle + 90), _outer_tip_x, _outer_tip_y, _x + lengthdir_x(_radius * 0.3, _angle + 90), _y + lengthdir_y(_radius * 0.3, _angle + 90), false);

    draw_set_alpha(0.84);
    draw_set_colour(_p.energy);
    draw_triangle(_x + lengthdir_x(-_radius * 0.19, _angle + 90), _y + lengthdir_y(-_radius * 0.19, _angle + 90), _energy_tip_x, _energy_tip_y, _x + lengthdir_x(_radius * 0.19, _angle + 90), _y + lengthdir_y(_radius * 0.19, _angle + 90), false);

    draw_set_alpha(1);
    draw_set_colour(_p.core);
    draw_triangle(_x + lengthdir_x(-_radius * 0.07, _angle + 90), _y + lengthdir_y(-_radius * 0.07, _angle + 90), _core_tip_x, _core_tip_y, _x + lengthdir_x(_radius * 0.07, _angle + 90), _y + lengthdir_y(_radius * 0.07, _angle + 90), false);
    draw_set_alpha(1);
}