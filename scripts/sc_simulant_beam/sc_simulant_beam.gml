/*
SIMULANT THIN BEAM

Reusable sustained Simulant beam weapon.
Uses the generic beam and capsule-damage pipeline.
Enemy definitions control which hardpoints use it and how long it remains active.
*/

/// @description Registers the reusable thin Simulant beam weapon.
function sc_weapon_register_simulant_thin_beam()
{
    var _palette = sc_faction_palette_get(Faction.SIMULANT);

    return sc_weapon_register({
        identity: { key: "weapon_simulant_thin_beam", name: "Simulant Thin Beam" },

        delivery: {
            type: AttackDelivery.BEAM,
            scale: 1,

            damage: {
                amount: 2.5,
                type: DamageType.ENERGY,
                effect: DamageEffect.NONE
            },

            beam: {
                shape: AttackAreaShape.CAPSULE,
                geometry: { length: 1250, radius: 5 },

                behaviour: {
                    growth_speed: 120,
                    release_duration: 10,
                    tick_interval: 6,
                    piercing: false,
                    blocks_on_solids: true,
                    max_targets: 1
                },

                visual: {
                    palette: _palette,

                    style: {
                        segment_length: 110,
                        width_start: 0.92,
                        width_end: 1.08,
                        pulse_amount: 0.11,
                        pulse_speed: 0.47,
                        pulse_secondary_amount: 0.05,
                        pulse_secondary_speed: 0.19,
                        wobble_amount: 0.16,
                        wobble_speed: 0.42,
                        wobble_step: 0.83,

                        glow_width: 4,
                        glow_alpha: 0.14,
                        body_width: 2.1,
                        body_alpha: 0.5,
                        inner_width: 0.85,
                        inner_alpha: 0.94,
                        hot_width: 0.28,
                        hot_alpha: 1,

                        body_colour_mix: 0,
                        inner_colour_mix: 0,
                        hot_colour_mix: 0,

                        band_spacing: 180,
                        band_length: 18,
                        band_speed: 7,
                        band_width: 0.18,
                        band_alpha: 0.28,

                        source_flare_radius: 0.8,
                        source_flare_alpha: 1
                    },

                    impact: {
                        overlap_ratio: 0.3,
                        overlap_max: 90,
                        solid_overlap: 14,
                        radius_scale: 1.45,
                        particles_enabled: true,
                        particle_interval: 3
                    },

                    draw_script: sc_attack_area_beam_layered_draw,
                    particles_register_script: sc_simulant_thin_beam_particles_register,
                    particle_script: sc_simulant_thin_beam_particles_emit
                }
            }
        },

        audio: { sound: noone, volume: 0.65, pitch_range: 0.03 }
    });
}

/// @description Registers detached violet embers for the thin Simulant beam.
function sc_simulant_thin_beam_particles_register()
{
    var _p = sc_faction_palette_get(Faction.SIMULANT);
    var _ember = sc_particles_type_create();

    if (!part_type_exists(_ember))
    {
        show_debug_message("SIMULANT BEAM PARTICLE ERROR - type creation failed");
        return false;
    }

    part_type_sprite(_ember, s_blur, false, false, false);
    part_type_size(_ember, 0.04, 0.085, -0.002, 0.012);
    part_type_colour3(_ember, _p.core, _p.energy, _p.glow);
    part_type_alpha3(_ember, 0.9, 0.58, 0);
    part_type_speed(_ember, 0.45, 1.35, -0.02, 0.08);
    part_type_direction(_ember, 0, 359, 0, 0);
    part_type_life(_ember, 18, 32);
    part_type_blend(_ember, true);

    return sc_particles_group_register("beam_simulant_thin", { ember: _ember });
}

