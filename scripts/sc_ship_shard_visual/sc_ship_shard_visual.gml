/*
SHARD VISUAL SCRIPT
Contains all primitive drawing and visual-effect functions unique to the Shard chassis.
Primitive components are baked into reusable sprites during game initialization.
Hull, armour, wings, guns, muzzle flash, shield and thrust are drawn separately.
Dynamic components can then move, recoil, animate or change damage stage during gameplay.
sc_ship_shard_death() assembles cached components into the generic death-fragment effect.
Gameplay stats, damage processing and player state changes do not belong in this file.
*/


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

/// @description Draws one reusable Shard pulse cannon for startup baking.
function sc_ship_shard_cannon_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    var _p = _visual.palette;

    sc_visual_quad(_x, _y, _radius, _angle, -0.24, -0.13, 0.16, -0.14, 0.16, 0.14, -0.24, 0.13, _p.hull_dark);
    sc_visual_line(_x, _y, _radius, _angle, -0.18, -0.1, 0.68, -0.1, 3, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, -0.18, 0.1, 0.68, 0.1, 3, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, -0.12, 0, 0.7, 0, 8, _p.void);
    sc_visual_line(_x, _y, _radius, _angle, -0.08, 0, 0.69, 0, 3, _p.hull_light);

    sc_visual_line(_x, _y, _radius, _angle, 0.18, -0.14, 0.18, 0.14, 2, _p.accent);
    sc_visual_line(_x, _y, _radius, _angle, 0.42, -0.13, 0.42, 0.13, 2, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, 0.59, -0.12, 0.59, 0.12, 2, _p.metal);

    sc_visual_circle(_x, _y, _radius, _angle, -0.1, 0, 0.17, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, -0.1, 0, 0.17, _p.metal, true);
    sc_visual_circle(_x, _y, _radius, _angle, -0.1, 0, 0.07, _p.energy, false);

    sc_visual_circle(_x, _y, _radius, _angle, 0.7, 0, 0.085, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, 0.7, 0, 0.085, _p.metal, true);
    sc_visual_circle(_x, _y, _radius, _angle, 0.7, 0, 0.032, _p.core, false);
}

/// @description Draws one bright Shard muzzle-flash animation frame for startup baking.
function sc_ship_shard_muzzle_flash_draw(_x, _y, _radius, _angle, _visual, _frame, _frame_count)
{
    var _p = _visual.palette;
    var _progress = _frame_count > 1 ? _frame / (_frame_count - 1) : 0;
    var _power = 1 - _progress * 0.72;
    var _length = _radius * lerp(0.72, 0.28, _progress);
    var _width = _radius * lerp(0.34, 0.13, _progress);
    var _tip_x = _x + lengthdir_x(_length, _angle);
    var _tip_y = _y + lengthdir_y(_length, _angle);

    draw_set_alpha(0.48 * _power);
    draw_set_colour(_p.glow);
    draw_circle(_x, _y, _width * 1.9, false);

    draw_set_alpha(0.82 * _power);
    draw_set_colour(_p.energy);
    draw_triangle(
        _x + lengthdir_x(-_width, _angle + 90),
        _y + lengthdir_y(-_width, _angle + 90),
        _tip_x,
        _tip_y,
        _x + lengthdir_x(_width, _angle + 90),
        _y + lengthdir_y(_width, _angle + 90),
        false
    );

    var _side_length = _length * 0.55;
    var _side_width = _width * 1.35;

    draw_set_alpha(0.72 * _power);
    draw_set_colour(_p.energy);
    draw_triangle(
        _x,
        _y,
        _x + lengthdir_x(_side_length, _angle - 28),
        _y + lengthdir_y(_side_length, _angle - 28),
        _x + lengthdir_x(_side_width, _angle - 90),
        _y + lengthdir_y(_side_width, _angle - 90),
        false
    );
    draw_triangle(
        _x,
        _y,
        _x + lengthdir_x(_side_width, _angle + 90),
        _y + lengthdir_y(_side_width, _angle + 90),
        _x + lengthdir_x(_side_length, _angle + 28),
        _y + lengthdir_y(_side_length, _angle + 28),
        false
    );

    draw_set_alpha(_power);
    draw_set_colour(_p.core);
    draw_line_width(_x, _y, _tip_x, _tip_y, max(3, _width * 0.48));
    draw_circle(_x, _y, max(2, _width * 0.58), false);

    draw_set_colour(c_white);
    draw_circle(_x, _y, max(1, _width * 0.24), false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
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

/// @description Bakes the Shard shield using the shared shield design.
function sc_ship_shard_shield_draw(_x, _y, _radius, _angle, _visual)
{
    sc_visual_shield_bake_draw(_x, _y, _radius, _visual.palette);
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

/// @description Creates the Shard's baked destruction fragments.
function sc_ship_shard_death(_player)
{
    var _ship = _player.ship;
    var _visual = _ship.visual;
    var _palette = _visual.palette;
    var _cache = _visual.runtime.cache;
    var _movement = _player.movement;
    var _angle = _player.draw_angle;
    var _radius = _visual.radius;
    var _wing = _visual.wing;
    var _fold = _visual.runtime.wing_fold;
    var _hull_stage = array_length(_cache.hull) - 1;
    var _fragments = [];

    array_push(_fragments, sc_death_fragment_data(
        _cache.hull[_hull_stage], _player.x, _player.y,
        _angle + random_range(-20, 20), random_range(0.8, 1.4),
        _angle, choose(-5, 5), 1, 1
    ));

    for (var _side = -1; _side <= 1; _side += 2)
    {
        var _hinge_x = _player.x + lengthdir_x(_wing.hinge_forward * _radius, _angle) + lengthdir_x(_wing.hinge_side * _radius * _side, _angle + 90);
        var _hinge_y = _player.y + lengthdir_y(_wing.hinge_forward * _radius, _angle) + lengthdir_y(_wing.hinge_side * _radius * _side, _angle + 90);
        var _direction = _angle + 90 * _side + random_range(-16, 16);

        array_push(_fragments, sc_death_fragment_data(
            _cache.wing_hull[_hull_stage], _hinge_x, _hinge_y,
            _direction, random_range(2, 3.2),
            _angle + _fold * _side, 7 * _side, 1, _side
        ));
    }

    var _hardpoints = _ship.hardpoints.primary;

    for (var _i = 0; _i < array_length(_hardpoints); _i++)
    {
        var _hardpoint = _hardpoints[_i];
        var _mount_x = _player.x + lengthdir_x(_hardpoint.x, _angle) + lengthdir_x(_hardpoint.y, _angle + 90);
        var _mount_y = _player.y + lengthdir_y(_hardpoint.x, _angle) + lengthdir_y(_hardpoint.y, _angle + 90);
        var _side = _hardpoint.y < 0 ? -1 : 1;
        var _direction = _angle + 55 * _side + random_range(-14, 14);

        array_push(_fragments, sc_death_fragment_data(
            _cache.hardpoint, _mount_x, _mount_y,
            _direction, random_range(2.5, 3.8),
            _angle + _hardpoint.angle, 10 * _side,
            _hardpoint.scale, _hardpoint.scale
        ));
    }

    for (var _i = 0; _i < array_length(_fragments); _i++)
    {
        _fragments[_i].velocity_x += _movement.velocity_x * 0.35;
        _fragments[_i].velocity_y += _movement.velocity_y * 0.35;
    }

    sc_death_fragment_create(_player.x, _player.y, _fragments, _palette.core, _palette.glow, _radius, 44);

    // Insert Shard destruction particles and audio here later.
    return true;
}