/*
SHARD MINIGUN

Contains the complete registration, baked projectile drawing and impact effects
for the Shard's rapid light-kinetic test weapon.
*/

/// @description Registers the reusable golden minigun visual template.
function sc_projectile_register_shard_minigun()
{
    return sc_projectile_register({
        identity: { key: "projectile_shard_minigun", name: "Shard Minigun Round" },
        projectile_class: ProjectileClass.LIGHT,
        collision: { radius: 3 },

        visual: {
            radius: 2,
            length: 11,

            palette: {
                core: make_colour_rgb(255, 250, 205),
                energy: make_colour_rgb(255, 190, 45),
                glow: make_colour_rgb(180, 85, 8)
            },

            draw_script: sc_projectile_shard_minigun_draw,
            impact_script: sc_projectile_shard_minigun_impact,
            particles_register_script: sc_projectile_shard_minigun_particles_register,

            bake: {
                canvas_size: 64,
                frames: 3,
                frame_speed: 2
            }
        }
    });
}

/// @description Registers the Shard's rapid alternating minigun weapon.
function sc_weapon_register_shard_minigun()
{
    return sc_weapon_register({
        identity: { key: "weapon_shard_minigun", name: "Shard Minigun" },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_shard_minigun",

            projectile: {
                scale: 1,
                speed: 30,
                life: 120
            },

            damage: {
                amount: 2,
                type: DamageType.KINETIC,
                effect: DamageEffect.NONE
            },

            guidance: {
                homing: 0
            }
        },

        shot: {
            pattern: ShotPattern.RANDOM_CONE,
            amount: 1,
            angle_total: 4
        },

        firing: {
            mount_mode: WeaponMountMode.HARDPOINT,
            interval: 2,
            recoil: 2.5,
            muzzle_flash_duration: 3
        },

        audio: {
            sound: noone,
            volume: 0.2,
            pitch_range: 0.12
        }
    });
}

/// @description Registers small golden kinetic impact particles.
function sc_projectile_shard_minigun_particles_register()
{
    var _palette = {
        core: make_colour_rgb(255, 250, 205),
        energy: make_colour_rgb(255, 190, 45),
        glow: make_colour_rgb(180, 85, 8)
    };

    return sc_particles_projectile_impact_register("impact_shard_minigun", _palette, {
        scale: 0.65,
        spark_amount: 4,
        fragment_amount: 2,
        spark_spread: 42,
        speed_min: 2,
        speed_max: 4.5
    });
}

/// @description Emits one scaled golden minigun impact.
function sc_projectile_shard_minigun_impact(_x, _y, _direction, _target, _scale)
{
    return sc_particles_projectile_impact_emit("impact_shard_minigun", _x, _y, _direction, _scale);
}

/// @description Draws one golden kinetic projectile frame for startup baking.
function sc_projectile_shard_minigun_draw(_x, _y, _angle, _visual, _frame, _frame_count)
{
    var _p = _visual.palette;
    var _radius = _visual.radius;
    var _length = _visual.length;
    var _phase = (_frame / _frame_count) * pi * 2;
    var _pulse = 0.88 + sin(_phase) * 0.12;

    var _front_x = _x + lengthdir_x(_radius * 1.4, _angle);
    var _front_y = _y + lengthdir_y(_radius * 1.4, _angle);
    var _rear_x = _x - lengthdir_x(_length, _angle);
    var _rear_y = _y - lengthdir_y(_length, _angle);
    var _middle_x = _x - lengthdir_x(_length * 0.3, _angle);
    var _middle_y = _y - lengthdir_y(_length * 0.3, _angle);
    var _half_width = _radius * _pulse;

    draw_set_alpha(0.24);
    draw_set_colour(_p.glow);
    draw_triangle(
        _front_x, _front_y,
        _rear_x + lengthdir_x(-_half_width * 1.8, _angle + 90), _rear_y + lengthdir_y(-_half_width * 1.8, _angle + 90),
        _rear_x + lengthdir_x(_half_width * 1.8, _angle + 90), _rear_y + lengthdir_y(_half_width * 1.8, _angle + 90),
        false
    );

    draw_set_alpha(0.9);
    draw_set_colour(_p.energy);
    draw_triangle(
        _front_x, _front_y,
        _middle_x + lengthdir_x(-_half_width, _angle + 90), _middle_y + lengthdir_y(-_half_width, _angle + 90),
        _rear_x, _rear_y,
        false
    );
    draw_triangle(
        _front_x, _front_y,
        _rear_x, _rear_y,
        _middle_x + lengthdir_x(_half_width, _angle + 90), _middle_y + lengthdir_y(_half_width, _angle + 90),
        false
    );

    draw_set_alpha(1);
    draw_set_colour(_p.core);
    draw_line_width(_rear_x, _rear_y, _front_x, _front_y, 2);
    draw_circle(_front_x, _front_y, max(1, _radius * 0.45), false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}