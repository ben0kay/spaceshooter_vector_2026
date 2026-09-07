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
        resource: { type: ResourceType.ENERGY, cost: 0.25 },

        delivery: {
            type: AttackDelivery.BEAM,
            scale: 1,

            damage: {
                amount: 5,
                type: DamageType.ENERGY,
                effect: DamageEffect.NONE
            },

            beam: {
                shape: AttackAreaShape.CAPSULE,
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

                    style: {
                        segment_length: 85,
                        width_start: 1,
                        width_end: 1,
                        pulse_amount: 0.13,
                        pulse_speed: 0.42,
                        pulse_secondary_amount: 0.07,
                        pulse_secondary_speed: 0.17,
                        wobble_amount: 0.22,
                        wobble_speed: 0.34,
                        wobble_step: 0.91,

                        glow_width: 4.4,
                        glow_alpha: 0.13,
                        body_width: 2.25,
                        body_alpha: 0.46,
                        inner_width: 0.88,
                        inner_alpha: 0.92,
                        hot_width: 0.28,
                        hot_alpha: 1,

                        body_colour_mix: 1,
                        inner_colour_mix: 1,
                        hot_colour_mix: 1,

                        band_spacing: 145,
                        band_length: 24,
                        band_speed: 5,
                        band_width: 0.22,
                        band_alpha: 0.22,

                        source_flare_radius: 0.9,
                        source_flare_alpha: 1
                    },

                    impact: {
                        overlap_ratio: 0.35,
                        overlap_max: 120,
                        solid_overlap: 18,
                        radius_scale: 1.4,
                        particles_enabled: true,
                        particle_interval: 2
                    },

                    draw_script: sc_attack_area_beam_layered_draw,
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
