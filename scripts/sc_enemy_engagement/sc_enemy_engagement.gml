/// @description Initializes directional hostility between all factions.
function sc_faction_hostility_init()
{
    var _count = Faction.AUTOMATED + 1;
    global.data.faction_hostility = array_create(_count);

    for (var _i = 0; _i < _count; ++_i)
        global.data.faction_hostility[_i] = array_create(_count,0);

    // All implemented enemy factions attack the player.
    sc_faction_hostility_set(Faction.SIMULANT,Faction.PLAYER,1);
    sc_faction_hostility_set(Faction.REBEL,Faction.PLAYER,1);
    sc_faction_hostility_set(Faction.CORPORATION,Faction.PLAYER,1);

    // Simulants are aggressively hostile toward other factions.
    sc_faction_hostility_set(Faction.SIMULANT,Faction.REBEL,1);
    sc_faction_hostility_set(Faction.SIMULANT,Faction.CORPORATION,1);
    sc_faction_hostility_set(Faction.REBEL,Faction.SIMULANT,1);
    sc_faction_hostility_set(Faction.CORPORATION,Faction.SIMULANT,1);

    // Rebels and Corporation frequently clash.
    sc_faction_hostility_set(Faction.REBEL,Faction.CORPORATION,0.8);
    sc_faction_hostility_set(Faction.CORPORATION,Faction.REBEL,0.8);

    return true;
}

/// @description Sets one directional faction-hostility value.
function sc_faction_hostility_set(_observer,_target,_hostility)
{
    global.data.faction_hostility[_observer][_target] = clamp(_hostility,0,1);
}

/// @description Returns one directional faction-hostility value.
function sc_faction_hostility_get(_observer,_target)
{
    if (_observer == _target) return 0;
    return global.data.faction_hostility[_observer][_target];
}

/// @description Returns whether an entity remains a valid combat target.
function sc_enemy_engagement_target_valid(_enemy,_target)
{
    if (!instance_exists(_target) || _target == _enemy) return false;
    if (_target.entity.faction == _enemy.entity.faction) return false;

    if (_target.entity.faction == Faction.PLAYER)
        return global.PlayerState != PlayerState.DESTROYED;

    return _target.initialized
        && _target.enemy.state != EnemyState.DEAD;
}

/// @description Removes expired or destroyed rejected-target memories.
function sc_enemy_engagement_rejections_clean(_enemy)
{
    var _rejected = _enemy.enemy.engagement.rejected;

    for (var _i = array_length(_rejected)-1; _i >= 0; --_i)
    {
        var _entry = _rejected[_i];

        if (!instance_exists(_entry.target_id)
        || GAME_TICK >= _entry.expiry_tick)
            array_delete(_rejected,_i,1);
    }
}

/// @description Returns whether this candidate is temporarily rejected.
function sc_enemy_engagement_candidate_rejected(_enemy,_candidate)
{
    var _rejected = _enemy.enemy.engagement.rejected;

    for (var _i = 0; _i < array_length(_rejected); ++_i)
        if (_rejected[_i].target_id == _candidate)
            return true;

    return false;
}

/// @description Removes one candidate from rejected-target memory.
function sc_enemy_engagement_rejection_remove(_enemy,_candidate)
{
    var _rejected = _enemy.enemy.engagement.rejected;

    for (var _i = array_length(_rejected)-1; _i >= 0; --_i)
        if (_rejected[_i].target_id == _candidate)
            array_delete(_rejected,_i,1);
}

/// @description Temporarily remembers one rejected engagement candidate.
function sc_enemy_engagement_candidate_reject(_enemy,_candidate)
{
    var _data = _enemy.enemy;

    array_push(_data.engagement.rejected,{
        target_id: _candidate,
        expiry_tick: GAME_TICK+max(1,round(_data.doctrine.engagement.reject_cooldown))
    });
}

/// @description Considers one valid entity for nearest-target acquisition.
function sc_enemy_engagement_candidate_consider(_enemy,_candidate,_range_sq,_current,_current_distance_sq)
{
    if (!sc_enemy_engagement_target_valid(_enemy,_candidate))
        return { target_id: _current, distance_sq: _current_distance_sq };

    var _observer_faction = _enemy.entity.faction;
    var _target_faction = _candidate.entity.faction;
    var _hostility = sc_faction_hostility_get(_observer_faction,_target_faction);

    if (_hostility <= 0
    || sc_enemy_engagement_candidate_rejected(_enemy,_candidate))
        return { target_id: _current, distance_sq: _current_distance_sq };

    var _distance_sq = sc_point_distance_sq(
        _enemy.x,_enemy.y,
        _candidate.x,_candidate.y
    );

    if (_distance_sq > _range_sq
    || _distance_sq >= _current_distance_sq)
        return { target_id: _current, distance_sq: _current_distance_sq };

    return {
        target_id: _candidate,
        distance_sq: _distance_sq
    };
}

/// @description Returns whether an entity is inside the faction-engagement area.
function sc_enemy_engagement_area_contains(_entity)
{
    var _config = global.config.enemy.engagement;

    if (!_config.limit_to_player_range)
        return true;

    if (!instance_exists(global.player_id))
        return false;

    return sc_point_distance_sq(
        _entity.x,_entity.y,
        global.player_id.x,global.player_id.y
    ) <= sqr(_config.activation_range);
}

