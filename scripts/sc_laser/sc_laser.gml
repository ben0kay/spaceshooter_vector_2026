/*
SHARD LASER

One sustained centre-mounted capsule beam.
It rapidly extends while LMB is held, remains attached to its mount,
applies damage on registered tick intervals and releases into a short fade.
*/

/// @description Registers the Shard's sustained aqua laser.
function sc_weapon_register_shard_laser()
{
    var _palette = variable_struct_get(global.data.ships, "ship_shard").visual.palette;

    return sc_weapon_register({
        identity: { key: "weapon_shard_laser", name: "Shard Laser" },

        delivery: {
            type: AttackDelivery.BEAM,
            scale: 1,

            damage: {
                amount: 5,
                type: DamageType.ENERGY,
                effect: DamageEffect.NONE
            },

            beam: {
                geometry: { length: 1100, radius: 8 },

                behaviour: {
                    growth_speed: 145,
                    release_duration: 7,
                    tick_interval: 6,
                    piercing: false,
                    blocks_on_solids: true,
                    max_targets: 1
                },

                visual: {
                    palette: _palette,
                    draw_script: sc_attack_area_shard_laser_draw,
                    particles_register_script: sc_shard_laser_particles_register,
                    particle_script: sc_shard_laser_particles_emit
                }
            }
        },

        shot: { pattern: ShotPattern.SINGLE, amount: 1, angle_total: 0 },

        firing: {
            mount_mode: WeaponMountMode.CENTRE,
            centre_forward: 1.62,
            interval: 12,
            recoil: 0,
            muzzle_flash_duration: 0
        },

        audio: { sound: noone, volume: 0.5, pitch_range: 0.03 }
    });
}

/// @description Registers bright detached aqua embers for the Shard laser.
function sc_shard_laser_particles_register()
{
    var _p = variable_struct_get(global.data.ships, "ship_shard").visual.palette;
    var _ember = sc_particles_type_create();

    if (!part_type_exists(_ember))
    {
        show_debug_message("SHARD LASER PARTICLE ERROR - type creation failed");
        return false;
    }

    part_type_sprite(_ember, s_blur, false, false, false);
    part_type_size(_ember, 0.055, 0.12, -0.002, 0.018);
    part_type_colour3(_ember, _p.core, _p.energy, _p.glow);
    part_type_alpha3(_ember, 1, 0.72, 0);
    part_type_speed(_ember, 0.6, 1.8, -0.025, 0.12);
    part_type_direction(_ember, 0, 359, 0, 0);
    part_type_life(_ember, 24, 42);
    part_type_blend(_ember, true);

    return sc_particles_group_register("beam_shard_laser", {
        ember: _ember
    });
}

/// @description Spews visible energy embers from random points along the active beam.
function sc_shard_laser_particles_emit(_area, _data)
{
    var _particles = sc_particles_group_get("beam_shard_laser");
    if (!is_struct(_particles)) return;

    var _length = _data.geometry.length;
    if (_length < 40) return;

    var _distance = random_range(24, _length);
    var _side_direction = choose(-1, 1);
    var _side_offset = random_range(_data.geometry.radius * 0.3, _data.geometry.radius);
    var _x = _area.x
        + lengthdir_x(_distance, _data.direction)
        + lengthdir_x(_side_offset * _side_direction, _data.direction + 90);

    var _y = _area.y
        + lengthdir_y(_distance, _data.direction)
        + lengthdir_y(_side_offset * _side_direction, _data.direction + 90);

    var _ember_direction = _data.direction + 90 * _side_direction + random_range(-32, 32);

    part_type_direction(
        _particles.ember,
        _ember_direction - 10,
        _ember_direction + 10,
        0, 0
    );

    part_particles_create(
        global.particles.impact_system,
        _x, _y,
        _particles.ember,
        irandom_range(2, 3)
    );
}

/// @description Draws the extending, pulsing and visually unstable Shard laser.
function sc_attack_area_shard_laser_draw(_area, _data)
{
    var _p = _data.visual.palette;
    var _geometry = _data.geometry;
    var _runtime = _data.runtime;
    var _length = _geometry.length;
    var _alpha = _runtime.release_alpha;
    var _pulse = 1 + sin(GAME_TICK * 0.42) * 0.13 + sin(GAME_TICK * 0.17) * 0.07;
    var _width = _geometry.radius * _pulse;
    var _segments = max(2, ceil(_length / 85));
    var _previous_x = _area.x;
    var _previous_y = _area.y;

    gpu_set_blendmode(bm_add);

    for (var _i = 1; _i <= _segments; _i++)
    {
        var _progress = _i / _segments;
        var _distance = _length * _progress;
        var _wobble = sin(GAME_TICK * 0.34 + _i * 0.91) * _width * 0.22 * sin(_progress * pi);
        var _current_x = _area.x
            + lengthdir_x(_distance, _data.direction)
            + lengthdir_x(_wobble, _data.direction + 90);

        var _current_y = _area.y
            + lengthdir_y(_distance, _data.direction)
            + lengthdir_y(_wobble, _data.direction + 90);

        draw_set_alpha(_alpha * 0.13);
        draw_set_colour(_p.glow);
        draw_line_width(_previous_x, _previous_y, _current_x, _current_y, _width * 4.4);

        draw_set_alpha(_alpha * 0.46);
        draw_set_colour(_p.energy);
        draw_line_width(_previous_x, _previous_y, _current_x, _current_y, _width * 2.25);

        draw_set_alpha(_alpha * 0.92);
        draw_set_colour(_p.core);
        draw_line_width(_previous_x, _previous_y, _current_x, _current_y, max(3, _width * 0.88));

        draw_set_alpha(_alpha);
        draw_set_colour(c_white);
        draw_line_width(_previous_x, _previous_y, _current_x, _current_y, max(1, _width * 0.28));

        _previous_x = _current_x;
        _previous_y = _current_y;
    }

    draw_set_alpha(_alpha * 0.3);
    draw_set_colour(_p.glow);
    draw_circle(_area.x, _area.y, _width * 3.4, false);

    draw_set_alpha(_alpha);
    draw_set_colour(_p.core);
    draw_circle(_area.x, _area.y, _width * 0.9, false);
}