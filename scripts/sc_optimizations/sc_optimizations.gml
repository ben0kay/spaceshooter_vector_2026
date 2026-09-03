/// @description Initializes shared optimization runtime data.
function sc_optimization_init()
{
    global.optimization = {
        camera: {
            ready: false,
            left: 0, top: 0,
            right: 0, bottom: 0
        }
    };

    return true;
}

/// @description Caches the active camera bounds once for all optimized systems.
function sc_optimization_camera_cache(_camera_id)
{
    var _camera = global.optimization.camera;
    var _left = camera_get_view_x(_camera_id);
    var _top = camera_get_view_y(_camera_id);

    _camera.left = _left;
    _camera.top = _top;
    _camera.right = _left + camera_get_view_width(_camera_id);
    _camera.bottom = _top + camera_get_view_height(_camera_id);
    _camera.ready = true;
}

/// @description Returns whether a circular visual area overlaps the cached camera bounds.
function sc_optimization_circle_visible(_x, _y, _radius, _padding = 0)
{
    var _camera = global.optimization.camera;
    if (!_camera.ready) return true;

    var _extent = _radius + _padding;

    return _x + _extent >= _camera.left
        && _x - _extent <= _camera.right
        && _y + _extent >= _camera.top
        && _y - _extent <= _camera.bottom;
}

/// @description Initializes one enemy's cached optimization state.
function sc_optimization_enemy_init(_enemy)
{
    _enemy.enemy.optimization = {
        render_active: true
    };
}

/// @description Refreshes one enemy's cached render visibility.
function sc_optimization_enemy_update(_enemy)
{
    var _config = global.config.optimization;
    var _radius = _enemy.enemy.visual.radius * _config.enemy_visual_radius_scale;

    _enemy.enemy.optimization.render_active = sc_optimization_circle_visible(
        _enemy.x,
        _enemy.y,
        _radius,
        _config.enemy_screen_padding
    );
}