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

/// @description Configures a flee target that escapes away from the player.
function sc_enemy_flee_target_map(_enemy, _option)
{
    var _data = _enemy.enemy;
    var _runtime = _data.flee;
    var _direction = _enemy.draw_angle;

    if (instance_exists(global.player_id))
        _direction = point_direction(global.player_id.x, global.player_id.y, _enemy.x, _enemy.y);
    else if (instance_exists(_data.target_id))
        _direction = point_direction(_data.target_id.x, _data.target_id.y, _enemy.x, _enemy.y);

    _runtime.direction = _direction;
    _runtime.target_id = noone;
    _runtime.arrived = false;
    return true;
}

/// @description Configures a flee target using the nearest larger same-faction ship.
function sc_enemy_flee_target_larger_ally(_enemy, _option)
{
    var _data = _enemy.enemy;
    var _list = ds_list_create();

    collision_circle_list(
        _enemy.x, _enemy.y, _option.range,
        o_enemy, false, true, _list, false
    );

    var _target = noone;
    var _best_distance_sq = _option.range * _option.range;

    for (var _i = 0; _i < ds_list_size(_list); _i++)
    {
        var _candidate = _list[| _i];
        if (_candidate == _enemy || !_candidate.initialized) continue;

        var _candidate_data = _candidate.enemy;

        if (_candidate_data.identity.faction != _data.identity.faction
        || _candidate_data.identity.ship_class <= _data.identity.ship_class
        || _candidate_data.state == EnemyState.FLEEING
        || _candidate_data.state == EnemyState.DEAD)
            continue;

        var _distance_sq = sc_point_distance_sq(
            _enemy.x, _enemy.y,
            _candidate.x, _candidate.y
        );

        if (_distance_sq >= _best_distance_sq) continue;

        _best_distance_sq = _distance_sq;
        _target = _candidate;
    }

    ds_list_destroy(_list);
    if (!instance_exists(_target)) return false;

    _data.flee.target_id = _target;
    _data.flee.arrived = false;
    return true;
}

/// @description Selects and configures one weighted valid flee target.
function sc_enemy_flee_target_select(_enemy)
{
    var _data = _enemy.enemy;
    var _options = _data.doctrine.flee.targets;
    var _available = [];

    for (var _i = 0; _i < array_length(_options); _i++)
    {
        if (_options[_i].weight > 0)
            array_push(_available, _i);
    }

    while (array_length(_available) > 0)
    {
        var _weight_total = 0;

        for (var _i = 0; _i < array_length(_available); _i++)
            _weight_total += _options[_available[_i]].weight;

        if (_weight_total <= 0) return false;

        var _roll = random(_weight_total);
        var _selected_position = -1;

        for (var _i = 0; _i < array_length(_available); _i++)
        {
            _roll -= _options[_available[_i]].weight;

            if (_roll <= 0)
            {
                _selected_position = _i;
                break;
            }
        }

        if (_selected_position < 0)
            _selected_position = array_length(_available) - 1;

        var _option = _options[_available[_selected_position]];
        array_delete(_available, _selected_position, 1);

        if (!_option.target_script(_enemy, _option))
            continue;

        _data.flee.option = _option;
        _data.flee.movement_script = _option.movement_script;
        _data.flee.arrival_script = _option.arrival_script;
        return true;
    }

    return false;
}

/// @description Replaces an unavailable directed retreat with map escape.
function sc_enemy_flee_fallback_map(_enemy)
{
    var _runtime = _enemy.enemy.flee;

    _runtime.option = undefined;
    _runtime.movement_script = sc_enemy_movement_flee_away;
    _runtime.arrival_script = sc_enemy_flee_arrive_map;

    return sc_enemy_flee_target_map(_enemy, undefined);
}

/// @description Begins fleeing using one weighted faction target.
function sc_enemy_flee_begin(_enemy)
{
    var _data = _enemy.enemy;
    if (_data.state == EnemyState.DEAD || _data.state == EnemyState.FLEEING) return false;
    if (!sc_enemy_flee_target_select(_enemy)) return false;

    sc_enemy_attack_cancel(_enemy);

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

/// @description Flees along a stable map-escape heading with faction-controlled sway.
function sc_enemy_movement_flee_away(_enemy, _option)
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

/// @description Flees toward and shelters beside the selected larger allied ship.
function sc_enemy_movement_flee_toward_ally(_enemy, _option)
{
    var _data = _enemy.enemy;
    var _runtime = _data.flee;
    var _target = _runtime.target_id;

    if (!instance_exists(_target))
    {
        sc_enemy_flee_fallback_map(_enemy);
        sc_enemy_movement_flee_away(_enemy, undefined);
        return;
    }

    var _command = _data.movement.command;
    var _target_radius = max(
        _target.enemy.collision.radius_forward,
        _target.enemy.collision.radius_side
    );

    var _enemy_radius = max(
        _data.collision.radius_forward,
        _data.collision.radius_side
    );

    var _arrival_radius = _target_radius + _enemy_radius + _option.arrival_margin;
    var _distance_sq = sc_point_distance_sq(_enemy.x, _enemy.y, _target.x, _target.y);

    if (_distance_sq <= _arrival_radius * _arrival_radius)
    {
        _command.apply_friction = true;
        return;
    }

    _command.active = true;
    _command.apply_friction = false;
    _command.direction = point_direction(_enemy.x, _enemy.y, _target.x, _target.y);
    _command.face_direction = _command.direction;
    _command.facing_mode = EnemyFacingMode.MOVEMENT;
    _command.speed_scale = max(0, _data.doctrine.flee.speed_scale);
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

    return sc_enemy_remove(_enemy, EnemyRemovalReason.ESCAPED);
}

/// @description Processes arrival for a ship fleeing off the map.
function sc_enemy_flee_arrive_map(_enemy, _option)
{
    return sc_enemy_flee_exit_check(_enemy);
}

/// @description Marks a fleeing ship as sheltered beside its larger ally.
function sc_enemy_flee_arrive_shelter(_enemy, _option)
{
    var _data = _enemy.enemy;
    var _runtime = _data.flee;
    var _target = _runtime.target_id;

    if (_runtime.arrived || !instance_exists(_target))
        return false;

    var _target_radius = max(
        _target.enemy.collision.radius_forward,
        _target.enemy.collision.radius_side
    );

    var _enemy_radius = max(
        _data.collision.radius_forward,
        _data.collision.radius_side
    );

    var _arrival_radius = _target_radius + _enemy_radius + _option.arrival_margin;

    if (sc_point_distance_sq(_enemy.x, _enemy.y, _target.x, _target.y)
    > _arrival_radius * _arrival_radius)
        return false;

    _runtime.arrived = true;

    // Add Corporation repair, regroup or combat-return behaviour here later.
    return false;
}

/// @description Runs the selected flee target's arrival callback.
function sc_enemy_flee_arrival_update(_enemy)
{
    var _runtime = _enemy.enemy.flee;
    return _runtime.arrival_script(_enemy, _runtime.option);
}