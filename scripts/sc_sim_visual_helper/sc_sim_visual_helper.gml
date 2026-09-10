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

/// @description Draws a segmented Simulant reactor ring.
function sc_sim_visual_core_ring(_x, _y, _r, _a, _forward, _side, _size, _rotation, _p, _alpha = 1)
{
    draw_set_alpha(_alpha);

    sc_visual_circle(_x, _y, _r, _a, _forward, _side, _size * 1.3, _p.void, false);
    sc_visual_circle(_x, _y, _r, _a, _forward, _side, _size, _p.hull_dark, false);
    sc_visual_circle(_x, _y, _r, _a, _forward, _side, _size * 0.78, _p.metal, true);
    sc_visual_circle(_x, _y, _r, _a, _forward, _side, _size * 0.55, _p.accent, true);

    var _cx = _x + lengthdir_x(_forward * _r, _a) + lengthdir_x(_side * _r, _a + 90);
    var _cy = _y + lengthdir_y(_forward * _r, _a) + lengthdir_y(_side * _r, _a + 90);
    var _outer = _r * _size;
    var _inner = _outer * 0.69;

    for (var _i = 0; _i < 8; _i++)
    {
        var _direction = _a + _rotation + _i * 45;

        draw_set_colour((_i mod 2) == 0 ? _p.energy : _p.outline);
        draw_line_width(
            _cx + lengthdir_x(_inner, _direction),
            _cy + lengthdir_y(_inner, _direction),
            _cx + lengthdir_x(_outer, _direction + 9),
            _cy + lengthdir_y(_outer, _direction + 9),
            max(1, _r * 0.018)
        );
    }

    draw_set_colour(_p.energy);
    draw_circle(_cx, _cy, _outer * 0.48, false);
    draw_set_colour(_p.core);
    draw_circle(_cx, _cy, _outer * 0.2, false);

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