/// @description Emits violet embers from random points along an active Simulant beam.
function sc_simulant_thin_beam_particles_emit(_area, _data)
{
    var _particles = sc_particles_group_get("beam_simulant_thin");
    if (!is_struct(_particles)) return;

    var _length = _data.geometry.length;
    if (_length < 60 || (GAME_TICK mod 2) != 0) return;

    var _distance = random_range(30, _length);
    var _side_sign = choose(-1, 1);
    var _side_offset = random_range(_data.geometry.radius * 0.3, _data.geometry.radius);
    var _x = _area.x + lengthdir_x(_distance, _data.direction) + lengthdir_x(_side_offset * _side_sign, _data.direction + 90);
    var _y = _area.y + lengthdir_y(_distance, _data.direction) + lengthdir_y(_side_offset * _side_sign, _data.direction + 90);
    var _ember_direction = _data.direction + 90 * _side_sign + random_range(-25, 25);

    part_type_direction(_particles.ember, _ember_direction - 9, _ember_direction + 9, 0, 0);
    part_particles_create(global.particles.impact_system, _x, _y, _particles.ember, irandom_range(1, 2));
}

/// @description Draws the Dreadwing's thin central beam emitter.
function sc_enemy_simulant_thin_beam_emitter_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;

    draw_set_alpha(_alpha);

    sc_visual_circle(_x, _y, _radius, _angle, 0, 0, 0.13, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, 0, 0, 0.13, _p.metal, true);
    sc_visual_circle(_x, _y, _radius, _angle, 0, 0, 0.085, _p.hull_mid, false);

    sc_visual_quad(_x, _y, _radius, _angle, -0.02, -0.07, 0.19, -0.045, 0.19, 0.045, -0.02, 0.07, _p.hull_light);
    sc_visual_line(_x, _y, _radius, _angle, 0.01, 0, 0.24, 0, 6, _p.void);
    sc_visual_line(_x, _y, _radius, _angle, 0.04, 0, 0.24, 0, 2, _p.energy);

    sc_visual_circle(_x, _y, _radius, _angle, 0.24, 0, 0.06, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, 0.24, 0, 0.06, _p.accent, true);
    sc_visual_circle(_x, _y, _radius, _angle, 0.24, 0, 0.025, _p.core, false);

    draw_set_alpha(1);
}

/// @description Registers the Voidlance's fixed sustained siege beam.
function sc_weapon_register_simulant_super_beam()
{
    var _palette = sc_faction_palette_get(Faction.SIMULANT);

    return sc_weapon_register({
        identity: {
            key: "weapon_simulant_super_beam",
            name: "Simulant Super Beam"
        },

        delivery: {
            type: AttackDelivery.BEAM,
            scale: 1,

            damage: {
                amount: 7,
                type: DamageType.ENERGY,
                effect: DamageEffect.DISRUPTION,
                effect_chance: 0.12
            },

            beam: {
                shape: AttackAreaShape.CAPSULE,

                geometry: {
                    length: 2400,
                    radius: 5
                },

                behaviour: {
                    growth_speed: 85,
                    release_duration: 18,
                    tick_interval: 6,
                    piercing: false,
                    blocks_on_solids: true,
                    max_targets: 1
                },

                visual: {
                    palette: _palette,

                    style: {
					    segment_length: 130,
					    width_start: 1.05,
					    width_end: 0.82,

					    pulse_amount: 0.13,
					    pulse_speed: 0.34,
					    pulse_secondary_amount: 0.06,
					    pulse_secondary_speed: 0.13,

					    wobble_amount: 0.12,
					    wobble_speed: 0.31,
					    wobble_step: 0.68,

					    glow_width: 7,
					    glow_alpha: 0.2,
					    body_width: 3.2,
					    body_alpha: 0.72,
					    inner_width: 1.35,
					    inner_alpha: 0.98,
					    hot_width: 0.42,
					    hot_alpha: 1,

					    body_colour_mix: 0,
					    inner_colour_mix: 0,
					    hot_colour_mix: 0,

					    band_spacing: 145,
					    band_length: 24,
					    band_speed: 10,
					    band_width: 0.22,
					    band_alpha: 0.42,

					    source_flare_radius: 1.05,
					    source_flare_alpha: 1
					},

                    impact: {
                        overlap_ratio: 0.3,
                        overlap_max: 120,
                        solid_overlap: 18,
                        radius_scale: 1.7,
                        particles_enabled: true,
                        particle_interval: 2
                    },

                    draw_script: sc_attack_area_beam_layered_draw,

                    // The normal beam registers this shared particle group first.
                    particle_script: sc_simulant_thin_beam_particles_emit
                }
            }
        },

        audio: {
            sound: noone,
            volume: 0.9,
            pitch_range: 0.015
        }
    });
}

