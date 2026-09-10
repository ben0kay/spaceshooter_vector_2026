/*
SIMULANT VISUAL HELPERS

Reusable angular armour, energy conduits, cores and weapon housings.
Ship-specific drawing functions decide their positions and sizes.
*/

/// @description Draws a recessed Simulant energy conduit.
function sc_sim_visual_energy_conduit(_x, _y, _r, _a, _f1, _s1, _f2, _s2, _width, _p, _alpha = 1)
{
    draw_set_alpha(_alpha);
    sc_visual_line(_x, _y, _r, _a, _f1, _s1, _f2, _s2, _width + 7, _p.void);
    sc_visual_line(_x, _y, _r, _a, _f1, _s1, _f2, _s2, _width + 3, _p.glow);
    sc_visual_line(_x, _y, _r, _a, _f1, _s1, _f2, _s2, _width, _p.energy);
    sc_visual_line(_x, _y, _r, _a, _f1, _s1, _f2, _s2, max(1, _width * 0.28), _p.core);
    draw_set_alpha(1);
}

/// @description Draws one sharp four-sided Simulant armour blade.
function sc_sim_visual_blade_panel(
    _x, _y, _r, _a,
    _f1, _s1, _f2, _s2, _f3, _s3, _f4, _s4,
    _fill, _p, _alpha = 1
)
{
    draw_set_alpha(_alpha);
    sc_visual_quad(_x, _y, _r, _a, _f1, _s1, _f2, _s2, _f3, _s3, _f4, _s4, _p.void);
    sc_visual_quad(
        _x, _y, _r, _a,
        lerp(_f1, 0, 0.035), lerp(_s1, 0, 0.035),
        lerp(_f2, 0, 0.035), lerp(_s2, 0, 0.035),
        lerp(_f3, 0, 0.035), lerp(_s3, 0, 0.035),
        lerp(_f4, 0, 0.035), lerp(_s4, 0, 0.035),
        _fill
    );

    sc_visual_line(_x, _y, _r, _a, _f1, _s1, _f2, _s2, 2, _p.outline);
    sc_visual_line(_x, _y, _r, _a, _f2, _s2, _f3, _s3, 1, _p.metal);
    sc_visual_line(_x, _y, _r, _a, _f3, _s3, _f4, _s4, 2, _p.outline);
    draw_set_alpha(1);
}

/// @description Draws a paired angular Simulant rear fin.
function sc_sim_visual_rear_fin(_x, _y, _r, _a, _forward, _side, _length, _width, _p, _alpha = 1)
{
    var _sign = sign(_side);
    var _inside = abs(_side);
    var _outside = _inside + _width;

    sc_sim_visual_blade_panel(
        _x, _y, _r, _a,
        _forward + _length * 0.48, _inside * _sign,
        _forward + _length * 0.12, _outside * _sign,
        _forward - _length * 0.52, (_outside * 0.86) * _sign,
        _forward - _length * 0.34, (_inside * 0.82) * _sign,
        _p.hull_dark, _p, _alpha
    );

    sc_sim_visual_energy_conduit(
        _x, _y, _r, _a,
        _forward + _length * 0.18, (_inside + _width * 0.28) * _sign,
        _forward - _length * 0.28, (_inside + _width * 0.47) * _sign,
        2, _p, _alpha
    );
}

/// @description Draws a layered circular Simulant energy socket.
function sc_sim_visual_energy_socket(_x, _y, _r, _a, _forward, _side, _size, _p, _alpha = 1)
{
    draw_set_alpha(_alpha);

    sc_visual_circle(_x, _y, _r, _a, _forward, _side, _size * 1.45, _p.void, false);
    sc_visual_circle(_x, _y, _r, _a, _forward, _side, _size * 1.2, _p.hull_mid, false);
    sc_visual_circle(_x, _y, _r, _a, _forward, _side, _size, _p.outline, true);
    sc_visual_circle(_x, _y, _r, _a, _forward, _side, _size * 0.66, _p.accent, false);
    sc_visual_circle(_x, _y, _r, _a, _forward, _side, _size * 0.3, _p.core, false);

    draw_set_alpha(1);
}

