/*
SIMULANT ROCKET

Reusable baked Simulant rocket projectile.
The projectile owns its visual identity, collision shape, impact particles,
explosion appearance and shockwave appearance.

Weapon modules own projectile scale, speed, lifespan, homing, damage,
explosion scale and explosion damage.
*/

/// @description Registers the reusable wide Simulant rocket projectile.
function sc_projectile_register_simulant_rocket()
{
    var _palette = sc_faction_palette_get(Faction.SIMULANT);

    return sc_projectile_register({
        identity: {
            key: "projectile_simulant_rocket",
            name: "Simulant Rocket"
        },

        projectile_motion: ProjectileMotion.ROCKET,
        projectile_class: ProjectileClass.HEAVY,

        collision: {
            radius: 9
        },

        detonation: {
            area: {
                shape: AttackAreaShape.CIRCLE,

                geometry: {
                    radius: 72
                },

                behaviour: {
                    duration: 18,
                    tick_interval: 0,
                    hit_once: true,
                    max_targets: 0,
                    falloff_minimum: 0.2,
                    falloff_exponent: 1.25
                },

                visual: {
                    palette: _palette,
                    draw_script: sc_attack_area_simulant_rocket_explosion_draw,

                    shockwave: {
                        radius_scale: 1.3,
                        expansion_response: 0.18,
                        fade_speed: 0.045,
                        thickness: 4,
                        colour: _palette.energy,

                        particles_enabled: true,
                        particle_interval: 1,
                        particle_min_radius: 8,

                        smoke_enabled: true,
                        smoke_amount_max: 4,
                        smoke_colour: make_colour_rgb(60, 38, 78),

                        fragments_enabled: true,
                        fragment_chance: 0.48,
                        fragment_colour: _palette.energy
                    }
                }
            }
        },

        visual: {
            radius: 10,
            length: 36,
            palette: _palette,

            draw_script: sc_projectile_simulant_rocket_draw,
            impact_script: sc_projectile_simulant_rocket_impact,
            particles_register_script: sc_projectile_simulant_rocket_particles_register,

            trail: {
                enabled: true,
                length: 64,
                width: 2.5,
                glow_width: 8,
                alpha: 0.78,
                glow_alpha: 0.2
            },

            bake: {
                canvas_size: 128,
                frames: 6,
                frame_speed: 2
            }
        }
    });
}

/// @description Registers the Simulant rocket's violet impact particles.
function sc_projectile_simulant_rocket_particles_register()
{
    var _palette = sc_faction_palette_get(Faction.SIMULANT);

    return sc_particles_projectile_impact_register("impact_simulant_rocket", _palette, {
        scale: 1.35,
        spark_amount: 16,
        fragment_amount: 10,
        spark_spread: 170,
        speed_min: 3,
        speed_max: 7.5
    });
}

/// @description Emits one Simulant rocket impact scaled by its weapon.
function sc_projectile_simulant_rocket_impact(_x, _y, _direction, _target, _scale)
{
    return sc_particles_projectile_impact_emit(
        "impact_simulant_rocket",
        _x,
        _y,
        _direction,
        _scale
    );
}