/// @description Draws the Voidlance's complete cannon charge over the baked ship.
function sc_enemy_sim_voidlance_beam_telegraph_draw(
    _enemy,
    _attack,
    _transform,
    _progress,
    _palette,
    _config
)
{
    var _radius = _enemy.enemy.visual.radius;
    var _charge = _progress * _progress * (3 - 2 * _progress);
    var _pulse = 0.82 + sin(GAME_TICK * lerp(0.12, 0.62, _charge)) * lerp(0.08, 0.18, _charge);
    var _direction = _transform.direction;

    // The muzzle transform lets this remain correct during camera shake.
    var _rear_distance = _radius * 1.28;
    var _rear_x = _transform.x + lengthdir_x(-_rear_distance, _direction);
    var _rear_y = _transform.y + lengthdir_y(-_rear_distance, _direction);
    var _mid_x = _transform.x + lengthdir_x(-_radius * 0.55, _direction);
    var _mid_y = _transform.y + lengthdir_y(-_radius * 0.55, _direction);
    var _width = lerp(3, 13, _charge) * _pulse;
    var _ball_radius = lerp(_radius * 0.025, _radius * 0.12, _charge) * _pulse;

    gpu_set_blendmode(bm_add);

    // The full embedded cannon progressively illuminates.
    draw_set_colour(_palette.glow);
    draw_set_alpha(lerp(0.04, 0.3, _charge));
    draw_line_width(_rear_x, _rear_y, _transform.x, _transform.y, _width * 3.2);

    draw_set_colour(_palette.accent);
    draw_set_alpha(lerp(0.1, 0.72, _charge));
    draw_line_width(_rear_x, _rear_y, _transform.x, _transform.y, _width * 1.45);

    draw_set_colour(_palette.energy);
    draw_set_alpha(lerp(0.18, 0.95, _charge));
    draw_line_width(_mid_x, _mid_y, _transform.x, _transform.y, _width);

    draw_set_colour(_palette.core);
    draw_set_alpha(_charge);
    draw_line_width(_mid_x, _mid_y, _transform.x, _transform.y, max(1, _width * 0.25));

    // A concentrated energy sphere forms at the muzzle.
    draw_set_colour(_palette.glow);
    draw_set_alpha(lerp(0.1, 0.38, _charge));
    draw_circle(_transform.x, _transform.y, _ball_radius * 3.2, false);

    draw_set_colour(_palette.energy);
    draw_set_alpha(lerp(0.3, 0.95, _charge));
    draw_circle(_transform.x, _transform.y, _ball_radius, false);

    draw_set_colour(_palette.core);
    draw_set_alpha(_charge);
    draw_circle(_transform.x, _transform.y, max(2, _ball_radius * 0.3), false);

    // Energy packets move from the reactor toward the muzzle.
    for (var _i = 0; _i < 5; _i++)
    {
        var _travel = frac(_charge * 2.8 + _i / 5);
        var _packet_x = lerp(_rear_x, _transform.x, _travel);
        var _packet_y = lerp(_rear_y, _transform.y, _travel);
        var _packet_radius = lerp(2, 5, _charge);

        draw_set_colour(_palette.core);
        draw_set_alpha(_charge * (0.45 + _travel * 0.55));
        draw_circle(_packet_x, _packet_y, _packet_radius, false);
    }

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}