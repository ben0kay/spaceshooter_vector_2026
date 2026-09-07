/*
FACTION DEVICES

Stationary damageable faction equipment.
Behaviour is composed from optional controllers.
*/

/// @description Registers one faction-device definition.
function sc_faction_device_register(_data)
{
    var _key = _data.identity.key;

    if (variable_struct_exists(global.data.devices,_key))
    {
        show_debug_message("FACTION DEVICE REGISTRATION ERROR - duplicate key: " + _key);
        return false;
    }

    variable_struct_set(global.data.devices,_key,_data);
    return true;
}

/// @description Returns one registered faction-device definition.
function sc_faction_device_get(_key)
{
    if (!variable_struct_exists(global.data.devices,_key))
    {
        show_debug_message("FACTION DEVICE ERROR - unknown key: " + _key);
        return undefined;
    }

    return variable_struct_get(global.data.devices,_key);
}

/// @description Registers all current faction devices.
function sc_faction_device_register_all()
{
    if (!sc_faction_device_register_corporation_alert_array()) return false;
    return true;
}

/// @description Initializes one stationary faction device.
function sc_faction_device_init(_device,_key)
{
    var _definition = sc_faction_device_get(_key);
    if (!is_struct(_definition)) return false;

    var _cache = sc_faction_device_visual_cache_get(_key);
    if (!is_struct(_cache)) return false;

        var _stats = variable_clone(_definition.stats);
    var _controllers = variable_clone(_definition.controllers);
    var _sensor_runtime = undefined;

    if (is_struct(_controllers.sensor))
    {
        _sensor_runtime = {
            previous_angle: _controllers.sensor.start_angle,
            angle: _controllers.sensor.start_angle,
            next_alert_tick: GAME_TICK,
            detected_alpha: 0,

            signal: {
                remaining: 0,
                target_x: 0,
                target_y: 0
            }
        };
    }

    _device.draw_angle = 0;
    _device.device = {
        key: _key,
        identity: variable_clone(_definition.identity),
        stats: _stats,

        defence: {
            shield: {
                current: _stats.shield_max,
                maximum: _stats.shield_max
            },

            armour: {
                current: _stats.armour_max,
                maximum: _stats.armour_max
            },

            hull: {
                current: _stats.hull_max,
                maximum: _stats.hull_max
            },

            recharge_delay_remaining: 0
        },

        collision: variable_clone(_definition.collision),
        controllers: _controllers,

        runtime: {
            destroyed: false,
            shield_hit_alpha: 0,
            sensor: _sensor_runtime,
            cache: _cache
        },

        visual: variable_clone(_definition.visual),

        attachment: {
            owner_id: noone,
            forward: 0,
            side: 0,
            angle: 0
        }
    };

    if (!sc_entity_init(
        _device,
        _device.device.identity.faction,
        sc_faction_device_damage,
        {
            radius_forward: _device.device.collision.radius,
            radius_side: _device.device.collision.radius
        },
        true
    ))
        return false;

    _device.health_bar = sc_health_bar_create(false);
    _device.health_bar.width = max(72,_device.device.visual.radius * 1.5);
    _device.initialized = true;
    return true;
}

/// @description Updates one device's shield recharge.
function sc_faction_device_defence_update(_device)
{
    var _data = _device.device;
    var _defence = _data.defence;
    var _stats = _data.stats;

    if (_defence.recharge_delay_remaining > 0)
    {
        _defence.recharge_delay_remaining--;
        return;
    }

    if (_defence.shield.current < _defence.shield.maximum)
        _defence.shield.current = min(
            _defence.shield.maximum,
            _defence.shield.current + _stats.shield_recharge_rate
        );
}

/// @description Creates a faction-coloured device alert pulse.
function sc_faction_device_alert_pulse_create(_device)
{
    var _data = _device.device;
    var _sensor = _data.controllers.sensor;
    var _palette = _data.visual.palette;

    return sc_shockwave_create(
        _device.x,
        _device.y,
        _device.layer,
        {
            radius_scale: 1,
            expansion_response: 0.24,
            fade_speed: 0.055,
            thickness: 3,
            colour: _palette.energy,

            particles_enabled: false,
            particle_interval: 1,
            particle_min_radius: 0,

            smoke_enabled: false,
            smoke_amount_max: 1,
            smoke_colour: _palette.glow,

            fragments_enabled: false,
            fragment_chance: 0,
            fragment_colour: _palette.core
        },
        _sensor.alert_pulse_radius
    );
}

