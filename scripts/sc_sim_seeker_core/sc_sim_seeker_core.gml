/*
SIMULANT SEEKER CORE

A large, slow homing energy orb used by elite Simulant ships.
The projectile owns its appearance and explosion.
The weapon owns its speed, damage, scale and guidance.
*/

/// @description Registers the reusable Simulant seeker-core projectile.
function sc_projectile_register_simulant_seeker_core()
{
    var _palette = sc_faction_palette_get(Faction.SIMULANT);

    return sc_projectile_register({
        identity: {
            key: "projectile_simulant_seeker_core",
            name: "Simulant Seeker Core"
        },

        projectile_motion: ProjectileMotion.STANDARD,
        projectile_class: ProjectileClass.HEAVY,

        collision: {
            radius: 13
        },

		defence: {
		    armour: 35,
		    hull: 45,
		    detonate_on_destroy: true
		},

        detonation: {
            area: {
                shape: AttackAreaShape.CIRCLE,

                geometry: {
                    radius: 92
                },

                behaviour: {
                    duration: 22,
                    tick_interval: 0,
                    hit_once: true,
                    max_targets: 0,
                    falloff_minimum: 0.25,
                    falloff_exponent: 1.3
                },

                visual: {
                    palette: _palette,
                    draw_script: sc_attack_area_simulant_seeker_core_draw,

                    shockwave: {
					    radius_scale: 1.55,
					    expansion_response: 0.14,
					    fade_speed: 0.028,
					    thickness: 6,
					    colour: _palette.energy,

					    particles_enabled: true,
					    particle_interval: 1,
					    particle_min_radius: 5,

					    smoke_enabled: true,
					    smoke_amount_max: 7,
					    smoke_colour: make_colour_rgb(105, 65, 145),

					    fragments_enabled: true,
					    fragment_chance: 0.7,
					    fragment_colour: _palette.energy
					}
		        }
            }
        },

        visual: {
            radius: 15,
            length: 24,
            palette: _palette,

            draw_script: sc_projectile_simulant_seeker_core_draw,
            impact_script: sc_projectile_simulant_seeker_core_impact,
            particles_register_script: sc_projectile_simulant_seeker_core_particles_register,
			trail_script: sc_projectile_simulant_seeker_core_trail,

            trail: {
                enabled: true,
                length: 92,
                width: 5,
                glow_width: 16,
                alpha: 0.88,
                glow_alpha: 0.3
            },

            bake: {
                canvas_size: 128,
                frames: 8,
                frame_speed: 2
            }
        }
    });
}

/// @description Registers the seeker core's heavy violet impact.
function sc_projectile_simulant_seeker_core_particles_register()
{
    var _palette = sc_faction_palette_get(Faction.SIMULANT);

    return sc_particles_projectile_impact_register(
        "impact_simulant_seeker_core",
        _palette,
        {
            scale: 1.8,
            spark_amount: 22,
            fragment_amount: 14,
            spark_spread: 220,
            speed_min: 2.5,
            speed_max: 8
        }
    );
}

/// @description Emits the seeker core impact particles.
function sc_projectile_simulant_seeker_core_impact(_x, _y, _direction, _target, _scale)
{
    return sc_particles_projectile_impact_emit(
        "impact_simulant_seeker_core",
        _x,
        _y,
        _direction,
        _scale
    );
}

