/// @description Draws the player's current primitive fallback or baked layered ship.
function sc_player_draw_ship(_player, _colour, _alpha, _draw_thrust, _draw_shield)
{
    var _visual = _player.ship.visual;
    var _runtime = _visual.runtime;
    var _cache = _runtime.cache;

    if (!is_struct(_cache))
    {
        sc_player_draw_fallback(_player, _colour, _alpha);
        return;
    }

    var _thrust_power = _runtime.thrust_power;

    if (_draw_thrust && _thrust_power > 0.01 && sprite_exists(_cache.thrust))
    {
        var _thrust_x = _player.x + lengthdir_x(-_visual.radius * 0.72, _player.draw_angle);
        var _thrust_y = _player.y + lengthdir_y(-_visual.radius * 0.72, _player.draw_angle);
        var _flicker = 0.94 + sin(GAME_TICK * 0.38 + _runtime.thrust_phase) * 0.06;

        draw_sprite_ext(
            _cache.thrust,
            0,
            _thrust_x,
            _thrust_y,
            (0.25 + _thrust_power * 0.75) * _flicker,
            0.85 + _thrust_power * 0.15,
            _player.draw_angle + 180,
            _colour,
            _thrust_power * _alpha
        );
    }

    var _hull_stage = sc_player_damage_visual_stage(
        _player.defence.hull.current,
        _player.defence.hull.maximum
    );

    draw_sprite_ext(
        _cache.hull[_hull_stage],
        0,
        _player.x,
        _player.y,
        1,
        1,
        _player.draw_angle,
        _colour,
        _alpha
    );

    if (_player.defence.armour.current > 0)
    {
        var _armour_stage = sc_player_damage_visual_stage(
            _player.defence.armour.current,
            _player.defence.armour.maximum
        );

        draw_sprite_ext(
            _cache.armour[_armour_stage],
            0,
            _player.x,
            _player.y,
            1,
            1,
            _player.draw_angle,
            _colour,
            _alpha
        );
    }

    if (
        _draw_shield
        && _player.defence.shield.current > 0
        && sprite_exists(_cache.shield)
    )
    {
        var _shield_ratio = _player.defence.shield.current / _player.defence.shield.maximum;
        var _shield_pulse = 0.82 + sin(GAME_TICK * 0.08) * 0.12;
        var _shield_alpha = clamp(
            _shield_ratio * 0.55 * _shield_pulse
            + _runtime.shield_hit_alpha,
            0,
            1
        );

        draw_sprite_ext(
            _cache.shield,
            0,
            _player.x,
            _player.y,
            1,
            1,
            _player.draw_angle,
            _colour,
            _shield_alpha * _alpha
        );
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws the temporary primitive Fighter or Bastion fallback.
function sc_player_draw_fallback(_player, _colour, _alpha)
{
    var _visual = _player.ship.visual;
    var _scale = _visual.scale;
    var _angle = _player.draw_angle;
    var _primary = merge_colour(_visual.colour_primary, _colour, 0.35);
    var _secondary = merge_colour(_visual.colour_secondary, _colour, 0.35);

    var _nose_x = _player.x + lengthdir_x(34 * _scale, _angle);
    var _nose_y = _player.y + lengthdir_y(34 * _scale, _angle);
    var _back_top_x = _player.x + lengthdir_x(33 * _scale, _angle + 140);
    var _back_top_y = _player.y + lengthdir_y(33 * _scale, _angle + 140);
    var _back_mid_x = _player.x + lengthdir_x(13 * _scale, _angle + 180);
    var _back_mid_y = _player.y + lengthdir_y(13 * _scale, _angle + 180);
    var _back_bottom_x = _player.x + lengthdir_x(33 * _scale, _angle + 220);
    var _back_bottom_y = _player.y + lengthdir_y(33 * _scale, _angle + 220);

    draw_set_alpha(_alpha);

    draw_set_colour(make_colour_rgb(5, 12, 24));
    draw_circle(_player.x, _player.y, 30 * _scale, false);

    draw_set_colour(_primary);
    draw_triangle(_nose_x, _nose_y, _back_top_x, _back_top_y, _back_mid_x, _back_mid_y, false);
    draw_triangle(_nose_x, _nose_y, _back_mid_x, _back_mid_y, _back_bottom_x, _back_bottom_y, false);

    draw_set_colour(_secondary);
    draw_line_width(_player.x, _player.y, _nose_x, _nose_y, 2);

    draw_set_colour(_colour);
    draw_circle(_player.x, _player.y, 7 * _scale, false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}