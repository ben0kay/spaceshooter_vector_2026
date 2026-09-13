/// @description Returns the interface colour belonging to an upgrade category.
function sc_player_upgrade_category_colour_get(_category)
{
    switch (_category)
    {
        case UpgradeCategory.WEAPONS:  return make_colour_rgb(45,205,255);
        case UpgradeCategory.DEFENCE:  return make_colour_rgb(35,235,205);
        case UpgradeCategory.MOBILITY: return make_colour_rgb(255,195,55);
        case UpgradeCategory.SYSTEMS:  return make_colour_rgb(180,85,255);
    }

    return c_white;
}

/// @description Returns the interface name belonging to an upgrade category.
function sc_player_upgrade_category_name_get(_category)
{
    switch (_category)
    {
        case UpgradeCategory.WEAPONS:  return "WEAPONS";
        case UpgradeCategory.DEFENCE:  return "DEFENCE";
        case UpgradeCategory.MOBILITY: return "MOBILITY";
        case UpgradeCategory.SYSTEMS:  return "SYSTEMS";
    }

    return "UNKNOWN";
}

/// @description Draws one filled or outlined interface hexagon.
function sc_player_upgrade_hexagon_draw(_x,_y,_radius,_colour,_alpha,_outline)
{
    draw_set_colour(_colour);
    draw_set_alpha(_alpha);

    if (_outline)
    {
        draw_primitive_begin(pr_linestrip);

        for (var _i = 0; _i <= 6; ++_i)
        {
            var _angle = 30 + _i * 60;

            draw_vertex(
                _x + lengthdir_x(_radius,_angle),
                _y + lengthdir_y(_radius,_angle)
            );
        }

        draw_primitive_end();
        return;
    }

    draw_primitive_begin(pr_trianglefan);
    draw_vertex(_x,_y);

    for (var _i = 0; _i <= 6; ++_i)
    {
        var _angle = 30 + _i * 60;

        draw_vertex(
            _x + lengthdir_x(_radius,_angle),
            _y + lengthdir_y(_radius,_angle)
        );
    }

    draw_primitive_end();
}

/// @description Returns a readable description of one stat modifier.
function sc_player_upgrade_modifier_text_get(_modifier)
{
    var _name = string_upper(
        string_replace_all(_modifier.stat,"_"," ")
    );

    if (variable_struct_exists(_modifier,"multiply_per_rank"))
    {
        var _percent = round(_modifier.multiply_per_rank * 100);
        var _sign = _percent >= 0 ? "+" : "";

        return _sign + string(_percent) + "% " + _name + " PER RANK";
    }

    var _amount = _modifier.add_per_rank;
    var _sign = _amount >= 0 ? "+" : "";

    return _sign + string(_amount) + " " + _name + " PER RANK";
}

