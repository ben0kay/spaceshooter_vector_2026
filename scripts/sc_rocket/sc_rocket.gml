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
		projectile_type: ProjectileType.ROCKET,
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
		    trail_script: sc_projectile_shard_rocket_trail,
		    particles_register_script: sc_projectile_shard_rocket_particles_register,
			
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
                homing: 1,
                acquire_range: 720,
                turn_speed: 4,
                reacquire_interval: 12
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
    {
        return false;
    }

    var _smoke = sc_particles_type_create();

    if (!part_type_exists(_smoke))
    {
        show_debug_message(
            "SHARD ROCKET PARTICLE ERROR - smoke creation failed"
        );

        return false;
    }

    part_type_sprite(
        _smoke,
        s_particle_firesmoke_trail_color,
        false,
        false,
        false
    );

    part_type_colour2(
        _smoke,
        make_colour_rgb(145, 185, 195),
        make_colour_rgb(45, 60, 65)
    );

    part_type_alpha3(
        _smoke,
        0.48,
        0.28,
        0
    );

    part_type_speed(
        _smoke,
        0.5,
        1.4,
        -0.025,
        0
    );

    part_type_direction(
        _smoke,
        170,
        190,
        0,
        0
    );

    part_type_orientation(
        _smoke,
        0,
        359,
        0,
        2,
        false
    );

    part_type_life(
        _smoke,
        14,
        22
    );

    part_type_blend(
        _smoke,
        false
    );

    return sc_particles_group_register(
        "trail_shard_rocket",
        {
            smoke: _smoke
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

/// @description Emits a restrained smoke trail behind one Shard rocket.
function sc_projectile_shard_rocket_trail(_projectile, _data)
{
    // One particle every two Steps, staggered between instances.
    if (((GAME_TICK + real(_projectile.id)) mod 2) != 0)
        return true;

    var _types = sc_particles_group_get(
        "trail_shard_rocket"
    );

    if (!is_struct(_types))
        return false;

    var _scale = _data.scale;
    var _direction = _data.direction;
    var _rear_distance =
        _data.visual.length * 0.46 * _scale;

    var _x =
        _projectile.x
        - lengthdir_x(_rear_distance, _direction);

    var _y =
        _projectile.y
        - lengthdir_y(_rear_distance, _direction);

    var _smoke_direction =
        _direction + 180;

    part_type_direction(
        _types.smoke,
        _smoke_direction - 9,
        _smoke_direction + 9,
        0,
        0
    );

    part_type_size(
        _types.smoke,
        0.12 * _scale,
        0.19 * _scale,
        0.006 * _scale,
        0
    );

    part_particles_create(
        global.particles.system,
        _x,
        _y,
        _types.smoke,
        1
    );

    return true;
}