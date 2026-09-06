/*
GENERIC GUI BUTTONS

Buttons own only their visual and interaction state.
The interface using them decides what each press does.
*/

/// @description Creates one reusable GUI button.
function sc_gui_button_create(_id, _x, _y, _width, _height, _text, _style = GUIButtonStyle.STANDARD)
{
    return {
        id: _id,
        x: _x, y: _y,
        width: _width, height: _height,
        text: _text,
        style: _style,
        visible: true,
        enabled: true,
        selected: false,
        hovered: false,
        pressed: false
    };
}

/// @description Updates one button from panel-local mouse coordinates.
function sc_gui_button_update(_button, _mouse_x, _mouse_y, _mouse_pressed)
{
    _button.hovered = false;
    _button.pressed = false;

    if (!_button.visible || !_button.enabled) return false;

    _button.hovered = point_in_rectangle(
        _mouse_x, _mouse_y,
        _button.x, _button.y,
        _button.x + _button.width,
        _button.y + _button.height
    );

    _button.pressed = _button.hovered && _mouse_pressed;
    return _button.pressed;
}

/// @description Draws one reusable vector GUI button.
function sc_gui_button_draw(_button, _origin_x, _origin_y, _palette)
{
    if (!_button.visible) return;

    var _x1 = _origin_x + _button.x;
    var _y1 = _origin_y + _button.y;
    var _x2 = _x1 + _button.width;
    var _y2 = _y1 + _button.height;
    var _active = _button.hovered || _button.selected;
    var _fill = _active ? _palette.panel_light : _palette.void;
    var _border = _active ? _palette.accent : _palette.outline;
    var _text = _active ? _palette.core : _palette.text;

    switch (_button.style)
    {
        case GUIButtonStyle.PRIMARY:
            _border = _palette.accent;
            _text = _active ? c_white : _palette.core;
        break;

        case GUIButtonStyle.DANGER:
            _fill = _active ? make_colour_rgb(65, 12, 20) : make_colour_rgb(25, 5, 10);
            _border = _active ? make_colour_rgb(255, 75, 90) : make_colour_rgb(145, 30, 45);
            _text = _active ? make_colour_rgb(255, 225, 230) : make_colour_rgb(230, 100, 115);
        break;
    }

    if (!_button.enabled)
    {
        _fill = _palette.void;
        _border = _palette.outline;
        _text = _palette.muted;
    }

    draw_set_alpha(_button.enabled ? 0.92 : 0.42);
    draw_set_colour(_fill);
    draw_rectangle(_x1, _y1, _x2, _y2, false);

    draw_set_alpha(_button.enabled ? 1 : 0.38);
    draw_set_colour(_border);
    draw_rectangle(_x1, _y1, _x2, _y2, true);

    var _corner = min(10, _button.height * 0.25);

    draw_line(_x1, _y1, _x1 + _corner, _y1);
    draw_line(_x1, _y1, _x1, _y1 + _corner);
    draw_line(_x2, _y2, _x2 - _corner, _y2);
    draw_line(_x2, _y2, _x2, _y2 - _corner);

    if (_button.selected)
    {
        draw_set_alpha(0.14);
        draw_set_colour(_palette.accent);
        draw_rectangle(_x1 + 3, _y1 + 3, _x2 - 3, _y2 - 3, false);

        draw_set_alpha(1);
        draw_line_width(_x1 + 12, _y2 - 3, _x2 - 12, _y2 - 3, 2);
    }

    draw_set_alpha(1);
    draw_set_colour(_text);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text((_x1 + _x2) * 0.5, (_y1 + _y2) * 0.5, _button.text);

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}