/// @description Alerts nearby same-faction enemies of one detected position.
function sc_faction_device_alert_emit(_device,_target_x,_target_y)
{
    var _data = _device.device;
    var _sensor = _data.controllers.sensor;
    var _list = ds_list_create();
    var _alerted = 0;

    var _count = collision_circle_list(
        _device.x,
        _device.y,
        _sensor.alert_radius,
        o_enemy,
        false,
        true,
        _list,
        false
    );

    for (var _i = 0; _i < _count; ++_i)
    {
        var _enemy = _list[| _i];

        if (!_enemy.initialized
        || _enemy.enemy.state == EnemyState.DEAD
        || _enemy.entity.faction != _data.identity.faction)
            continue;

        if (sc_enemy_alert_receive(_enemy,_target_x,_target_y))
            _alerted++;
    }

    ds_list_destroy(_list);
    sc_faction_device_alert_pulse_create(_device);

    show_debug_message(
        "FACTION DEVICE ALERT - "
        + _data.identity.key
        + " - ALLIES "
        + string(_alerted)
    );

    return _alerted;
}

/// @description Updates one rotating sweep sensor and detects line crossings.
function sc_faction_device_sensor_update(_device)
{
    var _data = _device.device;
    var _sensor = _data.controllers.sensor;
    var _runtime = _data.runtime.sensor;

    _runtime.previous_angle = _runtime.angle;
    _runtime.angle = (_runtime.angle + _sensor.sweep_speed) mod 360;
    _runtime.detected_alpha = max(0, _runtime.detected_alpha - 0.035);
    _runtime.signal.remaining = max(0, _runtime.signal.remaining - 1);

    if (!instance_exists(global.player_id)
    || global.PlayerState == PlayerState.DESTROYED
    || GAME_TICK < _runtime.next_alert_tick
    || sc_faction_hostility_get(
        _data.identity.faction,
        Faction.PLAYER
    ) <= 0)
        return false;

    var _player = global.player_id;
    var _dx = _player.x - _device.x;
    var _dy = _player.y - _device.y;

    if (_dx * _dx + _dy * _dy > sqr(_sensor.detection_radius))
        return false;

    var _target_direction = point_direction(
        _device.x,
        _device.y,
        _player.x,
        _player.y
    );

    var _crossed = abs(angle_difference(
        _target_direction,
        _runtime.angle
    )) <= abs(_sensor.sweep_speed) + _sensor.detection_width;

    if (!_crossed) return false;

    _runtime.next_alert_tick = GAME_TICK + _sensor.alert_cooldown;
    _runtime.detected_alpha = 1;

    _runtime.signal.remaining = _sensor.signal.duration;
    _runtime.signal.target_x = _player.x;
    _runtime.signal.target_y = _player.y;

    sc_faction_device_alert_emit(
        _device,
        _player.x,
        _player.y
    );

    return true;
}

/// @description Updates one stationary faction device.
function sc_faction_device_update(_device)
{
    var _data = _device.device;
    if (_data.runtime.destroyed) return;

    sc_faction_device_defence_update(_device);

    if (is_struct(_data.controllers.sensor))
        sc_faction_device_sensor_update(_device);

    _data.runtime.shield_hit_alpha = max(
        0,
        _data.runtime.shield_hit_alpha - 0.06
    );
}