/// @description Draws one animated rotating Simulant seeker orb.
function sc_projectile_simulant_seeker_core_draw(_x, _y, _angle, _visual, _frame, _frame_count)
{
    var _p = _visual.palette;
    var _r = _visual.radius;
    var _phase = (_frame / _frame_count) * pi * 2;
    var _pulse = 0.88 + sin(_phase) * 0.12;
    var _rotation = _angle + (_frame / _frame_count) * 360;

    gpu_set_blendmode(bm_add);

    draw_set_colour(_p.glow);
    draw_set_alpha(0.14);
    draw_circle(_x, _y, _r * 2.4 * _pulse, false);

    draw_set_colour(_p.accent);
    draw_set_alpha(0.28);
    draw_circle(_x, _y, _r * 1.7 * _pulse, false);

    draw_set_colour(_p.energy);
    draw_set_alpha(0.55);
    draw_circle(_x, _y, _r * 1.18, false);

    gpu_set_blendmode(bm_normal);

    draw_set_alpha(1);
    draw_set_colour(_p.void);
    draw_circle(_x, _y, _r, false);

    draw_set_colour(_p.metal);
    draw_circle(_x, _y, _r, true);

    draw_set_colour(_p.accent);
    draw_circle(_x, _y, _r * 0.72, true);

    for (var _i = 0; _i < 6; _i++)
    {
        var _direction = _rotation + _i * 60;
        var _inner = _r * 0.72;
        var _outer = _r * 1.2;

        draw_set_colour((_i mod 2) == 0 ? _p.energy : _p.accent);
        draw_set_alpha(0.85);

        draw_line_width(
            _x + lengthdir_x(_inner, _direction),
            _y + lengthdir_y(_inner, _direction),
            _x + lengthdir_x(_outer, _direction + 13),
            _y + lengthdir_y(_outer, _direction + 13),
            2
        );

        draw_set_colour(_p.core);
        draw_circle(
            _x + lengthdir_x(_outer, _direction + 13),
            _y + lengthdir_y(_outer, _direction + 13),
            max(1.5, _r * 0.11),
            false
        );
    }

    gpu_set_blendmode(bm_add);

    draw_set_colour(_p.energy);
    draw_set_alpha(0.8);
    draw_circle(_x, _y, _r * 0.56 * _pulse, false);

    draw_set_colour(_p.core);
    draw_set_alpha(1);
    draw_circle(_x, _y, _r * 0.23 * _pulse, false);

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws the seeker core's expanding energy detonation.
function sc_attack_area_simulant_seeker_core_draw(_area, _data)
{
    var _p = _data.visual.palette;
    var _life_ratio = _data.runtime.life / _data.behaviour.duration;
    var _progress = 1 - _life_ratio;
    var _radius = _data.geometry.radius * sin(_progress * pi * 0.78);
    var _alpha = clamp(_life_ratio * 1.6, 0, 1);
    var _rotation = GAME_TICK * 4;

    gpu_set_blendmode(bm_add);

    draw_set_colour(_p.glow);
    draw_set_alpha(_alpha * 0.16);
    draw_circle(_area.x, _area.y, _radius * 1.35, false);

    draw_set_colour(_p.accent);
    draw_set_alpha(_alpha * 0.3);
    draw_circle(_area.x, _area.y, _radius, false);

    draw_set_colour(_p.energy);
    draw_set_alpha(_alpha * 0.7);
    draw_circle(_area.x, _area.y, _radius * 0.66, false);

    draw_set_colour(_p.core);
    draw_set_alpha(_alpha);
    draw_circle(_area.x, _area.y, max(3, _radius * 0.22), false);

    for (var _i = 0; _i < 6; _i++)
    {
        var _direction = _rotation + _i * 60;

        draw_set_colour(_p.energy);
        draw_set_alpha(_alpha * 0.75);

        draw_line_width(
            _area.x + lengthdir_x(_radius * 0.25, _direction),
            _area.y + lengthdir_y(_radius * 0.25, _direction),
            _area.x + lengthdir_x(_radius * 0.92, _direction + 10),
            _area.y + lengthdir_y(_radius * 0.92, _direction + 10),
            3
        );
    }

    draw_set_colour(c_white);
    draw_set_alpha(_alpha);
    draw_circle(_area.x, _area.y, _radius, true);

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Registers the Dreadwing's heavy seeker-core weapon.
function sc_weapon_register_simulant_seeker_core()
{
    return sc_weapon_register({
        identity: {
            key: "weapon_simulant_seeker_core",
            name: "Simulant Seeker Core"
        },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_simulant_seeker_core",

            projectile: {
                scale: 1.3,
                speed: 7.5,
                life: 280
            },

            damage: {
                amount: 10,
                type: DamageType.ENERGY,
                effect: DamageEffect.NONE
            },

            guidance: {
                homing: 1,
                acquire_range: 1500,
                turn_speed: 1.65,
                reacquire_interval: 8
            },

            detonation: {
                scale: 1.15,

                damage: {
                    amount: 28,
                    type: DamageType.ENERGY,
                    effect: DamageEffect.STAGGER,
                    effect_chance: 1,
                    effect_duration: 18,
                    effect_strength: 0.55,
                    knockback_force: 4
                }
            }
        },

        audio: {
            sound: noone,
            volume: 0.8,
            pitch_range: 0.04
        }
    });
}

/// @description Emits the Seeker Core's large lingering Simulant particle trail.
function sc_projectile_simulant_seeker_core_trail(_projectile, _data)
{
    var _types = sc_particles_group_get("simulant");
    if (!is_struct(_types)) return false;

    var _system = global.particles.impact_system;
    var _direction = _data.direction;
    var _scale = _data.scale;

    var _rear_distance = _data.visual.length * 0.45 * _scale;

    var _x = _projectile.x
        - lengthdir_x(_rear_distance, _direction);

    var _y = _projectile.y
        - lengthdir_y(_rear_distance, _direction);

    // Large drifting violet energy plume.
    part_type_direction(
        _types.trail,
        _direction + 160,
        _direction + 200,
        0,
        0
    );

    part_type_speed(
        _types.trail,
        0.35,
        1.15,
        -0.015,
        0.05
    );

    part_type_size(
        _types.trail,
        0.32 * _scale,
        0.58 * _scale,
        -0.008,
        0.055
    );

    part_type_life(
        _types.trail,
        22,
        38
    );

    part_particles_create(
        _system,
        _x,
        _y,
        _types.trail,
        2
    );

    // Brighter concentrated inner wake.
    if (((GAME_TICK + real(_projectile.id)) mod 2) == 0)
    {
        part_type_direction(
            _types.trail,
            _direction + 174,
            _direction + 186,
            0,
            0
        );

        part_type_speed(
            _types.trail,
            0.2,
            0.65,
            -0.01,
            0.02
        );

        part_type_size(
            _types.trail,
            0.16 * _scale,
            0.3 * _scale,
            -0.005,
            0.025
        );

        part_type_life(
            _types.trail,
            16,
            28
        );

        part_particles_create(
            _system,
            _x,
            _y,
            _types.trail,
            1
        );
    }

    return true;
}