/// @description Draws one configurable rotating Simulant reactor.
function sc_sim_visual_reactor(_x, _y, _radius, _angle, _config, _palette, _alpha = 1)
{
    var _outer = _radius * _config.outer_scale;
    var _middle = _radius * _config.middle_scale;
    var _inner = _radius * _config.inner_scale;
    var _additive = _config.additive;

    if (_additive)
        gpu_set_blendmode(bm_add);

    // Optional outer reactor glow.
    if (_config.glow_alpha > 0)
    {
        draw_set_alpha(_alpha * _config.glow_alpha);
        draw_set_colour(_palette.glow);
        draw_circle(_x, _y, _outer * _config.glow_scale, false);
    }

    // Optional brighter secondary glow layer.
    if (_config.secondary_glow_alpha > 0)
    {
        draw_set_alpha(_alpha * _config.secondary_glow_alpha);
        draw_set_colour(_palette.accent);
        draw_circle(_x, _y, _outer * _config.secondary_glow_scale, false);
    }

    draw_set_alpha(_alpha);

    // The physical dark socket and metallic outer ring.
    if (_config.socket_enabled)
    {
        draw_set_colour(_palette.void);
        draw_circle(_x, _y, _outer, false);

        draw_set_colour(_palette.metal);
        draw_circle(_x, _y, _outer, true);
    }

    // Optional middle containment ring or filled energy layer.
    if (_middle > 0)
    {
        draw_set_colour(_config.middle_colour);

        draw_circle(
            _x,
            _y,
            _middle,
            !_config.middle_filled
        );
    }

    // Rotating mechanical/energy vanes.
    var _step = 360 / max(1, _config.vane_amount);

    for (var _i = 0; _i < _config.vane_amount; _i++)
    {
        var _direction = _angle + _config.vane_start + _i * _step;
        var _inner_direction = _direction;
        var _outer_direction = _direction + _config.vane_twist;

        draw_set_colour(
            (_i mod 2) == 0
                ? _palette.energy
                : _config.vane_secondary_colour
        );

        draw_line_width(
            _x + lengthdir_x(_inner * _config.vane_inner_scale, _inner_direction),
            _y + lengthdir_y(_inner * _config.vane_inner_scale, _inner_direction),
            _x + lengthdir_x(_outer * _config.vane_outer_scale, _outer_direction),
            _y + lengthdir_y(_outer * _config.vane_outer_scale, _outer_direction),
            _config.vane_width
        );
    }

    // Powered inner containment ring.
    draw_set_colour(_palette.accent);
    draw_circle(
        _x,
        _y,
        _inner * _config.accent_scale,
        !_config.accent_filled
    );

    // Active energy and white-hot centre.
    draw_set_colour(_palette.energy);
    draw_circle(_x, _y, _inner, false);

    draw_set_colour(_palette.core);
    draw_circle(_x, _y, _inner * _config.core_scale, false);

    if (_additive)
        gpu_set_blendmode(bm_normal);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws a long embedded Simulant beam-cannon spine.
function sc_sim_visual_beam_spine(_x, _y, _r, _a, _rear, _front, _half_width, _p, _alpha = 1)
{
    draw_set_alpha(_alpha);

    sc_visual_quad(
        _x, _y, _r, _a,
        _rear, -_half_width,
        _front, -_half_width * 0.3,
        _front, _half_width * 0.3,
        _rear, _half_width,
        _p.void
    );

    sc_visual_quad(
        _x, _y, _r, _a,
        _rear + 0.04, -_half_width * 0.7,
        _front - 0.02, -_half_width * 0.2,
        _front - 0.02, _half_width * 0.2,
        _rear + 0.04, _half_width * 0.7,
        _p.hull_mid
    );

    sc_sim_visual_energy_conduit(
        _x, _y, _r, _a,
        _rear + 0.08, 0,
        _front, 0,
        max(3, _r * 0.035),
        _p, _alpha
    );

    draw_set_alpha(1);
}

/// @description Draws a reusable Simulant multi-tube rocket launcher.
function sc_sim_visual_rocket_launcher(_x, _y, _r, _a, _scale, _p, _alpha = 1)
{
    var _rear = -0.2 * _scale;
    var _front = 0.24 * _scale;
    var _half = 0.2 * _scale;
    var _tube_radius = 0.055 * _scale;

    draw_set_alpha(_alpha);

    sc_visual_quad(
        _x, _y, _r, _a,
        _rear, -_half,
        _front, -_half * 0.76,
        _front, _half * 0.76,
        _rear, _half,
        _p.void
    );

    sc_visual_quad(
        _x, _y, _r, _a,
        _rear * 0.82, -_half * 0.72,
        _front * 0.82, -_half * 0.52,
        _front * 0.82, _half * 0.52,
        _rear * 0.82, _half * 0.72,
        _p.hull_mid
    );

    for (var _side = -1; _side <= 1; _side += 2)
    {
        var _tube_side = _side * _half * 0.43;

        sc_visual_line(
            _x, _y, _r, _a,
            _rear * 0.55, _tube_side,
            _front, _tube_side,
            max(4, _r * _tube_radius * 2.5),
            _p.void
        );

        sc_visual_circle(
            _x, _y, _r, _a,
            _front, _tube_side,
            _tube_radius,
            _p.accent,
            false
        );

        sc_visual_circle(
            _x, _y, _r, _a,
            _front, _tube_side,
            _tube_radius * 0.42,
            _p.core,
            false
        );
    }

    sc_visual_line(_x, _y, _r, _a, _rear * 0.7, 0, _front * 0.65, 0, 2, _p.metal);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Standard hardpoint wrapper for the reusable rocket launcher.
function sc_enemy_simulant_rocket_launcher_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _scale = variable_struct_exists(_visual, "rocket_launcher_scale")
        ? _visual.rocket_launcher_scale
        : 1;

    sc_sim_visual_rocket_launcher(
        _x, _y, _radius, _angle,
        _scale,
        _visual.palette,
        _alpha
    );
}

/// @description Draws one detached swept Simulant armour blade.
function sc_sim_visual_swept_blade(
    _x, _y, _radius, _angle,
    _forward, _side,
    _length, _width, _sweep,
    _fill, _palette,
    _energy_enabled = true,
    _alpha = 1
)
{
    var _sign = sign(_side);
    if (_sign == 0) _sign = 1;

    var _inner_side = abs(_side);
    var _outer_side = _inner_side + _width;

    // Outer edge is shifted rearward to create the swept shape.
    var _inner_front = _forward + _length * 0.5;
    var _inner_rear = _forward - _length * 0.5;
    var _outer_front = _inner_front - _sweep;
    var _outer_rear = _inner_rear - _sweep;

    sc_sim_visual_blade_panel(
        _x, _y, _radius, _angle,

        _inner_front, _inner_side * _sign,
        _outer_front, _outer_side * _sign,
        _outer_rear, _outer_side * _sign,
        _inner_rear, _inner_side * _sign,

        _fill,
        _palette,
        _alpha
    );

    if (_energy_enabled)
    {
        // Inset lighting follows the long outer section of the blade.
        var _energy_side = lerp(_inner_side, _outer_side, 0.68) * _sign;
        var _energy_front = lerp(_inner_front, _outer_front, 0.72) - _length * 0.13;
        var _energy_rear = lerp(_inner_rear, _outer_rear, 0.72) + _length * 0.13;

        sc_sim_visual_energy_conduit(
            _x, _y, _radius, _angle,
            _energy_rear, _energy_side,
            _energy_front, _energy_side,
            max(2, _radius * 0.014),
            _palette,
            _alpha
        );
    }
}

/// @description Draws one adjustable bank of separated swept Simulant blades.
function sc_sim_visual_swept_blade_bank(
    _x, _y, _radius, _angle,
    _side_sign,
    _config,
    _palette,
    _alpha = 1
)
{
    var _amount = max(1, round(_config.amount));

    for (var _i = 0; _i < _amount; _i++)
    {
        var _forward = _config.forward_start + _config.forward_step * _i;
        var _side = (_config.side_start + _config.side_step * _i) * _side_sign;
        var _length = max(0.05, _config.length_start + _config.length_step * _i);
        var _width = max(0.03, _config.width_start + _config.width_step * _i);
        var _sweep = _config.sweep_start + _config.sweep_step * _i;

        var _fill = (_i mod 2) == 0
            ? _config.colour_primary
            : _config.colour_secondary;

        sc_sim_visual_swept_blade(
            _x, _y, _radius, _angle,
            _forward, _side,
            _length, _width, _sweep,
            _fill,
            _palette,
            _config.energy_enabled,
            _alpha
        );
    }
}