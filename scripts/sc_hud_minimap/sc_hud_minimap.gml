/*
HUD MINIMAP

A movable player radar with periodic contact caching.
The sweep and contact fades remain smooth while world searches are staggered.
*/

/// @description Returns the radar-dot radius for one enemy class.
function sc_hud_minimap_enemy_size_get(_class)
{
    switch (_class)
    {
        case EnemyClass.TINY: return 1.5;
        case EnemyClass.LIGHT: return 2;
        case EnemyClass.STANDARD: return 3;
        case EnemyClass.HEAVY: return 4.5;
        case EnemyClass.SUPERHEAVY: return 6;
        case EnemyClass.CAPITAL: return 8;
        case EnemyClass.TITAN: return 11;
    }

    return 2;
}

/// @description Returns the radar-dot radius for one asteroid size.
function sc_hud_minimap_asteroid_size_get(_size)
{
    switch (_size)
    {
        case AsteroidSize.SMALL: return 1;
        case AsteroidSize.MEDIUM: return 1.5;
        case AsteroidSize.LARGE: return 2.5;
        case AsteroidSize.HUGE: return 4;
    }

    return 1;
}

/// @description Finds one previously cached enemy contact.
function sc_hud_minimap_enemy_contact_find(_contacts, _target_id)
{
    for (var _i = 0; _i < array_length(_contacts); ++_i)
        if (_contacts[_i].target_id == _target_id)
            return _contacts[_i];

    return undefined;
}

/// @description Clears contacts and forces an immediate radar refresh.
function sc_hud_minimap_refresh_force(_minimap)
{
    _minimap.enemy_contacts = [];
    _minimap.asteroid_contacts = [];
    _minimap.next_enemy_update_tick = GAME_TICK;
    _minimap.next_asteroid_update_tick = GAME_TICK;
}

/// @description Caches enemy contacts and evaluates radar-specific asteroid concealment.
function sc_hud_minimap_enemies_refresh(_minimap, _player)
{
    var _list = ds_list_create();

    var _count = collision_circle_list(
        _player.x,
        _player.y,
        _minimap.range,
        o_enemy,
        false,
        true,
        _list,
        false
    );

    var _previous = _minimap.enemy_contacts;
    var _contacts = [];
    var _concealment = _minimap.concealment;

    for (var _i = 0; _i < _count; ++_i)
    {
        var _target = _list[| _i];

        if (!_target.initialized
        || _target.enemy.state == EnemyState.DEAD)
            continue;

        var _contact = sc_hud_minimap_enemy_contact_find(
            _previous,
            _target
        );

        if (!is_struct(_contact))
        {
            _contact = {
                target_id: _target,
                world_x: _target.x,
                world_y: _target.y,
                size: sc_hud_minimap_enemy_size_get(
                    _target.enemy.identity.ship_class
                ),
                alpha: 0,
                reveal_alpha: 1,
                concealment: 0,
                next_concealment_tick: GAME_TICK,
                pulse: 0
            };
        }
        else
        {
            _contact.world_x = _target.x;
            _contact.world_y = _target.y;
        }

        if (GAME_TICK >= _contact.next_concealment_tick)
        {
            _contact.concealment =
                sc_asteroid_concealment_score_get(
                    _player.x,
                    _player.y,
                    _target.x,
                    _target.y,
                    _concealment
                );

            _contact.next_concealment_tick =
                GAME_TICK
                + max(1, round(_concealment.update_interval));
        }

        var _distance = point_distance(
            _player.x,
            _player.y,
            _target.x,
            _target.y
        );

        var _closeness = 1 - clamp(
            _distance / _minimap.range,
            0,
            1
        );

        var _concealed_alpha = lerp(
            _concealment.alpha_min,
            _concealment.alpha_max,
            power(
                _closeness,
                _concealment.distance_power
            )
        );

        _contact.reveal_alpha = lerp(
            1,
            _concealed_alpha,
            _contact.concealment
        );

        array_push(_contacts, _contact);
    }

    ds_list_destroy(_list);

    _minimap.enemy_contacts = _contacts;
    _minimap.next_enemy_update_tick =
        GAME_TICK + _minimap.enemy_update_interval;
}

