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
            void: make_colour_rgb(1, 5, 8),
            background: make_colour_rgb(2, 10, 14),
            panel: make_colour_rgb(4, 16, 21),
            panel_light: make_colour_rgb(10, 38, 45),
            outline: make_colour_rgb(0, 91, 105),
            accent: make_colour_rgb(0, 232, 242),
            core: make_colour_rgb(190, 255, 255),
            text: make_colour_rgb(145, 218, 224),
            muted: make_colour_rgb(60, 128, 136),

            shield: make_colour_rgb(25, 235, 245),
            armour: make_colour_rgb(125, 210, 220),
            hull: make_colour_rgb(55, 220, 230),
            energy: make_colour_rgb(0, 245, 255),
            fuel: make_colour_rgb(20, 205, 218),
            dash: make_colour_rgb(105, 250, 255),
            cargo: make_colour_rgb(45, 225, 205)
        },

        bottom: {
            width: 1320,
            height: 82,
            margin_bottom: 10,
            bar_segments: 10,
            effect_frames: 12,
            effect_speed: 4,

            cells: {
                shield: { x: 28, width: 112 },
                armour: { x: 148, width: 112 },
                hull: { x: 268, width: 112 },
                energy: { x: 388, width: 125 },
                fuel: { x: 521, width: 125 },
                bullets: { x: 654, width: 92 },
                explosives: { x: 754, width: 100 },
                dash: { x: 862, width: 96 },
                cargo: { x: 966, width: 100 },
                weapon: { x: 1074, width: 218 }
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

        runtime: {
            credits_display: global.profile.credits,
            credit_gain: 0,
            credit_pulse: 0
        },

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

/// @description Triggers the top-HUD credit gain animation.
function sc_hud_level_credit_gain(_hud, _amount)
{
    _hud.runtime.credit_gain += _amount;
    _hud.runtime.credit_pulse = 1;
}

/// @description Smoothly updates lightweight HUD runtime values.
function sc_hud_level_update(_hud)
{
    var _runtime = _hud.runtime;
    var _target = global.profile.credits;
    var _difference = _target - _runtime.credits_display;

    if (_difference != 0)
    {
        var _step = max(1, ceil(abs(_difference) * 0.14));
        _runtime.credits_display += sign(_difference) * min(abs(_difference), _step);
    }

    _runtime.credit_pulse = max(0, _runtime.credit_pulse - 0.045);
    if (_runtime.credit_pulse <= 0) _runtime.credit_gain = 0;
}

/// @description Draws one reusable dark jagged HUD panel.
function sc_hud_panel_primitive_draw(_width, _height, _cut, _palette)
{
    var _base_y = _height - 8;
    var _notch_left = _width * 0.43;
    var _notch_inner_left = _width * 0.445;
    var _notch_inner_right = _width * 0.555;
    var _notch_right = _width * 0.57;

    var _px = [
        _cut, _width - _cut, _width, _width,
        _width - _cut, _notch_right, _notch_inner_right, _notch_inner_left,
        _notch_left, _cut, 0, 0
    ];

    var _py = [
        0, 0, 18, _base_y - 18,
        _base_y, _base_y, _height, _height,
        _base_y, _base_y, _base_y - 18, 18
    ];

    draw_primitive_begin(pr_trianglefan);
    draw_vertex_colour(_width * 0.5, _base_y * 0.5, _palette.background, 0.98);

    for (var _i = 0; _i < array_length(_px); _i++)
        draw_vertex_colour(_px[_i], _py[_i], _palette.panel, 0.98);

    draw_vertex_colour(_px[0], _py[0], _palette.panel, 0.98);
    draw_primitive_end();

    draw_set_colour(_palette.outline);
    draw_set_alpha(0.9);

    for (var _i = 0; _i < array_length(_px); _i++)
    {
        var _next = (_i + 1) mod array_length(_px);
        draw_line_width(_px[_i], _py[_i], _px[_next], _py[_next], 2);
    }

    draw_set_colour(_palette.accent);
    draw_set_alpha(0.85);
    draw_line_width(_cut + 18, 4, _cut + 108, 4, 2);
    draw_line_width(_width - _cut - 108, 4, _width - _cut - 18, 4, 2);
    draw_line_width(_notch_inner_left + 18, _height - 3, _notch_inner_right - 18, _height - 3, 2);

    draw_set_colour(_palette.outline);
    draw_set_alpha(0.45);
    draw_line_width(_cut + 5, 7, _width - _cut - 5, 7, 1);
    draw_line_width(_cut + 5, _base_y - 5, _notch_left - 8, _base_y - 5, 1);
    draw_line_width(_notch_right + 8, _base_y - 5, _width - _cut - 5, _base_y - 5, 1);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws the static slim segmented bottom-HUD body before baking.
function sc_hud_bottom_body_primitive_draw(_data)
{
    var _bottom = _data.bottom;
    var _palette = _data.palette;
    var _cells = _bottom.cells;
    var _cell_names = ["shield", "armour", "hull", "energy", "fuel", "bullets", "explosives", "dash", "cargo", "weapon"];
    var _bar_names = ["shield", "armour", "hull", "energy", "fuel", "dash", "cargo"];

    sc_hud_panel_primitive_draw(_bottom.width, _bottom.height, 18, _palette);

    for (var _i = 0; _i < array_length(_cell_names); _i++)
    {
        var _cell = variable_struct_get(_cells, _cell_names[_i]);
        var _left = _cell.x;
        var _right = _left + _cell.width;

        draw_set_colour(_palette.void);
        draw_set_alpha(0.88);
        draw_rectangle(_left, 8, _right, _bottom.height - 12, false);

        draw_set_colour(_palette.panel_light);
        draw_set_alpha(0.65);
        draw_rectangle(_left, 8, _right, _bottom.height - 12, true);

        // Small baked interface node beside each label.
        draw_set_colour(_palette.outline);
        draw_set_alpha(0.75);
        draw_circle(_left + 10, 19, 4, true);

        draw_set_colour(_palette.accent);
        draw_set_alpha(0.6);
        draw_circle(_left + 10, 19, 1.5, false);

        if (_i < array_length(_cell_names) - 1)
        {
            draw_set_colour(_palette.outline);
            draw_set_alpha(0.6);
            draw_line_width(_right + 4, 13, _right + 4, _bottom.height - 17, 1);
            draw_line_width(_right + 4, 13, _right + 8, 9, 1);
            draw_line_width(_right + 4, _bottom.height - 17, _right + 8, _bottom.height - 13, 1);
        }
    }

    for (var _i = 0; _i < array_length(_bar_names); _i++)
    {
        var _cell = variable_struct_get(_cells, _bar_names[_i]);
        var _segments = _bottom.bar_segments;
        var _left = _cell.x + 7;
        var _available = _cell.width - 14;
        var _gap = 2;
        var _segment_width = (_available - (_segments - 1) * _gap) / _segments;

        for (var _segment = 0; _segment < _segments; _segment++)
        {
            var _segment_x = _left + _segment * (_segment_width + _gap);

            draw_set_colour(_palette.background);
            draw_set_alpha(1);
            draw_rectangle(_segment_x, 37, _segment_x + _segment_width, 49, false);

            draw_set_colour(_palette.panel_light);
            draw_set_alpha(0.8);
            draw_rectangle(_segment_x, 37, _segment_x + _segment_width, 49, true);
        }
    }

    // Reference-style central telemetry markings.
    draw_set_colour(_palette.accent);
    draw_set_alpha(0.8);

    for (var _i = -3; _i <= 3; _i++)
    {
        var _marker_x = _bottom.width * 0.5 + _i * 7;
        var _marker_height = 2 + (3 - abs(_i));
        draw_line(_marker_x, _bottom.height - 9, _marker_x, _bottom.height - 9 - _marker_height);
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws one restrained animated bottom-HUD effect frame before baking.
function sc_hud_bottom_effect_primitive_draw(_data, _frame)
{
    var _bottom = _data.bottom;
    var _palette = _data.palette;
    var _progress = _frame / max(1, _bottom.effect_frames - 1);
    var _scan_x = lerp(24, _bottom.width - 24, _progress);
    var _pulse = 0.25 + sin(_progress * 360) * 0.12;

    draw_set_colour(_palette.accent);
    draw_set_alpha(0.08);
    draw_line_width(_scan_x, 8, _scan_x, _bottom.height - 14, 5);

    draw_set_alpha(0.3);
    draw_line_width(_scan_x, 12, _scan_x, _bottom.height - 18, 1);

    draw_set_alpha(_pulse);
    draw_circle(10, _bottom.height * 0.5 - 4, 3, false);
    draw_circle(_bottom.width - 10, _bottom.height * 0.5 - 4, 3, false);

    var _centre = _bottom.width * 0.5;

    draw_set_alpha(0.35 + _pulse);
    draw_line_width(_centre - 18, _bottom.height - 5, _centre - 7, _bottom.height - 5, 1);
    draw_line_width(_centre + 7, _bottom.height - 5, _centre + 18, _bottom.height - 5, 1);

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
    draw_rectangle(45, 10, 330, _top.height - 10, false);
    draw_rectangle(348, 10, _top.width - 348, _top.height - 10, false);
    draw_rectangle(_top.width - 330, 10, _top.width - 45, _top.height - 10, false);

    draw_set_colour(_palette.panel_light);
    draw_rectangle(45, 10, 330, _top.height - 10, true);
    draw_rectangle(348, 10, _top.width - 348, _top.height - 10, true);
    draw_rectangle(_top.width - 330, 10, _top.width - 45, _top.height - 10, true);
    draw_line(150, 10, 150, _top.height - 10);

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



/// @description Draws one live labelled segmented HUD bar.
function sc_hud_level_bar_draw(_hud, _origin_x, _origin_y, _cell, _label, _value, _ratio, _colour)
{
    var _data = _hud.data;
    var _palette = _data.palette;
    var _segments = _data.bottom.bar_segments;
    var _left = _origin_x + _cell.x;
    var _available = _cell.width - 14;
    var _gap = 2;
    var _segment_width = (_available - (_segments - 1) * _gap) / _segments;
    var _filled = ceil(clamp(_ratio, 0, 1) * _segments);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_colour(_palette.muted);
    draw_text(_left + 19, _origin_y + 12, _label);

    for (var _segment = 0; _segment < _filled; _segment++)
    {
        var _segment_x = _left + 7 + _segment * (_segment_width + _gap);

        draw_set_colour(_colour);
        draw_set_alpha(0.22);
        draw_rectangle(_segment_x - 1, _origin_y + 36, _segment_x + _segment_width + 1, _origin_y + 50, false);

        draw_set_alpha(0.95);
        draw_rectangle(_segment_x, _origin_y + 38, _segment_x + _segment_width, _origin_y + 48, false);
    }

    draw_set_alpha(1);
    draw_set_halign(fa_center);
    draw_set_colour(_palette.text);
    draw_text(_left + _cell.width * 0.5, _origin_y + 55, _value);
}

/// @description Draws one compact live numeric or textual HUD value.
function sc_hud_level_value_draw(_origin_x, _origin_y, _cell, _label, _value, _palette)
{
    var _left = _origin_x + _cell.x;
    var _centre_x = _left + _cell.width * 0.5;

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_colour(_palette.muted);
    draw_text(_left + 19, _origin_y + 12, _label);

    draw_set_halign(fa_center);
    draw_set_colour(_palette.core);
    draw_text(_centre_x, _origin_y + 37, _value);

    draw_set_colour(_palette.accent);
    draw_set_alpha(0.8);
    draw_line_width(_centre_x - 12, _origin_y + 57, _centre_x + 12, _origin_y + 57, 2);
    draw_set_alpha(1);
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

    sc_hud_level_bar_draw(_hud, _x, _y, _cells.shield, "SHIELD", string(round(_shield_ratio * 100)) + "%", _shield_ratio, _palette.shield);
    sc_hud_level_bar_draw(_hud, _x, _y, _cells.armour, "ARMOUR", string(round(_armour_ratio * 100)) + "%", _armour_ratio, _palette.armour);
    sc_hud_level_bar_draw(_hud, _x, _y, _cells.hull, "HULL", string(round(_hull_ratio * 100)) + "%", _hull_ratio, _palette.hull);
    sc_hud_level_bar_draw(_hud, _x, _y, _cells.energy, "ENERGY", string(floor(_resources.energy.current)) + " / " + string(floor(_resources.energy.maximum)), _energy_ratio, _palette.energy);
    sc_hud_level_bar_draw(_hud, _x, _y, _cells.fuel, "FUEL", string(floor(_resources.fuel.current)) + " / " + string(floor(_resources.fuel.maximum)), _fuel_ratio, _palette.fuel);

    sc_hud_level_value_draw(_x, _y, _cells.bullets, "BULLETS", string(floor(_resources.bullets.current)), _palette);
    sc_hud_level_value_draw(_x, _y, _cells.explosives, "EXPLOSIVES", string(floor(_resources.explosives.current)), _palette);

    var _dash_text = _dash.cooldown_remaining <= 0 ? "READY" : string(ceil(_dash.cooldown_remaining));
    sc_hud_level_bar_draw(_hud, _x, _y, _cells.dash, "DASH", _dash_text, _dash_ratio, _palette.dash);

    var _cargo_text = string(floor(_resources.cargo.amount)) + " / " + string(floor(_resources.cargo.capacity));
    sc_hud_level_bar_draw(_hud, _x, _y, _cells.cargo, "CARGO", _cargo_text, _cargo_ratio, _palette.cargo);

    var _weapon = variable_struct_get(global.data.weapons, _player.ship.loadout.primary);
    sc_hud_level_value_draw(_x, _y, _cells.weapon, "PRIMARY WEAPON", _weapon.identity.name, _palette);
}

/// @description Draws credits, location, navigation and coordinates.
function sc_hud_level_top_content_draw(_hud, _player, _x, _y)
{
    var _data = _hud.data;
    var _runtime = _hud.runtime;
    var _palette = _data.palette;
    var _centre_y = _y + _data.top.height * 0.5;
    var _pulse = _runtime.credit_pulse;

    draw_set_valign(fa_middle);

    if (_pulse > 0)
    {
        gpu_set_blendmode(bm_add);
        draw_set_colour(_palette.accent);
        draw_set_alpha(_pulse * 0.22);
        draw_rectangle(_x + 48, _y + 12, _x + 147, _y + _data.top.height - 12, false);
        gpu_set_blendmode(bm_normal);
    }

    draw_set_alpha(1);
    draw_set_halign(fa_center);
    draw_set_colour(_pulse > 0 ? _palette.core : _palette.accent);

    var _credit_text = "CR " + string(floor(_runtime.credits_display));
    if (_runtime.credit_gain > 0 && _pulse > 0) _credit_text += "  +" + string(_runtime.credit_gain);
    draw_text(_x + 98, _centre_y, _credit_text);

    draw_set_halign(fa_left);
    draw_set_colour(_palette.muted);
    draw_text(_x + 162, _centre_y, "AREA // " + string_upper(room_get_name(room)));

    draw_set_halign(fa_center);
    draw_set_colour(_palette.core);
    draw_text(_x + _data.top.width * 0.5, _centre_y, "VECTOR NAVIGATION");

    draw_set_halign(fa_right);
    draw_set_colour(_palette.text);
    draw_text(_x + _data.top.width - 58, _centre_y,
        "X " + string(round(_player.x)) + "  Y " + string(round(_player.y)) + "  HDG " + string(round(_player.draw_angle)));
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

