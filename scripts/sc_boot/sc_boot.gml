function sc_boot()
{
    var _boot = {
        profile_slots: array_create(3),
        name_entry: {
            active: false,
            slot: -1
        },

        layout: {
            card_width: 420,
            card_height: 340,
            card_gap: 32
        }
    };

	_boot.refresh_profiles = method(_boot, function()
	{
	    for (var _i = 0; _i < array_length(profile_slots); _i++)
	        profile_slots[_i] = sc_profile_read(_i);
	});

    _boot.open_name_entry = method(_boot, function(_slot)
	{
	    name_entry.active = true;
	    name_entry.slot = _slot;
	    keyboard_string = "";
	});

	    _boot.close_name_entry = method(_boot, function()
	{
	    name_entry.active = false;
	    name_entry.slot = -1;
	    keyboard_string = "";
	});

	    _boot.continue_to_menu = method(_boot, function()
	{
	    global.GameState = GameState.MENU;
	    room_goto(r_menu_main);
	});

    _boot.update = method(_boot, function()
    {
        if (name_entry.active)
        {
            if (string_length(keyboard_string) > 16)
                keyboard_string = string_copy(keyboard_string, 1, 16);

            if (keyboard_check_pressed(vk_escape))
            {
                close_name_entry();
                return;
            }

            if (keyboard_check_pressed(vk_enter))
            {
                var _pilot_name = string_trim(keyboard_string);

                if (string_length(_pilot_name) > 0 && sc_profile_create(name_entry.slot, _pilot_name))
                    continue_to_menu();
            }

            return;
        }

        if (!mouse_check_button_pressed(mb_left)) return;

        var _gui_w = display_get_gui_width();
        var _gui_h = display_get_gui_height();
        var _count = array_length(profile_slots);
        var _total_w = _count * layout.card_width + (_count - 1) * layout.card_gap;
        var _start_x = (_gui_w - _total_w) * 0.5;
        var _card_y = _gui_h * 0.36;
        var _mx = device_mouse_x_to_gui(0);
        var _my = device_mouse_y_to_gui(0);

        for (var _i = 0; _i < _count; _i++)
        {
            var _x1 = _start_x + _i * (layout.card_width + layout.card_gap);
            var _x2 = _x1 + layout.card_width;
            var _y2 = _card_y + layout.card_height;

            if (_mx < _x1 || _mx > _x2 || _my < _card_y || _my > _y2) continue;

            if (is_struct(profile_slots[_i]))
            {
                if (sc_profile_load(_i)) continue_to_menu();
            }
            else open_name_entry(_i);

            return;
        }
    });

    _boot.draw = method(_boot, function()
    {
        var _gui_w = display_get_gui_width();
        var _gui_h = display_get_gui_height();
        var _gui_cx = _gui_w * 0.5;
        var _count = array_length(profile_slots);
        var _total_w = _count * layout.card_width + (_count - 1) * layout.card_gap;
        var _start_x = (_gui_w - _total_w) * 0.5;
        var _card_y = _gui_h * 0.36;
        var _mx = device_mouse_x_to_gui(0);
        var _my = device_mouse_y_to_gui(0);
        var _aqua = make_colour_rgb(35, 220, 255);
        var _panel = make_colour_rgb(7, 19, 34);
        var _panel_hover = make_colour_rgb(13, 42, 62);

        draw_set_alpha(1);
        draw_set_colour(c_black);
        draw_rectangle(0, 0, _gui_w, _gui_h, false);

        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);

        draw_set_colour(_aqua);
        draw_text(_gui_cx, _gui_h * 0.12, "SPACE SHOOTER VECTOR");

        draw_set_colour(c_white);
        draw_text(_gui_cx, _gui_h * 0.2, "SELECT PILOT PROFILE");

        for (var _i = 0; _i < _count; _i++)
        {
            var _x1 = _start_x + _i * (layout.card_width + layout.card_gap);
            var _x2 = _x1 + layout.card_width;
            var _y2 = _card_y + layout.card_height;
            var _cx = (_x1 + _x2) * 0.5;
            var _hover = _mx >= _x1 && _mx <= _x2 && _my >= _card_y && _my <= _y2;

            draw_set_colour(_hover ? _panel_hover : _panel);
            draw_roundrect(_x1, _card_y, _x2, _y2, false);

            draw_set_colour(_hover ? c_white : _aqua);
            draw_roundrect(_x1, _card_y, _x2, _y2, true);
            draw_text(_cx, _card_y + 48, "PROFILE " + string(_i + 1));

            if (is_struct(profile_slots[_i]))
            {
                var _profile = profile_slots[_i];

                draw_set_colour(c_white);
                draw_text(_cx, _card_y + 140, _profile.pilot_name);

                draw_set_colour(_aqua);
                draw_text(_cx, _card_y + 205, string_upper(string_replace_all(_profile.selected_ship_key, "ship_", "")));

                draw_set_colour(c_ltgray);
                draw_text(_cx, _card_y + 290, "LOAD PROFILE");
            }
            else
            {
                draw_set_colour(c_gray);
                draw_text(_cx, _card_y + 150, "EMPTY SLOT");

                draw_set_colour(_aqua);
                draw_text(_cx, _card_y + 275, "CREATE PROFILE");
            }
        }

        if (name_entry.active)
        {
            draw_set_alpha(0.82);
            draw_set_colour(c_black);
            draw_rectangle(0, 0, _gui_w, _gui_h, false);
            draw_set_alpha(1);

            var _window_w = min(760, _gui_w * 0.72);
            var _window_h = 360;
            var _x1 = (_gui_w - _window_w) * 0.5;
            var _y1 = (_gui_h - _window_h) * 0.5;
            var _x2 = _x1 + _window_w;
            var _y2 = _y1 + _window_h;

            draw_set_colour(_panel);
            draw_roundrect(_x1, _y1, _x2, _y2, false);
            draw_set_colour(_aqua);
            draw_roundrect(_x1, _y1, _x2, _y2, true);

            draw_set_colour(c_white);
            draw_text(_gui_cx, _y1 + 65, "CREATE PILOT PROFILE");

            draw_set_colour(make_colour_rgb(4, 13, 24));
            draw_rectangle(_x1 + 75, _y1 + 135, _x2 - 75, _y1 + 215, false);
            draw_set_colour(_aqua);
            draw_rectangle(_x1 + 75, _y1 + 135, _x2 - 75, _y1 + 215, true);

            var _cursor = ((GAME_TICK div 30) mod 2) == 0 ? "_" : "";
            draw_set_colour(c_white);
            draw_text(_gui_cx, _y1 + 175, keyboard_string + _cursor);

            draw_set_colour(c_ltgray);
            draw_text(_gui_cx, _y1 + 295, "ENTER TO CONFIRM     ESCAPE TO CANCEL");
        }

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_alpha(1);
        draw_set_colour(c_white);
    });

    _boot.refresh_profiles();
    return _boot;
}