/*
DEBUG WEAPON TEST

F2 opens a registry-driven weapon testing panel.
The selected weapon temporarily overrides the player's primary weapon.
The real ship loadout and resources remain unchanged.
*/

/// @description Returns a readable weapon delivery name.
function sc_debug_weapon_delivery_name(_type)
{
    switch (_type)
    {
        case AttackDelivery.PROJECTILE: return "PROJECTILE";
        case AttackDelivery.AREA: return "AREA";
        case AttackDelivery.BEAM: return "BEAM";
        case AttackDelivery.DEPLOYABLE: return "DEPLOYABLE";
    }

    return "UNKNOWN";
}

/// @description Creates the wider scrollable F2 weapon-testing interface.
function sc_debug_weapon_test_init(_hud)
{
    var _keys = variable_struct_get_names(global.data.weapons);
    var _weapon_buttons = [];
    var _viewport = { x: 34, y: 108, width: 1032, height: 510 };
    var _columns = 2;
    var _gap_x = 14;
    var _gap_y = 10;
    var _button_width = floor((_viewport.width - _gap_x) / _columns);
    var _button_height = 42;
    var _row_step = _button_height + _gap_y;
    var _rows = ceil(array_length(_keys) / _columns);

    for (var _i = 0; _i < array_length(_keys); ++_i)
    {
        var _key = _keys[_i];
        var _weapon = variable_struct_get(global.data.weapons,_key);
        var _column = _i mod _columns;
        var _row = floor(_i / _columns);
        var _label = _weapon.identity.name
            + " // "
            + sc_debug_weapon_delivery_name(_weapon.delivery.type);

        array_push(_weapon_buttons,sc_gui_button_create(
            _key,
            _column * (_button_width + _gap_x),
            _row * _row_step,
            _button_width,
            _button_height,
            _label,
            GUIButtonStyle.STANDARD
        ));
    }

    _hud.debug_weapon_test = {
        open: false,
        width: 1100,
        height: 740,

        viewport: _viewport,
        weapon_buttons: _weapon_buttons,
        content_height: max(0,_rows * _row_step - _gap_y),

        scroll: 0,
        scroll_target: 0,
        scroll_speed: _row_step,

        buttons: {
            restore: sc_gui_button_create(
                "restore",34,665,240,42,
                "RESTORE LOADOUT",
                GUIButtonStyle.PRIMARY
            ),

            close: sc_gui_button_create(
                "close",1032,26,38,38,
                "X",
                GUIButtonStyle.DANGER
            )
        }
    };

    return true;
}

/// @description Disables the debug weapon and restores normal loadout firing.
function sc_player_debug_weapon_disable(_player)
{
    var _debug = _player.combat.debug_weapon;
    if (!_debug.enabled) return false;

    sc_player_continuous_weapon_release(_player);

    _debug.enabled = false;
    _debug.weapon_key = "";
    _debug.shot = undefined;
    _debug.firing = undefined;

    _player.combat.primary.hardpoint_cursor = 0;
    _player.combat.primary.next_fire_tick = GAME_TICK;
    return true;
}

/// @description Selects one registered weapon as the temporary debug primary.
function sc_player_debug_weapon_select(_player,_weapon_key)
{
    if (!variable_struct_exists(global.data.weapons,_weapon_key))
        return false;

    var _weapon = variable_struct_get(global.data.weapons,_weapon_key);
    var _debug = _player.combat.debug_weapon;
    var _interval = 10;
    var _centre_forward = 0.9;

    switch (_weapon.delivery.type)
    {
        case AttackDelivery.AREA:
            _interval = 20;
        break;

        case AttackDelivery.BEAM:
            _interval = 1;
        break;

        case AttackDelivery.DEPLOYABLE:
            _interval = 45;
            _centre_forward = 0;
        break;
    }

    sc_player_continuous_weapon_release(_player);

    _debug.enabled = true;
    _debug.weapon_key = _weapon_key;

    _debug.shot = variable_struct_exists(_weapon,"shot")
        ? variable_clone(_weapon.shot)
        : {
            pattern: ShotPattern.SINGLE,
            amount: 1,
            angle_total: 0
        };

    _debug.firing = variable_struct_exists(_weapon,"firing")
        ? variable_clone(_weapon.firing)
        : {
            mount_mode: WeaponMountMode.CENTRE,
            centre_forward: _centre_forward,
            interval: _interval,
            recoil: 0,
            muzzle_flash_duration: 0
        };

    _player.combat.primary.hardpoint_cursor = 0;
    _player.combat.primary.next_fire_tick = GAME_TICK;

    show_debug_message(
        "DEBUG WEAPON SELECTED - "
        + _weapon.identity.name
    );

    return true;
}

