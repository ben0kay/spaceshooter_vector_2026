function sc_menu_main()
{
    var _menu = {
        button_width: 500,
        button_height: 74,
        button_gap: 18,

        buttons: [
            { label: "COMBAT TEST", action: MainMenuAction.DEPLOY, enabled: true },
            { label: "CAMPAIGN", action: MainMenuAction.HANGAR, enabled: true },
            { label: "OPTIONS", action: MainMenuAction.OPTIONS, enabled: false },
            { label: "CHANGE PROFILE", action: MainMenuAction.CHANGE_PROFILE, enabled: true },
            { label: "EXIT", action: MainMenuAction.EXIT, enabled: true }
        ]
    };

        _menu.action_execute = method(_menu, function(_action)
    {
        switch (_action)
        {
            case MainMenuAction.DEPLOY:
                global.GameState = GameState.PLAYING;
                global.LevelState = LevelState.INITIALIZING;
                room_goto(r_combat_test);
            break;

            case MainMenuAction.HANGAR:
                sc_sector_campaign_begin();

                global.GameState = GameState.PLAYING;
                global.LevelState = LevelState.INITIALIZING;

                room_goto(r_sector);
            break;

            case MainMenuAction.CHANGE_PROFILE:
                global.profile = undefined;
                global.GameState = GameState.BOOT;
                room_goto(r_boot);
            break;

            case MainMenuAction.EXIT:
                game_end();
            break;

            // Future Options action goes here.
        }
    });

    _menu.update = method(_menu, function()
    {
        if (!mouse_check_button_pressed(mb_left)) return;

        var _gui_w = display_get_gui_width();
        var _gui_h = display_get_gui_height();
        var _x1 = (_gui_w - button_width) * 0.5;
        var _start_y = _gui_h * 0.36;
        var _mx = device_mouse_x_to_gui(0);
        var _my = device_mouse_y_to_gui(0);

        for (var _i = 0; _i < array_length(buttons); _i++)
        {
            var _button = buttons[_i];
            var _y1 = _start_y + _i * (button_height + button_gap);

            if (!_button.enabled) continue;
            if (_mx < _x1 || _mx > _x1 + button_width || _my < _y1 || _my > _y1 + button_height) continue;

            action_execute(_button.action);
            return;
        }
    });

    _menu.draw = method(_menu, function()
    {
        var _gui_w = display_get_gui_width();
        var _gui_h = display_get_gui_height();
        var _gui_cx = _gui_w * 0.5;
        var _x1 = (_gui_w - button_width) * 0.5;
        var _start_y = _gui_h * 0.36;
        var _mx = device_mouse_x_to_gui(0);
        var _my = device_mouse_y_to_gui(0);
        var _aqua = make_colour_rgb(35, 220, 255);
        var _panel = make_colour_rgb(7, 19, 34);
        var _panel_hover = make_colour_rgb(13, 42, 62);

        draw_set_colour(c_black);
        draw_rectangle(0, 0, _gui_w, _gui_h, false);

        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);

        draw_set_colour(_aqua);
        draw_text(_gui_cx, _gui_h * 0.12, "SPACE SHOOTER VECTOR");

        draw_set_colour(c_white);
        draw_text(_gui_cx, _gui_h * 0.2, "PILOT: " + global.profile.pilot_name);

        draw_set_colour(c_ltgray);
        draw_text(_gui_cx, _gui_h * 0.27, "SELECT OPERATION");

        for (var _i = 0; _i < array_length(buttons); _i++)
        {
            var _button = buttons[_i];
            var _y1 = _start_y + _i * (button_height + button_gap);
            var _hover = _button.enabled && _mx >= _x1 && _mx <= _x1 + button_width && _my >= _y1 && _my <= _y1 + button_height;

            draw_set_colour(_hover ? _panel_hover : _panel);
            draw_roundrect(_x1, _y1, _x1 + button_width, _y1 + button_height, false);

            draw_set_colour(!_button.enabled ? c_dkgray : (_hover ? c_white : _aqua));
            draw_roundrect(_x1, _y1, _x1 + button_width, _y1 + button_height, true);
            draw_text(_gui_cx, _y1 + button_height * 0.5, _button.label + (!_button.enabled ? "  [LOCKED]" : ""));
        }

        draw_set_colour(c_gray);
        draw_text(_gui_cx, _gui_h - 55, "PROFILE " + string(global.profile.slot + 1));

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_alpha(1);
        draw_set_colour(c_white);
    });

    return _menu;
}