/*
SIMULANT ROCKET

Reusable baked Simulant rocket projectile.
The projectile owns its visual identity, collision shape, impact particles,
explosion appearance and shockwave appearance.

Weapon modules own projectile scale, speed, lifespan, homing, damage,
explosion scale and explosion damage.
*/

/// @description Registers the reusable baked Simulant rocket projectile.
function sc_projectile_register_simulant_rocket()
{
    var _palette = sc_faction_palette_get(Faction.SIMULANT);

    return sc_projectile_register({
        identity: {
            key: "projectile_simulant_rocket",
            name: "Simulant Rocket"
        },
		projectile_type: ProjectileType.ROCKET,
        projectile_class: ProjectileClass.HEAVY,
        collision: { radius: 8 },

        detonation: {
            area: {
                shape: AttackAreaShape.CIRCLE,
                geometry: { radius: 94 },

                behaviour: {
                    duration: 22,
                    tick_interval: 0,
                    hit_once: true,
                    max_targets: 0,
                    falloff_minimum: 0.2,
                    falloff_exponent: 1.35
                },

                visual: {
                    palette: _palette,
                    draw_script: sc_attack_area_simulant_rocket_explosion_draw,

                    shockwave: {
                        radius_scale: 1.35,
                        expansion_response: 0.17,
                        fade_speed: 0.04,
                        thickness: 5,
                        colour: _palette.energy,

                        particles_enabled: true,
                        particle_interval: 1,
                        particle_min_radius: 10,

                        smoke_enabled: true,
                        smoke_amount_max: 5,
                        smoke_colour: make_colour_rgb(60, 38, 78),

                        fragments_enabled: true,
                        fragment_chance: 0.55,
                        fragment_colour: _palette.energy
                    }
                }
            }
        },

        visual: {
            radius: 8,
            length: 34,
            palette: _palette,
            draw_script: sc_projectile_simulant_rocket_draw,
            impact_script: sc_projectile_simulant_rocket_impact,
            particles_register_script: sc_projectile_simulant_rocket_particles_register,

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

/// @description Draws one animated Simulant rocket frame for startup baking.
function sc_projectile_simulant_rocket_draw(_x, _y, _angle, _visual, _frame, _frame_count)
{
    var _p = _visual.palette;
    var _radius = _visual.radius;
    var _length = _visual.length;
    var _phase = (_frame / _frame_count) * pi * 2;
    var _pulse = 0.84 + sin(_phase) * 0.16;
    var _flame = 0.78 + sin(_phase + 0.8) * 0.22;
    var _nose_x = _x + lengthdir_x(_length * 0.58, _angle);
    var _nose_y = _y + lengthdir_y(_length * 0.58, _angle);
    var _rear_x = _x - lengthdir_x(_length * 0.42, _angle);
    var _rear_y = _y - lengthdir_y(_length * 0.42, _angle);
    var _tail_x = _rear_x - lengthdir_x(_length * 0.72 * _flame, _angle);
    var _tail_y = _rear_y - lengthdir_y(_length * 0.72 * _flame, _angle);

    // Broad violet exhaust glow.
    draw_set_alpha(0.18);
    draw_set_colour(_p.glow);
    draw_triangle(
        _rear_x + lengthdir_x(_radius * 1.7, _angle + 90),
        _rear_y + lengthdir_y(_radius * 1.7, _angle + 90),
        _tail_x,
        _tail_y,
        _rear_x - lengthdir_x(_radius * 1.7, _angle + 90),
        _rear_y - lengthdir_y(_radius * 1.7, _angle + 90),
        false
    );

    // Filled energy flame.
    draw_set_alpha(0.72);
    draw_set_colour(_p.accent);
    draw_triangle(
        _rear_x + lengthdir_x(_radius * 0.9, _angle + 90),
        _rear_y + lengthdir_y(_radius * 0.9, _angle + 90),
        _tail_x,
        _tail_y,
        _rear_x - lengthdir_x(_radius * 0.9, _angle + 90),
        _rear_y - lengthdir_y(_radius * 0.9, _angle + 90),
        false
    );

    draw_set_alpha(1);
    draw_set_colour(_p.core);
    draw_line_width(_rear_x, _rear_y, _tail_x, _tail_y, max(2, _radius * 0.35));

    // Rear stabilizing fins.
    draw_set_colour(_p.hull_light);
    draw_triangle(
        _rear_x,
        _rear_y,
        _rear_x - lengthdir_x(_radius * 1.45, _angle + 90),
        _rear_y - lengthdir_y(_radius * 1.45, _angle + 90),
        _x + lengthdir_x(_radius * 0.3, _angle + 90),
        _y + lengthdir_y(_radius * 0.3, _angle + 90),
        false
    );

    draw_triangle(
        _rear_x,
        _rear_y,
        _x - lengthdir_x(_radius * 0.3, _angle + 90),
        _y - lengthdir_y(_radius * 0.3, _angle + 90),
        _rear_x + lengthdir_x(_radius * 1.45, _angle + 90),
        _rear_y + lengthdir_y(_radius * 1.45, _angle + 90),
        false
    );

    // Main armoured rocket body.
    draw_set_colour(_p.void);
    draw_triangle(
        _nose_x,
        _nose_y,
        _rear_x + lengthdir_x(_radius * 1.05, _angle + 90),
        _rear_y + lengthdir_y(_radius * 1.05, _angle + 90),
        _rear_x - lengthdir_x(_radius * 1.05, _angle + 90),
        _rear_y - lengthdir_y(_radius * 1.05, _angle + 90),
        false
    );

    draw_set_colour(_p.hull_mid);
    draw_triangle(
        _nose_x - lengthdir_x(_radius * 0.4, _angle),
        _nose_y - lengthdir_y(_radius * 0.4, _angle),
        _rear_x + lengthdir_x(_radius * 0.78, _angle + 90),
        _rear_y + lengthdir_y(_radius * 0.78, _angle + 90),
        _rear_x - lengthdir_x(_radius * 0.78, _angle + 90),
        _rear_y - lengthdir_y(_radius * 0.78, _angle + 90),
        false
    );

    // Metallic central spine.
    draw_set_colour(_p.metal);
    draw_line_width(_rear_x, _rear_y, _nose_x, _nose_y, 3);

    // Animated containment rings.
    var _ring_offset_1 = -_length * 0.14;
    var _ring_offset_2 = _length * 0.1;

    draw_set_colour(_p.accent);
    draw_circle(
        _x + lengthdir_x(_ring_offset_1, _angle),
        _y + lengthdir_y(_ring_offset_1, _angle),
        _radius * (0.58 + _pulse * 0.08),
        true
    );

    draw_set_colour(_p.energy);
    draw_circle(
        _x + lengthdir_x(_ring_offset_2, _angle),
        _y + lengthdir_y(_ring_offset_2, _angle),
        _radius * (0.48 + _pulse * 0.06),
        true
    );

    // Bright warhead.
    draw_set_alpha(0.3);
    draw_set_colour(_p.glow);
    draw_circle(_nose_x, _nose_y, _radius * 0.95 * _pulse, false);

    draw_set_alpha(1);
    draw_set_colour(_p.energy);
    draw_circle(_nose_x, _nose_y, _radius * 0.42 * _pulse, false);

    draw_set_colour(_p.core);
    draw_circle(_nose_x, _nose_y, max(1.5, _radius * 0.18), false);

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