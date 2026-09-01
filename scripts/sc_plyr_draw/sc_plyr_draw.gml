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

    var _angle = _player.draw_angle;
    var _radius = _visual.radius;
    var _thrust_power = _runtime.thrust_power;

    // Shared shield is drawn behind the complete ship.
    if (_draw_shield && _player.defence.shield.current > 0 && sprite_exists(_cache.shield))
    {
        var _shield_ratio = _player.defence.shield.current / _player.defence.shield.maximum;
        sc_visual_shield_sprite_draw(_cache.shield, _player.x, _player.y, _angle, _visual.palette, _shield_ratio, _runtime.shield_hit_alpha, _alpha);
    }

    if (_draw_thrust && _thrust_power > 0.01 && sprite_exists(_cache.thrust))
    {
        var _thrust_x = _player.x + lengthdir_x(-_radius * 0.92, _angle);
        var _thrust_y = _player.y + lengthdir_y(-_radius * 0.92, _angle);
        var _flicker = 0.94 + sin(GAME_TICK * 0.38 + _runtime.thrust_phase) * 0.06;
        draw_sprite_ext(_cache.thrust, 0, _thrust_x, _thrust_y, (0.3 + _thrust_power * 0.9) * _flicker, 0.85 + _thrust_power * 0.2, _angle + 180, _colour, _thrust_power * _alpha);
    }

    var _hull_stage = sc_player_damage_visual_stage(_player.defence.hull.current, _player.defence.hull.maximum);
    var _armour_visible = _player.defence.armour.current > 0;
    var _armour_stage = sc_player_damage_visual_stage(_player.defence.armour.current, _player.defence.armour.maximum);
    var _wing = _visual.wing;
    var _hinge_forward = _wing.hinge_forward * _radius;
    var _hinge_side = _wing.hinge_side * _radius;
    var _fold = _runtime.wing_fold;

    for (var _side = -1; _side <= 1; _side += 2)
    {
        var _hinge_x = _player.x + lengthdir_x(_hinge_forward, _angle) + lengthdir_x(_hinge_side * _side, _angle + 90);
        var _hinge_y = _player.y + lengthdir_y(_hinge_forward, _angle) + lengthdir_y(_hinge_side * _side, _angle + 90);
        draw_sprite_ext(_cache.wing_hull[_hull_stage], 0, _hinge_x, _hinge_y, 1, _side, _angle + _fold * _side, _colour, _alpha);
    }

    draw_sprite_ext(_cache.hull[_hull_stage], 0, _player.x, _player.y, 1, 1, _angle, _colour, _alpha);

    if (_armour_visible)
    {
        for (var _side = -1; _side <= 1; _side += 2)
        {
            var _hinge_x = _player.x + lengthdir_x(_hinge_forward, _angle) + lengthdir_x(_hinge_side * _side, _angle + 90);
            var _hinge_y = _player.y + lengthdir_y(_hinge_forward, _angle) + lengthdir_y(_hinge_side * _side, _angle + 90);
            draw_sprite_ext(_cache.wing_armour[_armour_stage], 0, _hinge_x, _hinge_y, 1, _side, _angle + _fold * _side, _colour, _alpha);
        }

        draw_sprite_ext(_cache.armour[_armour_stage], 0, _player.x, _player.y, 1, 1, _angle, _colour, _alpha);
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

/// @description Draws shrinking bright-aqua baked ship afterimages.
function sc_player_dash_ghosts_draw(_player)
{
    var _dash = _player.movement.dash;
    var _visual = _player.ship.visual;
    var _cache = _visual.runtime.cache;

    if (_dash.ghost_count <= 0 || !is_struct(_cache)) return;

    var _hull_stage = sc_player_damage_visual_stage(
        _player.defence.hull.current,
        _player.defence.hull.maximum
    );

    var _armour_visible = _player.defence.armour.current > 0;
    var _armour_stage = sc_player_damage_visual_stage(
        _player.defence.armour.current,
        _player.defence.armour.maximum
    );

    var _aqua = merge_colour(c_white, _visual.palette.energy, 0.7);

    for (var _i = _dash.ghost_count - 1; _i >= 0; _i--)
    {
        var _ghost = _dash.ghosts[_i];
        var _life_ratio = clamp(_ghost.life / _dash.ghost_life, 0, 1);
        var _scale = lerp(_dash.ghost_scale_min, 1, _life_ratio);
        var _alpha = power(_life_ratio, 1.25) * _dash.ghost_alpha_max;

        draw_sprite_ext(
            _cache.hull[_hull_stage],
            0,
            _ghost.x,
            _ghost.y,
            _scale,
            _scale,
            _ghost.angle,
            _aqua,
            _alpha
        );

        if (_armour_visible)
        {
            draw_sprite_ext(
                _cache.armour[_armour_stage],
                0,
                _ghost.x,
                _ghost.y,
                _scale,
                _scale,
                _ghost.angle,
                _aqua,
                _alpha * 0.75
            );
        }
    }

    gpu_set_blendmode(bm_add);

    for (var _i = _dash.ghost_count - 1; _i >= 0; _i--)
    {
        var _ghost = _dash.ghosts[_i];
        var _life_ratio = clamp(_ghost.life / _dash.ghost_life, 0, 1);
        var _scale = lerp(_dash.ghost_scale_min * 1.06, 1.06, _life_ratio);
        var _alpha = power(_life_ratio, 1.5) * 0.22;

        draw_sprite_ext(
            _cache.hull[_hull_stage],
            0,
            _ghost.x,
            _ghost.y,
            _scale,
            _scale,
            _ghost.angle,
            _visual.palette.energy,
            _alpha
        );
    }

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}
