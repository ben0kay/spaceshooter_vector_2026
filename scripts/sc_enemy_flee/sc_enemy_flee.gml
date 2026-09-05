/// @description Returns whether the configured defence layer received damage.
function sc_enemy_flee_layer_damaged(_result, _layer)
{
    switch (_layer)
    {
        case DefenceLayer.SHIELD: return _result.dealt.shield > 0;
        case DefenceLayer.ARMOUR: return _result.dealt.armour > 0;
        case DefenceLayer.HULL: return _result.dealt.hull > 0;
    }

    return false;
}

/// @description Returns the enemy's current ratio for one defence layer.
function sc_enemy_flee_layer_ratio(_enemy, _layer)
{
    var _defence = _enemy.enemy.defence;

    switch (_layer)
    {
        case DefenceLayer.SHIELD:
            return _defence.shield.current / max(1, _defence.shield.maximum);

        case DefenceLayer.ARMOUR:
            return _defence.armour.current / max(1, _defence.armour.maximum);

        case DefenceLayer.HULL:
            return _defence.hull.current / max(1, _defence.hull.maximum);
    }

    return 1;
}

/// @description Begins fleeing along one stable direction away from the player.
function sc_enemy_flee_begin(_enemy)
{
    var _data = _enemy.enemy;
    if (_data.state == EnemyState.DEAD || _data.state == EnemyState.FLEEING) return false;

    var _direction = _enemy.draw_angle;

    if (instance_exists(global.player_id))
        _direction = point_direction(global.player_id.x, global.player_id.y, _enemy.x, _enemy.y);
    else if (instance_exists(_data.target_id))
        _direction = point_direction(_data.target_id.x, _data.target_id.y, _enemy.x, _enemy.y);

    sc_enemy_attack_cancel(_enemy);

    _data.flee.direction = _direction;
    _data.target_id = noone;
    _data.awareness.memory_until = 0;
    _data.awareness.arrived = false;
    _data.state = EnemyState.FLEEING;

    return true;
}

/// @description Rolls an eligible faction-controlled flee attempt after damage.
function sc_enemy_flee_try(_enemy, _result)
{
    var _data = _enemy.enemy;

    if (_data.state == EnemyState.DEAD
    || _data.state == EnemyState.FLEEING
    || _data.identity.rank == EnemyRank.BOSS)
        return false;

    var _config = _data.doctrine.flee;
    var _runtime = _data.flee;

    if (_config.max_attempts <= 0
    || _config.chance <= 0
    || _runtime.attempts >= _config.max_attempts
    || GAME_TICK < _runtime.next_attempt_tick)
        return false;

    if (!sc_enemy_flee_layer_damaged(_result, _config.trigger_layer))
        return false;

    var _ratio = sc_enemy_flee_layer_ratio(_enemy, _config.trigger_layer);

    if (_ratio > clamp(_config.trigger_ratio, 0, 1))
        return false;

    _runtime.attempts++;
    _runtime.next_attempt_tick = GAME_TICK + max(0, round(_config.cooldown));

    if (random(1) >= clamp(_config.chance, 0, 1))
        return false;

    return sc_enemy_flee_begin(_enemy);
}

/// @description Flees along a stable escape heading with faction-controlled sway.
function sc_enemy_movement_flee_away(_enemy)
{
    var _data = _enemy.enemy;
    var _config = _data.doctrine.flee;
    var _command = _data.movement.command;
    var _sway = sin(GAME_TICK * _config.sway_speed + real(_enemy.id) * 0.17)
        * _config.sway_amount;

    _command.active = true;
    _command.apply_friction = false;
    _command.direction = _data.flee.direction + _sway;
    _command.face_direction = _command.direction;
    _command.facing_mode = EnemyFacingMode.MOVEMENT;
    _command.speed_scale = max(0, _config.speed_scale);
}

/// @description Removes a fleeing enemy after its entire footprint clears the room.
function sc_enemy_flee_exit_check(_enemy)
{
    var _data = _enemy.enemy;

    if (_data.state != EnemyState.FLEEING)
        return false;

    var _padding = max(
        _data.collision.radius_forward,
        _data.collision.radius_side
    ) + 128;

    if (_enemy.x >= -_padding
    && _enemy.x <= room_width + _padding
    && _enemy.y >= -_padding
    && _enemy.y <= room_height + _padding)
        return false;

    instance_destroy(_enemy);
    return true;
}