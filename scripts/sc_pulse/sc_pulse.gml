/// @description Registers the Shard's reusable pulse weapon.
function sc_weapon_register_shard_pulse()
{
    return sc_weapon_register({
        identity: { key: "weapon_shard_pulse", name: "Shard Pulse" },
		
		resource: { type: ResourceType.ENERGY, cost: 2 },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_shard_pulse",

            projectile: {
                scale: 1,
                speed: 19,
                life: 150
            },

            damage: {
                amount: 8,
                type: DamageType.ENERGY,
                effect: DamageEffect.NONE
            },

            guidance: {
                homing: 0
            }
        },

        shot: {
            pattern: ShotPattern.SINGLE,
            amount: 1,
            angle_total: 0
        },

        firing: {
            mount_mode: WeaponMountMode.HARDPOINT,
            interval: 8,
            recoil: 6,
            muzzle_flash_duration: 8
        },

        audio: {
            sound: noone,
            volume: 0.3,
            pitch_range: 0.06
        }
    });
}

/// @description Registers the reusable animated aqua pulse visual template.
function sc_projectile_register_shard_pulse()
{
    var _palette = variable_struct_get(global.data.ships, "ship_shard").visual.palette;

    return sc_projectile_register({
        identity: { key: "projectile_shard_pulse", name: "Shard Pulse" },
        projectile_class: ProjectileClass.REGULAR,
        collision: { radius: 5 },

        visual: {
            radius: 5,
            length: 21,
            palette: _palette,
            draw_script: sc_projectile_shard_pulse_draw,
            impact_script: sc_projectile_shard_pulse_impact,
            particles_register_script: sc_projectile_shard_pulse_particles_register,

            bake: {
                canvas_size: 96,
                frames: 6,
                frame_speed: 2
            }
        }
    });
}

/// @description Registers the Shard pulse's aqua impact particles.
function sc_projectile_shard_pulse_particles_register()
{
    var _palette = variable_struct_get(global.data.ships, "ship_shard").visual.palette;

    return sc_particles_projectile_impact_register("impact_shard_pulse", _palette, {
        scale: 1.1,
        spark_amount: 7,
        fragment_amount: 3,
        spark_spread: 55,
        speed_min: 2.5,
        speed_max: 5
    });
}

/// @description Emits one scaled Shard aqua pulse impact.
function sc_projectile_shard_pulse_impact(_x, _y, _direction, _target, _scale)
{
    return sc_particles_projectile_impact_emit("impact_shard_pulse", _x, _y, _direction, _scale);
}

/// @description Draws one animated Shard aqua pulse frame for startup baking.
function sc_projectile_shard_pulse_draw(_x, _y, _angle, _visual, _frame, _frame_count)
{
    var _p = _visual.palette;
    var _radius = _visual.radius;
    var _length = _visual.length;
    var _phase = (_frame / _frame_count) * pi * 2;
    var _pulse = 0.88 + sin(_phase) * 0.12;

    var _front_x = _x + lengthdir_x(_radius * 1.2, _angle);
    var _front_y = _y + lengthdir_y(_radius * 1.2, _angle);
    var _tail_x = _x - lengthdir_x(_length, _angle);
    var _tail_y = _y - lengthdir_y(_length, _angle);
    var _wing_x = _x - lengthdir_x(_length * 0.32, _angle);
    var _wing_y = _y - lengthdir_y(_length * 0.32, _angle);
    var _glow_width = _radius * 1.9 * _pulse;
    var _energy_width = _radius * 1.05 * _pulse;

    draw_set_alpha(0.22);
    draw_set_colour(_p.glow);
    draw_triangle(
        _front_x, _front_y,
        _tail_x + lengthdir_x(-_glow_width, _angle + 90), _tail_y + lengthdir_y(-_glow_width, _angle + 90),
        _tail_x + lengthdir_x(_glow_width, _angle + 90), _tail_y + lengthdir_y(_glow_width, _angle + 90),
        false
    );

    draw_set_alpha(0.7);
    draw_set_colour(_p.energy);
    draw_triangle(
        _front_x, _front_y,
        _wing_x + lengthdir_x(-_energy_width, _angle + 90), _wing_y + lengthdir_y(-_energy_width, _angle + 90),
        _tail_x, _tail_y,
        false
    );
    draw_triangle(
        _front_x, _front_y,
        _tail_x, _tail_y,
        _wing_x + lengthdir_x(_energy_width, _angle + 90), _wing_y + lengthdir_y(_energy_width, _angle + 90),
        false
    );

    draw_set_alpha(1);
    draw_set_colour(_p.core);
    draw_line_width(_tail_x, _tail_y, _front_x, _front_y, max(2, _radius * 0.55));
    draw_circle(_x, _y, _radius * 0.62 * _pulse, false);

    draw_set_colour(c_white);
    draw_circle(_front_x, _front_y, max(1, _radius * 0.28), false);
    draw_set_alpha(1);
}