/// @description Draws a broad segmented Simulant assault rocket.
function sc_projectile_simulant_rocket_draw(_x, _y, _angle, _visual, _frame, _frame_count)
{
    var _p = _visual.palette;
    var _r = _visual.radius;
    var _length = _visual.length;
    var _phase = (_frame / _frame_count) * pi * 2;
    var _pulse = 0.86 + sin(_phase) * 0.14;
    var _flame = 0.84 + sin(_phase + 0.8) * 0.16;

    var _nose = 0.62;
    var _nose_mid = 0.34;
    var _body_front = 0.13;
    var _body_rear = -0.34;
    var _engine_rear = -0.52;

    // ==================================================
    // TWIN EXHAUST FLAMES
    // ==================================================
    for (var _side = -1; _side <= 1; _side += 2)
    {
        var _nozzle_side = _r * 0.43 * _side;

        var _nozzle_x = _x
            + lengthdir_x(_length * _engine_rear, _angle)
            + lengthdir_x(_nozzle_side, _angle + 90);

        var _nozzle_y = _y
            + lengthdir_y(_length * _engine_rear, _angle)
            + lengthdir_y(_nozzle_side, _angle + 90);

        var _flame_x = _x
            + lengthdir_x(-_length * (0.84 + 0.12 * _flame), _angle)
            + lengthdir_x(_nozzle_side, _angle + 90);

        var _flame_y = _y
            + lengthdir_y(-_length * (0.84 + 0.12 * _flame), _angle)
            + lengthdir_y(_nozzle_side, _angle + 90);

        draw_set_alpha(0.22);
        draw_set_colour(_p.glow);
        draw_line_width(
            _nozzle_x,
            _nozzle_y,
            _flame_x,
            _flame_y,
            _r * 0.75
        );

        draw_set_alpha(0.75);
        draw_set_colour(_p.energy);
        draw_line_width(
            _nozzle_x,
            _nozzle_y,
            _flame_x,
            _flame_y,
            _r * 0.34
        );

        draw_set_alpha(1);
        draw_set_colour(_p.core);
        draw_line_width(
            _nozzle_x,
            _nozzle_y,
            lerp(_nozzle_x, _flame_x, 0.58),
            lerp(_nozzle_y, _flame_y, 0.58),
            max(2, _r * 0.13)
        );
    }

    // ==================================================
    // LARGE REAR STABILIZER FINS
    // ==================================================
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_triangle(
            _x, _y, _length, _angle,
            -0.11, 0.2 * _side,
            -0.47, 0.28 * _side,
            -0.31, 0.5 * _side,
            _p.void, false
        );

        sc_visual_triangle(
            _x, _y, _length, _angle,
            -0.13, 0.21 * _side,
            -0.42, 0.27 * _side,
            -0.3, 0.45 * _side,
            _p.hull_mid, false
        );

        sc_visual_line(
            _x, _y, _length, _angle,
            -0.14, 0.22 * _side,
            -0.3, 0.42 * _side,
            2, _p.energy
        );

        sc_visual_line(
            _x, _y, _length, _angle,
            -0.3, 0.42 * _side,
            -0.42, 0.27 * _side,
            2, _p.outline
        );
    }

    // ==================================================
    // ENGINE HOUSING
    // ==================================================
    sc_visual_quad(
        _x, _y, _length, _angle,
        -0.22, -0.25,
        _engine_rear, -0.24,
        _engine_rear, 0.24,
        -0.22, 0.25,
        _p.void
    );

    sc_visual_quad(
        _x, _y, _length, _angle,
        -0.2, -0.2,
        -0.48, -0.19,
        -0.48, 0.19,
        -0.2, 0.2,
        _p.hull_light
    );

    sc_visual_line(
        _x, _y, _length, _angle,
        -0.22, -0.23,
        -0.22, 0.23,
        3, _p.metal
    );

    // Twin engine nozzles.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_circle(
            _x, _y, _length, _angle,
            -0.5, 0.12 * _side,
            0.085, _p.void, false
        );

        sc_visual_circle(
            _x, _y, _length, _angle,
            -0.5, 0.12 * _side,
            0.065, _p.metal, true
        );

        sc_visual_circle(
            _x, _y, _length, _angle,
            -0.5, 0.12 * _side,
            0.032 * _pulse, _p.core, false
        );
    }

    // ==================================================
    // BROAD CENTRAL BODY
    // ==================================================
    sc_visual_quad(
        _x, _y, _length, _angle,
        _body_front, -0.22,
        _body_rear, -0.24,
        _body_rear, 0.24,
        _body_front, 0.22,
        _p.void
    );

    sc_visual_quad(
        _x, _y, _length, _angle,
        0.1, -0.18,
        -0.31, -0.19,
        -0.31, 0.19,
        0.1, 0.18,
        _p.hull_mid
    );

    // Layered side armour.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_quad(
            _x, _y, _length, _angle,
            0.08, 0.17 * _side,
            -0.08, 0.22 * _side,
            -0.3, 0.19 * _side,
            -0.18, 0.13 * _side,
            _p.hull_light
        );

        sc_visual_line(
            _x, _y, _length, _angle,
            0.06, 0.17 * _side,
            -0.27, 0.18 * _side,
            2, _p.metal
        );
    }

    // Mechanical containment collars.
    sc_visual_line(
        _x, _y, _length, _angle,
        -0.13, -0.22,
        -0.13, 0.22,
        4, _p.metal
    );

    sc_visual_line(
        _x, _y, _length, _angle,
        0.07, -0.19,
        0.07, 0.19,
        3, _p.accent
    );

    // Central reactor channel.
    sc_visual_line(
        _x, _y, _length, _angle,
        -0.31, 0,
        0.15, 0,
        9, _p.void
    );

    sc_visual_line(
        _x, _y, _length, _angle,
        -0.27, 0,
        0.14, 0,
        4, _p.accent
    );

    sc_visual_line(
        _x, _y, _length, _angle,
        -0.2, 0,
        0.12, 0,
        2, _p.core
    );

    // ==================================================
    // FORWARD CONTROL FINS
    // ==================================================
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_triangle(
            _x, _y, _length, _angle,
            0.18, 0.16 * _side,
            -0.02, 0.2 * _side,
            0.08, 0.37 * _side,
            _p.void, false
        );

        sc_visual_triangle(
            _x, _y, _length, _angle,
            0.16, 0.16 * _side,
            0, 0.19 * _side,
            0.08, 0.33 * _side,
            _p.hull_light, false
        );

        sc_visual_line(
            _x, _y, _length, _angle,
            0.14, 0.17 * _side,
            0.08, 0.31 * _side,
            2, _p.energy
        );
    }

    // ==================================================
    // SEGMENTED ARMOURED WARHEAD
    // ==================================================
    sc_visual_triangle(
        _x, _y, _length, _angle,
        _nose, 0,
        _body_front, -0.21,
        _body_front, 0.21,
        _p.void, false
    );

    sc_visual_triangle(
        _x, _y, _length, _angle,
        0.57, 0,
        0.15, -0.17,
        0.15, 0.17,
        _p.hull_dark, false
    );

    sc_visual_quad(
        _x, _y, _length, _angle,
        0.5, -0.065,
        0.35, -0.135,
        0.35, 0.135,
        0.5, 0.065,
        _p.hull_light
    );

    sc_visual_quad(
        _x, _y, _length, _angle,
        0.36, -0.13,
        _nose_mid, -0.165,
        _nose_mid, 0.165,
        0.36, 0.13,
        _p.metal
    );

    sc_visual_quad(
        _x, _y, _length, _angle,
        0.27, -0.16,
        0.16, -0.19,
        0.16, 0.19,
        0.27, 0.16,
        _p.hull_light
    );

    // Violet gaps between warhead segments.
    sc_visual_line(
        _x, _y, _length, _angle,
        0.36, -0.13,
        0.36, 0.13,
        2, _p.energy
    );

    sc_visual_line(
        _x, _y, _length, _angle,
        0.27, -0.16,
        0.27, 0.16,
        2, _p.accent
    );

    sc_visual_line(
        _x, _y, _length, _angle,
        0.17, -0.18,
        0.17, 0.18,
        2, _p.energy
    );

    // Bright pointed guidance tip.
    sc_visual_circle(
        _x, _y, _length, _angle,
        0.57, 0,
        0.045 * _pulse,
        _p.energy, false
    );

    sc_visual_circle(
        _x, _y, _length, _angle,
        0.59, 0,
        0.02,
        _p.core, false
    );

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws one expanding Simulant rocket explosion.
function sc_attack_area_simulant_rocket_explosion_draw(_area, _data)
{
    var _p = _data.visual.palette;
    var _life_ratio = _data.runtime.life / _data.behaviour.duration;
    var _progress = 1 - _life_ratio;
    var _radius = _data.geometry.radius * sin(_progress * pi * 0.72);
    var _alpha = clamp(_life_ratio * 1.5, 0, 1);
    var _pulse = 0.9 + sin(GAME_TICK * 0.65) * 0.1;

    gpu_set_blendmode(bm_add);

    // Wide outer violet glow.
    draw_set_alpha(_alpha * 0.12);
    draw_set_colour(_p.glow);
    draw_circle(_area.x, _area.y, _radius * 1.2, false);

    draw_set_alpha(_alpha * 0.24);
    draw_set_colour(_p.accent);
    draw_circle(_area.x, _area.y, _radius, false);

    // Broken inner energy layers.
    draw_set_alpha(_alpha * 0.5);
    draw_set_colour(_p.energy);
    draw_circle(_area.x, _area.y, _radius * 0.72 * _pulse, false);

    draw_set_alpha(_alpha * 0.8);
    draw_set_colour(_p.core);
    draw_circle(_area.x, _area.y, max(3, _radius * 0.3), false);

    // Bright expanding ring.
    draw_set_alpha(_alpha);
    draw_set_colour(c_white);
    draw_circle(_area.x, _area.y, _radius, true);

    draw_set_alpha(_alpha * 0.75);
    draw_set_colour(_p.energy);
    draw_circle(_area.x, _area.y, max(0, _radius - 5), true);

    // Four short energy fractures.
    for (var _i = 0; _i < 4; _i++)
    {
        var _angle = _i * 90 + GAME_TICK * 2;
        var _inner = _radius * 0.36;
        var _outer = _radius * 0.82;

        draw_set_alpha(_alpha * 0.65);
        draw_set_colour(_p.accent);
        draw_line_width(
            _area.x + lengthdir_x(_inner, _angle),
            _area.y + lengthdir_y(_inner, _angle),
            _area.x + lengthdir_x(_outer, _angle + 9),
            _area.y + lengthdir_y(_outer, _angle + 9),
            3
        );
    }

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}