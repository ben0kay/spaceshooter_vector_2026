/// @description Creates reusable world-space health-bar settings.
function sc_health_bar_create(_always_visible)
{
    return {
        always_visible: _always_visible,
        visible_until: 0,
        damaged_duration: 180,
        width: 72,
        height: 4,
        gap: 2,
        offset_y: 12
    };
}

/// @description Makes one health bar temporarily visible after damage.
function sc_health_bar_damage_show(_health_bar)
{
    _health_bar.visible_until = GAME_TICK + _health_bar.damaged_duration;
}

/// @description Draws shield, armour and hull bars above one damageable entity.
function sc_health_bar_draw(_x, _y, _radius, _defence, _health_bar)
{
    if (!_health_bar.always_visible && GAME_TICK >= _health_bar.visible_until) return;

    var _layers = [_defence.shield, _defence.armour, _defence.hull];
    var _colours = [
        make_colour_rgb(65, 225, 255),
        make_colour_rgb(190, 200, 215),
        make_colour_rgb(255, 70, 90)
    ];

    var _width = _health_bar.width;
    var _height = _health_bar.height;
    var _gap = _health_bar.gap;
    var _left = _x - _width * 0.5;
    var _bar_y = _y - _radius - _health_bar.offset_y;
    var _row = 0;

    draw_set_alpha(0.9);

    for (var _i = 0; _i < 3; _i++)
    {
        var _layer = _layers[_i];
        if (_layer.maximum <= 0) continue;

        var _top = _bar_y + _row * (_height + _gap);
        var _ratio = clamp(_layer.current / _layer.maximum, 0, 1);

        draw_set_colour(make_colour_rgb(5, 8, 14));
        draw_rectangle(_left - 1, _top - 1, _left + _width + 1, _top + _height + 1, false);

        if (_ratio > 0)
        {
            draw_set_colour(_colours[_i]);
            draw_rectangle(_left, _top, _left + _width * _ratio, _top + _height, false);
        }

        _row++;
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
}