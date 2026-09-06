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
                    efficiency: 1.25,
					yield_multiplier: 1.5
                }
            },

            beam: {
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
                    draw_script: sc_attack_area_shard_mining_beam_draw,
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

/// @description Registers small yellow mining-contact sparks.
function sc_shard_mining_beam_particles_register()
{
    var _spark = sc_particles_type_create();

    if (!part_type_exists(_spark))
    {
        show_debug_message("MINING BEAM PARTICLE ERROR - type creation failed");
        return false;
    }

    part_type_sprite(_spark, s_blur, false, false, false);
    part_type_size(_spark, 0.035, 0.075, -0.003, 0.01);
    part_type_colour3(
        _spark,
        make_colour_rgb(255, 250, 190),
        make_colour_rgb(255, 190, 30),
        make_colour_rgb(135, 70, 0)
    );

    part_type_alpha3(_spark, 1, 0.72, 0);
    part_type_speed(_spark, 0.8, 2.4, -0.05, 0);
    part_type_direction(_spark, 0, 359, 0, 0);
    part_type_life(_spark, 10, 20);
    part_type_blend(_spark, true);

    return sc_particles_group_register("beam_shard_mining", {
        spark: _spark
    });
}

/// @description Emits material-coloured mining sparks where the beam contacts something.
function sc_shard_mining_beam_particles_emit(_area, _data)
{
    var _runtime = _data.runtime;

    if (_runtime.hit_length >= _runtime.growth_length - 0.5)
        return false;

    if (((GAME_TICK + real(_area.id)) mod 2) != 0)
        return false;

    var _particles = sc_particles_group_get("beam_shard_mining");
    if (!is_struct(_particles)) return false;

    var _distance = _data.geometry.length;
    var _x = _area.x + lengthdir_x(_distance, _data.direction);
    var _y = _area.y + lengthdir_y(_distance, _data.direction);
    var _direction = _data.direction + 180 + random_range(-65, 65);
    var _asteroid = collision_circle(_x, _y, 14, o_asteroid, false, true);

    if (instance_exists(_asteroid))
    {
        var _item = variable_struct_get(
            global.data.items,
            _asteroid.asteroid.item_key
        );

        part_type_colour3(
            _particles.spark,
            c_white,
            _item.visual.colour,
            _item.visual.glow
        );
    }
    else
    {
        part_type_colour3(
            _particles.spark,
            make_colour_rgb(255, 250, 190),
            make_colour_rgb(255, 190, 30),
            make_colour_rgb(135, 70, 0)
        );
    }

    part_type_direction(
        _particles.spark,
        _direction - 18,
        _direction + 18,
        0,
        0
    );

    part_particles_create(
        global.particles.impact_system,
        _x,
        _y,
        _particles.spark,
        irandom_range(1, 2)
    );

    return true;
}

/// @description Draws a thin unstable yellow mining beam and flickering contact point.
function sc_attack_area_shard_mining_beam_draw(_area, _data)
{
    var _p = _data.visual.palette;
    var _runtime = _data.runtime;
    var _length = _data.geometry.length;
    var _alpha = _runtime.release_alpha;
    var _pulse = 1 + sin(GAME_TICK * 0.38) * 0.08;
    var _width = _data.geometry.radius * _pulse;
    var _segments = max(2, ceil(_length / 75));
    var _previous_x = _area.x;
    var _previous_y = _area.y;

    gpu_set_blendmode(bm_add);

    for (var _i = 1; _i <= _segments; _i++)
    {
        var _progress = _i / _segments;
        var _distance = _length * _progress;

        var _wobble =
            sin(GAME_TICK * 0.29 + _i * 0.83)
            * _width
            * 0.12
            * sin(_progress * pi);

        var _current_x =
            _area.x
            + lengthdir_x(_distance, _data.direction)
            + lengthdir_x(_wobble, _data.direction + 90);

        var _current_y =
            _area.y
            + lengthdir_y(_distance, _data.direction)
            + lengthdir_y(_wobble, _data.direction + 90);

        draw_set_alpha(_alpha * 0.13);
        draw_set_colour(_p.glow);
        draw_line_width(_previous_x, _previous_y, _current_x, _current_y, _width * 4);

        draw_set_alpha(_alpha * 0.5);
        draw_set_colour(_p.accent);
        draw_line_width(_previous_x, _previous_y, _current_x, _current_y, _width * 2);

        draw_set_alpha(_alpha * 0.95);
        draw_set_colour(_p.energy);
        draw_line_width(_previous_x, _previous_y, _current_x, _current_y, max(2, _width * 0.8));

        draw_set_alpha(_alpha);
        draw_set_colour(_p.core);
        draw_line_width(_previous_x, _previous_y, _current_x, _current_y, max(1, _width * 0.25));

        _previous_x = _current_x;
        _previous_y = _current_y;
    }

    var _contact = _runtime.hit_length < _runtime.growth_length - 0.5;

    if (_contact)
    {
        var _impact_x = _area.x + lengthdir_x(_length, _data.direction);
        var _impact_y = _area.y + lengthdir_y(_length, _data.direction);
        var _flicker = 1 + sin(GAME_TICK * 0.73 + real(_area.id)) * 0.2;
        var _impact_radius = _width * 1.8 * _flicker;

        draw_set_alpha(_alpha * 0.2);
        draw_set_colour(_p.glow);
        draw_circle(_impact_x, _impact_y, _impact_radius * 2.4, false);

        draw_set_alpha(_alpha * 0.8);
        draw_set_colour(_p.energy);
        draw_circle(_impact_x, _impact_y, _impact_radius, false);

        draw_set_alpha(_alpha);
        draw_set_colour(_p.core);
        draw_line_width(
            _impact_x + lengthdir_x(_impact_radius, GAME_TICK * 7),
            _impact_y + lengthdir_y(_impact_radius, GAME_TICK * 7),
            _impact_x + lengthdir_x(_impact_radius, GAME_TICK * 7 + 180),
            _impact_y + lengthdir_y(_impact_radius, GAME_TICK * 7 + 180),
            1
        );
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
    gpu_set_blendmode(bm_normal);
}