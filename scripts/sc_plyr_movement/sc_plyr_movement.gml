/// @description Updates player movement timers and dash ghost lifetimes.
function sc_player_movement_runtime_update(_player)
{
    var _dash = _player.movement.dash;

    if (_dash.cooldown_remaining > 0) _dash.cooldown_remaining--;
    if (_dash.double_tap_remaining > 0) _dash.double_tap_remaining--;

    var _write = 0;

    for (var _i = 0; _i < _dash.ghost_count; _i++)
    {
        var _ghost = _dash.ghosts[_i];
        _ghost.life--;

        if (_ghost.life <= 0) continue;

        _dash.ghosts[_write] = _ghost;
        _write++;
    }

    for (var _i = _write; _i < _dash.ghost_count; _i++)
        _dash.ghosts[_i] = undefined;

    _dash.ghost_count = _write;
}

/// @description Reads and normalizes current WASD movement input.
function sc_player_input_update(_player)
{
    var _movement = _player.movement;

	_movement.input_x = keyboard_check(vk_right) - keyboard_check(vk_left);
	_movement.input_y = keyboard_check(vk_down) - keyboard_check(vk_up);
    _movement.moving = _movement.input_x != 0 || _movement.input_y != 0;

    if (!_movement.moving) return;

    var _length = point_distance(0, 0, _movement.input_x, _movement.input_y);
    _movement.input_x /= _length;
    _movement.input_y /= _length;
}

/// @description Updates player mouse aiming and visual rotation.
function sc_player_aim_update(_player)
{
    var _aim = _player.aim;
    var _turn_speed = _player.ship.stats.final.turn_speed;

    _aim.world_x = mouse_x;
    _aim.world_y = mouse_y;
    _aim.direction = point_direction(_player.x, _player.y, _aim.world_x, _aim.world_y);

    var _turn = angle_difference(_aim.direction, _player.draw_angle);
    _player.draw_angle += clamp(_turn, -_turn_speed, _turn_speed);
    _player.draw_angle = _player.draw_angle mod 360;
}

/// @description Moves the player with axis-separated solid collision.
function sc_player_solid_move(_player)
{
    var _movement = _player.movement;
    var _radius = _player.ship.collision.radius;
    var _next_x = _player.x + _movement.velocity_x;
    var _next_y = _player.y + _movement.velocity_y;

    if (collision_circle(_next_x, _player.y, _radius, o_solid, false, true) == noone)
        _player.x = _next_x;
    else
        _movement.velocity_x = 0;

    if (collision_circle(_player.x, _next_y, _radius, o_solid, false, true) == noone)
        _player.y = _next_y;
    else
        _movement.velocity_y = 0;

    _player.x = clamp(_player.x, _radius, room_width - _radius);
    _player.y = clamp(_player.y, _radius, room_height - _radius);
    _movement.speed = point_distance(0, 0, _movement.velocity_x, _movement.velocity_y);
}

/// @description Resolves whether the player may currently fire weapons.
function sc_player_combat_permission_update(_player)
{
    var _stats = _player.ship.stats.final;
    var _state = global.PlayerState;

    switch (_state)
    {
        case PlayerState.ACTIVE:
            _player.combat.weapons_allowed =
                !_player.movement.boost.active ||
                _stats.weapons_while_boosting > 0;
        break;

        case PlayerState.DASHING:
            _player.combat.weapons_allowed = _stats.weapons_while_dashing > 0;
        break;

        default:
            _player.combat.weapons_allowed = false;
        break;
    }
}

/// @description Starts a dash after a valid second Shift press.
function sc_player_dash_begin(_player)
{
    var _movement = _player.movement;
    var _dash = _movement.dash;
    var _stats = _player.ship.stats.final;

    if (_movement.speed > 0.05)
        _dash.direction = point_direction(0, 0, _movement.velocity_x, _movement.velocity_y);
    else if (_movement.moving)
        _dash.direction = point_direction(0, 0, _movement.input_x, _movement.input_y);
    else
        _dash.direction = _player.draw_angle;

    _movement.velocity_x = lengthdir_x(_stats.dash_speed, _dash.direction);
    _movement.velocity_y = lengthdir_y(_stats.dash_speed, _dash.direction);
    _movement.speed = _stats.dash_speed;
    _movement.boost.active = false;

    _dash.remaining = max(1, round(_stats.dash_duration));
    _dash.cooldown_remaining = max(1, round(_stats.dash_cooldown));
    _dash.double_tap_remaining = 0;
    _dash.invulnerable = _stats.dash_invulnerable > 0;
    _dash.ghost_count = 0;

    global.PlayerState = PlayerState.DASHING;
    sc_player_combat_permission_update(_player);

    // Insert player dash ignition particle burst and audio here.
    return true;
}

/// @description Processes first and second Shift presses.
function sc_player_dash_input_update(_player)
{
    var _movement = _player.movement;
    var _dash = _movement.dash;
    var _stats = _player.ship.stats.final;

    if (!keyboard_check_pressed(vk_shift) || !_movement.moving) return false;
    if (_dash.cooldown_remaining > 0) return false;

    if (_dash.double_tap_remaining > 0)
        return sc_player_dash_begin(_player);

    _dash.double_tap_remaining = max(1, round(_stats.dash_double_tap_window));
    return false;
}

