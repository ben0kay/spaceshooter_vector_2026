/// @description Weaves laterally across the target while maintaining a preferred firing range.
function sc_enemy_movement_combat_weave(_enemy)
{
    var _data = _enemy.enemy;
    var _target = _data.target_id;
    if (!instance_exists(_target)) return;

    var _movement = _data.movement;
    var _weave = _data.movement_controller.weave;
    var _command = _movement.command;

    var _dx = _target.x - _enemy.x;
    var _dy = _target.y - _enemy.y;
    var _distance = max(1, point_distance(0, 0, _dx, _dy));
    var _toward = point_direction(0, 0, _dx, _dy);

    var _phase = GAME_TICK * _weave.speed + _movement.strafe_phase;
    var _lateral = sin(_phase) * _weave.lateral_strength;

    var _range_error = _distance - _weave.range;
    var _radial = 0;

    if (abs(_range_error) > _weave.range_tolerance)
    {
        var _corrected_error = abs(_range_error) - _weave.range_tolerance;

        _radial = sign(_range_error)
            * clamp(_corrected_error / max(1, _weave.response_distance), 0, 1)
            * _weave.radial_strength;
    }

    var _move_x = lengthdir_x(_lateral, _toward + 90)
        + lengthdir_x(_radial, _toward);

    var _move_y = lengthdir_y(_lateral, _toward + 90)
        + lengthdir_y(_radial, _toward);

    var _movement_strength = point_distance(0, 0, _move_x, _move_y);

    _command.face_direction = _toward;
    _command.facing_mode = EnemyFacingMode.TARGET;

    if (_movement_strength <= 0.01) return;

    _command.active = true;
    _command.apply_friction = false;
    _command.direction = point_direction(0, 0, _move_x, _move_y);
    _command.speed_scale = min(_weave.speed_scale, _movement_strength);
}