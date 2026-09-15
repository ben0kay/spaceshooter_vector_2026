/*
DEBUG ENEMY VISUAL GALLERY

F3 opens a paused, registry-driven gallery of every enemy.
Ships are assembled from their real baked component sprites at 1:1 GUI scale.
*/

/// @description Returns the required gallery-card height for one enemy.
function sc_debug_enemy_visual_card_height(_data)
{
    var _visual_height = max(
        _data.visual.radius * 2,
        _data.visual.bake.body_canvas_size
    );

    return max(220,ceil(_visual_height) + 100);
}

/// @description Creates the scrollable F3 baked-enemy gallery.
function sc_debug_enemy_visual_init(_hud)
{
    var _keys = variable_struct_get_names(global.data.enemies);
    var _entries = [];
    var _viewport = { x: 40, y: 100, width: 1700, height: 820 };
    var _gap = 18;
    var _card_width = floor((_viewport.width - _gap) * 0.5);
    var _content_y = 0;
    var _i = 0;

    while (_i < array_length(_keys))
    {
        var _left_key = _keys[_i];
        var _left_data = variable_struct_get(global.data.enemies,_left_key);
        var _left_canvas = _left_data.visual.bake.body_canvas_size;
        var _left_height = sc_debug_enemy_visual_card_height(_left_data);
        var _left_wide = _left_canvas > _card_width - 40;

        // Large ships receive an entire row at true 1:1 size.
        if (_left_wide)
        {
            array_push(_entries,{
                key: _left_key,
                x: 0,
                y: _content_y,
                width: _viewport.width,
                height: _left_height
            });

            _content_y += _left_height + _gap;
            ++_i;
            continue;
        }

        var _right_available = _i + 1 < array_length(_keys);
        var _right_key = "";
        var _right_height = 0;
        var _right_wide = false;

        if (_right_available)
        {
            _right_key = _keys[_i + 1];

            var _right_data = variable_struct_get(
                global.data.enemies,
                _right_key
            );

            _right_height = sc_debug_enemy_visual_card_height(_right_data);
            _right_wide =
                _right_data.visual.bake.body_canvas_size
                > _card_width - 40;
        }

        // Pair two normal-sized ships on the same row.
        if (_right_available && !_right_wide)
        {
            var _row_height = max(_left_height,_right_height);

            array_push(_entries,{
                key: _left_key,
                x: 0,
                y: _content_y,
                width: _card_width,
                height: _row_height
            });

            array_push(_entries,{
                key: _right_key,
                x: _card_width + _gap,
                y: _content_y,
                width: _card_width,
                height: _row_height
            });

            _content_y += _row_height + _gap;
            _i += 2;
            continue;
        }

        // Keep this normal ship alone when the next ship needs a wide row.
        array_push(_entries,{
            key: _left_key,
            x: 0,
            y: _content_y,
            width: _card_width,
            height: _left_height
        });

        _content_y += _left_height + _gap;
        ++_i;
    }

    _hud.debug_enemy_visual = {
        open: false,
        show_hardpoints: true,
        width: 1780,
        height: 960,
        viewport: _viewport,
        entries: _entries,
        content_height: max(0,_content_y - _gap),
        scroll: 0,
        scroll_target: 0,
        scroll_speed: 100,
        surface: -1,

        buttons: {
            hardpoints: sc_gui_button_create(
                "hardpoints",1484,26,210,38,
                "HARDPOINTS: ON",GUIButtonStyle.STANDARD
            ),

            close: sc_gui_button_create(
                "close",1712,26,38,38,
                "X",GUIButtonStyle.DANGER
            )
        }
    };

    _hud.debug_enemy_visual.buttons.hardpoints.selected = true;
    return true;
}

/// @description Opens or closes the F3 baked-enemy gallery.
function sc_debug_enemy_visual_toggle(_hud)
{
    var _debug = _hud.debug_enemy_visual;

    if (_debug.open)
    {
        _debug.open = false;
        global.LevelState = LevelState.PLAYING;
        return true;
    }

    if (global.LevelState != LevelState.PLAYING
    || global.PlayerState != PlayerState.ACTIVE
    || !instance_exists(global.player_id))
        return false;

    _debug.open = true;
    _debug.scroll = 0;
    _debug.scroll_target = 0;
    global.LevelState = LevelState.DEBUG;
    return true;
}

