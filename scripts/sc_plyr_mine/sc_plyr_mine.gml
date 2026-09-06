/// @description Registers the Shard proximity detonation mine weapon.
function sc_weapon_register_shard_mine()
{
    var _palette = variable_struct_get(
        global.data.ships,
        "ship_shard"
    ).visual.palette;

    return sc_weapon_register({
        identity: {
            key: "weapon_shard_mine",
            name: "Detonation Mine"
        },

        resource: {
            type: ResourceType.EXPLOSIVES,
            cost: 1
        },

        delivery: {
            type: AttackDelivery.DEPLOYABLE,
            create_script: sc_player_mine_create,

            mine: {
                arming_duration: 45,
				life_duration: 900,
                trigger_radius: 180,
                trigger_check_interval: 4,
                countdown_duration: 150,

                bleep: {
                    sound: noone,
                    volume: 0.6,
                    pitch_start: 0.85,
                    pitch_end: 1.35,
                    interval_start: 30,
                    interval_end: 5
                },

                pulse: {
                    interval: 75,
                    radius_min: 30,
                    radius_max: 180,
                    arc_amount: 2,
                    arc_length: 82,
                    rotation_speed: 0.22,
                    thickness: 2,
                    alpha: 0.36,
                    segments: 12,
                    inner_offset: 9,
                    inner_angle_offset: 18
                },

                visual: {
                    radius: 18,
                    palette: _palette
                }
            },

            explosion: {
                scale: 1,

                damage: {
                    amount: 65,
                    type: DamageType.EXPLOSIVE,
                    effect: DamageEffect.STAGGER,
                    knockback_force: 7
                },

                area: {
                    shape: AttackAreaShape.CIRCLE,

                    geometry: {
                        radius: 230
                    },

                    behaviour: {
                        duration: 22,
                        tick_interval: 0,
                        hit_once: true,
                        max_targets: 0,
                        falloff_minimum: 0.18,
                        falloff_exponent: 1.35
                    },

                    visual: {
                        palette: _palette,
                        draw_script: sc_attack_area_shard_mine_explosion_draw,

                        shockwave: {
                            radius_scale: 1.35,
                            expansion_response: 0.17,
                            fade_speed: 0.04,
                            thickness: 6,
                            colour: _palette.energy,

                            particles_enabled: true,
                            particle_interval: 1,
                            particle_min_radius: 10,

                            smoke_enabled: true,
                            smoke_amount_max: 6,
                            smoke_colour: make_colour_rgb(78, 94, 98),

                            fragments_enabled: true,
                            fragment_chance: 0.6,
                            fragment_colour: _palette.energy
                        }
                    }
                }
            },

            visual: {
                palette: _palette,
                particles_register_script: sc_player_mine_particles_register
            }
        },

        shot: {
            pattern: ShotPattern.SINGLE,
            amount: 1,
            angle_total: 0
        },

        firing: {
            mount_mode: WeaponMountMode.CENTRE,
            centre_forward: 0,
            interval: 45,
            recoil: 0,
            muzzle_flash_duration: 0
        },

        audio: {
            sound: noone,
            volume: 0,
            pitch_range: 0
        }
    });
}

/// @description Creates one armed deployable mine at the owner's position.
function sc_player_mine_create(_delivery, _source, _x, _y, _direction, _layer)
{
    var _detonation_layer = layer_get_id("Effects_Front");

    if (_detonation_layer == -1)
        _detonation_layer = _layer;

    return instance_create_layer(
        _x,
        _y,
        _layer,
        o_player_mine,
        {
            mine_create: {
                source: _source,
                direction: _direction,
                detonation_layer: _detonation_layer,
                definition: variable_clone(_delivery.mine),
                explosion: variable_clone(_delivery.explosion)
            }
        }
    );
}

