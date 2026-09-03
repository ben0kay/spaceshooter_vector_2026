/// @description Updates camera deadzone following, zoom, shake and cached world bounds.
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

if (instance_exists(global.player_id))
{
    var _player = global.player_id;
    var _half_deadzone_w = _camera.follow.deadzone_width * 0.5;
    var _half_deadzone_h = _camera.follow.deadzone_height * 0.5;
    var _offset_x = _player.x - _camera.follow.x;
    var _offset_y = _player.y - _camera.follow.y;

    _camera.target_id = _player;

    if (_offset_x < -_half_deadzone_w)
        _camera.follow.x = _player.x + _half_deadzone_w;
    else if (_offset_x > _half_deadzone_w)
        _camera.follow.x = _player.x - _half_deadzone_w;

    if (_offset_y < -_half_deadzone_h)
        _camera.follow.y = _player.y + _half_deadzone_h;
    else if (_offset_y > _half_deadzone_h)
        _camera.follow.y = _player.y - _half_deadzone_h;
}
else
    _camera.target_id = noone;

var _camera_x = _camera.follow.x - _view_w * 0.5;
var _camera_y = _camera.follow.y - _view_h * 0.5;

if (_view_w < room_width)
{
    _camera_x = clamp(_camera_x, 0, room_width - _view_w);
    _camera.follow.x = _camera_x + _view_w * 0.5;
}
else
{
    _camera_x = (room_width - _view_w) * 0.5;
    _camera.follow.x = room_width * 0.5;
}

if (_view_h < room_height)
{
    _camera_y = clamp(_camera_y, 0, room_height - _view_h);
    _camera.follow.y = _camera_y + _view_h * 0.5;
}
else
{
    _camera_y = (room_height - _view_h) * 0.5;
    _camera.follow.y = room_height * 0.5;
}

var _draw_x = _camera_x;
var _draw_y = _camera_y;

if (_camera.shake.time > 0)
{
    var _strength = _camera.shake.magnitude * (_camera.shake.time / max(1, _camera.shake.duration));

    _draw_x += random_range(-_strength, _strength);
    _draw_y += random_range(-_strength, _strength);
    _camera.shake.time--;

    if (_camera.shake.time <= 0)
    {
        _camera.shake.magnitude = 0;
        _camera.shake.duration = 0;
    }
}

camera_set_view_pos(_camera_id, round(_draw_x), round(_draw_y));
sc_optimization_camera_cache(_camera_id);