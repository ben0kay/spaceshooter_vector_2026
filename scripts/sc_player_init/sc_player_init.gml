/// @description Initializes a player instance from a registered ship key.
function sc_player_init(_player, _ship_key)
{
    if (!instance_exists(_player) || !is_string(_ship_key))
    {
        show_debug_message("PLAYER INITIALIZATION ERROR - invalid player or ship key");
        return false;
    }

    if (!variable_struct_exists(global.data.ships, _ship_key))
    {
        show_debug_message("PLAYER INITIALIZATION ERROR - unknown ship key: " + _ship_key);
        return false;
    }

    var _definition = variable_struct_get(global.data.ships, _ship_key);
    var _cache = sc_ship_visual_cache_get(_ship_key);

    _player.ship = {
        key: _ship_key,
        identity: variable_clone(_definition.identity),
        collision: variable_clone(_definition.collision),
        visual: variable_clone(_definition.visual),
        hardpoints: variable_clone(_definition.hardpoints),
        loadout: variable_clone(_definition.starting_loadout),
        stats: undefined
    };

    _player.ship.visual.runtime = {
        cache: _cache,
        thrust_power: 0,
        thrust_phase: irandom(359),
        shield_hit_alpha: 0
    };

    if (!sc_player_stats_init(_player, _definition.stats_base))
        return false;

    var _final = _player.ship.stats.final;

    _player.defence = {
        shield: {
            current: _final.shield_max,
            maximum: _final.shield_max,
            recharge_delay_remaining: 0
        },

        armour: {
            current: _final.armour_max,
            maximum: _final.armour_max
        },

        hull: {
            current: _final.hull_max,
            maximum: _final.hull_max
        }
    };

    _player.movement = {
        input_x: 0,
        input_y: 0,
        velocity_x: 0,
        velocity_y: 0,
        speed: 0,
        moving: false
    };

    _player.aim = {
        world_x: _player.x,
        world_y: _player.y,
        direction: 0
    };

    _player.draw_angle = 0;
    _player.initialized = true;

    global.player_id = _player;
    global.PlayerState = PlayerState.ACTIVE;

    show_debug_message("PLAYER INITIALIZED - " + _player.ship.identity.name);
    return true;
}

/// @description Returns one of four visual damage stages.
function sc_player_damage_visual_stage(_current, _maximum)
{
    var _ratio = _maximum > 0 ? _current / _maximum : 0;

    if (_ratio > 0.75) return 0;
    if (_ratio > 0.5) return 1;
    if (_ratio > 0.25) return 2;
    return 3;
}

/// @description Updates player-only visual animation.
function sc_player_visual_update(_player)
{
    var _runtime = _player.ship.visual.runtime;

    if (!is_struct(_runtime.cache))
        return;

    var _speed_max = _player.ship.stats.final.speed_max;
    var _target = _speed_max > 0 ? clamp(_player.movement.speed / _speed_max, 0, 1) : 0;

    _runtime.thrust_power = lerp(
        _runtime.thrust_power,
        _target,
        _target > _runtime.thrust_power ? 0.2 : 0.12
    );

    _runtime.shield_hit_alpha = max(
        0,
        _runtime.shield_hit_alpha - 0.06
    );
}

/// @description Applies one damage packet to the player's layered defence.
function sc_player_damage(_player, _packet)
{
    if (global.PlayerState == PlayerState.DESTROYED) return false;

    var _defence = _player.defence;
    var _result = sc_damage_resolve(
        _packet,
        _defence.shield.current,
        _defence.armour.current,
        _defence.hull.current
    );

    _defence.shield.current = _result.shield;
    _defence.armour.current = _result.armour;
    _defence.hull.current = _result.hull;

    if (_result.dealt.total <= 0) return false;

    _defence.shield.recharge_delay_remaining = _player.ship.stats.final.shield_recharge_delay;

    if (_result.dealt.shield > 0)
        _player.ship.visual.runtime.shield_hit_alpha = 1;

    if (_defence.hull.current <= 0)
    {
        _defence.hull.current = 0;
        _player.movement.velocity_x = 0;
        _player.movement.velocity_y = 0;
        global.PlayerState = PlayerState.DESTROYED;

        // Insert player destruction effect and audio here.
    }

    // _result.effect is ready for the upcoming timed-effect manager.
    return true;
}

/// @description Updates player shield recharge after its damage delay expires.
function sc_player_defence_update(_player)
{
    var _shield = _player.defence.shield;
    if (_shield.current >= _shield.maximum) return;

    if (_shield.recharge_delay_remaining > 0)
    {
        _shield.recharge_delay_remaining--;
        return;
    }

    _shield.current = min(
        _shield.maximum,
        _shield.current + _player.ship.stats.final.shield_recharge_rate
    );
}