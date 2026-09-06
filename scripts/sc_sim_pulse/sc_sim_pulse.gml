/// @description Registers the reusable baked Simulant pulse visual template.
function sc_projectile_register_simulant_pulse()
{
    var _palette = sc_faction_palette_get(Faction.SIMULANT);

    return sc_projectile_register({
        identity: { key: "projectile_simulant_pulse", name: "Simulant Pulse" },
		projectile_motion: ProjectileMotion.STANDARD,
        projectile_class: ProjectileClass.REGULAR,
        collision: { radius: 6 },

        visual: {
            radius: 4,
            length: 18,
            palette: _palette,
			sprite: s_sim_pulse,
            draw_script: sc_projectile_simulant_pulse_draw,
            impact_script: sc_projectile_simulant_pulse_impact,
            particles_register_script: sc_projectile_simulant_pulse_particles_register,

            bake: {
                canvas_size: 96,
                frames: 8,
                frame_speed: 2
            }
        }
    });
}

/// @description Registers the Simulant pulse's violet impact particles.
function sc_projectile_simulant_pulse_particles_register()
{
    var _palette = sc_faction_palette_get(Faction.SIMULANT);

    return sc_particles_projectile_impact_register("impact_simulant_pulse", _palette, {
        scale: 1.2,
        spark_amount: 9,
        fragment_amount: 4,
        spark_spread: 85,
        speed_min: 2,
        speed_max: 4.4
    });
}

/// @description Emits one scaled Simulant violet pulse impact.
function sc_projectile_simulant_pulse_impact(_x, _y, _direction, _target, _scale)
{
    return sc_particles_projectile_impact_emit("impact_simulant_pulse", _x, _y, _direction, _scale);
}

/// @description Draws one animated Simulant pulse frame with an imported glow for startup baking.
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


    // ==================================================
    // IMPORTED SOFT GLOW
    // ==================================================
    // Assumes a 96x96 sprite with its origin at 48,48.
    // The glow is baked into each cached projectile frame.
    draw_sprite_ext(
        s_sim_pulse,
        0,
        _x,
        _y,
        0.72 * _pulse,
        0.46 * _pulse,
        _angle,
        c_white,
        0.82
    );


    // ==================================================
    // ENERGY TRAIL
    // ==================================================
    draw_set_alpha(0.24);
    draw_set_colour(_p.glow);
    draw_line_width(
        _tail_x,
        _tail_y,
        _front_x,
        _front_y,
        _radius * 2.5 * _pulse
    );

    draw_set_alpha(0.7);
    draw_set_colour(_p.energy);
    draw_line_width(
        _tail_x,
        _tail_y,
        _front_x,
        _front_y,
        _radius * 1.2 * _pulse
    );

    draw_set_alpha(1);
    draw_set_colour(_p.core);
    draw_line_width(
        _tail_x,
        _tail_y,
        _front_x,
        _front_y,
        max(2, _radius * 0.45)
    );


    // ==================================================
    // ROTATING PULSE BODY
    // ==================================================
    draw_set_colour(_p.void);
    draw_circle(
        _x,
        _y,
        _radius * 0.95,
        false
    );

    draw_set_colour(_p.energy);
    draw_circle(
        _x,
        _y,
        _radius * 1.15 * _pulse,
        true
    );

    for (var _i = 0; _i < 4; _i++)
    {
        var _direction = _rotation + _i * 90;

        var _inner_x =
            _x + lengthdir_x(
                _radius * 0.7,
                _direction
            );

        var _inner_y =
            _y + lengthdir_y(
                _radius * 0.7,
                _direction
            );

        var _outer_x =
            _x + lengthdir_x(
                _radius * 1.45,
                _direction
            );

        var _outer_y =
            _y + lengthdir_y(
                _radius * 1.45,
                _direction
            );

        draw_set_colour(
            (_i mod 2) == 0
            ? _p.energy
            : _p.accent
        );

        draw_line_width(
            _inner_x,
            _inner_y,
            _outer_x,
            _outer_y,
            2
        );
    }

    draw_set_colour(_p.core);
    draw_circle(
        _x,
        _y,
        _radius * 0.45 * _pulse,
        false
    );


    // ==================================================
    // RESTORE DRAW STATE
    // ==================================================
    draw_set_alpha(1);
    draw_set_colour(c_white);
}