/// @description Holds the boss camera still while applying shared camera shake.
var _camera = camera_data;
var _camera_id = _camera.camera_id;
var _view_w = camera_get_view_width(_camera_id);
var _view_h = camera_get_view_height(_camera_id);
var _camera_x = _camera.follow.x - _view_w * 0.5;
var _camera_y = _camera.follow.y - _view_h * 0.5;

if (_view_w >= room_width)
    _camera_x = (room_width - _view_w) * 0.5;
else
    _camera_x = clamp(_camera_x, 0, room_width - _view_w);

if (_view_h >= room_height)
    _camera_y = (room_height - _view_h) * 0.5;
else
    _camera_y = clamp(_camera_y, 0, room_height - _view_h);

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