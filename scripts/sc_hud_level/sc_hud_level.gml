/*
LEVEL HUD

One persistent level-HUD controller draws the permanent top and bottom GUI.
Static primitive artwork is baked once when the level starts.
Changing bars, resource values and text remain lightweight runtime draws.
The minimap dock is baked separately so it can move without rebaking the HUD.
Inventory and other windows should draw between or above these permanent components.
*/

/// @description Returns the complete shared level-HUD visual and layout definition.
function sc_hud_level_data()
{
    return {
        palette: {
            void: make_colour_rgb(3, 8, 13),
            background: make_colour_rgb(7, 17, 25),
            panel: make_colour_rgb(12, 29, 39),
            panel_light: make_colour_rgb(24, 54, 67),
            outline: make_colour_rgb(69, 166, 185),
            accent: make_colour_rgb(55, 225, 255),
            core: make_colour_rgb(220, 255, 255),
            text: make_colour_rgb(190, 218, 225),
            muted: make_colour_rgb(87, 120, 131),

            shield: make_colour_rgb(55, 225, 255),
            armour: make_colour_rgb(205, 220, 230),
            hull: make_colour_rgb(255, 70, 95),
            energy: make_colour_rgb(50, 145, 255),
            fuel: make_colour_rgb(255, 175, 55),
            dash: make_colour_rgb(100, 245, 255),
            cargo: make_colour_rgb(80, 220, 155)
        },

        bottom: {
            width: 1260,
            height: 104,
            margin_bottom: 18,
            effect_frames: 10,
            effect_speed: 4,

            cells: {
                shield: { x: 24, width: 105 },
                armour: { x: 139, width: 105 },
                hull: { x: 254, width: 105 },
                energy: { x: 369, width: 125 },
                fuel: { x: 504, width: 125 },
                bullets: { x: 639, width: 90 },
                explosives: { x: 739, width: 90 },
                dash: { x: 839, width: 105 },
                cargo: { x: 954, width: 110 },
                weapon: { x: 1074, width: 162 }
            }
        },

        top: {
            width: 960,
            height: 54,
            margin_top: 16,
            effect_frames: 10,
            effect_speed: 5
        },

        minimap: {
            width: 224,
            height: 224,
            x: 24,
            y: 88,
            visible: false,
            dragging: false,
            drag_offset_x: 0,
            drag_offset_y: 0
        }
    };
}

/// @description Initializes and bakes the complete level HUD.
function sc_hud_level_init(_hud_object)
{
    var _data = sc_hud_level_data();

    _hud_object.hud = {
        data: _data,

        cache: {
            bottom_body: -1,
            bottom_effects: array_create(_data.bottom.effect_frames, -1),
            top_body: -1,
            top_effects: array_create(_data.top.effect_frames, -1),
            minimap_dock: -1
        }
    };

    return sc_hud_level_cache_bake(_hud_object.hud);
}

/// @description Draws one reusable clipped-corner HUD panel.
function sc_hud_panel_primitive_draw(_width, _height, _cut, _palette)
{
    var _middle = _height * 0.5;

    draw_set_colour(_palette.background);
    draw_rectangle(_cut, 0, _width - _cut, _height, false);
    draw_triangle(0, _middle, _cut, 0, _cut, _height, false);
    draw_triangle(_width, _middle, _width - _cut, _height, _width - _cut, 0, false);

    draw_set_colour(_palette.panel);
    draw_rectangle(_cut + 4, 5, _width - _cut - 4, _height - 5, false);
    draw_triangle(7, _middle, _cut + 4, 5, _cut + 4, _height - 5, false);
    draw_triangle(_width - 7, _middle, _width - _cut - 4, _height - 5, _width - _cut - 4, 5, false);

    draw_set_colour(_palette.outline);
    draw_line_width(_cut, 0, _width - _cut, 0, 2);
    draw_line_width(_width - _cut, 0, _width, _middle, 2);
    draw_line_width(_width, _middle, _width - _cut, _height, 2);
    draw_line_width(_width - _cut, _height, _cut, _height, 2);
    draw_line_width(_cut, _height, 0, _middle, 2);
    draw_line_width(0, _middle, _cut, 0, 2);

    draw_set_colour(_palette.accent);
    draw_line_width(_cut + 18, 5, _cut + 92, 5, 2);
    draw_line_width(_width - _cut - 92, _height - 5, _width - _cut - 18, _height - 5, 2);
}