/// @description Initializes one player proximity mine.
function sc_player_mine_init(_mine, _create)
{
    var _definition = _create.definition;

    _mine.mine = {
        source: _create.source,
        direction: _create.direction,
        detonation_layer: _create.detonation_layer,

        arming_duration: max(
            1,
            round(_definition.arming_duration)
        ),

        life_duration: max(
            1,
            round(_definition.life_duration)
        ),

        trigger_radius: max(
            1,
            _definition.trigger_radius
        ),

        trigger_check_interval: max(
            1,
            round(_definition.trigger_check_interval)
        ),

        countdown_duration: max(
            1,
            round(_definition.countdown_duration)
        ),

        bleep: variable_clone(_definition.bleep),
        pulse: variable_clone(_definition.pulse),
        visual: variable_clone(_definition.visual),
        explosion: _create.explosion,

        runtime: {
            armed: false,
            triggered: false,

            arming_remaining: max(
                1,
                round(_definition.arming_duration)
            ),

            life_remaining: max(
                1,
                round(_definition.life_duration)
            ),

            countdown_remaining: max(
                1,
                round(_definition.countdown_duration)
            ),

            next_trigger_tick: GAME_TICK,
            next_bleep_tick: GAME_TICK,
            flash: 0,

            pulse_offset: real(_mine.id)
                mod max(
                    1,
                    round(_definition.pulse.interval)
                )
        }
    };

    _mine.depth = 420;
    _mine.initialized = true;
    return true;
}

/// @description Finds an enemy inside one armed mine's trigger radius.
function sc_player_mine_target_find(_mine)
{
    var _data = _mine.mine;

    var _target = collision_circle(
        _mine.x,
        _mine.y,
        _data.trigger_radius,
        o_enemy,
        false,
        true
    );

    if (!instance_exists(_target)
    || !_target.initialized
    || _target.enemy.state == EnemyState.DEAD)
        return noone;

    return _target;
}

/// @description Starts the mine's accelerating detonation countdown.
function sc_player_mine_trigger(_mine)
{
    var _runtime = _mine.mine.runtime;
    if (_runtime.triggered) return false;

    _runtime.triggered = true;
    _runtime.countdown_remaining = _mine.mine.countdown_duration;
    _runtime.next_bleep_tick = GAME_TICK;
    _runtime.flash = 1;
    return true;
}

/// @description Plays or displays one increasingly urgent mine countdown bleep.
function sc_player_mine_bleep(_mine)
{
    var _data = _mine.mine;
    var _runtime = _data.runtime;
    var _bleep = _data.bleep;

    var _progress = 1
        - _runtime.countdown_remaining
        / _data.countdown_duration;

    var _interval = lerp(
        _bleep.interval_start,
        _bleep.interval_end,
        _progress
    );

    if (_bleep.sound != noone)
    {
        var _audio = audio_play_sound(
            _bleep.sound,
            0,
            false
        );

        audio_sound_gain(
            _audio,
            _bleep.volume,
            0
        );

        audio_sound_pitch(
            _audio,
            lerp(
                _bleep.pitch_start,
                _bleep.pitch_end,
                _progress
            )
        );
    }

    _runtime.flash = 1;
    _runtime.next_bleep_tick = GAME_TICK
        + max(1, round(_interval));

    return true;
}

/// @description Detonates one mine through the shared area and shockwave systems.
function sc_player_mine_detonate(_mine)
{
    var _data = _mine.mine;
    var _explosion = _data.explosion;

    sc_attack_area_create(
        _explosion.area,
        _data.source,
        _explosion.damage,
        _mine.x,
        _mine.y,
        _data.direction,
        _data.detonation_layer,
        _explosion.scale
    );

    sc_player_mine_particles_emit(
        _mine.x,
        _mine.y,
        _explosion.scale
    );

    instance_destroy(_mine);
    return true;
}

