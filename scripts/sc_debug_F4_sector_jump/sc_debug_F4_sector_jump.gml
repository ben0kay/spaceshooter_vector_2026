/*
DEBUG SECTOR JUMP

F4 opens a paused sector-navigation debug panel.

Select any campaign sector from:
- X0 through X8 eastward
- Y-1, Y0 and Y+1

The current sector is highlighted.

Selecting a sector:
- captures current sector persistence
- saves the profile
- changes sector coordinates
- carries the player through the room restart
- regenerates the selected deterministic sector
- places the player in the middle of that sector
*/


/// @description Returns a readable debug name for one sector's enemy profile.
function sc_debug_sector_jump_profile_name_get(_sector_x,_sector_y)
{
    var _profile = sc_sector_enemy_profile_get(
        _sector_x,
        _sector_y
    );

    if (!is_struct(_profile))
        return "NO ENEMY PROFILE";

    switch (_profile.key)
    {
        case "starting_sector":
            return "STARTING SECTOR";

        case "rebel_outskirts":
            return "REBEL OUTSKIRTS";

        case "rebel_skirmishes":
            return "REBEL SKIRMISHES";

        case "rebel_territory":
            return "REBEL TERRITORY";
    }

    return string_upper(_profile.key);
}


/// @description Creates the F4 sector-jump debug interface.
function sc_debug_sector_jump_init(_hud)
{
    var _x_min = 0;
    var _x_max = 8;
    var _y_min = -1;
    var _y_max = 1;

    var _buttons = [];

    var _button_width = 140;
    var _button_height = 56;
    var _column_gap = 10;
    var _row_gap = 18;

    var _grid_x = 110;
    var _grid_y = 156;

    for (var _sector_y = _y_min;
    _sector_y <= _y_max;
    ++_sector_y)
    {
        var _row = _sector_y - _y_min;

        for (var _sector_x = _x_min;
        _sector_x <= _x_max;
        ++_sector_x)
        {
            var _column = _sector_x - _x_min;

            var _button = sc_gui_button_create(
                array_length(_buttons),
                _grid_x
                    + _column
                    * (_button_width + _column_gap),
                _grid_y
                    + _row
                    * (_button_height + _row_gap),
                _button_width,
                _button_height,
                "X"
                    + string(_sector_x)
                    + " / Y"
                    + string(_sector_y),
                GUIButtonStyle.STANDARD
            );

            _button.sector_x = _sector_x;
            _button.sector_y = _sector_y;

            array_push(
                _buttons,
                _button
            );
        }
    }

    _hud.debug_sector_jump = {
        open: false,

        width: 1500,
        height: 560,

        x_min: _x_min,
        x_max: _x_max,
        y_min: _y_min,
        y_max: _y_max,

        grid_x: _grid_x,
        grid_y: _grid_y,

        sector_buttons: _buttons,

        preview_x: global.game.sector.x,
        preview_y: global.game.sector.y,

        buttons: {
            close: sc_gui_button_create(
                "close",
                1432,26,
                38,38,
                "X",
                GUIButtonStyle.DANGER
            )
        }
    };

    return true;
}


/// @description Opens or closes the F4 sector-jump debug interface.
function sc_debug_sector_jump_toggle(_hud)
{
    var _debug = _hud.debug_sector_jump;

    if (_debug.open)
    {
        _debug.open = false;
        global.LevelState = LevelState.PLAYING;
        return true;
    }

    if (global.LevelState != LevelState.PLAYING
    || global.PlayerState != PlayerState.ACTIVE
    || !instance_exists(global.player_id)
    || !sc_sector_campaign_active())
        return false;

    _debug.open = true;

    _debug.preview_x =
        global.game.sector.x;

    _debug.preview_y =
        global.game.sector.y;

    global.LevelState = LevelState.DEBUG;

    return true;
}


/// @description Immediately reloads the campaign into one selected sector.
function sc_debug_sector_jump_execute(_sector_x,_sector_y)
{
    if (!sc_sector_campaign_active()
    || !instance_exists(global.player_id))
        return false;

    if (_sector_x < 0
    || _sector_y < -1
    || _sector_y > 1)
        return false;

    var _sector = global.game.sector;
    var _player = global.player_id;

    // Preserve changes made inside the sector being left.
    if (!sc_sector_persistence_capture())
    {
        show_debug_message(
            "DEBUG SECTOR JUMP ERROR - persistence capture failed"
        );

        return false;
    }

    if (!sc_profile_save())
    {
        show_debug_message(
            "DEBUG SECTOR JUMP ERROR - profile save failed"
        );

        return false;
    }

    show_debug_message(
        "DEBUG SECTOR JUMP - "
        + string(_sector.x)
        + ","
        + string(_sector.y)
        + " -> "
        + string(_sector_x)
        + ","
        + string(_sector_y)
    );

    _sector.x = _sector_x;
    _sector.y = _sector_y;

    // Centre entry uses the existing sector-entry pipeline.
    _sector.entry_side = "centre";
    _sector.entry_axis = 0.5;
    _sector.transitioning = true;

    sc_player_continuous_weapons_release(
        _player
    );

    _player.persistent = true;

    global.PlayerState =
        PlayerState.INITIALIZING;

    global.LevelState =
        LevelState.EXITING;

    room_restart();

    return true;
}