/// @description Draws the static primitive bottom-HUD body before baking.
function sc_hud_bottom_body_primitive_draw(_data)
{
    var _bottom = _data.bottom;
    var _palette = _data.palette;
    var _cells = _bottom.cells;

    sc_hud_panel_primitive_draw(_bottom.width, _bottom.height, 22, _palette);

    var _names = variable_struct_get_names(_cells);

    for (var _i = 0; _i < array_length(_names); _i++)
    {
        var _cell = variable_struct_get(_cells, _names[_i]);
        var _left = _cell.x;
        var _right = _left + _cell.width;

        draw_set_colour(_palette.void);
        draw_rectangle(_left, 10, _right, _bottom.height - 11, false);

        draw_set_colour(_palette.panel_light);
        draw_rectangle(_left + 1, 11, _right - 1, _bottom.height - 12, true);

        if (_i < array_length(_names) - 1)
        {
            draw_set_colour(_palette.outline);
            draw_set_alpha(0.32);
            draw_line(_right + 5, 17, _right + 5, _bottom.height - 17);
            draw_set_alpha(1);
        }
    }

    var _bar_names = ["shield", "armour", "hull", "energy", "fuel", "dash", "cargo"];

    for (var _i = 0; _i < array_length(_bar_names); _i++)
    {
        var _cell = variable_struct_get(_cells, _bar_names[_i]);

        draw_set_colour(_palette.background);
        draw_rectangle(_cell.x + 6, 42, _cell.x + _cell.width - 6, 56, false);

        draw_set_colour(_palette.panel_light);
        draw_rectangle(_cell.x + 6, 42, _cell.x + _cell.width - 6, 56, true);
    }

    draw_set_colour(_palette.accent);
    draw_circle(_bottom.width * 0.5, 5, 3, false);
    draw_circle(_bottom.width * 0.5, _bottom.height - 5, 3, false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws one animated primitive bottom-HUD effect frame before baking.
function sc_hud_bottom_effect_primitive_draw(_data, _frame)
{
    var _bottom = _data.bottom;
    var _palette = _data.palette;
    var _progress = _frame / max(1, _bottom.effect_frames - 1);
    var _scan_x = lerp(28, _bottom.width - 28, _progress);

    draw_set_alpha(0.13);
    draw_set_colour(_palette.accent);
    draw_line_width(_scan_x, 9, _scan_x, _bottom.height - 9, 4);

    draw_set_alpha(0.32);
    draw_line_width(_scan_x, 14, _scan_x, _bottom.height - 14, 1);

    var _pulse = 0.35 + sin(_progress * 360) * 0.15;

    draw_set_alpha(_pulse);
    draw_circle(14, _bottom.height * 0.5, 4, false);
    draw_circle(_bottom.width - 14, _bottom.height * 0.5, 4, false);
    draw_circle(_bottom.width * 0.5, 5, 2, false);
    draw_circle(_bottom.width * 0.5, _bottom.height - 5, 2, false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws the static primitive top-HUD body before baking.
function sc_hud_top_body_primitive_draw(_data)
{
    var _top = _data.top;
    var _palette = _data.palette;

    sc_hud_panel_primitive_draw(_top.width, _top.height, 28, _palette);

    draw_set_colour(_palette.void);
    draw_rectangle(45, 10, 285, _top.height - 10, false);
    draw_rectangle(303, 10, _top.width - 303, _top.height - 10, false);
    draw_rectangle(_top.width - 285, 10, _top.width - 45, _top.height - 10, false);

    draw_set_colour(_palette.panel_light);
    draw_rectangle(45, 10, 285, _top.height - 10, true);
    draw_rectangle(303, 10, _top.width - 303, _top.height - 10, true);
    draw_rectangle(_top.width - 285, 10, _top.width - 45, _top.height - 10, true);

    draw_set_colour(_palette.accent);
    draw_line_width(_top.width * 0.5 - 42, 5, _top.width * 0.5 + 42, 5, 2);
    draw_line_width(_top.width * 0.5 - 25, _top.height - 5, _top.width * 0.5 + 25, _top.height - 5, 2);

    draw_set_colour(c_white);
}

/// @description Draws one animated primitive top-HUD effect frame before baking.
function sc_hud_top_effect_primitive_draw(_data, _frame)
{
    var _top = _data.top;
    var _palette = _data.palette;
    var _progress = _frame / max(1, _top.effect_frames - 1);
    var _scan_x = lerp(45, _top.width - 45, _progress);
    var _pulse = 0.25 + sin(_progress * 360) * 0.12;

    draw_set_colour(_palette.accent);
    draw_set_alpha(0.13);
    draw_line_width(_scan_x, 10, _scan_x, _top.height - 10, 3);

    draw_set_alpha(_pulse);
    draw_circle(_top.width * 0.5, 5, 3, false);
    draw_circle(_top.width * 0.5, _top.height - 5, 3, false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws the future movable minimap dock before baking.
function sc_hud_minimap_dock_primitive_draw(_data)
{
    var _minimap = _data.minimap;
    var _palette = _data.palette;
    var _width = _minimap.width;
    var _height = _minimap.height;

    sc_hud_panel_primitive_draw(_width, _height, 20, _palette);

    draw_set_colour(_palette.void);
    draw_circle(_width * 0.5, _height * 0.5, min(_width, _height) * 0.42, false);

    draw_set_colour(_palette.panel_light);
    draw_circle(_width * 0.5, _height * 0.5, min(_width, _height) * 0.42, true);

    draw_set_colour(_palette.accent);
    draw_line_width(_width * 0.5 - 24, 9, _width * 0.5 + 24, 9, 2);

    draw_set_colour(c_white);
}

/// @description Bakes one HUD component into a runtime sprite.
function sc_hud_level_component_bake(_data, _component, _frame)
{
    var _width;
    var _height;

    switch (_component)
    {
        case "bottom_body":
        case "bottom_effect":
            _width = _data.bottom.width;
            _height = _data.bottom.height;
        break;

        case "top_body":
        case "top_effect":
            _width = _data.top.width;
            _height = _data.top.height;
        break;

        case "minimap_dock":
            _width = _data.minimap.width;
            _height = _data.minimap.height;
        break;

        default:
            return -1;
    }

    var _surface = surface_create(_width, _height);
    if (!surface_exists(_surface)) return -1;

    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);
    draw_set_alpha(1);
    draw_set_colour(c_white);

    switch (_component)
    {
        case "bottom_body": sc_hud_bottom_body_primitive_draw(_data); break;
        case "bottom_effect": sc_hud_bottom_effect_primitive_draw(_data, _frame); break;
        case "top_body": sc_hud_top_body_primitive_draw(_data); break;
        case "top_effect": sc_hud_top_effect_primitive_draw(_data, _frame); break;
        case "minimap_dock": sc_hud_minimap_dock_primitive_draw(_data); break;
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
    surface_reset_target();

    var _sprite = sprite_create_from_surface(_surface, 0, 0, _width, _height, false, false, 0, 0);
    surface_free(_surface);
    return _sprite;
}

/// @description Bakes all permanent level-HUD visual components.
function sc_hud_level_cache_bake(_hud)
{
    var _data = _hud.data;
    var _cache = _hud.cache;

    _cache.bottom_body = sc_hud_level_component_bake(_data, "bottom_body", 0);
    _cache.top_body = sc_hud_level_component_bake(_data, "top_body", 0);
    _cache.minimap_dock = sc_hud_level_component_bake(_data, "minimap_dock", 0);

    for (var _frame = 0; _frame < array_length(_cache.bottom_effects); _frame++)
        _cache.bottom_effects[_frame] = sc_hud_level_component_bake(_data, "bottom_effect", _frame);

    for (var _frame = 0; _frame < array_length(_cache.top_effects); _frame++)
        _cache.top_effects[_frame] = sc_hud_level_component_bake(_data, "top_effect", _frame);

    if (!sprite_exists(_cache.bottom_body) || !sprite_exists(_cache.top_body) || !sprite_exists(_cache.minimap_dock))
    {
        sc_hud_level_cleanup(_hud);
        return false;
    }

    show_debug_message("LEVEL HUD VISUAL CACHE BAKED");
    return true;
}

/// @description Draws one live labelled HUD bar.
function sc_hud_level_bar_draw(_origin_x, _origin_y, _cell, _label, _value, _ratio, _colour, _palette)
{
    var _left = _origin_x + _cell.x;
    var _right = _left + _cell.width;
    var _fill_left = _left + 8;
    var _fill_right = _right - 8;
    var _fill_width = max(0, (_fill_right - _fill_left) * clamp(_ratio, 0, 1));

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_colour(_palette.muted);
    draw_text(_left + 6, _origin_y + 17, _label);

    if (_fill_width > 0)
    {
        draw_set_alpha(0.28);
        draw_set_colour(_colour);
        draw_rectangle(_fill_left - 2, _origin_y + 42, _fill_left + _fill_width + 2, _origin_y + 56, false);

        draw_set_alpha(0.9);
        draw_rectangle(_fill_left, _origin_y + 44, _fill_left + _fill_width, _origin_y + 54, false);
    }

    draw_set_alpha(1);
    draw_set_halign(fa_center);
    draw_set_colour(_palette.text);
    draw_text((_left + _right) * 0.5, _origin_y + 65, _value);
}

/// @description Draws one live numeric or textual HUD value.
function sc_hud_level_value_draw(_origin_x, _origin_y, _cell, _label, _value, _palette)
{
    var _centre_x = _origin_x + _cell.x + _cell.width * 0.5;

    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_colour(_palette.muted);
    draw_text(_centre_x, _origin_y + 17, _label);

    draw_set_colour(_palette.core);
    draw_text(_centre_x, _origin_y + 49, _value);
}

/// @description Draws changing player data over the baked bottom HUD.
function sc_hud_level_bottom_content_draw(_hud, _player, _x, _y)
{
    var _data = _hud.data;
    var _palette = _data.palette;
    var _cells = _data.bottom.cells;
    var _defence = _player.defence;
    var _resources = _player.resources;
    var _dash = _player.movement.dash;
    var _stats = _player.ship.stats.final;

    var _shield_ratio = _defence.shield.maximum > 0 ? _defence.shield.current / _defence.shield.maximum : 0;
    var _armour_ratio = _defence.armour.maximum > 0 ? _defence.armour.current / _defence.armour.maximum : 0;
    var _hull_ratio = _defence.hull.maximum > 0 ? _defence.hull.current / _defence.hull.maximum : 0;
    var _energy_ratio = _resources.energy.maximum > 0 ? _resources.energy.current / _resources.energy.maximum : 0;
    var _fuel_ratio = _resources.fuel.maximum > 0 ? _resources.fuel.current / _resources.fuel.maximum : 0;
    var _dash_ratio = _stats.dash_cooldown > 0 ? 1 - _dash.cooldown_remaining / _stats.dash_cooldown : 1;
    var _cargo_ratio = _resources.cargo.capacity > 0 ? _resources.cargo.amount / _resources.cargo.capacity : 0;

    sc_hud_level_bar_draw(_x, _y, _cells.shield, "SHIELD", string(floor(_defence.shield.current)) + " / " + string(floor(_defence.shield.maximum)), _shield_ratio, _palette.shield, _palette);
    sc_hud_level_bar_draw(_x, _y, _cells.armour, "ARMOUR", string(floor(_defence.armour.current)) + " / " + string(floor(_defence.armour.maximum)), _armour_ratio, _palette.armour, _palette);
    sc_hud_level_bar_draw(_x, _y, _cells.hull, "HULL", string(floor(_defence.hull.current)) + " / " + string(floor(_defence.hull.maximum)), _hull_ratio, _palette.hull, _palette);
    sc_hud_level_bar_draw(_x, _y, _cells.energy, "ENERGY", string(floor(_resources.energy.current)) + " / " + string(floor(_resources.energy.maximum)), _energy_ratio, _palette.energy, _palette);
    sc_hud_level_bar_draw(_x, _y, _cells.fuel, "FUEL", string(floor(_resources.fuel.current)) + " / " + string(floor(_resources.fuel.maximum)), _fuel_ratio, _palette.fuel, _palette);

    sc_hud_level_value_draw(_x, _y, _cells.bullets, "BULLETS", string(floor(_resources.bullets.current)), _palette);
    sc_hud_level_value_draw(_x, _y, _cells.explosives, "EXPLOSIVES", string(floor(_resources.explosives.current)), _palette);

    var _dash_text = _dash.cooldown_remaining <= 0 ? "READY" : string(ceil(_dash.cooldown_remaining));
    sc_hud_level_bar_draw(_x, _y, _cells.dash, "DASH", _dash_text, _dash_ratio, _palette.dash, _palette);

    var _cargo_text = string(floor(_resources.cargo.amount)) + " / " + string(floor(_resources.cargo.capacity));
    sc_hud_level_bar_draw(_x, _y, _cells.cargo, "CARGO", _cargo_text, _cargo_ratio, _palette.cargo, _palette);

    var _weapon = variable_struct_get(global.data.weapons, _player.ship.loadout.primary);
    sc_hud_level_value_draw(_x, _y, _cells.weapon, "PRIMARY WEAPON", _weapon.identity.name, _palette);
}

/// @description Draws changing navigation data over the baked top HUD.
function sc_hud_level_top_content_draw(_hud, _player, _x, _y)
{
    var _data = _hud.data;
    var _palette = _data.palette;
    var _centre = _x + _data.top.width * 0.5;

    draw_set_valign(fa_middle);

    draw_set_halign(fa_left);
    draw_set_colour(_palette.muted);
    draw_text(_x + 58, _y + _data.top.height * 0.5, "AREA  //  " + string_upper(room_get_name(room)));

    draw_set_halign(fa_center);
    draw_set_colour(_palette.core);
    draw_text(_centre, _y + _data.top.height * 0.5, "VECTOR NAVIGATION");

    draw_set_halign(fa_right);
    draw_set_colour(_palette.text);
    draw_text(_x + _data.top.width - 58, _y + _data.top.height * 0.5,
        "X " + string(round(_player.x)) + "   Y " + string(round(_player.y)) + "   HDG " + string(round(_player.draw_angle)));
}

/// @description Draws the complete permanent HUD in GUI space.
function sc_hud_level_draw(_hud)
{
    if (global.LevelState != LevelState.PLAYING) return;

    var _data = _hud.data;
    var _cache = _hud.cache;
    var _gui_width = display_get_gui_width();
    var _gui_height = display_get_gui_height();

    var _bottom_x = floor((_gui_width - _data.bottom.width) * 0.5);
    var _bottom_y = floor(_gui_height - _data.bottom.height - _data.bottom.margin_bottom);
    var _top_x = floor((_gui_width - _data.top.width) * 0.5);
    var _top_y = _data.top.margin_top;

    var _bottom_frame = floor(GAME_TICK / _data.bottom.effect_speed) mod array_length(_cache.bottom_effects);
    var _top_frame = floor(GAME_TICK / _data.top.effect_speed) mod array_length(_cache.top_effects);

    draw_set_alpha(1);
    draw_set_colour(c_white);

    draw_sprite(_cache.top_body, 0, _top_x, _top_y);
    draw_sprite(_cache.bottom_body, 0, _bottom_x, _bottom_y);

    if (instance_exists(global.player_id))
    {
        sc_hud_level_top_content_draw(_hud, global.player_id, _top_x, _top_y);
        sc_hud_level_bottom_content_draw(_hud, global.player_id, _bottom_x, _bottom_y);
    }
    else
    {
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_colour(_data.palette.hull);
        draw_text(_bottom_x + _data.bottom.width * 0.5, _bottom_y + _data.bottom.height * 0.5, "NO ACTIVE SHIP LINK");
    }

    gpu_set_blendmode(bm_add);
    draw_sprite(_cache.top_effects[_top_frame], 0, _top_x, _top_y);
    draw_sprite(_cache.bottom_effects[_bottom_frame], 0, _bottom_x, _bottom_y);
    gpu_set_blendmode(bm_normal);

    if (_data.minimap.visible)
        draw_sprite(_cache.minimap_dock, 0, _data.minimap.x, _data.minimap.y);

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

/// @description Deletes all generated HUD sprites.
function sc_hud_level_cleanup(_hud)
{
    var _cache = _hud.cache;

    if (sprite_exists(_cache.bottom_body)) sprite_delete(_cache.bottom_body);
    if (sprite_exists(_cache.top_body)) sprite_delete(_cache.top_body);
    if (sprite_exists(_cache.minimap_dock)) sprite_delete(_cache.minimap_dock);

    for (var _i = 0; _i < array_length(_cache.bottom_effects); _i++)
        if (sprite_exists(_cache.bottom_effects[_i])) sprite_delete(_cache.bottom_effects[_i]);

    for (var _i = 0; _i < array_length(_cache.top_effects); _i++)
        if (sprite_exists(_cache.top_effects[_i])) sprite_delete(_cache.top_effects[_i]);

    _cache.bottom_body = -1;
    _cache.top_body = -1;
    _cache.minimap_dock = -1;
    _cache.bottom_effects = [];
    _cache.top_effects = [];

    show_debug_message("LEVEL HUD VISUAL CACHE DESTROYED");
}