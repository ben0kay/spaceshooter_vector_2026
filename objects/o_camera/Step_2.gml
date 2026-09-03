/// @description Updates camera zoom, targeting, shake and cached world bounds.
var _camera = camera_data;
var _camera_id = _camera.camera_id;

if (mouse_wheel_down()) _camera.zoom.target += _camera.zoom.step;
if (mouse_wheel_up()) _camera.zoom.target -= _camera.zoom.step;

_camera.zoom.target = clamp(_camera.zoom.target, _camera.zoom.minimum, _camera.zoom.maximum);

if (abs(_camera.zoom.current - _camera.zoom.target) > 0.0001)
{
    _camera.zoom.current = lerp(_camera.zoom.current, _camera.zoom.target, _camera.zoom.smoothing);
    camera_set_view_size(_camera_id, _camera.base.width * _camera.zoom.current, _camera.base.height * _camera.zoom.current);
}

var _view_w = camera_get_view_width(_camera_id);
var _view_h = camera_get_view_height(_camera_id);
var _target_x = camera_get_view_x(_camera_id) + _view_w * 0.5;
var _target_y = camera_get_view_y(_camera_id) + _view_h * 0.5;

if (instance_exists(global.player_id))
{
    _camera.target_id = global.player_id;
    _target_x = global.player_id.x;
    _target_y = global.player_id.y;
}
else
    _camera.target_id = noone;

var _camera_x = _target_x - _view_w * 0.5;
var _camera_y = _target_y - _view_h * 0.5;

if (_view_w < room_width) _camera_x = clamp(_camera_x, 0, room_width - _view_w);
else _camera_x = (room_width - _view_w) * 0.5;

if (_view_h < room_height) _camera_y = clamp(_camera_y, 0, room_height - _view_h);
else _camera_y = (room_height - _view_h) * 0.5;

if (_camera.shake.time > 0)
{
    var _strength = _camera.shake.magnitude * (_camera.shake.time / max(1, _camera.shake.duration));

    _camera_x += random_range(-_strength, _strength);
    _camera_y += random_range(-_strength, _strength);
    _camera.shake.time--;

    if (_camera.shake.time <= 0)
    {
        _camera.shake.magnitude = 0;
        _camera.shake.duration = 0;
    }
}

camera_set_view_pos(_camera_id, round(_camera_x), round(_camera_y));
sc_optimization_camera_cache(_camera_id);