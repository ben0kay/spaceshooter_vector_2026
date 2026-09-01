if (!initialized)
    exit;

var _visual = ship.visual;
var _runtime = _visual.runtime;
var _cache = _runtime.cache;

if (!is_struct(_cache))
{
    // Temporary fallback for Fighter and Bastion.
    var _scale = _visual.scale;
    var _primary = _visual.colour_primary;
    var _secondary = _visual.colour_secondary;

    var _nose_x = x + lengthdir_x(34 * _scale, draw_angle);
    var _nose_y = y + lengthdir_y(34 * _scale, draw_angle);
    var _back_top_x = x + lengthdir_x(33 * _scale, draw_angle + 140);
    var _back_top_y = y + lengthdir_y(33 * _scale, draw_angle + 140);
    var _back_mid_x = x + lengthdir_x(13 * _scale, draw_angle + 180);
    var _back_mid_y = y + lengthdir_y(13 * _scale, draw_angle + 180);
    var _back_bottom_x = x + lengthdir_x(33 * _scale, draw_angle + 220);
    var _back_bottom_y = y + lengthdir_y(33 * _scale, draw_angle + 220);

    draw_set_colour(make_colour_rgb(5, 12, 24));
    draw_circle(x, y, 30 * _scale, false);

    draw_set_colour(_primary);
    draw_triangle(_nose_x, _nose_y, _back_top_x, _back_top_y, _back_mid_x, _back_mid_y, false);
    draw_triangle(_nose_x, _nose_y, _back_mid_x, _back_mid_y, _back_bottom_x, _back_bottom_y, false);

    draw_set_colour(_secondary);
    draw_line_width(x, y, _nose_x, _nose_y, 2);

    draw_set_colour(c_white);
    draw_circle(x, y, 7 * _scale, false);
    exit;
}

var _thrust_power = _runtime.thrust_power;

if (_thrust_power > 0.01 && sprite_exists(_cache.thrust))
{
    var _thrust_x = x + lengthdir_x(-_visual.radius * 0.72, draw_angle);
    var _thrust_y = y + lengthdir_y(-_visual.radius * 0.72, draw_angle);
    var _flicker = 0.94 + sin(GAME_TICK * 0.38 + _runtime.thrust_phase) * 0.06;

    draw_sprite_ext(
        _cache.thrust,
        0,
        _thrust_x,
        _thrust_y,
        (0.25 + _thrust_power * 0.75) * _flicker,
        0.85 + _thrust_power * 0.15,
        draw_angle + 180,
        c_white,
        _thrust_power
    );
}

var _hull_stage = sc_player_damage_visual_stage(
    defence.hull.current,
    defence.hull.maximum
);

draw_sprite_ext(
    _cache.hull[_hull_stage],
    0,
    x,
    y,
    1,
    1,
    draw_angle,
    c_white,
    1
);

if (defence.armour.current > 0)
{
    var _armour_stage = sc_player_damage_visual_stage(
        defence.armour.current,
        defence.armour.maximum
    );

    draw_sprite_ext(
        _cache.armour[_armour_stage],
        0,
        x,
        y,
        1,
        1,
        draw_angle,
        c_white,
        1
    );
}

if (defence.shield.current > 0 && sprite_exists(_cache.shield))
{
    var _shield_ratio = defence.shield.current / defence.shield.maximum;
    var _shield_pulse = 0.82 + sin(GAME_TICK * 0.08) * 0.12;
    var _shield_alpha = clamp(_shield_ratio * 0.55 * _shield_pulse + _runtime.shield_hit_alpha, 0, 1);

    draw_sprite_ext(
        _cache.shield,
        0,
        x,
        y,
        1,
        1,
        draw_angle,
        c_white,
        _shield_alpha
    );
}