/// @description Updates one mine through arming, detection, expiry and detonation.
function sc_player_mine_update(_mine)
{
    var _data = _mine.mine;
    var _runtime = _data.runtime;

    _runtime.flash = max(
        0,
        _runtime.flash - 0.08
    );

    if (!_runtime.armed)
    {
        _runtime.arming_remaining--;

        if (_runtime.arming_remaining <= 0)
        {
            _runtime.arming_remaining = 0;
            _runtime.armed = true;
            _runtime.flash = 1;
        }

        return;
    }

    if (!_runtime.triggered)
    {
        _runtime.life_remaining--;

        if (_runtime.life_remaining <= 0)
        {
            _runtime.life_remaining = 0;
            sc_player_mine_trigger(_mine);
        }
        else if (GAME_TICK >= _runtime.next_trigger_tick)
        {
            _runtime.next_trigger_tick = GAME_TICK
                + _data.trigger_check_interval;

            if (instance_exists(
                sc_player_mine_target_find(_mine)
            ))
                sc_player_mine_trigger(_mine);
        }

        if (!_runtime.triggered)
            return;
    }

    _runtime.countdown_remaining--;

    if (GAME_TICK >= _runtime.next_bleep_tick)
        sc_player_mine_bleep(_mine);

    if (_runtime.countdown_remaining <= 0)
        sc_player_mine_detonate(_mine);
}

/// @description Draws one armed aqua proximity mine and its detection pulses.
function sc_player_mine_draw(_mine)
{
    var _data = _mine.mine;
    var _runtime = _data.runtime;
    var _visual = _data.visual;
    var _palette = _visual.palette;
    var _radius = _visual.radius;
    var _angle = _data.direction
        + GAME_TICK * 0.18;

    if (_runtime.armed)
    {
        var _interval = _runtime.triggered
            ? max(18, round(_data.pulse.interval * 0.45))
            : _data.pulse.interval;

        var _pulse_tick = (
            GAME_TICK
            + _runtime.pulse_offset
        ) mod _interval;

        sc_visual_effect_arc_pulse(
            _mine.x,
            _mine.y,
            _data.pulse,
            _pulse_tick / _interval,
            _palette,
            _angle
        );
    }

    gpu_set_blendmode(bm_add);

    draw_set_alpha(
        0.12
        + _runtime.flash * 0.3
    );

    draw_set_colour(_palette.glow);
    draw_circle(
        _mine.x,
        _mine.y,
        _radius * (
            1.45
            + _runtime.flash * 0.25
        ),
        false
    );

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);

    sc_visual_quad(
        _mine.x, _mine.y,
        _radius, _angle,
        -0.7, -0.38,
         0.7, -0.38,
         0.7,  0.38,
        -0.7,  0.38,
        _palette.outline
    );

    sc_visual_quad(
        _mine.x, _mine.y,
        _radius, _angle,
        -0.58, -0.28,
         0.58, -0.28,
         0.58,  0.28,
        -0.58,  0.28,
        _palette.hull_mid
    );

    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_triangle(
            _mine.x, _mine.y,
            _radius, _angle,
            -0.38, 0.24 * _side,
             0,    0.82 * _side,
             0.38, 0.24 * _side,
            _palette.hull_light,
            false
        );
    }

    sc_visual_circle(
        _mine.x,
        _mine.y,
        _radius,
        _angle,
        0, 0,
        0.3,
        _runtime.triggered
            ? c_white
            : _palette.energy,
        false
    );

    sc_visual_circle(
        _mine.x,
        _mine.y,
        _radius,
        _angle,
        0, 0,
        0.13 + _runtime.flash * 0.08,
        _palette.core,
        false
    );

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Registers grey smoke and aqua flame for mine detonations.
function sc_player_mine_particles_register()
{
    var _smoke = sc_particles_type_create();
    var _flame = sc_particles_type_create();

    if (!part_type_exists(_smoke)
    || !part_type_exists(_flame))
    {
        show_debug_message(
            "PLAYER MINE PARTICLE ERROR - type creation failed"
        );

        return false;
    }

    part_type_sprite(
        _smoke,
        s_particle_firesmoke_trail_color,
        false,
        false,
        false
    );

    part_type_size(
        _smoke,
        0.3,
        0.58,
        0.025,
        0.05
    );

    part_type_colour3(
        _smoke,
        make_colour_rgb(150, 175, 178),
        make_colour_rgb(72, 92, 96),
        make_colour_rgb(28, 38, 42)
    );

    part_type_alpha3(
        _smoke,
        0.72,
        0.42,
        0
    );

    part_type_speed(
        _smoke,
        1,
        3.5,
        -0.055,
        0.08
    );

    part_type_direction(
        _smoke,
        0,
        359,
        0,
        0
    );

    part_type_orientation(
        _smoke,
        0,
        359,
        0,
        3,
        false
    );

    part_type_life(
        _smoke,
        28,
        48
    );

    part_type_blend(
        _smoke,
        false
    );

    part_type_sprite(
        _flame,
        s_blur,
        false,
        false,
        false
    );

    part_type_size(
        _flame,
        0.18,
        0.36,
        -0.009,
        0.025
    );

    part_type_colour3(
        _flame,
        c_white,
        make_colour_rgb(80, 235, 255),
        make_colour_rgb(10, 90, 120)
    );

    part_type_alpha3(
        _flame,
        1,
        0.7,
        0
    );

    part_type_speed(
        _flame,
        2,
        6,
        -0.12,
        0
    );

    part_type_direction(
        _flame,
        0,
        359,
        0,
        0
    );

    part_type_life(
        _flame,
        10,
        20
    );

    part_type_blend(
        _flame,
        true
    );

    return sc_particles_group_register(
        "player_mine",
        {
            smoke: _smoke,
            flame: _flame
        }
    );
}