/// @description Updates scrolling and button input for the F3 gallery.
function sc_debug_enemy_visual_update(_hud)
{
    var _debug = _hud.debug_enemy_visual;
    if (!_debug.open) return;

    var _panel_x = floor((display_get_gui_width() - _debug.width) * 0.5);
    var _panel_y = floor((display_get_gui_height() - _debug.height) * 0.5);
    var _mouse_x = device_mouse_x_to_gui(0) - _panel_x;
    var _mouse_y = device_mouse_y_to_gui(0) - _panel_y;
    var _pressed = global.input.action.ui_select_pressed;

    if (sc_gui_button_update(_debug.buttons.close,_mouse_x,_mouse_y,_pressed))
    {
        sc_debug_enemy_visual_toggle(_hud);
        return;
    }

    if (sc_gui_button_update(_debug.buttons.hardpoints,_mouse_x,_mouse_y,_pressed))
    {
        _debug.show_hardpoints = !_debug.show_hardpoints;
        _debug.buttons.hardpoints.selected = _debug.show_hardpoints;
        _debug.buttons.hardpoints.text = _debug.show_hardpoints
            ? "HARDPOINTS: ON"
            : "HARDPOINTS: OFF";
    }

    var _viewport = _debug.viewport;
    var _mouse_inside = point_in_rectangle(
        _mouse_x,_mouse_y,
        _viewport.x,_viewport.y,
        _viewport.x + _viewport.width,
        _viewport.y + _viewport.height
    );

    if (_mouse_inside)
    {
        var _wheel = mouse_wheel_down() - mouse_wheel_up();

        if (_wheel != 0)
            _debug.scroll_target += _wheel * _debug.scroll_speed;
    }

    var _scroll_max = max(0,_debug.content_height - _viewport.height);
    _debug.scroll_target = clamp(_debug.scroll_target,0,_scroll_max);
    _debug.scroll = lerp(_debug.scroll,_debug.scroll_target,0.35);

    if (abs(_debug.scroll - _debug.scroll_target) < 0.1)
        _debug.scroll = _debug.scroll_target;
}

