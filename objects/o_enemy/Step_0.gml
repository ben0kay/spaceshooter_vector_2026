/// @description Updates enemy gameplay using distance-aware scheduling.
if (!initialized || !GAMEPLAY_ACTIVE) exit;

sc_optimization_enemy_update(id);

if (enemy.flee.sheltered)
    sc_enemy_flee_recovery_update(id);

var _updates = global.config.optimization.enemy_updates;
var _optimization = enemy.optimization;
var _perception_interval = enemy.state == EnemyState.IDLE
    ? _updates.perception_idle_interval
    : _updates.perception_active_interval;

var _perception_due = sc_optimization_update_due(
    id,
    _perception_interval,
    _optimization.lazy_factor
);

if ((enemy.state == EnemyState.CHASING || enemy.state == EnemyState.ATTACKING)
&& !instance_exists(enemy.target_id))
    _perception_due = true;

if (enemy.state != EnemyState.STUNNED
&& enemy.state != EnemyState.FLEEING
&& enemy.state != EnemyState.DEAD
&& _perception_due)
    sc_enemy_perception_update(id);

var _retarget = enemy.doctrine.engagement.retarget;

if (_optimization.render_active
&& (enemy.state == EnemyState.CHASING || enemy.state == EnemyState.ATTACKING)
&& !is_undefined(_retarget.script)
&& sc_optimization_update_due(id,_retarget.interval,1))
    _retarget.script(id);

var _destroying_asteroid = sc_enemy_asteroid_destroy_active(id);

var _hardpoint_due = _optimization.render_active
    || enemy.state == EnemyState.ATTACKING
    || _destroying_asteroid
    || sc_optimization_update_due(
        id,
        _updates.hardpoint_idle_interval,
        _optimization.lazy_factor
    );

if (_hardpoint_due)
    sc_enemy_hardpoint_update(id);

if (is_struct(enemy.utility_controller))
    sc_enemy_utility_update(id);

var _state_before_movement = enemy.state;

if (sc_enemy_movement_update(id))
    exit;

_destroying_asteroid = sc_enemy_asteroid_destroy_active(id);

if (_state_before_movement == EnemyState.ATTACKING
|| _destroying_asteroid)
    sc_enemy_attack_update(id);

if (_optimization.render_active)
    sc_enemy_visual_update(id);
else
    enemy.visual.runtime.shield_hit_alpha = 0;

image_angle = draw_angle;