/// @description Emits the mine's grey smoke plumes and aqua flame burst.
function sc_player_mine_particles_emit(_x, _y, _scale = 1)
{
    if (!sc_optimization_circle_visible(
        _x,
        _y,
        280 * _scale,
        96
    ))
        return true;

    var _types = sc_particles_group_get("player_mine");
    if (!is_struct(_types)) return false;

    part_type_size(
        _types.smoke,
        0.3 * _scale,
        0.58 * _scale,
        0.025 * _scale,
        0.05
    );

    part_type_speed(
        _types.smoke,
        1 * _scale,
        3.5 * _scale,
        -0.055,
        0.08
    );

    part_particles_create(
        global.particles.impact_system,
        _x,
        _y,
        _types.smoke,
        18
    );

    part_type_size(
        _types.flame,
        0.18 * _scale,
        0.36 * _scale,
        -0.009 * _scale,
        0.025
    );

    part_type_speed(
        _types.flame,
        2 * _scale,
        6 * _scale,
        -0.12,
        0
    );

    part_particles_create(
        global.particles.impact_system,
        _x,
        _y,
        _types.flame,
        14
    );

    return true;
}

/// @description Draws one heavy aqua-grey mine explosion.
function sc_attack_area_shard_mine_explosion_draw(_area, _data)
{
    var _palette = _data.visual.palette;
    var _life_ratio = _data.runtime.life
        / _data.behaviour.duration;

    var _progress = 1 - _life_ratio;
    var _radius = _data.geometry.radius
        * sin(_progress * pi * 0.72);

    var _alpha = clamp(
        _life_ratio * 1.5,
        0,
        1
    );

    gpu_set_blendmode(bm_add);

    draw_set_alpha(_alpha * 0.16);
    draw_set_colour(_palette.glow);
    draw_circle(
        _area.x,
        _area.y,
        _radius,
        false
    );

    draw_set_alpha(_alpha * 0.52);
    draw_set_colour(_palette.energy);
    draw_circle(
        _area.x,
        _area.y,
        _radius * 0.7,
        false
    );

    draw_set_alpha(_alpha);
    draw_set_colour(_palette.core);
    draw_circle(
        _area.x,
        _area.y,
        max(4, _radius * 0.22),
        false
    );

    draw_set_alpha(_alpha * 0.9);
    draw_set_colour(c_white);
    draw_circle(
        _area.x,
        _area.y,
        _radius,
        true
    );

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}