/// @description Opens or closes the F2 weapon-testing interface.
function sc_debug_weapon_test_toggle(_hud)
{
    var _debug = _hud.debug_weapon_test;

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

/// @description Returns whether a weapon button is fully inside the scroll viewport.
function sc_debug_weapon_test_button_visible(_debug,_button)
{
    var _draw_y = _button.y - _debug.scroll;

    return _draw_y >= 0
        && _draw_y + _button.height <= _debug.viewport.height;
}

/// @description Updates scrolling and weapon selection in the open F2 interface.
function sc_debug_weapon_test_update(_hud)
{
    var _debug = _hud.debug_weapon_test;
    if (!_debug.open) return;

    var _panel_x = floor((display_get_gui_width() - _debug.width) * 0.5);
    var _panel_y = floor((display_get_gui_height() - _debug.height) * 0.5);
    var _mouse_x = device_mouse_x_to_gui(0) - _panel_x;
    var _mouse_y = device_mouse_y_to_gui(0) - _panel_y;
    var _pressed = global.input.action.ui_select_pressed;
    var _player = global.player_id;
    var _viewport = _debug.viewport;

    if (sc_gui_button_update(_debug.buttons.close,_mouse_x,_mouse_y,_pressed))
    {
        sc_debug_weapon_test_toggle(_hud);
        return;
    }

    if (sc_gui_button_update(_debug.buttons.restore,_mouse_x,_mouse_y,_pressed))
    {
        sc_player_debug_weapon_disable(_player);
        sc_debug_weapon_test_toggle(_hud);
        return;
    }

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
    _debug.scroll = _debug.scroll_target;

    var _list_mouse_x = _mouse_x - _viewport.x;
    var _list_mouse_y = _mouse_y - _viewport.y + _debug.scroll;

    for (var _i = 0; _i < array_length(_debug.weapon_buttons); ++_i)
    {
        var _button = _debug.weapon_buttons[_i];

        _button.selected = _player.combat.debug_weapon.enabled
            && _player.combat.debug_weapon.weapon_key == _button.id;

        _button.hovered = false;
        _button.pressed = false;

        if (!_mouse_inside
        || !sc_debug_weapon_test_button_visible(_debug,_button))
            continue;

        if (sc_gui_button_update(
            _button,
            _list_mouse_x,
            _list_mouse_y,
            _pressed
        ))
        {
            sc_player_debug_weapon_select(_player,_button.id);
            sc_debug_weapon_test_toggle(_hud);
            return;
        }
    }
}

/// @description Draws the wider scrollable F2 interface and active override status.
function sc_debug_weapon_test_draw(_hud)
{
    var _debug = _hud.debug_weapon_test;
    var _palette = _hud.data.palette;

    if (!_debug.open)
    {
        if (!instance_exists(global.player_id)
        || !global.player_id.combat.debug_weapon.enabled)
            return;

        var _key = global.player_id.combat.debug_weapon.weapon_key;
        var _weapon = variable_struct_get(global.data.weapons,_key);

        draw_set_alpha(1);
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        draw_set_colour(_palette.accent);

        draw_text(
            display_get_gui_width() * 0.5,
            18,
            "DEBUG WEAPON // " + string_upper(_weapon.identity.name)
        );

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_colour(c_white);
        return;
    }

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
    draw_line_width(_x + 24,_y + 642,_x + _width - 24,_y + 642,2);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_colour(_palette.core);
    draw_text(_x + 34,_y + 27,"DEBUG // WEAPON TESTING");

    draw_set_colour(_palette.muted);
    draw_text(
        _x + 34,
        _y + 52,
        "Temporarily fire any registered weapon with unlimited resources"
    );

    var _list_origin_x = _x + _viewport.x;
    var _list_origin_y = _y + _viewport.y - _debug.scroll;

    for (var _i = 0; _i < array_length(_debug.weapon_buttons); ++_i)
    {
        var _button = _debug.weapon_buttons[_i];

        if (sc_debug_weapon_test_button_visible(_debug,_button))
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
        var _track_x = _x + _width - 22;
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
    draw_text(
        _x + 294,
        _y + 686,
        "REMOVE THE ACTIVE DEBUG WEAPON AND RESTORE THE SHIP LOADOUT"
    );

    sc_gui_button_draw(_debug.buttons.restore,_x,_y,_palette);
    sc_gui_button_draw(_debug.buttons.close,_x,_y,_palette);

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}