/// @description Draws the inspector for the selected upgrade.
function sc_player_upgrade_inspector_draw(_hud,_origin_x,_origin_y)
{
    var _runtime = _hud.inventory.upgrades;
    var _palette = _hud.data.palette;
    var _upgrade = sc_player_upgrade_get(_runtime.selected_key);
    if (is_undefined(_upgrade)) return;

    var _panel_x = _origin_x + 1115;
    var _panel_y = _origin_y + 165;
    var _panel_width = 390;
    var _panel_height = 560;
    var _colour = sc_player_upgrade_category_colour_get(_upgrade.category);
    var _rank = sc_player_upgrade_rank_get(_upgrade.key);
    var _requirements_met = sc_player_upgrade_requirements_met(_upgrade);

    draw_set_alpha(0.97);
    draw_set_colour(_palette.void);
    draw_rectangle(
        _panel_x,_panel_y,
        _panel_x + _panel_width,
        _panel_y + _panel_height,
        false
    );

    draw_set_alpha(0.85);
    draw_set_colour(_colour);
    draw_rectangle(
        _panel_x,_panel_y,
        _panel_x + _panel_width,
        _panel_y + _panel_height,
        true
    );

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
    draw_set_colour(_colour);
    draw_text(_panel_x + 22,_panel_y + 20,"UPGRADE INSPECTOR");

    draw_set_colour(_palette.core);
    draw_text(_panel_x + 22,_panel_y + 62,_upgrade.name);

    draw_set_colour(_colour);
    draw_text(
        _panel_x + 22,
        _panel_y + 90,
        sc_player_upgrade_category_name_get(_upgrade.category)
        + "  //  RANK "
        + string(_rank)
        + "/"
        + string(_upgrade.maximum_rank)
    );

    draw_set_colour(_palette.text);
    draw_text_ext(
        _panel_x + 22,
        _panel_y + 125,
        _upgrade.description,
        20,
        _panel_width - 44
    );

    draw_set_colour(_colour);
    draw_text(_panel_x + 22,_panel_y + 205,"REQUIREMENTS");

    var _requirement_y = _panel_y + 235;

    if (array_length(_upgrade.requirements) <= 0)
    {
        draw_set_colour(_palette.text);
        draw_text(_panel_x + 22,_requirement_y,"NO PREREQUISITES");
        _requirement_y += 25;
    }
    else
    {
        for (var _i = 0; _i < array_length(_upgrade.requirements); ++_i)
        {
            var _requirement = _upgrade.requirements[_i];
            var _required_upgrade = sc_player_upgrade_get(_requirement.key);
            var _current_rank = sc_player_upgrade_rank_get(_requirement.key);
            var _met = _current_rank >= _requirement.rank;

            draw_set_colour(_met ? _colour : _palette.muted);
            draw_text(
                _panel_x + 22,
                _requirement_y,
                (_met ? "[OK] " : "[--] ")
                + _required_upgrade.name
                + "  "
                + string(_current_rank)
                + "/"
                + string(_requirement.rank)
            );

            _requirement_y += 25;
        }
    }

    draw_set_colour(_colour);
    draw_text(_panel_x + 22,_panel_y + 330,"EFFECTS");

    var _effect_y = _panel_y + 360;

    for (var _i = 0; _i < array_length(_upgrade.modifiers); ++_i)
    {
        draw_set_colour(_palette.text);
        draw_text(
            _panel_x + 22,
            _effect_y,
            sc_player_upgrade_modifier_text_get(_upgrade.modifiers[_i])
        );

        _effect_y += 25;
    }

    draw_set_colour(_colour);
    draw_text(_panel_x + 22,_panel_y + 455,"COST");

    draw_set_colour(
        global.profile.progression.data_shards >= _upgrade.cost_per_rank
            ? _palette.data_shard
            : _palette.danger
    );

    draw_text(
        _panel_x + 22,
        _panel_y + 485,
        string(_upgrade.cost_per_rank)
        + " DATA SHARD"
        + (_upgrade.cost_per_rank == 1 ? "" : "S")
    );

    var _button = _runtime.purchase_button;

    if (_rank >= _upgrade.maximum_rank)
        _button.text = "UPGRADE COMPLETE";
    else if (!_requirements_met)
        _button.text = "REQUIREMENTS NOT MET";
    else if (global.profile.progression.data_shards < _upgrade.cost_per_rank)
        _button.text = "INSUFFICIENT DATA SHARDS";
    else
        _button.text = "INSTALL RANK " + string(_rank + 1);

    sc_gui_button_draw(_button,_origin_x,_origin_y,_palette);
}

/// @description Converts a tree-design X coordinate into clipped surface space.
function sc_player_upgrade_view_x(_view,_design_x)
{
    return _view.width * 0.5
        + (_design_x - _view.design_centre_x) * _view.zoom
        + _view.pan_x;
}

/// @description Converts a tree-design Y coordinate into clipped surface space.
function sc_player_upgrade_view_y(_view,_design_y)
{
    return _view.height * 0.5
        + (_design_y - _view.design_centre_y) * _view.zoom
        + _view.pan_y;
}

/// @description Returns whether panel-local coordinates are inside the tree viewport.
function sc_player_upgrade_view_contains(_view,_mouse_x,_mouse_y)
{
    return point_in_rectangle(
        _mouse_x,_mouse_y,
        _view.x,_view.y,
        _view.x + _view.width,
        _view.y + _view.height
    );
}

/// @description Returns the transformed upgrade beneath panel-local coordinates.
function sc_player_upgrade_at_position(_view,_mouse_x,_mouse_y)
{
    var _surface_x = _mouse_x - _view.x;
    var _surface_y = _mouse_y - _view.y;
    var _radius = 38 * _view.zoom;
    var _upgrades = sc_player_upgrades_get();

    for (var _i = array_length(_upgrades) - 1; _i >= 0; --_i)
    {
        var _upgrade = _upgrades[_i];
        var _x = sc_player_upgrade_view_x(_view,_upgrade.position.x);
        var _y = sc_player_upgrade_view_y(_view,_upgrade.position.y);

        if (point_distance(_surface_x,_surface_y,_x,_y) <= _radius)
            return _upgrade;
    }

    return undefined;
}

