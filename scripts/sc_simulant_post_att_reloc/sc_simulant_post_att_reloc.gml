

/*
SIMULANT POST-ATTACK RELOCATION

Selected Simulant attacks may call sc_simulant_attack_finish_relocation
after completing their final shot.

The relocation pipeline separates:

1. Destination selection.
2. Destination validation.
3. Relocation execution.
4. Recovery.
5. Normal combat movement.

Current implementation:
- Side destination.
- Physical lunge.
- Controlled braking.

Future teleport implementation:
- Reuse sc_simulant_relocation_destination_side() for a lateral blink.
- Add sc_simulant_relocation_destination_arc() for another point on a ring
  around the target.
- Add sc_simulant_relocation_execute_teleport() to handle disappearance,
  relocation, arrival effects and recovery.
- Teleport execution must validate the cached destination again immediately
  before changing the enemy's x and y.
*/

enum SimulantRelocationPhase { IDLE, LUNGE, BRAKING }

/// @description Returns whether a proposed Simulant relocation destination is safe.
function sc_simulant_relocation_destination_valid(_enemy,_x,_y,_config)
{
    var _data = _enemy.enemy;
    var _target = _data.target_id;
    var _radius = max(
        _data.collision.radius_forward,
        _data.collision.radius_side
    );

    var _clearance = _radius + _config.clearance;

    if (_x < _clearance
    || _x > room_width - _clearance
    || _y < _clearance
    || _y > room_height - _clearance)
        return false;

    if (!sc_enemy_territory_position_valid(_enemy,_x,_y))
        return false;

    if (instance_exists(_target)
    && sc_point_distance_sq(_x,_y,_target.x,_target.y)
        < sqr(_config.target_clearance))
        return false;

    if (collision_circle(
        _x,
        _y,
        _clearance,
        o_solid,
        false,
        true
    ) != noone)
        return false;

    if (collision_circle(
        _x,
        _y,
        _clearance,
        o_asteroid,
        false,
        true
    ) != noone)
        return false;

    if (collision_circle(
        _x,
        _y,
        _clearance,
        o_enemy,
        false,
        true
    ) != noone)
        return false;

    return true;
}

/// @description Selects a cached lateral destination relative to the current target.
function sc_simulant_relocation_destination_side(_enemy,_config,_runtime)
{
    var _target = _enemy.enemy.target_id;
    if (!instance_exists(_target)) return false;

    var _toward = point_direction(
        _enemy.x,
        _enemy.y,
        _target.x,
        _target.y
    );

    var _side = choose(-1,1);

    for (var _attempt = 0; _attempt < _config.attempts; ++_attempt)
    {
        var _distance = random_range(
            _config.distance_min,
            _config.distance_max
        );

        var _direction = _toward + 90 * _side;
        var _destination_x = _enemy.x
            + lengthdir_x(_distance,_direction);

        var _destination_y = _enemy.y
            + lengthdir_y(_distance,_direction);

        if (sc_simulant_relocation_destination_valid(
            _enemy,
            _destination_x,
            _destination_y,
            _config
        ))
        {
            _runtime.destination_x = _destination_x;
            _runtime.destination_y = _destination_y;
            _runtime.direction = _direction;
            return true;
        }

        _side *= -1;
    }

    return false;
}

/// @description Arms an optional Simulant relocation after an attack completes.
function sc_simulant_attack_finish_relocation(_enemy,_attack)
{
    var _data = _enemy.enemy;
    var _target = _data.target_id;
    if (!instance_exists(_target)) return;

    var _controller = _data.attack_controller;

    for (var _i = 0; _i < array_length(_controller.channels); ++_i)
    {
        if (sc_enemy_attack_channel_active(_controller.channels[_i]))
            return;
    }

    var _config = _data.movement_controller.post_attack_relocation;
    var _runtime = _data.movement.behaviour_runtime.post_attack_relocation;

    if (_runtime.phase != SimulantRelocationPhase.IDLE)
        return;

    if (!_config.destination_script(
        _enemy,
        _config,
        _runtime
    ))
        return;

    _runtime.phase = SimulantRelocationPhase.LUNGE;
    _runtime.phase_until = GAME_TICK + _config.lunge_duration_max;

    _controller.runtime.cooldown_until = max(
        _controller.runtime.cooldown_until,
        GAME_TICK + _config.attack_lockout
    );
}

/// @description Executes one physical Simulant post-attack lunge and braking cycle.
function sc_simulant_relocation_execute_lunge(_enemy,_config,_runtime)
{
    var _data = _enemy.enemy;
    var _target = _data.target_id;
    var _movement = _data.movement;
    var _command = _movement.command;

    if (!instance_exists(_target))
    {
        _runtime.phase = SimulantRelocationPhase.IDLE;
        return false;
    }

    _command.face_direction = point_direction(
        _enemy.x,
        _enemy.y,
        _target.x,
        _target.y
    );

    _command.facing_mode = EnemyFacingMode.TARGET;

    switch (_runtime.phase)
    {
        case SimulantRelocationPhase.LUNGE:
        {
            var _dx = _runtime.destination_x - _enemy.x;
            var _dy = _runtime.destination_y - _enemy.y;
            var _distance_sq = _dx * _dx + _dy * _dy;

            if (_distance_sq <= sqr(_config.arrival_radius)
            || GAME_TICK >= _runtime.phase_until)
            {
                _runtime.phase = SimulantRelocationPhase.BRAKING;
                _runtime.phase_until = GAME_TICK + _config.brake_duration;
                return true;
            }

            _command.active = true;
            _command.apply_friction = false;
            _command.direction = point_direction(0,0,_dx,_dy);
            _command.speed_scale = _config.speed_scale;
            return true;
        }

        case SimulantRelocationPhase.BRAKING:
            _movement.velocity_x *= _config.brake_multiplier;
            _movement.velocity_y *= _config.brake_multiplier;

            _command.active = false;
            _command.apply_friction = false;

            if (GAME_TICK >= _runtime.phase_until)
            {
                _runtime.phase = SimulantRelocationPhase.IDLE;
                return false;
            }

            return true;
    }

    return false;
}

/// @description Runs post-attack relocation or the ship's ordinary combat movement.
function sc_simulant_movement_post_attack_relocation(_enemy)
{
    var _data = _enemy.enemy;
    var _controller = _data.movement_controller;
    var _config = _controller.post_attack_relocation;
    var _runtime = _data.movement.behaviour_runtime.post_attack_relocation;

    if (_runtime.phase != SimulantRelocationPhase.IDLE
    && _config.execution_script(
        _enemy,
        _config,
        _runtime
    ))
        return;

    _config.fallback_script(_enemy);
}