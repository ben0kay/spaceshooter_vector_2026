/*
SHARD MINING BEAM

A sustained industrial thermal beam activated with MMB.
It deals weak combat damage but extracts asteroid resources efficiently.
*/

/// @description Registers the Shard's sustained mining beam.
function sc_weapon_register_shard_mining_beam()
{
    var _palette = {
        glow: make_colour_rgb(120, 65, 0),
        accent: make_colour_rgb(225, 125, 10),
        energy: make_colour_rgb(255, 195, 35),
        core: make_colour_rgb(255, 248, 185)
    };

    return sc_weapon_register({
        identity: { key: "weapon_shard_mining_beam", name: "Shard Mining Beam" },
        resource: { type: ResourceType.ENERGY, cost: 0.35 },

        delivery: {
            type: AttackDelivery.BEAM,
            scale: 1,

            damage: {
                amount: 1.25,
                type: DamageType.THERMAL,
                effect: DamageEffect.NONE,

                extraction: {
				    asteroid_damage_multiplier: 4,
				    efficiency: 1.25,
				    yield_multiplier: 1.5
				}
            },

            beam: {
                shape: AttackAreaShape.CAPSULE,
                geometry: { length: 650, radius: 3.5 },

                behaviour: {
                    growth_speed: 100,
                    release_duration: 7,
                    tick_interval: 5,
                    piercing: false,
                    blocks_on_solids: true,
                    max_targets: 1
                },

                visual: {
                    palette: _palette,

                    style: {
                        segment_length: 75,
                        width_start: 0.82,
                        width_end: 1.12,
                        pulse_amount: 0.08,
                        pulse_speed: 0.38,
                        pulse_secondary_amount: 0,
                        pulse_secondary_speed: 0,
                        wobble_amount: 0.12,
                        wobble_speed: 0.29,
                        wobble_step: 0.83,

                        glow_width: 4,
                        glow_alpha: 0.13,
                        body_width: 2,
                        body_alpha: 0.5,
                        inner_width: 0.8,
                        inner_alpha: 0.95,
                        hot_width: 0.25,
                        hot_alpha: 1,

                        body_colour_mix: 0,
                        inner_colour_mix: 0,
                        hot_colour_mix: 0,

                        band_spacing: 95,
                        band_length: 14,
                        band_speed: 4,
                        band_width: 0.2,
                        band_alpha: 0.18,

                        source_flare_radius: 0.75,
                        source_flare_alpha: 0.9
                    },

                    impact: {
                        overlap_ratio: 0.3,
                        overlap_max: 110,
                        solid_overlap: 12,
                        radius_scale: 1.6,
                        particles_enabled: false,
                        particle_interval: 2
                    },

                    draw_script: sc_attack_area_beam_layered_draw,
                    particles_register_script: sc_shard_mining_beam_particles_register,
                    particle_script: sc_shard_mining_beam_particles_emit
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

        audio: { sound: noone, volume: 0.4, pitch_range: 0.04 }
    });
}

/// @description Registers visible mining sparks and soft contact motes.
function sc_shard_mining_beam_particles_register()
{
    var _spark = sc_particles_type_create();
    var _mote = sc_particles_type_create();

    if (!part_type_exists(_spark) || !part_type_exists(_mote))
    {
        show_debug_message("MINING BEAM PARTICLE ERROR - type creation failed");
        return false;
    }


    // ==================================================
    // ELONGATED CUTTING SPARK
    // ==================================================
    part_type_sprite(
        _spark,
        s_particle_trail_white_beam,
        false,
        false,
        false
    );

    part_type_size(_spark, 0.06, 0.12, -0.004, 0.015);
    part_type_scale(_spark, 1, 0.45);
    part_type_colour3(
        _spark,
        make_colour_rgb(255, 255, 220),
        make_colour_rgb(255, 195, 35),
        make_colour_rgb(130, 70, 0)
    );

    part_type_alpha3(_spark, 1, 0.8, 0);
    part_type_speed(_spark, 1.4, 4, -0.08, 0);
    part_type_direction(_spark, 0, 359, 0, 0);
    part_type_orientation(_spark, -8, 8, 0, 4, true);
    part_type_life(_spark, 10, 18);
    part_type_blend(_spark, true);


    // ==================================================
    // SOFT CONTACT MOTE
    // ==================================================
    part_type_sprite(
        _mote,
        s_blur,
        false,
        false,
        false
    );

    part_type_size(_mote, 0.11, 0.2, 0.005, 0.025);
    part_type_colour3(
        _mote,
        make_colour_rgb(255, 245, 170),
        make_colour_rgb(255, 170, 25),
        make_colour_rgb(120, 60, 0)
    );

    part_type_alpha3(_mote, 0.85, 0.52, 0);
    part_type_speed(_mote, 0.3, 1.3, -0.025, 0);
    part_type_direction(_mote, 0, 359, 0, 0);
    part_type_life(_mote, 14, 25);
    part_type_blend(_mote, true);

    return sc_particles_group_register("beam_shard_mining", {
        spark: _spark,
        mote: _mote
    });
}

/// @description Emits visible material-coloured particles at the mining beam's visual endpoint.
function sc_shard_mining_beam_particles_emit(_area, _data)
{
    var _runtime = _data.runtime;
    if (!_runtime.impact_active) return false;

    var _particles = sc_particles_group_get("beam_shard_mining");
    if (!is_struct(_particles)) return false;

    var _distance = _runtime.visual_length;
    var _x = _area.x + lengthdir_x(_distance, _data.direction);
    var _y = _area.y + lengthdir_y(_distance, _data.direction);
    var _direction = _data.direction + 180 + random_range(-70, 70);
    var _asteroid = collision_circle(_x, _y, 14, o_asteroid, false, true);

    var _core = make_colour_rgb(255, 255, 220);
    var _colour = make_colour_rgb(255, 195, 35);
    var _glow = make_colour_rgb(130, 70, 0);

    if (instance_exists(_asteroid))
    {
        var _item = variable_struct_get(
            global.data.items,
            _asteroid.asteroid.item_key
        );

        _colour = _item.visual.colour;
        _glow = _item.visual.glow;
    }

    part_type_colour3(_particles.spark, _core, _colour, _glow);
    part_type_colour3(_particles.mote, _core, _colour, _glow);

    part_type_direction(
        _particles.spark,
        _direction - 22,
        _direction + 22,
        0, 0
    );

    part_type_direction(
        _particles.mote,
        _direction - 55,
        _direction + 55,
        0, 0
    );

    part_particles_create(
        global.particles.impact_system,
        _x, _y,
        _particles.spark,
        irandom_range(1, 2)
    );

    if (((GAME_TICK + real(_area.id)) mod 2) == 0)
    {
        part_particles_create(
            global.particles.impact_system,
            _x, _y,
            _particles.mote,
            1
        );
    }

    return true;
}