/// @description Updates clipped-tree panning, zooming, selection and purchasing.
function sc_player_upgrades_interface_update(_hud,_mouse_x,_mouse_y,_pressed)
{
    var _runtime = _hud.inventory.upgrades;
    var _view = _runtime.view;
    var _inside = sc_player_upgrade_view_contains(
        _view,_mouse_x,_mouse_y
    );

    var _middle_pressed = mouse_check_button_pressed(mb_middle);
    var _middle_held = mouse_check_button(mb_middle);

    if (_inside && _middle_pressed)
    {
        _view.dragging = true;
        _view.drag_mouse_x = _mouse_x;
        _view.drag_mouse_y = _mouse_y;
    }

    if (!_middle_held)
        _view.dragging = false;

    if (_view.dragging)
    {
        _view.pan_x += _mouse_x - _view.drag_mouse_x;
        _view.pan_y += _mouse_y - _view.drag_mouse_y;

        _view.pan_x = clamp(_view.pan_x,-700,700);
        _view.pan_y = clamp(_view.pan_y,-500,500);

        _view.drag_mouse_x = _mouse_x;
        _view.drag_mouse_y = _mouse_y;
    }

    if (_inside)
    {
        var _wheel = mouse_wheel_up() - mouse_wheel_down();

        if (_wheel != 0)
        {
            var _old_zoom = _view.zoom;
            var _new_zoom = clamp(
                _old_zoom + _wheel * _view.zoom_step,
                _view.zoom_min,
                _view.zoom_max
            );

            if (_new_zoom != _old_zoom)
            {
                var _surface_x = _mouse_x - _view.x;
                var _surface_y = _mouse_y - _view.y;
                var _centre_x = _view.width * 0.5;
                var _centre_y = _view.height * 0.5;
                var _scale = _new_zoom / _old_zoom;

                // Keep the design point beneath the cursor stationary.
                _view.pan_x = _surface_x - _centre_x
                    - (_surface_x - _centre_x - _view.pan_x) * _scale;

                _view.pan_y = _surface_y - _centre_y
                    - (_surface_y - _centre_y - _view.pan_y) * _scale;

                _view.zoom = _new_zoom;
            }
        }

        if (_pressed && !_view.dragging)
        {
            var _hovered = sc_player_upgrade_at_position(
                _view,_mouse_x,_mouse_y
            );

            if (!is_undefined(_hovered))
                _runtime.selected_key = _hovered.key;
        }
    }

    var _selected = sc_player_upgrade_get(_runtime.selected_key);
    var _button = _runtime.purchase_button;

    _button.enabled = !is_undefined(_selected)
        && sc_player_upgrade_can_purchase(_selected);

    if (sc_gui_button_update(_button,_mouse_x,_mouse_y,_pressed))
        sc_player_upgrade_purchase(_selected.key);
}

