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

    _movement.input_x = keyboard_check(ord("D")) - keyboard_check(ord("A"));
    _movement.input_y = keyboard_check(ord("S")) - keyboard_check(ord("W"));
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

/// @description Draws fading baked Shard afterimages behind the player.
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

    for (var _i = _dash.ghost_count - 1; _i >= 0; _i--)
    {
        var _ghost = _dash.ghosts[_i];
        var _alpha = (_ghost.life / _dash.ghost_life) * 0.32;

        draw_sprite_ext(
            _cache.hull[_hull_stage],
            0,
            _ghost.x,
            _ghost.y,
            1,
            1,
            _ghost.angle,
            _visual.palette.energy,
            _alpha
        );

        if (_armour_visible)
        {
            draw_sprite_ext(
                _cache.armour[_armour_stage],
                0,
                _ghost.x,
                _ghost.y,
                1,
                1,
                _ghost.angle,
                _visual.palette.core,
                _alpha * 0.55
            );
        }
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
}