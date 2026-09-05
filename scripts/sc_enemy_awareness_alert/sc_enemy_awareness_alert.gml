/// @description Begins investigating one unconfirmed world position.
function sc_enemy_investigate_begin(_enemy, _x, _y, _duration)
{
    var _data = _enemy.enemy;
    if (_data.state == EnemyState.DEAD || _data.state == EnemyState.STUNNED) return false;

    sc_enemy_attack_cancel(_enemy);

    _data.target_id = noone;
    _data.awareness.last_known_x = _x;
    _data.awareness.last_known_y = _y;
    _data.awareness.memory_until = GAME_TICK + max(1, round(_duration));
    _data.awareness.arrived = false;
    _data.awareness.search_until = 0;
    _data.state = EnemyState.INVESTIGATING;
    return true;
}

/// @description Explicitly ignores one unconfirmed threat position.
function sc_enemy_awareness_ignore(_enemy, _x, _y, _duration_override)
{
    return false;
}

/// @description Uses this ship's controller to investigate an unconfirmed position.
function sc_enemy_awareness_investigate(_enemy, _x, _y, _duration_override)
{
    var _controller = _enemy.enemy.awareness_controller;
    var _duration = _duration_override > 0 ? _duration_override : _controller.duration;

    return sc_enemy_investigate_begin(_enemy, _x, _y, _duration);
}

/// @description Passes an unseen player attack into this ship's awareness callback.
function sc_enemy_awareness_damage_try(_enemy, _packet)
{
    var _data = _enemy.enemy;
    var _source = _packet.source;

    if (_source.faction != Faction.PLAYER
    || !instance_exists(_source.owner_id))
        return false;

    var _attacker = _source.owner_id;
    var _distance_sq = sc_point_distance_sq(_enemy.x, _enemy.y, _attacker.x, _attacker.y);

    _data.awareness.last_known_x = _attacker.x;
    _data.awareness.last_known_y = _attacker.y;

    if (_data.state != EnemyState.IDLE
    || _distance_sq <= _data.stats.final.range.detection_sq)
        return false;

    return _data.awareness_controller.unseen_damage_script(
        _enemy,
        _attacker.x,
        _attacker.y,
        0
    );
}

/// @description Passes allied threat information into this ship's awareness callback.
function sc_enemy_alert_receive(_enemy, _x, _y)
{
    if (!_enemy.initialized || _enemy.enemy.state != EnemyState.IDLE) return false;

    var _data = _enemy.enemy;

    return _data.awareness_controller.alert_receive_script(
        _enemy,
        _x,
        _y,
        _data.doctrine.alert.memory_duration
    );
}

/// @description Creates one clean faction-coloured communication pulse.
function sc_enemy_alert_pulse_create(_enemy)
{
    var _data = _enemy.enemy;
    var _palette = _data.visual.palette;
    var _radius = clamp(_data.visual.radius * 4, 180, 320);

    return sc_shockwave_create(
        _enemy.x, _enemy.y, _enemy.layer,
        {
            radius_scale: 1,
            expansion_response: 0.28,
            fade_speed: 0.075,
            thickness: 2,
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
        _radius
    );
}

/// @description Attempts one doctrine-controlled alert and wakes nearby faction allies.
function sc_enemy_alert_try(_enemy, _enabled)
{
    var _data = _enemy.enemy;
    if (!_enabled || _data.state == EnemyState.DEAD || !instance_exists(global.player_id)) return false;

    var _config = _data.doctrine.alert;
    var _runtime = _data.alert;

    if (_runtime.attempts >= _config.max_attempts
    || GAME_TICK < _runtime.next_attempt_tick)
        return false;

    _runtime.attempts++;
    _runtime.next_attempt_tick = GAME_TICK + max(0, round(_config.cooldown));

    if (random(1) >= clamp(_config.chance, 0, 1))
        return false;

    var _range = _data.stats.final.range.alert_share;
    if (_range <= 0) return false;
	
	if (instance_exists(_data.target_id))
		{
		    _data.awareness.last_known_x = _data.target_id.x;
		    _data.awareness.last_known_y = _data.target_id.y;
		}
		else
		{
		    _data.awareness.last_known_x = global.player_id.x;
		    _data.awareness.last_known_y = global.player_id.y;
		}

    var _list = ds_list_create();
    var _alerted = 0;

    collision_circle_list(
        _enemy.x, _enemy.y, _range,
        o_enemy, false, true, _list, false
    );

    for (var _i = 0; _i < ds_list_size(_list); _i++)
    {
        var _ally = _list[| _i];

        if (_ally == _enemy
        || !_ally.initialized
        || _ally.enemy.identity.faction != _data.identity.faction)
            continue;

        if (sc_enemy_alert_receive(_ally, _data.awareness.last_known_x, _data.awareness.last_known_y))
            _alerted++;
    }

    ds_list_destroy(_list);

    if (_alerted <= 0)
        return false;

    sc_enemy_alert_pulse_create(_enemy);
    return true;
}