/// @description Draws one scaled symbol inside a transformed upgrade node.
function sc_player_upgrade_symbol_draw(_upgrade,_x,_y,_colour,_scale)
{
    var _s = _scale;

    draw_set_colour(_colour);
    draw_set_alpha(1);

    switch (_upgrade.category)
    {
        case UpgradeCategory.WEAPONS:
        {
            draw_line_width(
                _x - 11 * _s,_y + 8 * _s,
                _x + 10 * _s,_y - 8 * _s,
                max(1,3 * _s)
            );

            draw_line_width(
                _x - 5 * _s,_y + 12 * _s,
                _x + 14 * _s,_y - 3 * _s,
                max(1,2 * _s)
            );

            draw_circle(
                _x + 11 * _s,
                _y - 9 * _s,
                max(2,3 * _s),
                false
            );
        }
        break;

        case UpgradeCategory.DEFENCE:
        {
            draw_primitive_begin(pr_trianglefan);
            draw_vertex(_x,_y + 13 * _s);
            draw_vertex(_x - 12 * _s,_y - 8 * _s);
            draw_vertex(_x,_y - 14 * _s);
            draw_vertex(_x + 12 * _s,_y - 8 * _s);
            draw_vertex(_x,_y + 13 * _s);
            draw_primitive_end();

            draw_set_colour(make_colour_rgb(2,10,14));
            draw_circle(_x,_y - 2 * _s,max(2,5 * _s),false);
        }
        break;

        case UpgradeCategory.MOBILITY:
        {
            draw_line_width(
                _x - 13 * _s,_y - 10 * _s,
                _x - 2 * _s,_y,
                max(1,3 * _s)
            );

            draw_line_width(
                _x - 2 * _s,_y,
                _x - 13 * _s,_y + 10 * _s,
                max(1,3 * _s)
            );

            draw_line_width(
                _x,_y - 10 * _s,
                _x + 11 * _s,_y,
                max(1,3 * _s)
            );

            draw_line_width(
                _x + 11 * _s,_y,
                _x,_y + 10 * _s,
                max(1,3 * _s)
            );
        }
        break;

        case UpgradeCategory.SYSTEMS:
        {
            draw_rectangle(
                _x - 10 * _s,_y - 10 * _s,
                _x + 10 * _s,_y + 10 * _s,
                true
            );

            draw_rectangle(
                _x - 5 * _s,_y - 5 * _s,
                _x + 5 * _s,_y + 5 * _s,
                false
            );

            for (var _i = -8; _i <= 8; _i += 8)
            {
                var _offset = _i * _s;

                draw_line(
                    _x + _offset,_y - 15 * _s,
                    _x + _offset,_y - 11 * _s
                );

                draw_line(
                    _x + _offset,_y + 11 * _s,
                    _x + _offset,_y + 15 * _s
                );

                draw_line(
                    _x - 15 * _s,_y + _offset,
                    _x - 11 * _s,_y + _offset
                );

                draw_line(
                    _x + 11 * _s,_y + _offset,
                    _x + 15 * _s,_y + _offset
                );
            }
        }
        break;
    }
}

/// @description Draws directional prerequisite connections inside the clipped surface.
function sc_player_upgrades_connections_draw(_runtime,_palette)
{
    var _view = _runtime.view;
    var _upgrades = sc_player_upgrades_get();
    var _node_radius = 38 * _view.zoom;

    for (var _i = 0; _i < array_length(_upgrades); ++_i)
    {
        var _upgrade = _upgrades[_i];
        var _end_x = sc_player_upgrade_view_x(_view,_upgrade.position.x);
        var _end_y = sc_player_upgrade_view_y(_view,_upgrade.position.y);
        var _colour = sc_player_upgrade_category_colour_get(_upgrade.category);

        for (var _j = 0; _j < array_length(_upgrade.requirements); ++_j)
        {
            var _requirement = _upgrade.requirements[_j];
            var _parent = sc_player_upgrade_get(_requirement.key);
            if (is_undefined(_parent)) continue;

            var _start_x = sc_player_upgrade_view_x(_view,_parent.position.x);
            var _start_y = sc_player_upgrade_view_y(_view,_parent.position.y);
            var _distance = max(1,point_distance(_start_x,_start_y,_end_x,_end_y));
            var _normal_x = (_end_x - _start_x) / _distance;
            var _normal_y = (_end_y - _start_y) / _distance;

            var _x1 = _start_x + _normal_x * _node_radius;
            var _y1 = _start_y + _normal_y * _node_radius;
            var _x2 = _end_x - _normal_x * _node_radius;
            var _y2 = _end_y - _normal_y * _node_radius;
            var _active = sc_player_upgrade_rank_get(_parent.key) >= _requirement.rank;

            if (_active)
            {
                gpu_set_blendmode(bm_add);
                draw_set_colour(_colour);
                draw_set_alpha(0.12);
                draw_line_width(_x1,_y1,_x2,_y2,max(3,6 * _view.zoom));
                gpu_set_blendmode(bm_normal);
            }

            draw_set_colour(_active ? _colour : _palette.outline);
            draw_set_alpha(_active ? 0.9 : 0.28);
            draw_line_width(_x1,_y1,_x2,_y2,max(1,2 * _view.zoom));
        }
    }
}