/// @description Draws one complete enemy from its baked component cache.
function sc_debug_enemy_visual_ship_draw(_enemy_key,_x,_y,_show_hardpoints)
{
    var _data = variable_struct_get(global.data.enemies,_enemy_key);
    var _visual = _data.visual;
    var _cache = sc_enemy_visual_cache_get(_enemy_key);
    var _radius = _visual.radius;
    var _angle = 0;

    if (is_struct(_cache.damage_layers))
    {
        draw_sprite_ext(
            _cache.damage_layers.hull[0],0,
            _x,_y,1,1,_angle,c_white,1
        );

        draw_sprite_ext(
            _cache.damage_layers.armour[0],0,
            _x,_y,1,1,_angle,c_white,1
        );
    }
    else
    {
        draw_sprite_ext(
            _cache.body,0,
            _x,_y,1,1,_angle,c_white,1
        );
    }

    var _core_x = _x
        + lengthdir_x(_visual.core.forward * _radius,_angle)
        + lengthdir_x(_visual.core.side * _radius,_angle + 90);

    var _core_y = _y
        + lengthdir_y(_visual.core.forward * _radius,_angle)
        + lengthdir_y(_visual.core.side * _radius,_angle + 90);

    draw_sprite_ext(
        _cache.core,0,
        _core_x,_core_y,1,1,_angle,c_white,1
    );

    if (_show_hardpoints)
    {
        for (var _i = 0; _i < array_length(_data.hardpoints); ++_i)
        {
            var _hardpoint = _data.hardpoints[_i];
            var _hardpoint_angle = _angle + _hardpoint.angle;
            var _hardpoint_x = _x
                + lengthdir_x(_hardpoint.forward * _radius,_angle)
                + lengthdir_x(_hardpoint.side * _radius,_angle + 90);

            var _hardpoint_y = _y
                + lengthdir_y(_hardpoint.forward * _radius,_angle)
                + lengthdir_y(_hardpoint.side * _radius,_angle + 90);

            draw_sprite_ext(
                _cache.hardpoints[_i],0,
                _hardpoint_x,_hardpoint_y,
                1,1,_hardpoint_angle,c_white,1
            );
        }
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws one enemy gallery card and its true-size baked assembly.
function sc_debug_enemy_visual_card_draw(_hud,_entry,_draw_y)
{
    var _palette = _hud.data.palette;
    var _data = variable_struct_get(global.data.enemies,_entry.key);
    var _visual = _data.visual;
    var _x1 = _entry.x;
    var _y1 = _draw_y;
    var _x2 = _x1 + _entry.width;
    var _y2 = _y1 + _entry.height;
    var _ship_x = floor((_x1 + _x2) * 0.5);
    var _ship_y = floor(_y1 + 78 + (_entry.height - 78) * 0.5);

    draw_set_alpha(0.88);
    draw_set_colour(_palette.background);
    draw_rectangle(_x1,_y1,_x2,_y2,false);

    draw_set_alpha(1);
    draw_set_colour(_palette.outline);
    draw_rectangle(_x1,_y1,_x2,_y2,true);

    draw_set_alpha(0.1);
    draw_set_colour(_palette.accent);
    draw_line(_ship_x - 16,_ship_y,_ship_x + 16,_ship_y);
    draw_line(_ship_x,_ship_y - 16,_ship_x,_ship_y + 16);

    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_colour(_palette.core);
    draw_text(_x1 + 18,_y1 + 14,string_upper(_data.identity.name));

    draw_set_colour(_palette.muted);
    draw_text(
        _x1 + 18,_y1 + 40,
        _entry.key
        + "  //  RADIUS " + string(_visual.radius)
        + "  //  CANVAS " + string(_visual.bake.body_canvas_size)
        + "  //  HARDPOINTS " + string(array_length(_data.hardpoints))
    );

    draw_set_alpha(0.3);
    draw_set_colour(_palette.outline);
    draw_line(_x1 + 18,_y1 + 66,_x2 - 18,_y1 + 66);

    draw_set_alpha(1);
    sc_debug_enemy_visual_ship_draw(
        _entry.key,_ship_x,_ship_y,
        _hud.debug_enemy_visual.show_hardpoints
    );
}

/// @description Ensures the F3 clipping surface exists at the correct size.
function sc_debug_enemy_visual_surface_ensure(_debug)
{
    var _viewport = _debug.viewport;

    if (surface_exists(_debug.surface)
    && surface_get_width(_debug.surface) == _viewport.width
    && surface_get_height(_debug.surface) == _viewport.height)
        return true;

    if (surface_exists(_debug.surface))
        surface_free(_debug.surface);

    _debug.surface = surface_create(_viewport.width,_viewport.height);
    return surface_exists(_debug.surface);
}

/// @description Draws the scrollable F3 baked-enemy gallery.
function sc_debug_enemy_visual_draw(_hud)
{
    var _debug = _hud.debug_enemy_visual;
    if (!_debug.open) return;

    var _palette = _hud.data.palette;
    var _viewport = _debug.viewport;
    var _width = _debug.width;
    var _height = _debug.height;
    var _x = floor((display_get_gui_width() - _width) * 0.5);
    var _y = floor((display_get_gui_height() - _height) * 0.5);

    draw_set_alpha(0.78);
    draw_set_colour(c_black);
    draw_rectangle(
        0,0,
        display_get_gui_width(),
        display_get_gui_height(),
        false
    );

    draw_set_alpha(0.98);
    draw_set_colour(_palette.background);
    draw_rectangle(_x,_y,_x + _width,_y + _height,false);

    draw_set_alpha(1);
    draw_set_colour(_palette.outline);
    draw_rectangle(_x,_y,_x + _width,_y + _height,true);

    draw_set_colour(_palette.accent);
    draw_line_width(_x + 24,_y + 78,_x + _width - 24,_y + 78,2);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_colour(_palette.core);
    draw_text(_x + 40,_y + 27,"DEBUG // BAKED ENEMY VISUAL GALLERY");

    draw_set_colour(_palette.muted);
    draw_text(
        _x + 40,_y + 52,
        string(array_length(_debug.entries))
        + " REGISTERED ENEMIES  //  TRUE SIZE 1:1  //  MOUSE WHEEL TO SCROLL"
    );

    if (sc_debug_enemy_visual_surface_ensure(_debug))
    {
        surface_set_target(_debug.surface);
        draw_clear_alpha(_palette.void,1);

        for (var _i = 0; _i < array_length(_debug.entries); ++_i)
        {
            var _entry = _debug.entries[_i];
            var _draw_y = _entry.y - _debug.scroll;

            if (_draw_y + _entry.height < 0 || _draw_y > _viewport.height)
                continue;

            sc_debug_enemy_visual_card_draw(_hud,_entry,_draw_y);
        }

        draw_set_alpha(1);
        draw_set_colour(c_white);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        surface_reset_target();

        draw_surface(
            _debug.surface,
            _x + _viewport.x,
            _y + _viewport.y
        );
    }

    var _scroll_max = max(0,_debug.content_height - _viewport.height);

    if (_scroll_max > 0)
    {
        var _track_x = _x + _width - 22;
        var _track_y1 = _y + _viewport.y;
        var _track_y2 = _track_y1 + _viewport.height;
        var _handle_height = max(
            48,
            _viewport.height * (_viewport.height / _debug.content_height)
        );

        var _handle_y = _track_y1
            + (_debug.scroll / _scroll_max)
            * (_viewport.height - _handle_height);

        draw_set_alpha(0.35);
        draw_set_colour(_palette.outline);
        draw_rectangle(_track_x,_track_y1,_track_x + 6,_track_y2,false);

        draw_set_alpha(1);
        draw_set_colour(_palette.accent);
        draw_rectangle(
            _track_x,_handle_y,
            _track_x + 6,_handle_y + _handle_height,
            false
        );
    }

    sc_gui_button_draw(_debug.buttons.hardpoints,_x,_y,_palette);
    sc_gui_button_draw(_debug.buttons.close,_x,_y,_palette);

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

/// @description Releases the F3 gallery's temporary clipping surface.
function sc_debug_enemy_visual_cleanup(_hud)
{
    if (surface_exists(_hud.debug_enemy_visual.surface))
        surface_free(_hud.debug_enemy_visual.surface);

    _hud.debug_enemy_visual.surface = -1;
}