/// @description Starts a dash after a valid second Shift press.
function sc_player_dash_begin(_player)
{
    var _movement = _player.movement;
    var _dash = _movement.dash;
    var _stats = _player.ship.stats.final;

    if (!sc_player_resource_spend(_player, ResourceType.FUEL, _stats.fuel_dash_cost))
        return false;

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
    sc_player_thrust_ignition_emit(_player, 1.5);

    // Insert player dash audio and camera impulse here.
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
    sc_player_primary_weapon_update(_player);
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