/// @description Caches nearby asteroid contacts at a slower interval.
function sc_hud_minimap_asteroids_refresh(_minimap, _player)
{
    var _list = ds_list_create();
    var _count = collision_circle_list(
        _player.x,
        _player.y,
        _minimap.range,
        o_asteroid,
        false,
        true,
        _list,
        false
    );

    var _contacts = [];

    for (var _i = 0; _i < _count; ++_i)
    {
        var _target = _list[| _i];
        if (!_target.initialized) continue;

        array_push(_contacts, {
            target_id: _target,
            world_x: _target.x,
            world_y: _target.y,
            size: sc_hud_minimap_asteroid_size_get(_target.asteroid.size)
        });
    }

    ds_list_destroy(_list);
    _minimap.asteroid_contacts = _contacts;
    _minimap.next_asteroid_update_tick = GAME_TICK + _minimap.asteroid_update_interval;
}

/// @description Updates the radar sweep and reveals contacts according to certainty.
function sc_hud_minimap_sweep_update(_minimap, _player)
{
    var _previous_angle = _minimap.sweep_angle;

    _minimap.sweep_angle = (
        _minimap.sweep_angle
        - _minimap.sweep_speed
        + 360
    ) mod 360;

    var _travel = (
        _previous_angle
        - _minimap.sweep_angle
        + 360
    ) mod 360;

    var _contacts = _minimap.enemy_contacts;

    for (var _i = 0; _i < array_length(_contacts); ++_i)
    {
        var _contact = _contacts[_i];

        _contact.alpha = max(
            0,
            _contact.alpha
                - 1 / _minimap.contact_fade_duration
        );

        _contact.pulse = max(
            0,
            _contact.pulse - 0.08
        );

        var _direction = point_direction(
            _player.x,
            _player.y,
            _contact.world_x,
            _contact.world_y
        );

        var _clockwise_distance = (
            _previous_angle
            - _direction
            + 360
        ) mod 360;

        if (_clockwise_distance
        <= _travel + _minimap.detection_width)
        {
            _contact.alpha = _contact.reveal_alpha;
            _contact.pulse = _contact.reveal_alpha;
        }
    }
}

/// @description Changes radar range by one configured zoom level.
function sc_hud_minimap_zoom_change(_minimap, _amount)
{
    var _index = clamp(
        _minimap.range_index + _amount,
        0,
        array_length(_minimap.range_levels) - 1
    );

    if (_index == _minimap.range_index) return;

    _minimap.range_index = _index;
    _minimap.range = _minimap.range_levels[_index];
    sc_hud_minimap_refresh_force(_minimap);
}

/// @description Updates dragging, buttons, cached contacts and radar sweep.
function sc_hud_minimap_update(_hud)
{
    var _data = _hud.data.minimap;
    var _minimap = _hud.minimap;
    var _mouse_x = device_mouse_x_to_gui(0);
    var _mouse_y = device_mouse_y_to_gui(0);
    var _pressed = mouse_check_button_pressed(mb_left);
    var _released = mouse_check_button_released(mb_left);

    if (_released)
        _minimap.dragging = false;

    if (global.PlayerState == PlayerState.ACTIVE && _pressed)
    {
        if (_minimap.minimized)
        {
            if (point_in_rectangle(
                _mouse_x,
                _mouse_y,
                _minimap.x,
                _minimap.y,
                _minimap.x + _data.minimized_width,
                _minimap.y + _data.minimized_height
            ))
            {
                _minimap.minimized = false;
                sc_hud_minimap_refresh_force(_minimap);
            }
        }
        else
        {
            var _local_x = _mouse_x - _minimap.x;
            var _local_y = _mouse_y - _minimap.y;

            if (point_in_rectangle(
                _local_x,
                _local_y,
                _data.width - 30,
                5,
                _data.width - 7,
                25
            ))
            {
                _minimap.minimized = true;
                _minimap.dragging = false;
            }
            else if (point_in_rectangle(
                _local_x,
                _local_y,
                12,
                _data.height - 25,
                38,
                _data.height - 7
            ))
            {
                sc_hud_minimap_zoom_change(_minimap, -1);
            }
            else if (point_in_rectangle(
                _local_x,
                _local_y,
                _data.width - 38,
                _data.height - 25,
                _data.width - 12,
                _data.height - 7
            ))
            {
                sc_hud_minimap_zoom_change(_minimap, 1);
            }
            else if (_local_y >= 0 && _local_y <= _data.header_height)
            {
                _minimap.dragging = true;
                _minimap.drag_offset_x = _local_x;
                _minimap.drag_offset_y = _local_y;
            }
        }
    }

    if (_minimap.dragging && mouse_check_button(mb_left))
    {
        var _gui_width = display_get_gui_width();
        var _gui_height = display_get_gui_height();

        _minimap.x = clamp(
            _mouse_x - _minimap.drag_offset_x,
            0,
            _gui_width - _data.width
        );

        _minimap.y = clamp(
            _mouse_y - _minimap.drag_offset_y,
            0,
            _gui_height - _data.height
        );
    }

    if (_minimap.minimized || !instance_exists(global.player_id)) return;

    var _player = global.player_id;

    if (GAME_TICK >= _minimap.next_enemy_update_tick)
        sc_hud_minimap_enemies_refresh(_minimap, _player);

    if (GAME_TICK >= _minimap.next_asteroid_update_tick)
        sc_hud_minimap_asteroids_refresh(_minimap, _player);

    sc_hud_minimap_sweep_update(_minimap, _player);
}

