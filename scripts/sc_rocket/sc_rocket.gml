/*
SHARD ROCKET

Slot 4 test weapon.
The rocket body is baked once during startup.
Its circular attack area and explosion visual are created only when it detonates.
*/

/// @description Registers the reusable baked Shard rocket template.
function sc_projectile_register_shard_rocket()
{
    var _palette = variable_struct_get(global.data.ships, "ship_shard").visual.palette;

    return sc_projectile_register({
        identity: { key: "projectile_shard_rocket", name: "Shard Rocket" },
        projectile_class: ProjectileClass.HEAVY,
        movement: { speed: 12 },
        collision: { radius: 7 },
        life: { maximum: 180 },

        detonation: {
            area: {
                shape: AttackAreaShape.CIRCLE,
                geometry: { radius: 82 },

                behaviour: {
                    duration: 18,
                    tick_interval: 0,
                    hit_once: true,
                    max_targets: 0
                },

                visual: {
                    palette: _palette,
                    draw_script: sc_attack_area_shard_rocket_explosion_draw
                }
            }
        },

        visual: {
            radius: 7,
            length: 25,
            palette: _palette,
            draw_script: sc_projectile_shard_rocket_draw,
            impact_script: sc_projectile_shard_rocket_impact,
            particles_register_script: sc_projectile_shard_rocket_particles_register,

            bake: {
                canvas_size: 96,
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

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_shard_rocket",

            projectile: {
                scale: 1,
                speed_multiplier: 1
            },

            damage: {
                amount: 4,
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
                scale: 1,

                damage: {
                    amount: 18,
                    type: DamageType.EXPLOSIVE,
                    effect: DamageEffect.NONE
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
            interval: 42,
            recoil: 8,
            muzzle_flash_duration: 8
        },

        audio: {
            sound: noone,
            volume: 0.55,
            pitch_range: 0.05
        }
    });
}

/// @description Registers large aqua rocket impact particles.
function sc_projectile_shard_rocket_particles_register()
{
    var _palette = variable_struct_get(global.data.ships, "ship_shard").visual.palette;

    return sc_particles_projectile_impact_register("impact_shard_rocket", _palette, {
        scale: 2,
        spark_amount: 14,
        fragment_amount: 8,
        spark_spread: 180,
        speed_min: 3,
        speed_max: 7
    });
}

/// @description Emits the detached rocket impact particles.
function sc_projectile_shard_rocket_impact(_x, _y, _direction, _target)
{
    return sc_particles_projectile_impact_emit("impact_shard_rocket", _x, _y, _direction);
}

/// @description Draws one animated rocket frame for startup baking.
function sc_projectile_shard_rocket_draw(_x, _y, _angle, _visual, _frame, _frame_count)
{
    var _p = _visual.palette;
    var _radius = _visual.radius;
    var _length = _visual.length;
    var _phase = (_frame / _frame_count) * pi * 2;
    var _flame = 0.82 + sin(_phase) * 0.18;
    var _nose_x = _x + lengthdir_x(_length * 0.55, _angle);
    var _nose_y = _y + lengthdir_y(_length * 0.55, _angle);
    var _rear_x = _x - lengthdir_x(_length * 0.45, _angle);
    var _rear_y = _y - lengthdir_y(_length * 0.45, _angle);
    var _flame_x = _rear_x - lengthdir_x(_length * 0.5 * _flame, _angle);
    var _flame_y = _rear_y - lengthdir_y(_length * 0.5 * _flame, _angle);

    draw_set_alpha(0.28);
    draw_set_colour(_p.glow);
    draw_triangle(
        _rear_x + lengthdir_x(-_radius * 1.35, _angle + 90),
        _rear_y + lengthdir_y(-_radius * 1.35, _angle + 90),
        _flame_x, _flame_y,
        _rear_x + lengthdir_x(_radius * 1.35, _angle + 90),
        _rear_y + lengthdir_y(_radius * 1.35, _angle + 90),
        false
    );

    draw_set_alpha(0.9);
    draw_set_colour(_p.energy);
    draw_triangle(
        _rear_x + lengthdir_x(-_radius * 0.55, _angle + 90),
        _rear_y + lengthdir_y(-_radius * 0.55, _angle + 90),
        _flame_x, _flame_y,
        _rear_x + lengthdir_x(_radius * 0.55, _angle + 90),
        _rear_y + lengthdir_y(_radius * 0.55, _angle + 90),
        false
    );

    draw_set_alpha(1);
    draw_set_colour(_p.hull_dark);
    draw_triangle(
        _nose_x, _nose_y,
        _rear_x + lengthdir_x(-_radius, _angle + 90),
        _rear_y + lengthdir_y(-_radius, _angle + 90),
        _rear_x + lengthdir_x(_radius, _angle + 90),
        _rear_y + lengthdir_y(_radius, _angle + 90),
        false
    );

    draw_set_colour(_p.metal);
    draw_line_width(_rear_x, _rear_y, _nose_x, _nose_y, 2);

    draw_set_colour(_p.accent);
    draw_circle(_x, _y, _radius * 0.48, false);

    draw_set_colour(_p.core);
    draw_circle(_nose_x, _nose_y, max(1, _radius * 0.25), false);
    draw_set_alpha(1);
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