/*
SHARD ROCKET

Slot 4 test weapon.
The rocket body is baked once during startup.
Its circular attack area and explosion visual are created only when it detonates.
*/

/// @description Registers the reusable baked Shard rocket visual template.
function sc_projectile_register_shard_rocket()
{
    var _palette = variable_struct_get(global.data.ships, "ship_shard").visual.palette;

    return sc_projectile_register({
        identity: { key: "projectile_shard_rocket", name: "Shard Rocket" },
		projectile_motion: ProjectileMotion.ROCKET,
        projectile_class: ProjectileClass.HEAVY,
        collision: { radius: 7 },

        detonation: {
            area: {
                shape: AttackAreaShape.CIRCLE,
                geometry: { radius: 82 },

                behaviour: {
                    duration: 18,
                    tick_interval: 0,
                    hit_once: true,
                    max_targets: 0,
                    falloff_minimum: 0.25,
                    falloff_exponent: 1
                },

                visual: {
                    palette: _palette,
                    draw_script: sc_attack_area_shard_rocket_explosion_draw,

                    shockwave: {
                        radius_scale: 1.15,
                        expansion_response: 0.2,
                        fade_speed: 0.05,
                        thickness: 4,
                        colour: _palette.energy,

                        particles_enabled: true,
                        particle_interval: 1,
                        particle_min_radius: 8,

                        smoke_enabled: true,
                        smoke_amount_max: 3,
                        smoke_colour: make_colour_rgb(55, 80, 90),

                        fragments_enabled: true,
                        fragment_chance: 0.42,
                        fragment_colour: _palette.energy
                    }
                }
            }
        },

                visual: {
            radius: 8,
            length: 34,
            palette: _palette,
            draw_script: sc_projectile_shard_rocket_draw,
            impact_script: sc_projectile_shard_rocket_impact,
            trail_script: sc_projectile_particle_trail_emit,
            particles_register_script: sc_projectile_shard_rocket_particles_register,

            particle_trail: {
                group: "trail_shard_rocket",
                interval: 2,
                amount: 1,
                rear_scale: 0.46,
                spread: 9,
                size_min: 0.12,
                size_max: 0.19,
                size_growth: 0.006,
                size_wiggle: 0
            },

            trail: {
                enabled: true,
                length: 72,
                width: 2,
                glow_width: 7,
                alpha: 0.8,
                glow_alpha: 0.18
            },

            bake: {
                canvas_size: 128,
                frames: 4,
                frame_speed: 2
            }
        }
    });
}

/// @description Registers the Shard's evenly distributed mini-rocket salvo.
function sc_weapon_register_shard_missile_salvo()
{
    return sc_weapon_register({
        identity: {
            key: "weapon_shard_missile_salvo",
            name: "Shard Micro-Missile Salvo"
        },

        // This cost is paid once for the complete volley.
        resource: {
            type: ResourceType.EXPLOSIVES,
            cost: 2
        },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_shard_rocket",

            projectile: {
                scale: 0.5,
                speed: 18,
                life: 165
            },

            damage: {
                amount: 6,
                type: DamageType.EXPLOSIVE,
                effect: DamageEffect.NONE
            },

            guidance: {
                acquire_range: 1200,
                turn_speed: 5.5,
                reacquire_interval: 12,
                lead_strength: 0.15,
                guidance_delay: 10,
                lock_angle: 220,

                // Preserve the evenly assigned target while it remains alive.
                retain_assigned_target: true,

                avoidance: {
                    strength: 0.7,
                    asteroids: 1,
                    structures: 1,
                    clearance_scale: 0.75
                }
            },

            detonation: {
                scale: 0.5,

                damage: {
                    amount: 4,
                    type: DamageType.EXPLOSIVE,
                    effect: DamageEffect.NONE,
                    knockback_force: 1
                }
            }
        },

        shot: {
            pattern: ShotPattern.RANDOM_CONE,
            amount: 6,
            angle_total: 38,
            volley_target_script: sc_weapon_volley_targets_even
        },

        firing: {
            mount_mode: WeaponMountMode.HARDPOINT,
            interval: 60,
            recoil: 4,
            muzzle_flash_duration: 6
        },

        audio: {
            sound: noone,
            volume: 0.5,
            pitch_range: 0.08
        }
    });
}

