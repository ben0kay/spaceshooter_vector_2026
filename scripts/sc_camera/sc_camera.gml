/// @description Activates or strengthens the gameplay camera shake.
function sc_camera_shake(_magnitude, _time)
{
    if (!is_struct(global.level) || !instance_exists(global.level.camera)) return false;

    var _shake = global.level.camera.camera_data.shake;
    _shake.magnitude = max(_shake.magnitude, _magnitude);
    _shake.time = max(_shake.time, _time);
    _shake.duration = max(_shake.duration, _time);
    return true;
}