/// @description Draws one transformed upgrade node with a subtle outline glow.
function sc_player_upgrade_node_draw(_upgrade,_selected,_runtime,_palette)
{
    var _view = _runtime.view;
    var _x = sc_player_upgrade_view_x(_view,_upgrade.position.x);
    var _y = sc_player_upgrade_view_y(_view,_upgrade.position.y);
    var _zoom = _view.zoom;
    var _rank = sc_player_upgrade_rank_get(_upgrade.key);
    var _requirements_met = sc_player_upgrade_requirements_met(_upgrade);
    var _complete = _rank >= _upgrade.maximum_rank;
    var _colour = sc_player_upgrade_category_colour_get(_upgrade.category);

    var _fill = _palette.void;
    var _border = _palette.outline;
    var _symbol = _palette.muted;
    var _border_alpha = 0.45;
    var _glow_alpha = 0.05;

    if (_requirements_met)
    {
        _border = _colour;
        _symbol = _colour;
        _border_alpha = 0.85;
        _glow_alpha = 0.11;
    }

    if (_rank > 0)
    {
        _fill = merge_colour(_palette.panel,_colour,0.3);
        _border = _colour;
        _symbol = _palette.core;
        _border_alpha = 1;
        _glow_alpha = 0.17;
    }

    if (_selected)
        _glow_alpha = 0.25;

    // Soft additive outline glow.
    gpu_set_blendmode(bm_add);

    sc_player_upgrade_hexagon_draw(
        _x,_y,48 * _zoom,
        _requirements_met ? _colour : _palette.outline,
        _glow_alpha * 0.35,
        true
    );

    sc_player_upgrade_hexagon_draw(
        _x,_y,44 * _zoom,
        _requirements_met ? _colour : _palette.outline,
        _glow_alpha,
        true
    );

    if (_selected)
    {
        sc_player_upgrade_hexagon_draw(
            _x,_y,43 * _zoom,_colour,0.1,false
        );
    }

    gpu_set_blendmode(bm_normal);

    sc_player_upgrade_hexagon_draw(
        _x,_y,36 * _zoom,_fill,0.96,false
    );

    sc_player_upgrade_hexagon_draw(
        _x,_y,
        (_selected ? 41 : 37) * _zoom,
        _selected ? _palette.core : _border,
        _selected ? 1 : _border_alpha,
        true
    );

    sc_player_upgrade_symbol_draw(
        _upgrade,_x,_y,_symbol,_zoom
    );

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_colour(_complete ? _palette.core : _symbol);
    draw_set_alpha(_requirements_met ? 1 : 0.5);

    draw_text(
        _x,
        _y + 51 * _zoom,
        string(_rank) + "/" + string(_upgrade.maximum_rank)
    );
}

