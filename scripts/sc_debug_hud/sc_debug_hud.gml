/// @description Returns the debug FPS colour for one measured value.
function sc_debug_fps_colour_get(_fps)
{
    if (_fps >= 60)
        return c_white;

    var _orange = make_colour_rgb(255, 170, 45);
    var _red = make_colour_rgb(255, 45, 45);
    var _danger = 1 - clamp(_fps / 60, 0, 1);

    return merge_colour(_orange, _red, _danger);
}

/// @description Draws current FPS and a smoothed multi-second average.
function sc_debug_fps_draw()
{
    if (!global.config.debug.show_fps) return;

    static _average = 0;
    static _initialized = false;

    var _current = 1000000 / max(1, delta_time);
    _current = clamp(_current, 0, 9999);

    if (!_initialized)
    {
        _average = _current;
        _initialized = true;
    }

    // Time-based smoothing approximates a three-second average.
    var _response = 1 - exp(-delta_time / 3000000);
    _average += (_current - _average) * _response;

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);

    draw_set_colour(sc_debug_fps_colour_get(_current));
    draw_text(12, 12, "FPS  " + string(round(_current)));

    draw_set_colour(sc_debug_fps_colour_get(_average));
    draw_text(12, 30, "AVG  " + string(round(_average)));

    draw_set_colour(c_white);
    draw_set_alpha(1);
}