/// @description Finds the nearest eligible, non-rejected combat candidate.
function sc_enemy_engagement_candidate_find(_enemy,_range_sq = undefined)
{
    var _data = _enemy.enemy;

    if (is_undefined(_range_sq))
        _range_sq = _data.stats.final.range.detection_sq;

    var _range = sqrt(_range_sq);
    var _target = noone;
    var _nearest_sq = _range_sq+1;

    sc_enemy_engagement_rejections_clean(_enemy);

    // Player acquisition always uses the enemy's ordinary detection range.
    if (instance_exists(global.player_id))
    {
        var _result = sc_enemy_engagement_candidate_consider(
            _enemy,global.player_id,
            _range_sq,_target,_nearest_sq
        );

        _target = _result.target_id;
        _nearest_sq = _result.distance_sq;
    }

    // Only enemy-versus-enemy acquisition is restricted by this config.
    if (!sc_enemy_engagement_area_contains(_enemy))
        return _target;

    var _list = ds_list_create();
    var _count = collision_circle_list(
        _enemy.x,_enemy.y,_range,
        o_enemy,false,true,_list,false
    );

    for (var _i = 0; _i < _count; ++_i)
    {
        var _candidate = _list[| _i];

        if (!sc_enemy_engagement_area_contains(_candidate))
            continue;

        var _result = sc_enemy_engagement_candidate_consider(
            _enemy,_candidate,
            _range_sq,_target,_nearest_sq
        );

        _target = _result.target_id;
        _nearest_sq = _result.distance_sq;
    }

    ds_list_destroy(_list);
    return _target;
}

/// @description Commits one enemy to a supplied combat target.
function sc_enemy_engagement_acquire(_enemy,_target,_alert)
{
    if (!sc_enemy_engagement_target_valid(_enemy,_target))
        return false;

    var _data = _enemy.enemy;

    sc_enemy_attack_cancel(_enemy);
    sc_enemy_engagement_rejection_remove(_enemy,_target);

    _data.target_id = _target;
    _data.target_distance_sq = sc_point_distance_sq(
        _enemy.x,_enemy.y,
        _target.x,_target.y
    );

    _data.awareness.last_known_x = _target.x;
    _data.awareness.last_known_y = _target.y;
    _data.awareness.memory_until = 0;
    _data.awareness.arrived = false;
    _data.awareness.search_until = 0;
    _data.state = _data.target_distance_sq <= _data.stats.final.range.combat_sq
        ? EnemyState.ATTACKING
        : EnemyState.CHASING;

    if (_alert)
        sc_enemy_alert_try(_enemy,_data.doctrine.alert.on_detection);

    return true;
}

/// @description Makes one doctrine-controlled engagement decision.
function sc_enemy_engagement_try(_enemy,_candidate)
{
    var _data = _enemy.enemy;
    var _hostility = sc_faction_hostility_get(
        _data.identity.faction,
        _candidate.entity.faction
    );

    var _chance = clamp(
        _hostility*_data.doctrine.engagement.chance,
        0,1
    );

    if (random(1) >= _chance)
    {
        sc_enemy_engagement_candidate_reject(_enemy,_candidate);
        return false;
    }

    return sc_enemy_engagement_acquire(_enemy,_candidate,true);
}

/// @description Switches to a meaningfully closer hostile inside combat range.
function sc_enemy_engagement_retarget_closer(_enemy)
{
    var _data = _enemy.enemy;
    var _current = _data.target_id;

    if (!sc_enemy_engagement_target_valid(_enemy,_current))
        return false;

    var _candidate = sc_enemy_engagement_candidate_find(
        _enemy,
        _data.stats.final.range.combat_sq
    );

    if (!instance_exists(_candidate)
    || _candidate == _current)
        return false;

    var _current_distance_sq = sc_point_distance_sq(
        _enemy.x,_enemy.y,
        _current.x,_current.y
    );

    var _candidate_distance_sq = sc_point_distance_sq(
        _enemy.x,_enemy.y,
        _candidate.x,_candidate.y
    );

    var _ratio = clamp(
        _data.doctrine.engagement.retarget.distance_ratio,
               0,1
    );

    if (_candidate_distance_sq >= _current_distance_sq*sqr(_ratio))
        return false;

    return sc_enemy_engagement_acquire(_enemy,_candidate,false);
}

/// @description Default retaliation immediately commits to a valid attacker.
function sc_enemy_engagement_retaliate_default(_enemy,_attacker)
{
    var _data = _enemy.enemy;

    if (_data.state == EnemyState.DEAD
    || _data.state == EnemyState.FLEEING
    || _data.state == EnemyState.STUNNED)
        return false;

    if (sc_enemy_engagement_target_valid(_enemy,_data.target_id))
        return false;

    return sc_enemy_engagement_acquire(_enemy,_attacker,false);
}

/// @description Passes a damage source into this faction's retaliation callback.
function sc_enemy_engagement_retaliation_try(_enemy,_packet)
{
    var _source = _packet.source;

    if (!instance_exists(_source.owner_id)
    || _source.faction == _enemy.entity.faction)
        return false;

    return _enemy.enemy.doctrine.engagement.retaliation_script(
        _enemy,
        _source.owner_id
    );
}