/// @description Converts one world position into local radar coordinates.
function sc_hud_minimap_position_get(_minimap, _data, _player, _world_x, _world_y)
{
    var _scale = _data.radar_radius / _minimap.range;

    return {
        x: _data.radar_centre_x + (_world_x - _player.x) * _scale,
        y: _data.radar_centre_y + (_world_y - _player.y) * _scale
    };
}

/// @description Draws the minimized radar restore tab.
function sc_hud_minimap_minimized_draw(_hud)
{
    var _data = _hud.data.minimap;
    var _palette = _hud.data.palette;
    var _minimap = _hud.minimap;
    var _x = _minimap.x;
    var _y = _minimap.y;
    var _width = _data.minimized_width;
    var _height = _data.minimized_height;

    draw_set_alpha(0.96);
    draw_set_colour(_palette.panel);
    draw_rectangle(_x, _y, _x + _width, _y + _height, false);

    draw_set_colour(_palette.outline);
    draw_rectangle(_x, _y, _x + _width, _y + _height, true);

    draw_set_colour(_palette.accent);
    draw_line_width(_x + 7, _y + 4, _x + 34, _y + 4, 2);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_colour(_palette.text);
    draw_text(_x + _width * 0.5, _y + _height * 0.5, "RADAR  +");
}

/// @description Draws cached asteroid contacts.
function sc_hud_minimap_asteroids_draw(_hud, _player)
{
    var _data = _hud.data.minimap;
    var _palette = _hud.data.palette;
    var _minimap = _hud.minimap;
    var _contacts = _minimap.asteroid_contacts;

    draw_set_colour(_palette.muted);
    draw_set_alpha(0.42);

    for (var _i = 0; _i < array_length(_contacts); ++_i)
    {
        var _contact = _contacts[_i];
        var _position = sc_hud_minimap_position_get(
            _minimap,
            _data,
            _player,
            _contact.world_x,
            _contact.world_y
        );

        var _dx = _position.x - _data.radar_centre_x;
        var _dy = _position.y - _data.radar_centre_y;

        if (_dx * _dx + _dy * _dy <= sqr(_data.radar_radius))
            draw_circle(
                _minimap.x + _position.x,
                _minimap.y + _position.y,
                _contact.size,
                false
            );
    }
}

/// @description Draws cached world structures within radar range.
function sc_hud_minimap_structures_draw(_hud, _player)
{
    var _data = _hud.data.minimap;
    var _palette = _hud.data.palette;
    var _minimap = _hud.minimap;
    var _contacts = _hud.sector_map.structure_contacts;

    draw_set_alpha(0.9);

    for (var _i = 0; _i < array_length(_contacts); ++_i)
    {
        var _contact = _contacts[_i];

        if (sc_point_distance_sq(
            _player.x,
            _player.y,
            _contact.world_x,
            _contact.world_y
        ) > sqr(_minimap.range))
            continue;

        var _position = sc_hud_minimap_position_get(
            _minimap,
            _data,
            _player,
            _contact.world_x,
            _contact.world_y
        );

        var _dx = _position.x - _data.radar_centre_x;
        var _dy = _position.y - _data.radar_centre_y;

        if (_dx * _dx + _dy * _dy > sqr(_data.radar_radius))
            continue;

        sc_hud_map_structure_symbol_draw(
            _minimap.x + _position.x,
            _minimap.y + _position.y,
            4,
            _contact.type,
            _palette
        );
    }
}

