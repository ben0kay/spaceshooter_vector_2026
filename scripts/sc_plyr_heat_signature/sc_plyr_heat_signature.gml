/// @description Emits one detectable heat signature to nearby hostile enemies.
function sc_heat_signature_emit(_source, _x, _y, _strength)
{
    if (!instance_exists(_source) || _strength <= 0)
        return 0;

    var _config = GCFG.player.heat_signature;
    var _list = ds_list_create();

    var _count = collision_circle_list(
        _x, _y,
        _config.maximum_range,
        o_enemy,
        false, true,
        _list, false
    );

    var _alerted = 0;

    for (var _i = 0; _i < _count; ++_i)
    {
        var _enemy = _list[| _i];
        if (!_enemy.initialized) continue;

        var _data = _enemy.enemy;

        // Heat does not interrupt committed combat or critical responses.
        if (_data.target_id != noone
        || (_data.state != EnemyState.IDLE
        && _data.state != EnemyState.INVESTIGATING))
            continue;

        if (sc_faction_hostility_get(
            _data.identity.faction,
            _source.entity.faction
        ) <= 0)
            continue;

        var _range = min(
            _config.maximum_range,
            _data.stats.final.range.detection * _strength
        );

        if (sc_point_distance_sq(
            _enemy.x, _enemy.y,
            _x, _y
        ) > sqr(_range))
            continue;

        if (_data.awareness_controller.alert_receive_script(
            _enemy,
            _x,
            _y,
            0
        ))
            _alerted++;
    }

    ds_list_destroy(_list);
    return _alerted;
}

/// @description Periodically emits mining heat when a player beam damages an asteroid.
function sc_heat_signature_mining_try(_area, _target, _packet)
{
    if (!instance_exists(_target)
    || !is_struct(_packet.extraction)
    || _target.object_index != o_asteroid)
        return false;

    var _source = _packet.source;

    if (_source.faction != Faction.PLAYER
    || !instance_exists(_source.owner_id))
        return false;

    var _player = _source.owner_id;
    var _runtime = _player.combat.heat_signature;
    var _config = GCFG.player.heat_signature.mining;

    if (GAME_TICK < _runtime.next_mining_tick)
        return false;

    _runtime.next_mining_tick =
        GAME_TICK + max(1, round(_config.interval));

    sc_heat_signature_emit(
        _player,
        _target.x,
        _target.y,
        _config.strength
    );

    return true;
}