/// @description Activates a camera shake only when stronger than the shake currently being displayed.
function sc_camera_shake(_magnitude, _time)
{
    if (!is_struct(global.level) || !instance_exists(global.level.camera)) return false;

    var _shake = global.level.camera.camera_data.shake;
    var _current = _shake.time > 0 ? _shake.magnitude * (_shake.time / max(1, _shake.duration)) : 0;

    if (_magnitude <= _current) return false;

    _shake.magnitude = max(0, _magnitude);
    _shake.time = max(1, round(_time));
    _shake.duration = _shake.time;
    return true;
}

/// @description Requests distance-scaled camera shake from a world position.
function sc_camera_shake_at(_x, _y, _magnitude, _time, _falloff_start, _falloff_end, _falloff_min = 0)
{
    if (!is_struct(global.level) || !instance_exists(global.level.camera)) return false;

    var _camera = global.level.camera.camera_data;
    var _distance = point_distance(_x, _y, _camera.follow.x, _camera.follow.y);
    var _progress = clamp((_distance - _falloff_start) / max(1, _falloff_end - _falloff_start), 0, 1);
    var _distance_scale = lerp(1, _falloff_min, _progress);
    var _final_magnitude = _magnitude * _distance_scale;

    if (_final_magnitude <= 0) return false;

    return sc_camera_shake(_final_magnitude, _time);
}