/// @description Draws fading red enemy contacts.
function sc_hud_minimap_enemies_draw(_hud, _player)
{
    var _data = _hud.data.minimap;
    var _minimap = _hud.minimap;
    var _contacts = _minimap.enemy_contacts;
    var _colour = make_colour_rgb(255, 48, 65);

    for (var _i = 0; _i < array_length(_contacts); ++_i)
    {
        var _contact = _contacts[_i];
        if (_contact.alpha <= 0) continue;

        var _position = sc_hud_minimap_position_get(
            _minimap,
            _data,
            _player,
            _contact.world_x,
            _contact.world_y
        );

        var _dx = _position.x - _data.radar_centre_x;
        var _dy = _position.y - _data.radar_centre_y;
        if (_dx * _dx + _dy * _dy > sqr(_data.radar_radius)) continue;

        var _x = _minimap.x + _position.x;
        var _y = _minimap.y + _position.y;

        if (_contact.pulse > 0)
        {
            draw_set_colour(_colour);
            draw_set_alpha(_contact.pulse * 0.25);
            draw_circle(
                _x,
                _y,
                _contact.size + (1 - _contact.pulse) * 10,
                true
            );
        }

        draw_set_colour(_colour);
        draw_set_alpha(_contact.alpha * 0.28);
        draw_circle(_x, _y, _contact.size + 2, false);

        draw_set_alpha(_contact.alpha);
        draw_circle(_x, _y, _contact.size, false);
    }
}

/// @description Draws the clockwise radar sweep and fading trail lines.
function sc_hud_minimap_sweep_draw(_hud)
{
    var _data = _hud.data.minimap;
    var _palette = _hud.data.palette;
    var _minimap = _hud.minimap;
    var _centre_x = _minimap.x + _data.radar_centre_x;
    var _centre_y = _minimap.y + _data.radar_centre_y;

    for (var _i = _data.sweep_trails; _i >= 0; --_i)
    {
        var _angle = _minimap.sweep_angle + _i * _data.sweep_trail_spacing;
        var _alpha = lerp(0.06, 0.72, 1 - _i / (_data.sweep_trails + 1));
        var _end_x = _centre_x + lengthdir_x(_data.radar_radius, _angle);
        var _end_y = _centre_y + lengthdir_y(_data.radar_radius, _angle);

        draw_set_colour(_i == 0 ? _palette.core : _palette.accent);
        draw_set_alpha(_alpha);
        draw_line_width(
            _centre_x,
            _centre_y,
            _end_x,
            _end_y,
            _i == 0 ? 2 : 1
        );
    }
}

/// @description Draws the complete movable minimap.
function sc_hud_minimap_draw(_hud)
{
    var _data = _hud.data.minimap;
    var _palette = _hud.data.palette;
    var _minimap = _hud.minimap;

    if (_minimap.minimized)
    {
        sc_hud_minimap_minimized_draw(_hud);
        return;
    }

    var _x = _minimap.x;
    var _y = _minimap.y;

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_sprite(_hud.cache.minimap_dock, 0, _x, _y);

    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_set_colour(_palette.text);
    draw_text(_x + 15, _y + _data.header_height * 0.5, "TACTICAL RADAR");

    draw_set_halign(fa_center);
    draw_set_colour(_palette.accent);
    draw_text(_x + _data.width - 18, _y + 15, "_");

    if (instance_exists(global.player_id))
    {
        var _player = global.player_id;

        sc_hud_minimap_asteroids_draw(_hud, _player);
		sc_hud_minimap_structures_draw(_hud, _player);
        sc_hud_minimap_enemies_draw(_hud, _player);
        sc_hud_minimap_sweep_draw(_hud);

        var _centre_x = _x + _data.radar_centre_x;
        var _centre_y = _y + _data.radar_centre_y;
        var _angle = _player.draw_angle;

        draw_set_colour(_palette.core);
        draw_set_alpha(1);
        draw_triangle(
            _centre_x + lengthdir_x(8, _angle),
            _centre_y + lengthdir_y(8, _angle),
            _centre_x + lengthdir_x(6, _angle + 145),
            _centre_y + lengthdir_y(6, _angle + 145),
            _centre_x + lengthdir_x(6, _angle - 145),
            _centre_y + lengthdir_y(6, _angle - 145),
            false
        );
    }

    var _footer_y = _y + _data.height - 16;

    draw_set_alpha(1);
    draw_set_colour(_palette.panel_light);
    draw_rectangle(_x + 12, _footer_y - 9, _x + 38, _footer_y + 9, false);
    draw_rectangle(_x + _data.width - 38, _footer_y - 9, _x + _data.width - 12, _footer_y + 9, false);

    draw_set_colour(_palette.outline);
    draw_rectangle(_x + 12, _footer_y - 9, _x + 38, _footer_y + 9, true);
    draw_rectangle(_x + _data.width - 38, _footer_y - 9, _x + _data.width - 12, _footer_y + 9, true);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_colour(_palette.core);
    draw_text(_x + 25, _footer_y, "-");
    draw_text(_x + _data.width - 25, _footer_y, "+");

    draw_set_colour(_palette.muted);
    draw_text(
        _x + _data.width * 0.5,
        _footer_y,
        "RANGE // " + string(_minimap.range)
    );

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}