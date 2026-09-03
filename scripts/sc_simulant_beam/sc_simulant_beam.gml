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
                    draw_script: sc_attack_area_simulant_thin_beam_draw,
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

/// @description Draws a thin unstable violet Simulant beam.
function sc_attack_area_simulant_thin_beam_draw(_area, _data)
{
    var _p = _data.visual.palette;
    var _length = _data.geometry.length;
    var _alpha = _data.runtime.release_alpha;
    var _pulse = 1 + sin(GAME_TICK * 0.47) * 0.11 + sin(GAME_TICK * 0.19) * 0.05;
    var _width = _data.geometry.radius * _pulse;
    var _segments = max(2, ceil(_length / 110));
    var _previous_x = _area.x;
    var _previous_y = _area.y;

    gpu_set_blendmode(bm_add);

    for (var _i = 1; _i <= _segments; _i++)
    {
        var _progress = _i / _segments;
        var _distance = _length * _progress;
        var _wobble = sin(GAME_TICK * 0.42 + _i * 0.83) * _width * 0.16 * sin(_progress * pi);
        var _current_x = _area.x + lengthdir_x(_distance, _data.direction) + lengthdir_x(_wobble, _data.direction + 90);
        var _current_y = _area.y + lengthdir_y(_distance, _data.direction) + lengthdir_y(_wobble, _data.direction + 90);

        draw_set_alpha(_alpha * 0.14);
        draw_set_colour(_p.glow);
        draw_line_width(_previous_x, _previous_y, _current_x, _current_y, _width * 4);

        draw_set_alpha(_alpha * 0.5);
        draw_set_colour(_p.accent);
        draw_line_width(_previous_x, _previous_y, _current_x, _current_y, _width * 2.1);

        draw_set_alpha(_alpha * 0.94);
        draw_set_colour(_p.energy);
        draw_line_width(_previous_x, _previous_y, _current_x, _current_y, max(2, _width * 0.85));

        draw_set_alpha(_alpha);
        draw_set_colour(_p.core);
        draw_line_width(_previous_x, _previous_y, _current_x, _current_y, max(1, _width * 0.28));

        _previous_x = _current_x;
        _previous_y = _current_y;
    }

    draw_set_alpha(_alpha * 0.25);
    draw_set_colour(_p.glow);
    draw_circle(_area.x, _area.y, _width * 3.2, false);

    draw_set_alpha(_alpha);
    draw_set_colour(_p.core);
    draw_circle(_area.x, _area.y, _width * 0.8, false);
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