/*
DEBUG ENEMY SPAWNER

F1 opens a paused registry-driven enemy spawning panel.
Enemies are grouped into one column per currently registered faction.
*/

/// @description Creates the taller scrollable three-column F1 enemy-spawning interface.
function sc_debug_enemy_spawn_init(_hud)
{
    var _keys = variable_struct_get_names(global.data.enemies);
    var _enemy_buttons = [];
    var _factions = [
        { faction: Faction.SIMULANT, name: "SIMULANT" },
        { faction: Faction.CORPORATION, name: "CORPORATION" },
        { faction: Faction.REBEL, name: "REBEL" }
    ];

    var _viewport = { x: 34, y: 136, width: 1258, height: 510 };
    var _column_gap = 14;
    var _column_width = floor((_viewport.width - _column_gap * 2) / 3);
    var _button_height = 42;
    var _row_gap = 10;
    var _row_step = _button_height + _row_gap;
    var _faction_rows = [0,0,0];

    for (var _f = 0; _f < array_length(_factions); ++_f)
    {
        for (var _i = 0; _i < array_length(_keys); ++_i)
        {
            var _key = _keys[_i];
            var _enemy = variable_struct_get(global.data.enemies,_key);

            if (_enemy.identity.faction != _factions[_f].faction) continue;

            var _button = sc_gui_button_create(
                _key,
                _f * (_column_width + _column_gap),
                _faction_rows[_f] * _row_step,
                _column_width,
                _button_height,
                _enemy.identity.name,
                GUIButtonStyle.STANDARD
            );

            _button.faction_column = _f;
            array_push(_enemy_buttons,_button);
            ++_faction_rows[_f];
        }
    }

    var _largest_row_count = max(_faction_rows[0],max(_faction_rows[1],_faction_rows[2]));

    _hud.debug_enemy_spawn = {
        open: false,
        width: 1350,
        height: 855,

        factions: _factions,
        faction_rows: _faction_rows,
        enemy_buttons: _enemy_buttons,

        viewport: _viewport,
        column_gap: _column_gap,
        column_width: _column_width,
        row_step: _row_step,
        content_height: max(0,_largest_row_count * _row_step - _row_gap),

        scroll: 0,
        scroll_target: 0,
        scroll_speed: _row_step,

        amount: 1,
        spawn_distance: 1000,
        formation: DebugSpawnFormation.LINE,
        formation_radius: 500,

        buttons: {
            amount_1: sc_gui_button_create(1,220,720,82,42,"x1",GUIButtonStyle.STANDARD),
            amount_5: sc_gui_button_create(5,312,720,82,42,"x5",GUIButtonStyle.STANDARD),
            amount_10: sc_gui_button_create(10,404,720,82,42,"x10",GUIButtonStyle.STANDARD),

            formation_line: sc_gui_button_create(DebugSpawnFormation.LINE,220,772,128,42,"LINE",GUIButtonStyle.STANDARD),
            formation_circle: sc_gui_button_create(DebugSpawnFormation.CIRCLE,358,772,128,42,"CIRCLE",GUIButtonStyle.STANDARD),

            distance_500: sc_gui_button_create(500,720,720,120,42,"500 PX",GUIButtonStyle.STANDARD),
            distance_1000: sc_gui_button_create(1000,850,720,120,42,"1000 PX",GUIButtonStyle.STANDARD),
            distance_2000: sc_gui_button_create(2000,980,720,120,42,"2000 PX",GUIButtonStyle.STANDARD),
            distance_5000: sc_gui_button_create(5000,1110,720,120,42,"5000 PX",GUIButtonStyle.STANDARD),

            close: sc_gui_button_create("close",1282,26,38,38,"X",GUIButtonStyle.DANGER)
        }
    };

    return true;
}