/// @description Updates ordinary acceleration and held-Shift boost.
function sc_player_normal_movement_update(_player)
{
    var _movement = _player.movement;
    var _stats = _player.ship.stats.final;

    _movement.boost.active = keyboard_check(vk_shift) && _movement.moving;

    var _speed_max = _stats.speed_max;
    if (_movement.boost.active) _speed_max *= _stats.boost_speed_multiplier;

    var _target_vx = _movement.input_x * _speed_max;
    var _target_vy = _movement.input_y * _speed_max;
    var _change = _movement.moving ? _stats.acceleration : _stats.deceleration;

    _movement.velocity_x += clamp(_target_vx - _movement.velocity_x, -_change, _change);
    _movement.velocity_y += clamp(_target_vy - _movement.velocity_y, -_change, _change);

    if (abs(_movement.velocity_x) < 0.001) _movement.velocity_x = 0;
    if (abs(_movement.velocity_y) < 0.001) _movement.velocity_y = 0;

    sc_player_solid_move(_player);
}

/// @description Records one baked-sprite dash afterimage.
function sc_player_dash_ghost_record(_player)
{
    var _dash = _player.movement.dash;
    var _limit = _dash.ghost_limit;
    var _last = min(_dash.ghost_count, _limit - 1);

    for (var _i = _last; _i > 0; _i--)
        _dash.ghosts[_i] = _dash.ghosts[_i - 1];

    _dash.ghosts[0] = {
        x: _player.x,
        y: _player.y,
        angle: _player.draw_angle,
        life: _dash.ghost_life
    };

    _dash.ghost_count = min(_dash.ghost_count + 1, _limit);
}

/// @description Updates normal player movement, boost and dash activation.
function sc_player_update_active(_player)
{
    sc_player_input_update(_player);
    sc_player_aim_update(_player);

    if (sc_player_dash_input_update(_player))
    {
        sc_player_update_dashing(_player);
        return;
    }

    sc_player_normal_movement_update(_player);
    sc_player_combat_permission_update(_player);
    sc_player_visual_update(_player);
}

/// @description Updates the short direction-locked player dash.
function sc_player_update_dashing(_player)
{
    var _movement = _player.movement;
    var _dash = _movement.dash;
    var _stats = _player.ship.stats.final;

    sc_player_aim_update(_player);

    if ((_dash.remaining mod _dash.ghost_interval) == 0)
        sc_player_dash_ghost_record(_player);

    sc_player_solid_move(_player);
    sc_player_combat_permission_update(_player);
    sc_player_visual_update(_player);

    // Insert continuous player dash corridor particles here.

    _dash.remaining--;

    if (_dash.remaining > 0 && _movement.speed > 0.05) return;

    _movement.velocity_x *= _stats.dash_exit_speed_multiplier;
    _movement.velocity_y *= _stats.dash_exit_speed_multiplier;
    _movement.speed = point_distance(0, 0, _movement.velocity_x, _movement.velocity_y);

    _dash.remaining = 0;
    _dash.invulnerable = false;
    global.PlayerState = PlayerState.ACTIVE;
}

/// @description Updates player drift while temporarily stunned.
function sc_player_update_stunned(_player)
{
    var _movement = _player.movement;

    _movement.boost.active = false;
    _movement.velocity_x = lerp(_movement.velocity_x, 0, 0.12);
    _movement.velocity_y = lerp(_movement.velocity_y, 0, 0.12);

    sc_player_solid_move(_player);
    sc_player_combat_permission_update(_player);
    sc_player_visual_update(_player);
}

/// @description Updates player drift while systems are disabled.
function sc_player_update_disabled(_player)
{
    var _movement = _player.movement;

    _movement.boost.active = false;
    _movement.velocity_x = lerp(_movement.velocity_x, 0, 0.05);
    _movement.velocity_y = lerp(_movement.velocity_y, 0, 0.05);

    sc_player_solid_move(_player);
    sc_player_combat_permission_update(_player);
    sc_player_visual_update(_player);
}

