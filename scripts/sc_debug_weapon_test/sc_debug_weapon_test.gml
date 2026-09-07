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

/// @description Creates the F2 weapon-testing interface.
function sc_debug_weapon_test_init(_hud)
{
    var _keys = variable_struct_get_names(global.data.weapons);
    var _weapon_buttons = [];
    var _columns = 2;
    var _button_width = 340;
    var _button_height = 42;
    var _gap_x = 14;
    var _gap_y = 10;

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
            34 + _column * (_button_width + _gap_x),
            108 + _row * (_button_height + _gap_y),
            _button_width,
            _button_height,
            _label,
            GUIButtonStyle.STANDARD
        ));
    }

    _hud.debug_weapon_test = {
        open: false,
        width: 754,
        height: 680,
        weapon_buttons: _weapon_buttons,

        buttons: {
            restore: sc_gui_button_create(
                "restore",34,605,220,42,
                "RESTORE LOADOUT",
                GUIButtonStyle.PRIMARY
            ),

            close: sc_gui_button_create(
                "close",686,26,38,38,
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
    global.LevelState = LevelState.DEBUG;
    return true;
}

/// @description Updates the open F2 weapon-testing interface.
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

    for (var _i = 0; _i < array_length(_debug.weapon_buttons); ++_i)
    {
        var _button = _debug.weapon_buttons[_i];

        _button.selected = _player.combat.debug_weapon.enabled
            && _player.combat.debug_weapon.weapon_key == _button.id;

        if (sc_gui_button_update(_button,_mouse_x,_mouse_y,_pressed))
        {
            sc_player_debug_weapon_select(_player,_button.id);
            sc_debug_weapon_test_toggle(_hud);
            return;
        }
    }
}

/// @description Draws the F2 weapon-testing interface and active override status.
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
        draw_set_colour(_palette.warning);
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
    draw_line_width(_x + 24,_y + 580,_x + _width - 24,_y + 580,2);

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

    for (var _i = 0; _i < array_length(_debug.weapon_buttons); ++_i)
        sc_gui_button_draw(_debug.weapon_buttons[_i],_x,_y,_palette);

    sc_gui_button_draw(_debug.buttons.restore,_x,_y,_palette);
    sc_gui_button_draw(_debug.buttons.close,_x,_y,_palette);

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}