/// @description Updates F4 sector selection and jump controls.
function sc_debug_sector_jump_update(_hud)
{
    var _debug = _hud.debug_sector_jump;
    if (!_debug.open) return;

    var _panel_x = floor(
        (display_get_gui_width()
        - _debug.width)
        * 0.5
    );

    var _panel_y = floor(
        (display_get_gui_height()
        - _debug.height)
        * 0.5
    );

    var _mouse_x =
        device_mouse_x_to_gui(0)
        - _panel_x;

    var _mouse_y =
        device_mouse_y_to_gui(0)
        - _panel_y;

    var _pressed =
        global.input.action.ui_select_pressed;

    if (sc_gui_button_update(
        _debug.buttons.close,
        _mouse_x,
        _mouse_y,
        _pressed
    ))
    {
        sc_debug_sector_jump_toggle(_hud);
        return;
    }

    var _sector =
        global.game.sector;

    _debug.preview_x = _sector.x;
    _debug.preview_y = _sector.y;

    for (var _i = 0;
    _i < array_length(_debug.sector_buttons);
    ++_i)
    {
        var _button =
            _debug.sector_buttons[_i];

        _button.selected =
            _button.sector_x == _sector.x
            && _button.sector_y == _sector.y;

        var _clicked =
            sc_gui_button_update(
                _button,
                _mouse_x,
                _mouse_y,
                _pressed
            );

        if (_button.hovered)
        {
            _debug.preview_x =
                _button.sector_x;

            _debug.preview_y =
                _button.sector_y;
        }

        if (_clicked)
        {
            sc_debug_sector_jump_execute(
                _button.sector_x,
                _button.sector_y
            );

            return;
        }
    }
}


/// @description Draws the F4 campaign-sector jump interface.
function sc_debug_sector_jump_draw(_hud)
{
    var _debug = _hud.debug_sector_jump;
    if (!_debug.open) return;

    var _palette = _hud.data.palette;

    var _width = _debug.width;
    var _height = _debug.height;

    var _x = floor(
        (display_get_gui_width()
        - _width)
        * 0.5
    );

    var _y = floor(
        (display_get_gui_height()
        - _height)
        * 0.5
    );

    // Screen dim.
    draw_set_alpha(0.72);
    draw_set_colour(c_black);

    draw_rectangle(
        0,0,
        display_get_gui_width(),
        display_get_gui_height(),
        false
    );

    // Main panel.
    draw_set_alpha(0.98);
    draw_set_colour(_palette.background);

    draw_rectangle(
        _x,_y,
        _x + _width,
        _y + _height,
        false
    );

    draw_set_alpha(1);
    draw_set_colour(_palette.outline);

    draw_rectangle(
        _x,_y,
        _x + _width,
        _y + _height,
        true
    );

    // Header divider.
    draw_set_colour(_palette.accent);

    draw_line_width(
        _x + 24,
        _y + 78,
        _x + _width - 24,
        _y + 78,
        2
    );

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    draw_set_colour(_palette.core);

    draw_text(
        _x + 40,
        _y + 27,
        "DEBUG // SECTOR JUMP"
    );

    draw_set_colour(_palette.muted);

    draw_text(
        _x + 40,
        _y + 52,
        "Select a campaign sector // player arrives at sector centre"
    );

    // Current position.
    draw_set_colour(_palette.text);

    draw_text(
        _x + 40,
        _y + 101,
        "CURRENT // X"
        + string(global.game.sector.x)
        + " / Y"
        + string(global.game.sector.y)
    );

    draw_set_colour(_palette.muted);

    draw_text(
        _x + 1140,
        _y + 101,
        "EASTWARD PROGRESSION ->"
    );

    // Row labels.
    draw_set_colour(_palette.muted);

    draw_text(
        _x + 38,
        _y + _debug.grid_y + 18,
        "Y -1"
    );

    draw_text(
        _x + 38,
        _y + _debug.grid_y + 92,
        "Y  0"
    );

    draw_text(
        _x + 38,
        _y + _debug.grid_y + 166,
        "Y +1"
    );

    // Sector buttons.
    for (var _i = 0;
    _i < array_length(_debug.sector_buttons);
    ++_i)
    {
        sc_gui_button_draw(
            _debug.sector_buttons[_i],
            _x,_y,
            _palette
        );
    }

    // Preview divider.
    draw_set_colour(_palette.outline);

    draw_line(
        _x + 40,
        _y + 395,
        _x + _width - 40,
        _y + 395
    );

    var _preview_x =
        _debug.preview_x;

    var _preview_y =
        _debug.preview_y;

    var _profile_name =
        sc_debug_sector_jump_profile_name_get(
            _preview_x,
            _preview_y
        );

    var _seed =
        sc_sector_seed_get(
            _preview_x,
            _preview_y
        );

    draw_set_colour(_palette.core);

    draw_text(
        _x + 40,
        _y + 421,
        "SECTOR X"
        + string(_preview_x)
        + " / Y"
        + string(_preview_y)
    );

    draw_set_colour(_palette.text);

    draw_text(
        _x + 40,
        _y + 450,
        "ENEMY PROFILE // "
        + _profile_name
    );

    draw_text(
        _x + 40,
        _y + 479,
        "DETERMINISTIC SEED // "
        + string(_seed)
    );

    draw_set_colour(_palette.muted);

    draw_text(
        _x + 700,
        _y + 450,
        "CLICK SECTOR TO REGENERATE WORLD"
    );

    draw_text(
        _x + 700,
        _y + 479,
        "CURRENT SECTOR MAY ALSO BE RELOADED"
    );

    sc_gui_button_draw(
        _debug.buttons.close,
        _x,_y,
        _palette
    );

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}