/// @description Holds the destroyed player in an inert state.
function sc_player_update_destroyed(_player)
{
    _player.movement.boost.active = false;
    _player.movement.velocity_x = 0;
    _player.movement.velocity_y = 0;
    _player.movement.speed = 0;

    sc_player_combat_permission_update(_player);
    sc_player_visual_update(_player);
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

/// @description Returns one of four visual damage stages.
function sc_player_damage_visual_stage(_current, _maximum)
{
    var _ratio = _maximum > 0 ? _current / _maximum : 0;

    if (_ratio > 0.75) return 0;
    if (_ratio > 0.5) return 1;
    if (_ratio > 0.25) return 2;
    return 3;
}

/// @description Updates player-only visual animation.
function sc_player_visual_update(_player)
{
    var _visual = _player.ship.visual;
    var _runtime = _visual.runtime;
    if (!is_struct(_runtime.cache)) return;

    var _movement = _player.movement;
    var _speed_max = _player.ship.stats.final.speed_max;
    var _thrust_target = _speed_max > 0 ? clamp(_movement.speed / _speed_max, 0, 1) : 0;

    _runtime.thrust_power = lerp(
        _runtime.thrust_power,
        _thrust_target,
        _thrust_target > _runtime.thrust_power ? 0.2 : 0.12
    );

    var _wing = _visual.wing;
    var _wing_target = _wing.fold_idle;

    if (global.PlayerState == PlayerState.DASHING)
        _wing_target = _wing.fold_dash;
    else if (_movement.boost.active)
        _wing_target = _wing.fold_boost;
    else if (_movement.moving)
        _wing_target = _wing.fold_moving;

    _runtime.wing_fold = lerp(_runtime.wing_fold, _wing_target, _wing.fold_response);
    _runtime.shield_hit_alpha = max(0, _runtime.shield_hit_alpha - 0.06);
}

/// @description Applies one damage packet to the player's layered defence.
function sc_player_damage(_player, _packet)
{
    if (global.PlayerState == PlayerState.DESTROYED) return false;

    var _dash = _player.movement.dash;

    if (global.PlayerState == PlayerState.DASHING && _dash.invulnerable)
        return false;

    var _defence = _player.defence;
    var _result = sc_damage_resolve(
        _packet,
        _defence.shield.current,
        _defence.armour.current,
        _defence.hull.current
    );

    _defence.shield.current = _result.shield;
    _defence.armour.current = _result.armour;
    _defence.hull.current = _result.hull;

    if (_result.dealt.total <= 0) return false;

    _defence.shield.recharge_delay_remaining = _player.ship.stats.final.shield_recharge_delay;
    sc_health_bar_damage_show(_player.health_bar);

    if (_result.dealt.shield > 0)
        _player.ship.visual.runtime.shield_hit_alpha = 1;

    if (_defence.hull.current <= 0)
    {
        _defence.hull.current = 0;
        _player.movement.velocity_x = 0;
        _player.movement.velocity_y = 0;
        global.PlayerState = PlayerState.DESTROYED;

        // Insert player destruction effect and audio here.
    }

    // _result.effect is ready for the upcoming timed-effect manager.
    return true;
}

/// @description Updates player shield recharge after its damage delay expires.
function sc_player_defence_update(_player)
{
    var _shield = _player.defence.shield;
    if (_shield.current >= _shield.maximum) return;

    if (_shield.recharge_delay_remaining > 0)
    {
        _shield.recharge_delay_remaining--;
        return;
    }

    _shield.current = min(
        _shield.maximum,
        _shield.current + _player.ship.stats.final.shield_recharge_rate
    );
}

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

    if (_draw_thrust && _thrust_power > 0.01 && sprite_exists(_cache.thrust))
    {
        var _thrust_x = _player.x + lengthdir_x(-_radius * 0.92, _angle);
        var _thrust_y = _player.y + lengthdir_y(-_radius * 0.92, _angle);
        var _flicker = 0.94 + sin(GAME_TICK * 0.38 + _runtime.thrust_phase) * 0.06;

        draw_sprite_ext(
            _cache.thrust, 0, _thrust_x, _thrust_y,
            (0.3 + _thrust_power * 0.9) * _flicker,
            0.85 + _thrust_power * 0.2,
            _angle + 180, _colour, _thrust_power * _alpha
        );
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
        var _hinge_x = _player.x
            + lengthdir_x(_hinge_forward, _angle)
            + lengthdir_x(_hinge_side * _side, _angle + 90);

        var _hinge_y = _player.y
            + lengthdir_y(_hinge_forward, _angle)
            + lengthdir_y(_hinge_side * _side, _angle + 90);

        var _wing_angle = _angle + _fold * _side;
        var _wing_yscale = _side;

        draw_sprite_ext(
            _cache.wing_hull[_hull_stage], 0,
            _hinge_x, _hinge_y,
            1, _wing_yscale,
            _wing_angle, _colour, _alpha
        );

        if (_armour_visible)
        {
            draw_sprite_ext(
                _cache.wing_armour[_armour_stage], 0,
                _hinge_x, _hinge_y,
                1, _wing_yscale,
                _wing_angle, _colour, _alpha
            );
        }
    }

    draw_sprite_ext(_cache.hull[_hull_stage], 0, _player.x, _player.y, 1, 1, _angle, _colour, _alpha);

    if (_armour_visible)
        draw_sprite_ext(_cache.armour[_armour_stage], 0, _player.x, _player.y, 1, 1, _angle, _colour, _alpha);

    if (_draw_shield && _player.defence.shield.current > 0 && sprite_exists(_cache.shield))
    {
        var _shield_ratio = _player.defence.shield.current / _player.defence.shield.maximum;
        var _shield_pulse = 0.82 + sin(GAME_TICK * 0.08) * 0.12;
        var _shield_alpha = clamp(_shield_ratio * 0.55 * _shield_pulse + _runtime.shield_hit_alpha, 0, 1);

        draw_sprite_ext(_cache.shield, 0, _player.x, _player.y, 1, 1, _angle, _colour, _shield_alpha * _alpha);
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