/// @description Opens or closes the F1 enemy-spawning interface.
function sc_debug_enemy_spawn_toggle(_hud)
{
    var _debug = _hud.debug_enemy_spawn;

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

/// @description Spawns one registered enemy formation ahead of the player.
function sc_debug_enemy_spawn_execute(_enemy_key,_amount,_distance,_formation,_formation_radius)
{
    if (!instance_exists(global.player_id)
    || !variable_struct_exists(global.data.enemies,_enemy_key))
        return false;

    var _player = global.player_id;
    var _data = variable_struct_get(global.data.enemies,_enemy_key);
    var _radius = _data.visual.radius;
    var _spacing = max(160,_radius * 2.4);
    var _direction = _player.draw_angle;
    var _side_direction = _direction + 90;
    var _centre_x = _player.x + lengthdir_x(_distance,_direction);
    var _centre_y = _player.y + lengthdir_y(_distance,_direction);
    var _start = -(_amount - 1) * _spacing * 0.5;

    for (var _i = 0; _i < _amount; ++_i)
    {
        var _x;
        var _y;

        if (_formation == DebugSpawnFormation.CIRCLE)
        {
            // sqrt gives a roughly even distribution across the full circular area.
            var _scatter_direction = random(360);
            var _scatter_distance = sqrt(random(1)) * _formation_radius;

            _x = _centre_x + lengthdir_x(_scatter_distance,_scatter_direction);
            _y = _centre_y + lengthdir_y(_scatter_distance,_scatter_direction);
        }
        else
        {
            var _side = _start + _i * _spacing;
            _x = _centre_x + lengthdir_x(_side,_side_direction);
            _y = _centre_y + lengthdir_y(_side,_side_direction);
        }

        _x = clamp(_x,_radius,room_width - _radius);
        _y = clamp(_y,_radius,room_height - _radius);

        instance_create_layer(_x,_y,"Enemy",o_enemy,{ enemy_key: _enemy_key });
    }

    show_debug_message(
        "DEBUG ENEMY SPAWN - "
        + _enemy_key
        + " x"
        + string(_amount)
        + " AT "
        + string(_distance)
        + " PX"
    );

    return true;
}

/// @description Returns whether an enemy button is fully visible inside the list viewport.
function sc_debug_enemy_spawn_button_visible(_debug,_button)
{
    var _draw_y = _button.y - _debug.scroll;

    return _draw_y >= 0
        && _draw_y + _button.height <= _debug.viewport.height;
}

/// @description Updates scrolling, formation amount, shape, distance and enemy selection.
function sc_debug_enemy_spawn_update(_hud)
{
    var _debug = _hud.debug_enemy_spawn;
    if (!_debug.open) return;

    var _panel_x = floor((display_get_gui_width() - _debug.width) * 0.5);
    var _panel_y = floor((display_get_gui_height() - _debug.height) * 0.5);
    var _mouse_x = device_mouse_x_to_gui(0) - _panel_x;
    var _mouse_y = device_mouse_y_to_gui(0) - _panel_y;
    var _pressed = global.input.action.ui_select_pressed;
    var _buttons = _debug.buttons;
    var _viewport = _debug.viewport;

    if (sc_gui_button_update(_buttons.close,_mouse_x,_mouse_y,_pressed))
    {
        sc_debug_enemy_spawn_toggle(_hud);
        return;
    }

    var _amount_buttons = [_buttons.amount_1,_buttons.amount_5,_buttons.amount_10];

    for (var _i = 0; _i < array_length(_amount_buttons); ++_i)
    {
        var _button = _amount_buttons[_i];
        _button.selected = _debug.amount == _button.id;

        if (sc_gui_button_update(_button,_mouse_x,_mouse_y,_pressed))
        {
            _debug.amount = _button.id;
            return;
        }
    }

    var _formation_buttons = [_buttons.formation_line,_buttons.formation_circle];

    for (var _i = 0; _i < array_length(_formation_buttons); ++_i)
    {
        var _button = _formation_buttons[_i];
        _button.selected = _debug.formation == _button.id;

        if (sc_gui_button_update(_button,_mouse_x,_mouse_y,_pressed))
        {
            _debug.formation = _button.id;
            return;
        }
    }

    var _distance_buttons = [
        _buttons.distance_500,
        _buttons.distance_1000,
        _buttons.distance_2000,
        _buttons.distance_5000
    ];

    for (var _i = 0; _i < array_length(_distance_buttons); ++_i)
    {
        var _button = _distance_buttons[_i];
        _button.selected = _debug.spawn_distance == _button.id;

        if (sc_gui_button_update(_button,_mouse_x,_mouse_y,_pressed))
        {
            _debug.spawn_distance = _button.id;
            return;
        }
    }

    var _mouse_inside = point_in_rectangle(
        _mouse_x,_mouse_y,
        _viewport.x,_viewport.y,
        _viewport.x + _viewport.width,
        _viewport.y + _viewport.height
    );

    if (!_mouse_inside) return;

    var _wheel = mouse_wheel_down() - mouse_wheel_up();

    if (_wheel != 0)
        _debug.scroll_target += _wheel * _debug.scroll_speed;

    var _scroll_max = max(0,_debug.content_height - _viewport.height);
    _debug.scroll_target = clamp(_debug.scroll_target,0,_scroll_max);
    _debug.scroll = _debug.scroll_target;

    var _list_mouse_x = _mouse_x - _viewport.x;
    var _list_mouse_y = _mouse_y - _viewport.y + _debug.scroll;

    for (var _i = 0; _i < array_length(_debug.enemy_buttons); ++_i)
    {
        var _button = _debug.enemy_buttons[_i];
        _button.hovered = false;
        _button.pressed = false;

        if (!sc_debug_enemy_spawn_button_visible(_debug,_button)) continue;

        if (sc_gui_button_update(_button,_list_mouse_x,_list_mouse_y,_pressed))
        {
            sc_debug_enemy_spawn_execute(
                _button.id,
                _debug.amount,
                _debug.spawn_distance,
                _debug.formation,
                _debug.formation_radius
            );

            return;
        }
    }
}

/// @description Draws the taller scrollable three-column F1 enemy-spawning interface.
function sc_debug_enemy_spawn_draw(_hud)
{
    var _debug = _hud.debug_enemy_spawn;
    if (!_debug.open) return;

    var _palette = _hud.data.palette;
    var _viewport = _debug.viewport;
    var _width = _debug.width;
    var _height = _debug.height;
    var _x = floor((display_get_gui_width() - _width) * 0.5);
    var _y = floor((display_get_gui_height() - _height) * 0.5);

    draw_set_alpha(0.72);
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
    draw_line_width(_x + 24,_y + 680,_x + _width - 24,_y + 680,2);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_colour(_palette.core);
    draw_text(_x + 34,_y + 27,"DEBUG // ENEMY DEPLOYMENT");

    draw_set_colour(_palette.muted);
    draw_text(
        _x + 34,
        _y + 52,
        "Select a faction unit, formation amount and deployment distance"
    );

    for (var _f = 0; _f < array_length(_debug.factions); ++_f)
    {
        var _column_x = _x + _viewport.x
            + _f * (_debug.column_width + _debug.column_gap);

        draw_set_colour(_palette.core);
        draw_text(
            _column_x,
            _y + 101,
            _debug.factions[_f].name
        );

        draw_set_colour(_palette.muted);
        draw_text(
            _column_x + _debug.column_width - 72,
            _y + 101,
            string(_debug.faction_rows[_f]) + " UNITS"
        );

        draw_set_colour(_palette.outline);
        draw_line(
            _column_x,
            _y + 125,
            _column_x + _debug.column_width,
            _y + 125
        );
    }

    var _list_origin_x = _x + _viewport.x;
    var _list_origin_y = _y + _viewport.y - _debug.scroll;

    for (var _i = 0; _i < array_length(_debug.enemy_buttons); ++_i)
    {
        var _button = _debug.enemy_buttons[_i];

        if (sc_debug_enemy_spawn_button_visible(_debug,_button))
        {
            sc_gui_button_draw(
                _button,
                _list_origin_x,
                _list_origin_y,
                _palette
            );
        }
    }

    var _scroll_max = max(0,_debug.content_height - _viewport.height);

    if (_scroll_max > 0)
    {
        var _track_x = _x + 1310;
        var _track_y1 = _y + _viewport.y;
        var _track_y2 = _track_y1 + _viewport.height;
        var _handle_height = max(
            44,
            _viewport.height * (_viewport.height / _debug.content_height)
        );

        var _handle_y = _track_y1
            + (_debug.scroll / _scroll_max)
            * (_viewport.height - _handle_height);

        draw_set_alpha(0.35);
        draw_set_colour(_palette.outline);
        draw_rectangle(
            _track_x,
            _track_y1,
            _track_x + 6,
            _track_y2,
            false
        );

        draw_set_alpha(1);
        draw_set_colour(_palette.accent);
        draw_rectangle(
            _track_x,
            _handle_y,
            _track_x + 6,
            _handle_y + _handle_height,
            false
        );
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_set_colour(_palette.text);
    draw_text(_x + 34,_y + 741,"FORMATION AMOUNT");
    draw_text(_x + 34,_y + 793,"FORMATION SHAPE");
    draw_text(_x + 670,_y + 741,"SPAWN DISTANCE");

    sc_gui_button_draw(_debug.buttons.amount_1,_x,_y,_palette);
    sc_gui_button_draw(_debug.buttons.amount_5,_x,_y,_palette);
    sc_gui_button_draw(_debug.buttons.amount_10,_x,_y,_palette);

    sc_gui_button_draw(_debug.buttons.formation_line,_x,_y,_palette);
    sc_gui_button_draw(_debug.buttons.formation_circle,_x,_y,_palette);

    sc_gui_button_draw(_debug.buttons.distance_500,_x,_y,_palette);
    sc_gui_button_draw(_debug.buttons.distance_1000,_x,_y,_palette);
    sc_gui_button_draw(_debug.buttons.distance_2000,_x,_y,_palette);
    sc_gui_button_draw(_debug.buttons.distance_5000,_x,_y,_palette);

    sc_gui_button_draw(_debug.buttons.close,_x,_y,_palette);

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}