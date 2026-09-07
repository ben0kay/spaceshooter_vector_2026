/*
CORPORATION COMBAT BEAM

Accurate close-defence laser used by elite Corporation vessels.
Uses the shared capsule beam runtime and layered beam renderer.
*/

/// @description Registers the Corporation precision combat beam.
function sc_weapon_register_corporation_combat_beam()
{
    var _palette = sc_faction_palette_elite_get(Faction.CORPORATION);

    return sc_weapon_register({
        identity: {
            key: "weapon_corporation_combat_beam",
            name: "Corporation Precision Laser"
        },

        delivery: {
            type: AttackDelivery.BEAM,
            scale: 1,

            damage: {
                amount: 3.5,
                type: DamageType.ENERGY,
                effect: DamageEffect.NONE
            },

            beam: {
                shape: AttackAreaShape.CAPSULE,

                geometry: {
                    length: 400,
                    radius: 5
                },

                behaviour: {
                    growth_speed: 160,
                    release_duration: 8,
                    tick_interval: 5,
                    piercing: false,
                    blocks_on_solids: true,
                    max_targets: 1
                },

                visual: {
                    palette: _palette,

                    style: {
                        segment_length: 90,
                        width_start: 1.05,
                        width_end: 0.82,
                        pulse_amount: 0.08,
                        pulse_speed: 0.55,
                        pulse_secondary_amount: 0.04,
                        pulse_secondary_speed: 0.24,
                        wobble_amount: 0.06,
                        wobble_speed: 0.5,
                        wobble_step: 0.9,

                        glow_width: 4.5,
                        glow_alpha: 0.16,
                        body_width: 2.2,
                        body_alpha: 0.58,
                        inner_width: 0.9,
                        inner_alpha: 0.96,
                        hot_width: 0.3,
                        hot_alpha: 1,

                        body_colour_mix: 0,
                        inner_colour_mix: 0,
                        hot_colour_mix: 0,

                        band_spacing: 120,
                        band_length: 15,
                        band_speed: 9,
                        band_width: 0.2,
                        band_alpha: 0.35,

                        source_flare_radius: 1,
                        source_flare_alpha: 1
                    },

                    impact: {
                        overlap_ratio: 0.34,
                        overlap_max: 48,
                        solid_overlap: 10,
                        radius_scale: 1.55,
                        particles_enabled: true,
                        particle_interval: 2
                    },

                    draw_script: sc_attack_area_beam_layered_draw,
                    particles_register_script: sc_corporation_combat_beam_particles_register,
                    particle_script: sc_corporation_combat_beam_particles_emit
                }
            }
        },

        audio: {
            sound: noone,
            volume: 0.62,
            pitch_range: 0.025
        }
    });
}

/// @description Registers Corporation combat-beam contact sparks.
function sc_corporation_combat_beam_particles_register()
{
    var _p = sc_faction_palette_elite_get(Faction.CORPORATION);
    var _spark = sc_particles_type_create();

    if (!part_type_exists(_spark))
    {
        show_debug_message("CORPORATION BEAM PARTICLE ERROR - type creation failed");
        return false;
    }

    part_type_sprite(_spark,s_blur,false,false,false);
    part_type_size(_spark,0.035,0.075,-0.002,0.01);
    part_type_colour3(_spark,_p.core,_p.energy,_p.glow);
    part_type_alpha3(_spark,1,0.62,0);
    part_type_speed(_spark,0.7,2,-0.04,0);
    part_type_direction(_spark,0,359,0,0);
    part_type_life(_spark,12,24);
    part_type_blend(_spark,true);

    return sc_particles_group_register(
        "beam_corporation_combat",
        { spark: _spark }
    );
}

/// @description Emits precise blue sparks along the active combat beam.
function sc_corporation_combat_beam_particles_emit(_area,_data)
{
    var _particles = sc_particles_group_get("beam_corporation_combat");
    if (!is_struct(_particles)) return;

    var _length = _data.geometry.length;
    if (_length < 40 || (GAME_TICK mod 2) != 0) return;

    var _distance = random_range(24,_length);
    var _side = choose(-1,1);
    var _offset = random_range(0,_data.geometry.radius);
    var _x = _area.x
        + lengthdir_x(_distance,_data.direction)
        + lengthdir_x(_offset * _side,_data.direction + 90);

    var _y = _area.y
        + lengthdir_y(_distance,_data.direction)
        + lengthdir_y(_offset * _side,_data.direction + 90);

    var _direction = _data.direction + 90 * _side + random_range(-16,16);

    part_type_direction(
        _particles.spark,
        _direction - 7,
        _direction + 7,
        0,0
    );

    part_particles_create(
        global.particles.impact_system,
        _x,_y,
        _particles.spark,
        1
    );
}