/// @description Draws one device sensor sweep, signal arcs and fading trail.
function sc_faction_device_sensor_draw(_device)
{
    var _data = _device.device;
    var _sensor = _data.controllers.sensor;
    var _runtime = _data.runtime.sensor;
    var _palette = _data.visual.palette;
    var _radius = _sensor.detection_radius;

    if (!sc_optimization_circle_visible(
        _device.x,
        _device.y,
        _radius,
        32
    ))
        return;

    gpu_set_blendmode(bm_add);

    for (var _i = _sensor.trail_lines - 1; _i >= 0; --_i)
    {
        var _amount = 1 - _i / _sensor.trail_lines;
        var _angle = _runtime.angle
            - _sensor.sweep_speed
            * _i
            * _sensor.trail_spacing;

        var _end_x = _device.x + lengthdir_x(_radius, _angle);
        var _end_y = _device.y + lengthdir_y(_radius, _angle);

        draw_set_colour(_palette.energy);
        draw_set_alpha(_sensor.trail_alpha * _amount * _amount);

        draw_line_width(
            _device.x,
            _device.y,
            _end_x,
            _end_y,
            max(1, _sensor.sweep_width * _amount)
        );
    }

    if (_runtime.detected_alpha > 0)
    {
        var _end_x = _device.x + lengthdir_x(_radius, _runtime.angle);
        var _end_y = _device.y + lengthdir_y(_radius, _runtime.angle);

        draw_set_colour(_palette.core);
        draw_set_alpha(_runtime.detected_alpha);

        draw_line_width(
            _device.x,
            _device.y,
            _end_x,
            _end_y,
            _sensor.sweep_width + 2
        );
    }

    gpu_set_blendmode(bm_normal);

    if (_runtime.signal.remaining > 0)
    {
        var _signal_progress = 1
            - _runtime.signal.remaining
            / _sensor.signal.duration;

        sc_visual_effect_signal_arcs(
            _device.x,
            _device.y,
            _runtime.signal.target_x,
            _runtime.signal.target_y,
            _sensor.signal,
            _signal_progress,
            _palette
        );
    }

    draw_set_colour(_palette.outline);
    draw_set_alpha(0.12);
    draw_circle(_device.x, _device.y, _radius, true);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws one assembled faction device.
function sc_faction_device_draw(_device)
{
    var _data = _device.device;
    var _runtime = _data.runtime;
    var _cache = _runtime.cache;
    var _palette = _data.visual.palette;

    if (is_struct(_data.controllers.sensor))
        sc_faction_device_sensor_draw(_device);

    if (sprite_exists(_cache.base))
        draw_sprite_ext(
            _cache.base,
            0,
            _device.x,
            _device.y,
            1,
            1,
            _device.draw_angle,
            c_white,
            1
        );

    if (sprite_exists(_cache.head))
    {
        var _head_angle = is_struct(_runtime.sensor)
            ? _runtime.sensor.angle
            : _device.draw_angle;

        draw_sprite_ext(
            _cache.head,
            0,
            _device.x,
            _device.y,
            1,
            1,
            _head_angle,
            c_white,
            1
        );
    }

    if (_data.defence.shield.current > 0
    && sprite_exists(_cache.shield))
    {
        var _shield_ratio = _data.defence.shield.current
            / _data.defence.shield.maximum;

        sc_visual_shield_sprite_draw(
            _cache.shield,
            _device.x,
            _device.y,
            _device.draw_angle,
            _palette,
            _shield_ratio,
            _runtime.shield_hit_alpha,
            1
        );
    }
}

/// @description Applies layered damage to one faction device.
function sc_faction_device_damage(_device,_packet,_impact = undefined)
{
    var _data = _device.device;
    if (_data.runtime.destroyed) return false;

    var _defence = _data.defence;
    var _result = sc_damage_resolve(
        _packet,
        _defence.shield.current,
        _defence.armour.current,
        _defence.hull.current
    );

    _defence.shield.current = _result.shield;
    _defence.armour.current = _result.armour;
    _defence.hull.current = _result.hull;

    if (_result.dealt.total <= 0)
        return false;

    _defence.recharge_delay_remaining = _data.stats.shield_recharge_delay;
    sc_health_bar_damage_show(_device.health_bar);

    if (_result.dealt.shield > 0)
        _data.runtime.shield_hit_alpha = 1;

    if (_defence.hull.current <= 0)
    {
        _defence.hull.current = 0;
        sc_faction_device_destroy(_device,_packet);
    }

    return _result;
}

/// @description Destroys one faction device with faction-coloured feedback.
function sc_faction_device_destroy(_device,_packet)
{
    var _data = _device.device;
    if (_data.runtime.destroyed) return false;

    _data.runtime.destroyed = true;

    sc_shockwave_create(
        _device.x,
        _device.y,
        _device.layer,
        {
            radius_scale: 1,
            expansion_response: 0.24,
            fade_speed: 0.07,
            thickness: 3,
            colour: _data.visual.palette.energy,

            particles_enabled: false,
            particle_interval: 1,
            particle_min_radius: 0,

            smoke_enabled: false,
            smoke_amount_max: 1,
            smoke_colour: _data.visual.palette.hull_dark,

            fragments_enabled: false,
            fragment_chance: 0,
            fragment_colour: _data.visual.palette.metal
        },
        _data.visual.radius * 2.5
    );

    instance_destroy(_device);
    return true;
}