/// @description Registers the Shard's homing rocket launcher.
function sc_weapon_register_shard_rocket()
{
    return sc_weapon_register({
        identity: { key: "weapon_shard_rocket", name: "Shard Rockets" },
		
		resource: { type: ResourceType.EXPLOSIVES, cost: 1 },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_shard_rocket",

            projectile: {
                scale: 1.15,
                speed: 16,
                life: 180
            },

            damage: {
                amount: 20,
                type: DamageType.EXPLOSIVE,
                effect: DamageEffect.NONE
            },

            guidance: {
			    acquire_range: 720,
			    turn_speed: 4,
			    reacquire_interval: 12,

			    lead_strength: 0.45,
			    guidance_delay: 6,
			    lock_angle: 160,

			    avoidance: {
			        strength: 0.75,
			        asteroids: 1,
			        structures: 1,
			        clearance_scale: 1.15
			    }
			},

            detonation: {
                scale: 1.15,

                damage: {
				    amount: 18,
				    type: DamageType.EXPLOSIVE,
				    effect: DamageEffect.STAGGER,
				    knockback_force: 4
				}
            }
        },

        shot: { pattern: ShotPattern.SINGLE, amount: 1, angle_total: 0 },

        firing: {
            mount_mode: WeaponMountMode.HARDPOINT,
            interval: 32,
            recoil: 8,
            muzzle_flash_duration: 8
        },

        audio: { sound: noone, volume: 0.55, pitch_range: 0.05 }
    });
}

/// @description Registers Shard rocket impact and smoke-trail particles.
function sc_projectile_shard_rocket_particles_register()
{
    var _palette = variable_struct_get(
        global.data.ships,
        "ship_shard"
    ).visual.palette;

    if (!sc_particles_projectile_impact_register(
        "impact_shard_rocket",
        _palette,
        {
            scale: 2,
            spark_amount: 14,
            fragment_amount: 8,
            spark_spread: 180,
            speed_min: 3,
            speed_max: 7
        }
    ))
        return false;

    return sc_particles_projectile_trail_register(
        "trail_shard_rocket",
        {
            sprite: s_particle_firesmoke_trail_color,

            colour_start: make_colour_rgb(145, 185, 195),
            colour_middle: make_colour_rgb(82, 105, 112),
            colour_end: make_colour_rgb(45, 60, 65),

            alpha_start: 0.48,
            alpha_middle: 0.28,

            speed_min: 0.5,
            speed_max: 1.4,
            speed_reduce: -0.025,

            life_min: 14,
            life_max: 22,

            rotation_speed: 2,
            blend_additive: false
        }
    );
}

/// @description Emits one scaled Shard rocket impact.
function sc_projectile_shard_rocket_impact(_x, _y, _direction, _target, _scale)
{
    return sc_particles_projectile_impact_emit("impact_shard_rocket", _x, _y, _direction, _scale);
}