/// @description Draws the four-direction upgrade cross into surface-local space.
function sc_player_upgrades_canvas_draw(_hud)
{
    var _runtime = _hud.inventory.upgrades;
    var _view = _runtime.view;
    var _palette = _hud.data.palette;
    var _upgrades = sc_player_upgrades_get();

    draw_clear_alpha(_palette.background,1);

    var _core_x = sc_player_upgrade_view_x(_view,475);
    var _core_y = sc_player_upgrade_view_y(_view,425);

    var _branches = [
        {
            key: "weapon_calibration",
            label: "WEAPONS",
            label_x: 610,
            label_y: 350,
            colour: sc_player_upgrade_category_colour_get(UpgradeCategory.WEAPONS)
        },
        {
            key: "defence_hull",
            label: "DEFENCE",
            label_x: 340,
            label_y: 350,
            colour: sc_player_upgrade_category_colour_get(UpgradeCategory.DEFENCE)
        },
        {
            key: "systems_reactor",
            label: "SYSTEMS",
            label_x: 535,
            label_y: 290,
            colour: sc_player_upgrade_category_colour_get(UpgradeCategory.SYSTEMS)
        },
        {
            key: "mobility_thrusters",
            label: "MOBILITY",
            label_x: 535,
            label_y: 560,
            colour: sc_player_upgrade_category_colour_get(UpgradeCategory.MOBILITY)
        }
    ];

    // Connect the central command core to each root branch.
    for (var _i = 0; _i < array_length(_branches); ++_i)
    {
        var _branch = _branches[_i];
        var _root = sc_player_upgrade_get(_branch.key);
        var _root_x = sc_player_upgrade_view_x(_view,_root.position.x);
        var _root_y = sc_player_upgrade_view_y(_view,_root.position.y);
        var _distance = max(1,point_distance(_core_x,_core_y,_root_x,_root_y));
        var _normal_x = (_root_x - _core_x) / _distance;
        var _normal_y = (_root_y - _core_y) / _distance;

        var _x1 = _core_x + _normal_x * 31 * _view.zoom;
        var _y1 = _core_y + _normal_y * 31 * _view.zoom;
        var _x2 = _root_x - _normal_x * 38 * _view.zoom;
        var _y2 = _root_y - _normal_y * 38 * _view.zoom;

        gpu_set_blendmode(bm_add);
        draw_set_colour(_branch.colour);
        draw_set_alpha(0.1);
        draw_line_width(_x1,_y1,_x2,_y2,max(3,6 * _view.zoom));
        gpu_set_blendmode(bm_normal);

        draw_set_colour(_branch.colour);
        draw_set_alpha(0.7);
        draw_line_width(_x1,_y1,_x2,_y2,max(1,2 * _view.zoom));

        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_colour(_branch.colour);
        draw_set_alpha(0.9);

        draw_text(
            sc_player_upgrade_view_x(_view,_branch.label_x),
            sc_player_upgrade_view_y(_view,_branch.label_y),
            _branch.label
        );
    }

    // Decorative centre from which all four categories divide.
    gpu_set_blendmode(bm_add);
    sc_player_upgrade_hexagon_draw(
        _core_x,_core_y,39 * _view.zoom,
        _palette.accent,0.08,false
    );
    sc_player_upgrade_hexagon_draw(
        _core_x,_core_y,36 * _view.zoom,
        _palette.core,0.22,true
    );
    gpu_set_blendmode(bm_normal);

    sc_player_upgrade_hexagon_draw(
        _core_x,_core_y,29 * _view.zoom,
        _palette.panel,0.98,false
    );
    sc_player_upgrade_hexagon_draw(
        _core_x,_core_y,30 * _view.zoom,
        _palette.accent,0.95,true
    );

    draw_set_colour(_palette.core);
    draw_set_alpha(1);
    draw_circle(_core_x,_core_y,7 * _view.zoom,true);
    draw_circle(_core_x,_core_y,3 * _view.zoom,false);

    sc_player_upgrades_connections_draw(_runtime,_palette);

    for (var _i = 0; _i < array_length(_upgrades); ++_i)
    {
        var _upgrade = _upgrades[_i];
        var _x = sc_player_upgrade_view_x(_view,_upgrade.position.x);
        var _y = sc_player_upgrade_view_y(_view,_upgrade.position.y);
        var _margin = 70 * _view.zoom;

        if (_x < -_margin || _x > _view.width + _margin
        || _y < -_margin || _y > _view.height + _margin)
            continue;

        sc_player_upgrade_node_draw(
            _upgrade,
            _runtime.selected_key == _upgrade.key,
            _runtime,
            _palette
        );
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

/// @description Draws the clipped pannable upgrade tree and fixed inspector.
function sc_player_upgrades_interface_draw(_hud,_origin_x,_origin_y)
{
    var _runtime = _hud.inventory.upgrades;
    var _view = _runtime.view;
    var _palette = _hud.data.palette;

    if (!surface_exists(_runtime.surface))
        _runtime.surface = surface_create(_view.width,_view.height);

    if (surface_exists(_runtime.surface))
    {
        surface_set_target(_runtime.surface);
        sc_player_upgrades_canvas_draw(_hud);
        surface_reset_target();

        draw_set_alpha(1);
        draw_set_colour(c_white);

        draw_surface(
            _runtime.surface,
            _origin_x + _view.x,
            _origin_y + _view.y
        );
    }

    // The viewport border, title and inspector are not affected by pan/zoom.
    draw_set_colour(_palette.outline);
    draw_set_alpha(0.8);

    draw_rectangle(
        _origin_x + _view.x,
        _origin_y + _view.y,
        _origin_x + _view.x + _view.width,
        _origin_y + _view.y + _view.height,
        true
    );

    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_set_colour(_palette.accent);
    draw_set_alpha(1);

    draw_text(
        _origin_x + 52,
        _origin_y + 178,
        "SHIP UPGRADE MATRIX"
    );

    draw_set_halign(fa_right);
    draw_set_colour(_palette.data_shard);

    draw_text(
        _origin_x + 1060,
        _origin_y + 178,
        "DATA SHARDS // "
        + string(global.profile.progression.data_shards)
    );

    draw_set_colour(_palette.muted);
    draw_text(
        _origin_x + 1055,
        _origin_y + 810,
        "MIDDLE MOUSE: PAN  //  WHEEL: ZOOM  //  "
        + string(round(_view.zoom * 100))
        + "%"
    );

    sc_player_upgrade_inspector_draw(_hud,_origin_x,_origin_y);

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
