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

/// @description Returns whether a staggered dynamic update interval is due.
function sc_optimization_update_due(_instance_id, _base_interval, _lazy_factor = 1)
{
    var _interval = max(1, round(_base_interval * _lazy_factor));
    return ((GAME_TICK + real(_instance_id)) mod _interval) == 0;
}

/// @description Initializes one enemy's cached optimization state.
function sc_optimization_enemy_init(_enemy)
{
    _enemy.enemy.optimization = {
        render_active: true,
        lazy_factor: 1
    };
}

/// @description Refreshes one enemy's render visibility and distance-based update factor.
function sc_optimization_enemy_update(_enemy)
{
    var _config = global.config.optimization;
    var _updates = _config.enemy_updates;
    var _optimization = _enemy.enemy.optimization;
    var _radius = _enemy.enemy.visual.radius * _config.enemy_visual_radius_scale;

    _optimization.render_active = sc_optimization_circle_visible(
        _enemy.x,
        _enemy.y,
        _radius,
        _config.enemy_screen_padding
    );

    if (_optimization.render_active)
    {
        _optimization.lazy_factor = _updates.lazy_visible;
        return;
    }

    if (!instance_exists(global.player_id))
    {
        _optimization.lazy_factor = _updates.lazy_very_distant;
        return;
    }

    var _dx = global.player_id.x - _enemy.x;
    var _dy = global.player_id.y - _enemy.y;
    var _distance_sq = _dx * _dx + _dy * _dy;

    if (_distance_sq <= sqr(_updates.distant_range))
        _optimization.lazy_factor = _updates.lazy_offscreen;
    else if (_distance_sq <= sqr(_updates.very_distant_range))
        _optimization.lazy_factor = _updates.lazy_distant;
    else
        _optimization.lazy_factor = _updates.lazy_very_distant;
}