/// @description Draws one recognisable animated Shard rocket.
function sc_projectile_shard_rocket_draw(
    _x,
    _y,
    _angle,
    _visual,
    _frame,
    _frame_count
)
{
    var _p = _visual.palette;
    var _radius = _visual.radius;
    var _length = _visual.length;
    var _phase = (_frame / _frame_count) * pi * 2;
    var _flame = 0.82 + sin(_phase) * 0.18;

    var _nose_distance = _length * 0.55;
    var _shoulder_distance = _length * 0.22;
    var _rear_distance = -_length * 0.43;

    var _nose_x =
        _x + lengthdir_x(_nose_distance, _angle);

    var _nose_y =
        _y + lengthdir_y(_nose_distance, _angle);

    var _shoulder_x =
        _x + lengthdir_x(_shoulder_distance, _angle);

    var _shoulder_y =
        _y + lengthdir_y(_shoulder_distance, _angle);

    var _rear_x =
        _x + lengthdir_x(_rear_distance, _angle);

    var _rear_y =
        _y + lengthdir_y(_rear_distance, _angle);

    var _left_x =
        lengthdir_x(_radius * 0.7, _angle + 90);

    var _left_y =
        lengthdir_y(_radius * 0.7, _angle + 90);

    var _fin_x =
        lengthdir_x(_radius * 1.25, _angle + 90);

    var _fin_y =
        lengthdir_y(_radius * 1.25, _angle + 90);

    var _flame_x =
        _rear_x
        - lengthdir_x(_length * 0.48 * _flame, _angle);

    var _flame_y =
        _rear_y
        - lengthdir_y(_length * 0.48 * _flame, _angle);

    // Exhaust glow.
    draw_set_alpha(0.28);
    draw_set_colour(_p.glow);

    draw_triangle(
        _rear_x + _left_x,
        _rear_y + _left_y,
        _flame_x,
        _flame_y,
        _rear_x - _left_x,
        _rear_y - _left_y,
        false
    );

    draw_set_alpha(0.9);
    draw_set_colour(_p.energy);

    draw_triangle(
        _rear_x + _left_x * 0.42,
        _rear_y + _left_y * 0.42,
        _flame_x,
        _flame_y,
        _rear_x - _left_x * 0.42,
        _rear_y - _left_y * 0.42,
        false
    );

    // Rear fins.
    draw_set_alpha(1);
    draw_set_colour(_p.hull_dark);

    draw_triangle(
        _rear_x,
        _rear_y,
        _rear_x + _fin_x,
        _rear_y + _fin_y,
        _x + _left_x,
        _y + _left_y,
        false
    );

    draw_triangle(
        _rear_x,
        _rear_y,
        _rear_x - _fin_x,
        _rear_y - _fin_y,
        _x - _left_x,
        _y - _left_y,
        false
    );

    // Main cylindrical body.
    draw_set_colour(_p.metal);

    draw_triangle(
        _rear_x + _left_x,
        _rear_y + _left_y,
        _shoulder_x + _left_x,
        _shoulder_y + _left_y,
        _rear_x - _left_x,
        _rear_y - _left_y,
        false
    );

    draw_triangle(
        _rear_x - _left_x,
        _rear_y - _left_y,
        _shoulder_x + _left_x,
        _shoulder_y + _left_y,
        _shoulder_x - _left_x,
        _shoulder_y - _left_y,
        false
    );

    // Pointed nose.
    draw_set_colour(_p.hull_light);

    draw_triangle(
        _nose_x,
        _nose_y,
        _shoulder_x + _left_x,
        _shoulder_y + _left_y,
        _shoulder_x - _left_x,
        _shoulder_y - _left_y,
        false
    );

    // Dark engine housing.
    draw_set_colour(_p.void);

    draw_line_width(
        _rear_x + _left_x,
        _rear_y + _left_y,
        _rear_x - _left_x,
        _rear_y - _left_y,
        3
    );

    // Aqua body stripe.
    draw_set_colour(_p.accent);

    draw_line_width(
        _x + _left_x,
        _y + _left_y,
        _x - _left_x,
        _y - _left_y,
        2
    );

    // Bright guidance tip.
    draw_set_colour(_p.core);
    draw_circle(
        _nose_x,
        _nose_y,
        max(1, _radius * 0.24),
        false
    );

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws one expanding circular rocket explosion.
function sc_attack_area_shard_rocket_explosion_draw(_area, _data)
{
    var _p = _data.visual.palette;
    var _life_ratio = _data.runtime.life / _data.behaviour.duration;
    var _progress = 1 - _life_ratio;
    var _radius = _data.geometry.radius * sin(_progress * pi * 0.72);
    var _alpha = clamp(_life_ratio * 1.45, 0, 1);

    gpu_set_blendmode(bm_add);

    draw_set_alpha(_alpha * 0.18);
    draw_set_colour(_p.glow);
    draw_circle(_area.x, _area.y, _radius, false);

    draw_set_alpha(_alpha * 0.42);
    draw_set_colour(_p.energy);
    draw_circle(_area.x, _area.y, _radius * 0.72, false);

    draw_set_alpha(_alpha);
    draw_set_colour(_p.core);
    draw_circle(_area.x, _area.y, max(2, _radius * 0.24), false);

    draw_set_alpha(_alpha * 0.9);
    draw_set_colour(c_white);
    draw_circle(_area.x, _area.y, _radius, true);
}

/// @description Registers the Shard's large non-homing demolition rocket.
function sc_projectile_register_shard_demolition_rocket()
{
    var _palette = variable_struct_get(
        global.data.ships,
        "ship_shard"
    ).visual.palette;

    return sc_projectile_register({
        identity: {
            key: "projectile_shard_demolition_rocket",
            name: "Shard Demolition Rocket"
        },

        projectile_motion: ProjectileMotion.ROCKET,
        projectile_class: ProjectileClass.HEAVY,

        collision: {
            radius: 12
        },

        detonation: {
            area: {
                shape: AttackAreaShape.CIRCLE,

                geometry: {
                    radius: 82
                },

                behaviour: {
                    duration: 28,
                    tick_interval: 0,
                    hit_once: true,
                    max_targets: 0,
                    falloff_minimum: 0.45,
                    falloff_exponent: 0.75
                },

                visual: {
                    palette: _palette,
                    draw_script: sc_attack_area_shard_rocket_explosion_draw,

                    shockwave: {
                        radius_scale: 1.15,
                        expansion_response: 0.12,
                        fade_speed: 0.035,
                        thickness: 7,
                        colour: _palette.energy,

                        particles_enabled: true,
                        particle_interval: 1,
                        particle_min_radius: 12,

                        smoke_enabled: true,
                        smoke_amount_max: 8,
                        smoke_colour: make_colour_rgb(55, 80, 90),

                        fragments_enabled: true,
                        fragment_chance: 0.7,
                        fragment_colour: _palette.energy
                    }
                }
            }
        },

        // Reuses the standard Shard rocket drawing and particle groups.
        visual: {
            radius: 14,
            length: 52,
            palette: _palette,
            draw_script: sc_projectile_shard_rocket_draw,
            impact_script: sc_projectile_shard_rocket_impact,
            trail_script: sc_projectile_particle_trail_emit,

            particle_trail: {
                group: "trail_shard_rocket",
                interval: 1,
                amount: 2,
                rear_scale: 0.5,
                spread: 13,
                size_min: 0.18,
                size_max: 0.3,
                size_growth: 0.009,
                size_wiggle: 0
            },

            trail: {
                enabled: true,
                length: 125,
                width: 5,
                glow_width: 16,
                alpha: 0.9,
                glow_alpha: 0.25
            },

            bake: {
                canvas_size: 192,
                frames: 4,
                frame_speed: 2
            }
        }
    });
}

/// @description Registers the Shard's asteroid demolition launcher.
function sc_weapon_register_shard_demolition_rocket()
{
    return sc_weapon_register({
        identity: {
            key: "weapon_shard_demolition_rocket",
            name: "Demolition Rocket"
        },

        resource: {
            type: ResourceType.EXPLOSIVES,
            cost: 3
        },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_shard_demolition_rocket",

            projectile: {
                scale: 2.2,
                speed: 10,
                life: 300
            },

            // Direct impact can destroy the asteroid the rocket strikes.
            damage: {
                amount: 35,
                type: DamageType.EXPLOSIVE,
                effect: DamageEffect.STAGGER,

                extraction: {
                    efficiency: 0.15,
                    yield_multiplier: 1,
                    asteroid_damage_multiplier: 30
                }
            },

            // Completely unguided.
            guidance: 0,

            detonation: {
                // 82 × 7.5 produces an approximately 615-pixel radius.
                scale: 7.5,

                damage: {
                    amount: 28,
                    type: DamageType.EXPLOSIVE,
                    effect: DamageEffect.STAGGER,
                    knockback_force: 12,

                    extraction: {
                        efficiency: 0.15,
                        yield_multiplier: 1,
                        asteroid_damage_multiplier: 30
                    }
                }
            }
        },

        shot: {
            pattern: ShotPattern.SINGLE,
            amount: 1,
            angle_total: 0
        },

        firing: {
            mount_mode: WeaponMountMode.HARDPOINT,
            interval: 90,
            recoil: 16,
            muzzle_flash_duration: 12
        },

        audio: {
            sound: noone,
            volume: 0.8,
            pitch_range: 0.03
        }
    });
}