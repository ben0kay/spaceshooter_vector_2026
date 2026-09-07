/*
DEBUG ENEMY SPAWNER

F1 opens a paused registry-driven enemy spawning panel.
Enemy definitions are read directly from global.data.enemies.
*/

/// @description Creates the F1 enemy-spawning interface.
function sc_debug_enemy_spawn_init(_hud)
{
    var _keys = variable_struct_get_names(global.data.enemies);
    var _enemy_buttons = [];
    var _columns = 2;
    var _button_width = 340;
    var _button_height = 42;
    var _gap_x = 14;
    var _gap_y = 10;

    for (var _i = 0; _i < array_length(_keys); ++_i)
    {
        var _key = _keys[_i];
        var _enemy = variable_struct_get(global.data.enemies,_key);
        var _column = _i mod _columns;
        var _row = floor(_i / _columns);

        array_push(_enemy_buttons,sc_gui_button_create(
            _key,
            34 + _column * (_button_width + _gap_x),
            108 + _row * (_button_height + _gap_y),
            _button_width,
            _button_height,
            _enemy.identity.name,
            GUIButtonStyle.STANDARD
        ));
    }

    _hud.debug_enemy_spawn = {
        open: false,
        width: 754,
        height: 680,
        spawn_distance: 1000,
        amount: 1,
        enemy_buttons: _enemy_buttons,

        buttons: {
            amount_1: sc_gui_button_create(1,34,605,110,42,"x1",GUIButtonStyle.STANDARD),
            amount_5: sc_gui_button_create(5,154,605,110,42,"x5",GUIButtonStyle.STANDARD),
            amount_10: sc_gui_button_create(10,274,605,110,42,"x10",GUIButtonStyle.STANDARD),
            close: sc_gui_button_create("close",686,26,38,38,"X",GUIButtonStyle.DANGER)
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
    global.LevelState = LevelState.DEBUG;
    return true;
}

/// @description Spawns one registered enemy formation ahead of the player.
function sc_debug_enemy_spawn_execute(_enemy_key,_amount,_distance)
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
        var _side = _start + _i * _spacing;
        var _x = _centre_x + lengthdir_x(_side,_side_direction);
        var _y = _centre_y + lengthdir_y(_side,_side_direction);

        _x = clamp(_x,_radius,room_width - _radius);
        _y = clamp(_y,_radius,room_height - _radius);

        instance_create_layer(
            _x,
            _y,
            "Enemy",
            o_enemy,
            { enemy_key: _enemy_key }
        );
    }

    show_debug_message(
        "DEBUG ENEMY SPAWN - "
        + _enemy_key
        + " x"
        + string(_amount)
    );

    return true;
}

/// @description Updates the open F1 enemy-spawning interface.
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

    if (sc_gui_button_update(_buttons.close,_mouse_x,_mouse_y,_pressed))
    {
        sc_debug_enemy_spawn_toggle(_hud);
        return;
    }

    var _amount_buttons = [
        _buttons.amount_1,
        _buttons.amount_5,
        _buttons.amount_10
    ];

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

    for (var _i = 0; _i < array_length(_debug.enemy_buttons); ++_i)
    {
        var _button = _debug.enemy_buttons[_i];

        if (sc_gui_button_update(_button,_mouse_x,_mouse_y,_pressed))
        {
            sc_debug_enemy_spawn_execute(
                _button.id,
                _debug.amount,
                _debug.spawn_distance
            );

            return;
        }
    }
}

/// @description Draws the F1 enemy-spawning interface.
function sc_debug_enemy_spawn_draw(_hud)
{
    var _debug = _hud.debug_enemy_spawn;
    if (!_debug.open) return;

    var _palette = _hud.data.palette;
    var _width = _debug.width;
    var _height = _debug.height;
    var _x = floor((display_get_gui_width() - _width) * 0.5);
    var _y = floor((display_get_gui_height() - _height) * 0.5);

    draw_set_alpha(0.72);
    draw_set_colour(c_black);
    draw_rectangle(
        0,
        0,
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
    draw_line_width(_x + 24,_y + 580,_x + _width - 24,_y + 580,2);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_colour(_palette.core);
    draw_text(_x + 34,_y + 27,"DEBUG // ENEMY DEPLOYMENT");

    draw_set_colour(_palette.muted);
    draw_text(
        _x + 34,
        _y + 52,
        "Spawn registered enemies 1000 pixels ahead of the active ship"
    );

    draw_set_colour(_palette.text);
    draw_text(_x + 400,_y + 617,"FORMATION AMOUNT");

    for (var _i = 0; _i < array_length(_debug.enemy_buttons); ++_i)
        sc_gui_button_draw(_debug.enemy_buttons[_i],_x,_y,_palette);

    sc_gui_button_draw(_debug.buttons.amount_1,_x,_y,_palette);
    sc_gui_button_draw(_debug.buttons.amount_5,_x,_y,_palette);
    sc_gui_button_draw(_debug.buttons.amount_10,_x,_y,_palette);
    sc_gui_button_draw(_debug.buttons.close,_x,_y,_palette);

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}