/// @description Initializes open-world logic for a standard enemy.
function sc_enemy_controller_standard_init(_enemy, _definition)
{
    var _data = _enemy.enemy;

    _data.doctrine =
        variable_clone(
            sc_faction_doctrine_get(_data.identity.faction)
        );

    _data.awareness_controller =
        variable_clone(_definition.awareness_controller);

    _data.alert = {
        attempts: 0,
        next_attempt_tick: 0
    };

    _data.awareness = {
        memory_until: 0,
        last_known_x: _enemy.x,
        last_known_y: _enemy.y,
        arrived: false,
        search_until: 0
    };

    return true;
}


/// @description Initializes dedicated encounter-boss logic.
function sc_enemy_controller_boss_init(_enemy, _definition)
{
    var _data = _enemy.enemy;

    _data.target_id = noone;
    _data.state = EnemyState.ATTACKING;

    return true;
}


/// @description Runs the complete open-world enemy pipeline.
function sc_enemy_controller_standard_step(_enemy)
{
    var _data = _enemy.enemy;

    sc_optimization_enemy_update(_enemy);

    var _updates = global.config.optimization.enemy_updates;
    var _optimization = _data.optimization;

    var _perception_interval =
        _data.state == EnemyState.IDLE
        ? _updates.perception_idle_interval
        : _updates.perception_active_interval;

    var _perception_due =
        sc_optimization_update_due(
            _enemy,
            _perception_interval,
            _optimization.lazy_factor
        );

    if ((_data.state == EnemyState.CHASING
    || _data.state == EnemyState.ATTACKING)
    && !instance_exists(_data.target_id))
    {
        _perception_due = true;
    }

    if (!instance_exists(global.player_id))
        _perception_due = true;

    if (_data.state != EnemyState.STUNNED
    && _data.state != EnemyState.DEAD
    && _perception_due)
    {
        sc_enemy_perception_update(_enemy);
    }

    var _hardpoint_due =
        _optimization.render_active
        || _data.state == EnemyState.ATTACKING
        || sc_optimization_update_due(
            _enemy,
            _updates.hardpoint_idle_interval,
            _optimization.lazy_factor
        );

    if (_hardpoint_due)
        sc_enemy_hardpoint_update(_enemy);

    var _state_before_movement = _data.state;

    sc_enemy_movement_update(_enemy);

    if (_state_before_movement == EnemyState.ATTACKING)
        sc_enemy_attack_update(_enemy);

    if (_optimization.render_active)
        sc_enemy_visual_update(_enemy);
    else
        _data.visual.runtime.shield_hit_alpha = 0;

    return true;
}


/// @description Runs a dedicated encounter boss without world awareness.
function sc_enemy_controller_boss_step(_enemy)
{
    var _data = _enemy.enemy;

    sc_optimization_enemy_update(_enemy);

    if (!instance_exists(global.player_id))
    {
        sc_enemy_attack_cancel(_enemy);
        _data.target_id = noone;
        return false;
    }

    _data.target_id = global.player_id;

    var _dx = global.player_id.x - _enemy.x;
    var _dy = global.player_id.y - _enemy.y;

    _data.target_distance_sq = _dx * _dx + _dy * _dy;

    if (_data.state != EnemyState.STUNNED
    && _data.state != EnemyState.DEAD)
    {
        _data.state = EnemyState.ATTACKING;
    }

    sc_enemy_hardpoint_update(_enemy);

    var _state_before_movement = _data.state;

    sc_enemy_movement_update(_enemy);

    if (_state_before_movement == EnemyState.ATTACKING)
        sc_enemy_attack_update(_enemy);

    if (_data.optimization.render_active)
        sc_enemy_visual_update(_enemy);
    else
        _data.visual.runtime.shield_hit_alpha = 0;

    return true;
}


/// @description Reacts to standard enemy damage with awareness and alerts.
function sc_enemy_controller_standard_damage_response(
    _enemy,
    _packet,
    _result
)
{
    var _data = _enemy.enemy;

    sc_enemy_awareness_damage_try(_enemy, _packet);
    sc_enemy_alert_try(
        _enemy,
        _data.doctrine.alert.on_damage
    );

    return true;
}


/// @description Dedicated bosses do not use world-awareness reactions.
function sc_enemy_controller_boss_damage_response(
    _enemy,
    _packet,
    _result
)
{
    return true;
}