/*
WORLD FACILITIES

Optional facility controllers allow world structures to host processing services.
Each processor owns one active job and an independent waiting queue.
*/

/// @description Creates one structure facility runtime.
function sc_facility_runtime_create(_structure, _definition)
{
    var _processors = [];

    for (var _i = 0; _i < array_length(_definition.processors); ++_i)
    {
        var _processor = _definition.processors[_i];

        array_push(_processors, {
            type: _processor.type,
            speed: _processor.speed,
            queue_max: _processor.queue_max,
            active: undefined,
            queue: []
        });
    }

    return {
        definition: variable_clone(_definition),
        processors: _processors,
        output: []
    };
}

/// @description Returns one facility's world-space interaction terminal.
function sc_facility_terminal_position_get(_structure)
{
    var _interaction = _structure.structure.facility.definition.interaction;
    var _angle = _structure.draw_angle;

    return {
        x: _structure.x
            + lengthdir_x(_interaction.forward, _angle)
            + lengthdir_x(_interaction.side, _angle - 90),

        y: _structure.y
            + lengthdir_y(_interaction.forward, _angle)
            + lengthdir_y(_interaction.side, _angle - 90)
    };
}

/// @description Returns one processor from a facility.
function sc_facility_processor_get(_facility, _service)
{
    var _processors = _facility.processors;

    for (var _i = 0; _i < array_length(_processors); ++_i)
        if (_processors[_i].type == _service)
            return _processors[_i];

    return undefined;
}

/// @description Returns whether a facility provides one processing service.
function sc_facility_service_has(_facility, _service)
{
    return is_struct(sc_facility_processor_get(_facility, _service));
}

/// @description Returns the maximum recipe batches currently available.
function sc_recipe_player_amount_get(_player, _recipe)
{
    var _amount = 999999;

    for (var _i = 0; _i < array_length(_recipe.inputs); ++_i)
    {
        var _input = _recipe.inputs[_i];
        var _stored = sc_player_inventory_item_count(_player, _input[0]);
        _amount = min(_amount, floor(_stored / _input[1]));
    }

    return max(0, _amount);
}

/// @description Consumes all inputs required for a recipe batch.
function sc_recipe_inputs_remove(_player, _recipe, _amount)
{
    for (var _i = 0; _i < array_length(_recipe.inputs); ++_i)
    {
        var _input = _recipe.inputs[_i];

        sc_player_inventory_item_remove(
            _player,
            _input[0],
            _input[1] * _amount
        );
    }
}

/// @description Adds completed recipe output to facility storage.
function sc_facility_output_add(_facility, _item_key, _amount)
{
    var _output = _facility.output;

    for (var _i = 0; _i < array_length(_output); ++_i)
    {
        if (_output[_i].key != _item_key) continue;

        _output[_i].amount += _amount;
        return true;
    }

    var _definition = variable_struct_get(global.data.items, _item_key);

    array_push(_output, {
        key: _item_key,
        name: _definition.identity.name,
        amount: _amount
    });

    return true;
}

/// @description Begins a queued job when its processor becomes available.
function sc_facility_processor_begin_next(_processor)
{
    if (!is_undefined(_processor.active)
    || array_length(_processor.queue) <= 0)
        return false;

    _processor.active = _processor.queue[0];
    array_delete(_processor.queue, 0, 1);
    return true;
}

/// @description Starts or queues one recipe at a facility.
function sc_facility_job_add(_structure, _recipe_key, _amount, _player)
{
    var _facility = _structure.structure.facility;
    var _recipe = sc_recipe_get(_recipe_key);
    var _processor = sc_facility_processor_get(_facility, _recipe.service);
    var _amount_max = sc_recipe_player_amount_get(_player, _recipe);

    _amount = clamp(floor(_amount), 1, _amount_max);

    if (!is_struct(_processor)
    || _amount_max <= 0
    || array_length(_processor.queue) >= _processor.queue_max)
        return false;

    sc_recipe_inputs_remove(_player, _recipe, _amount);

    var _job = {
        recipe_key: _recipe_key,
        amount: _amount,
        duration: max(1, ceil(_recipe.duration * _amount / _processor.speed)),
        remaining: max(1, ceil(_recipe.duration * _amount / _processor.speed))
    };

    array_push(_processor.queue, _job);
    sc_facility_processor_begin_next(_processor);
    return true;
}

/// @description Completes one processing job into facility output storage.
function sc_facility_job_complete(_facility, _processor)
{
    var _job = _processor.active;
    var _recipe = sc_recipe_get(_job.recipe_key);

    for (var _i = 0; _i < array_length(_recipe.outputs); ++_i)
    {
        var _output = _recipe.outputs[_i];

        sc_facility_output_add(
            _facility,
            _output[0],
            _output[1] * _job.amount
        );
    }

    _processor.active = undefined;
    sc_facility_processor_begin_next(_processor);
}

/// @description Advances all active processors belonging to one facility.
function sc_facility_update(_structure)
{
    var _facility = _structure.structure.facility;
    var _processors = _facility.processors;

    for (var _i = 0; _i < array_length(_processors); ++_i)
    {
        var _processor = _processors[_i];

        sc_facility_processor_begin_next(_processor);
        if (is_undefined(_processor.active)) continue;

        _processor.active.remaining--;

        if (_processor.active.remaining <= 0)
            sc_facility_job_complete(_facility, _processor);
    }
}

/// @description Collects all currently fitting facility output.
function sc_facility_output_collect(_structure, _player)
{
    var _output = _structure.structure.facility.output;

    for (var _i = array_length(_output) - 1; _i >= 0; --_i)
    {
        var _entry = _output[_i];
        var _result = sc_player_inventory_add(
            _player,
            _entry.key,
            _entry.amount
        );

        _entry.amount = _result.remaining;

        if (_entry.amount <= 0)
            array_delete(_output, _i, 1);
    }
}

/// @description Returns a readable processor name.
function sc_facility_service_name_get(_service)
{
    switch (_service)
    {
        case FacilityService.REFINERY: return "REFINERY";
        case FacilityService.FABRICATOR: return "FABRICATOR";
        case FacilityService.REPAIR: return "REPAIR";
    }

    return "UNKNOWN";
}

/// @description Finds the nearest usable facility to the player.
function sc_facility_nearest_find(_player)
{
    var _nearest = noone;
    var _nearest_distance = 999999999999;
    var _count = instance_number(o_world_structure);

    for (var _i = 0; _i < _count; ++_i)
    {
        var _structure = instance_find(o_world_structure, _i);
        if (!is_struct(_structure.structure.facility)) continue;

        var _facility = _structure.structure.facility;
        var _interaction = _facility.definition.interaction;
        var _terminal = sc_facility_terminal_position_get(_structure);
        var _dx = _terminal.x - _player.x;
        var _dy = _terminal.y - _player.y;
        var _distance = _dx * _dx + _dy * _dy;

        if (_distance > sqr(_interaction.radius)
        || _distance >= _nearest_distance)
            continue;

        _nearest = _structure;
        _nearest_distance = _distance;
    }

    return _nearest;
}

/// @description Builds the supported recipe list for one output layer.
function sc_facility_recipe_keys_get(_structure, _layer)
{
    var _facility = _structure.structure.facility;
    var _keys = variable_struct_get_names(global.data.recipes);
    var _recipes = [];

    for (var _i = 0; _i < array_length(_keys); ++_i)
    {
        var _recipe = variable_struct_get(global.data.recipes, _keys[_i]);
        var _output = _recipe.outputs[0];
        var _item = variable_struct_get(global.data.items, _output[0]);

        if (_item.layer == _layer
        && sc_facility_service_has(_facility, _recipe.service))
            array_push(_recipes, _keys[_i]);
    }

    return _recipes;
}

/// @description Selects one facility recipe-output category.
function sc_facility_category_select(_hud, _layer)
{
    var _runtime = _hud.facility;

    _runtime.selected_layer = _layer;
    _runtime.recipe_keys = sc_facility_recipe_keys_get(_runtime.active_id, _layer);
    _runtime.selected_recipe = 0;
    _runtime.recipe_scroll_row = 0;
    _runtime.amount = 1;
}

/// @description Opens one nearby industrial-processing interface.
function sc_facility_interface_open(_hud, _structure)
{
    var _runtime = _hud.facility;

    sc_player_control_suspend(global.player_id);

    _runtime.open = true;
    _runtime.active_id = _structure;
    _runtime.selected_layer = ItemLayer.MATERIAL;
    _runtime.recipe_keys = sc_facility_recipe_keys_get(_structure, _runtime.selected_layer);
    _runtime.selected_recipe = 0;
    _runtime.recipe_scroll_row = 0;
    _runtime.amount = 1;

    global.PlayerState = PlayerState.FACILITY;
    return true;
}

/// @description Closes the facility interface while allowing jobs to continue.
function sc_facility_interface_close(_hud)
{
    var _runtime = _hud.facility;

    _runtime.open = false;
    _runtime.active_id = noone;
    _runtime.recipe_keys = [];
    _runtime.selected_recipe = 0;
    _runtime.amount = 1;

    global.PlayerState = PlayerState.ACTIVE;
    sc_player_combat_permission_update(global.player_id);
    return true;
}

/// @description Updates nearby facility detection and interaction.
function sc_facility_interaction_update(_hud)
{
    var _runtime = _hud.facility;

    if (global.PlayerState == PlayerState.FACILITY)
    {
        sc_facility_interface_update(_hud);
        return;
    }

    if (global.PlayerState != PlayerState.ACTIVE
    || !instance_exists(global.player_id))
        return;

    if (GAME_TICK >= _runtime.next_scan_tick)
    {
        _runtime.nearby_id = sc_facility_nearest_find(global.player_id);
        _runtime.next_scan_tick = GAME_TICK + _runtime.scan_interval;
    }

    if (global.input.action.interact_pressed
    && instance_exists(_runtime.nearby_id))
        sc_facility_interface_open(_hud, _runtime.nearby_id);
}

/// @description Updates facility categories, recipe scrolling and processing controls.
function sc_facility_interface_update(_hud)
{
    var _runtime = _hud.facility;

    if (!instance_exists(_runtime.active_id)
    || global.input.action.interact_pressed
    || global.input.action.inventory_pressed)
    {
        sc_facility_interface_close(_hud);
        return;
    }

    var _data = _hud.data.facility;
    var _buttons = _runtime.buttons;
    var _panel_x = floor((display_get_gui_width()-_data.width)*0.5);
    var _panel_y = floor((display_get_gui_height()-_data.height)*0.5);
    var _mouse_x = device_mouse_x_to_gui(0)-_panel_x;
    var _mouse_y = device_mouse_y_to_gui(0)-_panel_y;
    var _pressed = global.input.action.ui_select_pressed;
    var _recipe_amount = array_length(_runtime.recipe_keys);
    var _recipe_rows = ceil(_recipe_amount/_data.recipe_columns);
    var _scroll_max = max(0,_recipe_rows-_data.recipe_rows_visible);

    _runtime.recipe_scroll_row = clamp(_runtime.recipe_scroll_row,0,_scroll_max);

    if (sc_gui_button_update(_buttons.close,_mouse_x,_mouse_y,_pressed))
    {
        sc_facility_interface_close(_hud);
        return;
    }

    if (point_in_rectangle(
        _mouse_x,_mouse_y,
        _data.recipe_x,_data.recipe_y,
        _data.recipe_x+_data.recipe_width,
        _data.recipe_y+_data.recipe_rows_visible*_data.recipe_height
    ))
    {
        if (mouse_wheel_up()) _runtime.recipe_scroll_row = max(0,_runtime.recipe_scroll_row-1);
        if (mouse_wheel_down()) _runtime.recipe_scroll_row = min(_scroll_max,_runtime.recipe_scroll_row+1);
    }

    if (_pressed)
    {
        for (var _i = 0; _i < array_length(_data.categories); ++_i)
        {
            var _category = _data.categories[_i];
            var _y = _data.category_y+_i*(_data.category_height+_data.category_gap);

            if (point_in_rectangle(
                _mouse_x,_mouse_y,
                _data.category_x,_y,
                _data.category_x+_data.category_width,
                _y+_data.category_height
            ))
            {
                sc_facility_category_select(_hud,_category.layer);
                return;
            }
        }

        var _start = _runtime.recipe_scroll_row*_data.recipe_columns;
        var _visible = _data.recipe_rows_visible*_data.recipe_columns;
        var _finish = min(_recipe_amount,_start+_visible);
        var _card_width = (_data.recipe_width-_data.recipe_scroll_width-_data.recipe_gap)/_data.recipe_columns;

        for (var _i = _start; _i < _finish; ++_i)
        {
            var _relative = _i-_start;
            var _column = _relative mod _data.recipe_columns;
            var _row = _relative div _data.recipe_columns;
            var _x = _data.recipe_x+_column*(_card_width+_data.recipe_gap);
            var _y = _data.recipe_y+_row*_data.recipe_height;

            if (point_in_rectangle(
                _mouse_x,_mouse_y,
                _x,_y,
                _x+_card_width,
                _y+_data.recipe_height-_data.recipe_gap
            ))
            {
                _runtime.selected_recipe = _i;
                _runtime.amount = 1;
                return;
            }
        }
    }

    if (sc_gui_button_update(_buttons.amount_down,_mouse_x,_mouse_y,_pressed))
        _runtime.amount = max(1,_runtime.amount-1);

    if (sc_gui_button_update(_buttons.amount_up,_mouse_x,_mouse_y,_pressed))
        _runtime.amount = min(99,_runtime.amount+1);

    var _recipe_available = _recipe_amount > 0;
    _buttons.process.enabled = false;

    if (_recipe_available)
    {
        var _recipe = sc_recipe_get(_runtime.recipe_keys[_runtime.selected_recipe]);
        var _processor = sc_facility_processor_get(_runtime.active_id.structure.facility,_recipe.service);
        var _amount_max = sc_recipe_player_amount_get(global.player_id,_recipe);

        _runtime.amount = min(_runtime.amount,max(1,_amount_max));
        _buttons.process.enabled = _amount_max >= _runtime.amount
            && array_length(_processor.queue) < _processor.queue_max;
    }

    if (sc_gui_button_update(_buttons.process,_mouse_x,_mouse_y,_pressed))
    {
        sc_facility_job_add(
            _runtime.active_id,
            _runtime.recipe_keys[_runtime.selected_recipe],
            _runtime.amount,
            global.player_id
        );

        _runtime.amount = 1;
    }

    var _output = _runtime.active_id.structure.facility.output;
    _buttons.collect.enabled = array_length(_output) > 0;

    if (sc_gui_button_update(_buttons.collect,_mouse_x,_mouse_y,_pressed))
        sc_facility_output_collect(_runtime.active_id,global.player_id);
}

/// @description Draws the nearby facility interaction prompt.
function sc_facility_prompt_draw(_hud)
{
    var _runtime = _hud.facility;

    if (global.PlayerState != PlayerState.ACTIVE
    || !instance_exists(_runtime.nearby_id))
        return;

    var _structure = _runtime.nearby_id;
    var _interaction = _structure.structure.facility.definition.interaction;
    var _terminal = sc_facility_terminal_position_get(_structure);
    var _camera = view_camera[0];
    var _view_x = camera_get_view_x(_camera);
    var _view_y = camera_get_view_y(_camera);
    var _view_width = camera_get_view_width(_camera);
    var _view_height = camera_get_view_height(_camera);
    var _gui_width = display_get_gui_width();
    var _gui_height = display_get_gui_height();
    var _x = (_terminal.x - _view_x) / _view_width * _gui_width;
    var _y = (_terminal.y - _view_y) / _view_height * _gui_height - 54;
    var _palette = _hud.data.palette;

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    draw_set_colour(_palette.void);
    draw_set_alpha(0.92);
    draw_rectangle(_x - 145, _y - 18, _x + 145, _y + 18, false);

    draw_set_colour(_palette.outline);
    draw_set_alpha(1);
    draw_rectangle(_x - 145, _y - 18, _x + 145, _y + 18, true);

    draw_set_colour(_palette.core);
    draw_text(_x, _y, "[F]  " + _interaction.prompt);

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

/// @description Draws one compact inventory list inside the facility interface.
function sc_facility_inventory_draw(_hud, _x, _y)
{
    var _slots = global.player_id.inventory.slots;
    var _palette = _hud.data.palette;
    var _draw_y = _y + 142;

    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_set_colour(_palette.accent);
    draw_text(_x + 42, _y + 102, "SHIP CARGO");

    for (var _i = 0; _i < array_length(_slots); ++_i)
    {
        var _slot = _slots[_i];
        if (is_undefined(_slot)) continue;

        var _definition = variable_struct_get(global.data.items, _slot.key);
        var _sprite = sc_resource_pickup_visual_cache_get(_slot.key, _i mod 4);

        if (sprite_exists(_sprite))
            draw_sprite_ext(_sprite, 0, _x + 65, _draw_y, 0.9, 0.9, 0, c_white, 1);

        draw_set_colour(_palette.text);
        draw_text(_x + 100, _draw_y - 8, _slot.name);

        draw_set_colour(_palette.muted);
        draw_text(
            _x + 100,
            _draw_y + 10,
            "x" + string(_slot.amount)
            + "   MASS "
            + string(_slot.amount * _definition.cargo.weight)
        );

        _draw_y += 43;
        if (_draw_y > _y + 610) break;
    }
}

/// @description Draws processor activity and completed facility output.
function sc_facility_status_draw(_hud, _structure, _x, _y, _width)
{
    var _facility = _structure.structure.facility;
    var _palette = _hud.data.palette;
    var _processors = _facility.processors;

    draw_set_colour(_palette.void);
    draw_rectangle(_x,_y,_x+_width,_y+110,false);

    draw_set_colour(_palette.outline);
    draw_rectangle(_x,_y,_x+_width,_y+110,true);

    draw_set_colour(_palette.accent);
    draw_text(_x+18,_y+20,"MACHINE STATUS");

    for (var _i = 0; _i < array_length(_processors); ++_i)
    {
        var _processor = _processors[_i];
        var _row_y = _y+48+_i*28;

        draw_set_colour(_palette.text);
        draw_text(_x+18,_row_y,sc_facility_service_name_get(_processor.type));

        if (is_undefined(_processor.active))
        {
            draw_set_colour(_palette.muted);
            draw_text(_x+180,_row_y,"IDLE");
        }
        else
        {
            var _job = _processor.active;
            var _recipe = sc_recipe_get(_job.recipe_key);
            var _ratio = 1-_job.remaining/max(1,_job.duration);

            draw_set_colour(_palette.core);
            draw_text(_x+180,_row_y,_recipe.identity.name);

            draw_set_colour(_palette.background);
            draw_rectangle(_x+330,_row_y+4,_x+_width-85,_row_y+11,false);

            draw_set_colour(_palette.accent);
            draw_rectangle(_x+330,_row_y+4,_x+330+(_width-415)*_ratio,_row_y+11,false);
        }

        draw_set_halign(fa_right);
        draw_set_colour(_palette.muted);
        draw_text(_x+_width-18,_row_y,"QUEUE "+string(array_length(_processor.queue)));
        draw_set_halign(fa_left);
    }

    var _output_y = _y+120;

    draw_set_colour(_palette.void);
    draw_rectangle(_x,_output_y,_x+_width,_output_y+110,false);

    draw_set_colour(_palette.outline);
    draw_rectangle(_x,_output_y,_x+_width,_output_y+110,true);

    draw_set_colour(_palette.accent);
    draw_text(_x+18,_output_y+20,"COMPLETED OUTPUT");

    if (array_length(_facility.output) <= 0)
    {
        draw_set_colour(_palette.muted);
        draw_text(_x+18,_output_y+57,"NO COMPLETED ITEMS");
    }
    else
    {
        var _draw_y = _output_y+52;

        for (var _i = 0; _i < array_length(_facility.output); ++_i)
        {
            var _entry = _facility.output[_i];

            draw_set_colour(_palette.text);
            draw_text(_x+18,_draw_y,_entry.name);

            draw_set_halign(fa_right);
            draw_set_colour(_palette.core);
            draw_text(_x+_width-205,_draw_y,"x"+string(_entry.amount));
            draw_set_halign(fa_left);

            _draw_y += 23;
            if (_draw_y > _output_y+82) break;
        }
    }
}

/// @description Draws the complete industrial-processing interface.
function sc_facility_interface_draw(_hud)
{
    var _runtime = _hud.facility;

    if (!_runtime.open
    || global.PlayerState != PlayerState.FACILITY
    || !instance_exists(_runtime.active_id))
        return;

    var _data = _hud.data.facility;
    var _palette = _hud.data.palette;
    var _structure = _runtime.active_id;
    var _panel_x = floor((display_get_gui_width()-_data.width)*0.5);
    var _panel_y = floor((display_get_gui_height()-_data.height)*0.5);

    draw_set_colour(c_black);
    draw_set_alpha(0.72);
    draw_rectangle(0,0,display_get_gui_width(),display_get_gui_height(),false);

    draw_set_alpha(1);
    matrix_set(matrix_world,matrix_build(_panel_x,_panel_y,0,0,0,0,1,1,1));
    sc_hud_panel_primitive_draw(_data.width,_data.height,28,_palette);
    matrix_set(matrix_world,matrix_build_identity());

    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);

    draw_set_colour(_palette.core);
    draw_text(_panel_x+42,_panel_y+38,string_upper(_structure.structure.data.identity.name));

    draw_set_colour(_palette.accent);
    draw_text(_panel_x+42,_panel_y+67,"INDUSTRIAL PROCESSING");

    draw_set_halign(fa_right);
    draw_set_colour(_palette.muted);
    draw_text(_panel_x+_data.width-75,_panel_y+42,"REFINE // FABRICATE // SUPPLY");
    draw_set_halign(fa_left);

    draw_set_colour(_palette.outline);
    draw_line(_panel_x+25,_panel_y+100,_panel_x+_data.width-25,_panel_y+100);

    for (var _i = 0; _i < array_length(_data.categories); ++_i)
    {
        var _category = _data.categories[_i];
        var _x = _panel_x+_data.category_x;
        var _y = _panel_y+_data.category_y+_i*(_data.category_height+_data.category_gap);
        var _selected = _runtime.selected_layer == _category.layer;

        draw_set_colour(_selected ? _palette.panel_light : _palette.void);
        draw_rectangle(_x,_y,_x+_data.category_width,_y+_data.category_height,false);

        draw_set_colour(_selected ? _palette.accent : _palette.outline);
        draw_rectangle(_x,_y,_x+_data.category_width,_y+_data.category_height,true);

        draw_set_colour(_selected ? _palette.core : _palette.text);
        draw_text(_x+24,_y+30,_category.name);

        draw_set_colour(_palette.muted);
        draw_text_ext(_x+24,_y+58,_category.description,17,_data.category_width-52);

        draw_set_halign(fa_right);
        draw_set_colour(_selected ? _palette.core : _palette.muted);
        draw_text(_x+_data.category_width-22,_y+60,">");
        draw_set_halign(fa_left);
    }

    var _recipe_panel_x = _panel_x+_data.recipe_x;
    var _recipe_panel_y = _panel_y+_data.recipe_y;
    var _recipe_amount = array_length(_runtime.recipe_keys);
    var _card_width = (_data.recipe_width-_data.recipe_scroll_width-_data.recipe_gap)/_data.recipe_columns;
    var _start = _runtime.recipe_scroll_row*_data.recipe_columns;
    var _visible = _data.recipe_rows_visible*_data.recipe_columns;
    var _finish = min(_recipe_amount,_start+_visible);

    draw_set_colour(_palette.accent);
    draw_text(_recipe_panel_x,_recipe_panel_y-28,"AVAILABLE RECIPES");

    if (_recipe_amount <= 0)
    {
        draw_set_colour(_palette.void);
        draw_rectangle(_recipe_panel_x,_recipe_panel_y,_recipe_panel_x+_data.recipe_width,_recipe_panel_y+90,false);

        draw_set_colour(_palette.outline);
        draw_rectangle(_recipe_panel_x,_recipe_panel_y,_recipe_panel_x+_data.recipe_width,_recipe_panel_y+90,true);

        draw_set_colour(_palette.muted);
        draw_text(_recipe_panel_x+22,_recipe_panel_y+42,"NO RECIPES AVAILABLE");
    }

    for (var _i = _start; _i < _finish; ++_i)
    {
        var _relative = _i-_start;
        var _column = _relative mod _data.recipe_columns;
        var _row = _relative div _data.recipe_columns;
        var _x = _recipe_panel_x+_column*(_card_width+_data.recipe_gap);
        var _y = _recipe_panel_y+_row*_data.recipe_height;
        var _recipe = sc_recipe_get(_runtime.recipe_keys[_i]);
        var _output = _recipe.outputs[0];
        var _sprite = sc_resource_pickup_visual_cache_get(_output[0],_i mod 4);
        var _selected = _runtime.selected_recipe == _i;

        draw_set_colour(_selected ? _palette.panel_light : _palette.void);
        draw_rectangle(_x,_y,_x+_card_width,_y+_data.recipe_height-_data.recipe_gap,false);

        draw_set_colour(_selected ? _palette.accent : _palette.outline);
        draw_rectangle(_x,_y,_x+_card_width,_y+_data.recipe_height-_data.recipe_gap,true);

        if (sprite_exists(_sprite))
            draw_sprite_ext(_sprite,0,_x+40,_y+41,1.05,1.05,0,c_white,1);

        draw_set_colour(_selected ? _palette.core : _palette.text);
        draw_text(_x+78,_y+24,_recipe.identity.name);

        var _input = _recipe.inputs[0];
        var _input_item = variable_struct_get(global.data.items,_input[0]);

        draw_set_colour(_palette.muted);
        draw_text(_x+78,_y+48,"FROM "+string_upper(_input_item.identity.name));

        draw_set_halign(fa_right);
        draw_set_colour(_palette.accent);
        draw_text(_x+_card_width-14,_y+68,sc_facility_service_name_get(_recipe.service));
        draw_set_halign(fa_left);
    }

    var _total_rows = ceil(_recipe_amount/_data.recipe_columns);
    var _scroll_max = max(0,_total_rows-_data.recipe_rows_visible);

    if (_scroll_max > 0)
    {
        var _track_x = _recipe_panel_x+_data.recipe_width-5;
        var _track_y = _recipe_panel_y;
        var _track_height = _data.recipe_rows_visible*_data.recipe_height-_data.recipe_gap;
        var _thumb_height = max(40,_track_height*(_data.recipe_rows_visible/_total_rows));
        var _thumb_y = _track_y+(_track_height-_thumb_height)*(_runtime.recipe_scroll_row/_scroll_max);

        draw_set_colour(_palette.background);
        draw_rectangle(_track_x,_track_y,_track_x+4,_track_y+_track_height,false);

        draw_set_colour(_palette.accent);
        draw_rectangle(_track_x,_thumb_y,_track_x+4,_thumb_y+_thumb_height,false);
    }

    var _detail_x = _panel_x+_data.detail_x;
    var _detail_y = _panel_y+_data.detail_y;
    var _detail_width = _data.detail_width;

    if (_recipe_amount > 0)
    {
        var _recipe = sc_recipe_get(_runtime.recipe_keys[_runtime.selected_recipe]);
        var _output = _recipe.outputs[0];
        var _item = variable_struct_get(global.data.items,_output[0]);
        var _sprite = sc_resource_pickup_visual_cache_get(_output[0],0);

        draw_set_colour(_palette.void);
        draw_rectangle(_detail_x,_detail_y,_detail_x+_detail_width,_detail_y+_data.detail_height,false);

        draw_set_colour(_palette.outline);
        draw_rectangle(_detail_x,_detail_y,_detail_x+_detail_width,_detail_y+_data.detail_height,true);

        if (sprite_exists(_sprite))
            draw_sprite_ext(_sprite,0,_detail_x+58,_detail_y+55,1.35,1.35,0,c_white,1);

        draw_set_colour(_palette.core);
        draw_text(_detail_x+108,_detail_y+32,_recipe.identity.name);

        draw_set_colour(_palette.accent);
        draw_text(_detail_x+108,_detail_y+59,sc_facility_service_name_get(_recipe.service));

        draw_set_colour(_palette.muted);
        draw_text_ext(_detail_x+24,_detail_y+96,_item.description,20,_detail_width-48);

        draw_set_colour(_palette.outline);
        draw_line(_detail_x+20,_detail_y+158,_detail_x+_detail_width-20,_detail_y+158);

        draw_set_colour(_palette.accent);
        draw_text(_detail_x+22,_detail_y+181,"REQUIREMENTS");

        var _requirement_gap = 8;
        var _requirement_width = (_detail_width-44-_requirement_gap)*0.5;
        var _requirement_height = 48;

        for (var _i = 0; _i < array_length(_recipe.inputs); ++_i)
        {
            var _input = _recipe.inputs[_i];
            var _input_item = variable_struct_get(global.data.items,_input[0]);
            var _stored = sc_player_inventory_item_count(global.player_id,_input[0]);
            var _needed = _input[1]*_runtime.amount;
            var _sufficient = _stored >= _needed;
            var _column = _i mod 2;
            var _row = _i div 2;
            var _x = _detail_x+22+_column*(_requirement_width+_requirement_gap);
            var _y = _detail_y+202+_row*(_requirement_height+7);
            var _input_sprite = sc_resource_pickup_visual_cache_get(_input[0],_i mod 4);
            var _colour = _sufficient ? _palette.text : _palette.danger;

            draw_set_colour(_palette.background);
            draw_rectangle(_x,_y,_x+_requirement_width,_y+_requirement_height,false);

            draw_set_colour(_sufficient ? _palette.outline : _palette.danger);
            draw_set_alpha(_sufficient ? 1 : 0.8);
            draw_rectangle(_x,_y,_x+_requirement_width,_y+_requirement_height,true);
            draw_set_alpha(1);

            if (sprite_exists(_input_sprite))
                draw_sprite_ext(_input_sprite,0,_x+25,_y+24,0.72,0.72,0,c_white,1);

            draw_set_colour(_colour);
            draw_text(_x+52,_y+17,_input_item.identity.name);

            draw_set_halign(fa_right);
            draw_text(_x+_requirement_width-12,_y+32,string(_stored)+" / "+string(_needed));
            draw_set_halign(fa_left);
        }

        draw_set_colour(_palette.muted);
        draw_text(
            _detail_x+24,
            _detail_y+_data.detail_height-22,
            "PROCESS TIME // "+string(ceil(_recipe.duration*_runtime.amount/60))+" SEC"
        );
    }

    draw_set_colour(_palette.accent);
    draw_text(_detail_x,_panel_y+_data.processing_y,"PROCESSING");

    draw_set_halign(fa_center);
    draw_set_colour(_palette.core);
    draw_text(_panel_x+1121,_panel_y+608,"BATCH x"+string(_runtime.amount));
    draw_set_halign(fa_left);

    sc_facility_status_draw(
        _hud,
        _structure,
        _detail_x,
        _panel_y+_data.status_y,
        _detail_width
    );

    sc_gui_button_draw(_runtime.buttons.close,_panel_x,_panel_y,_palette);
    sc_gui_button_draw(_runtime.buttons.amount_down,_panel_x,_panel_y,_palette);
    sc_gui_button_draw(_runtime.buttons.amount_up,_panel_x,_panel_y,_palette);
    sc_gui_button_draw(_runtime.buttons.process,_panel_x,_panel_y,_palette);
    sc_gui_button_draw(_runtime.buttons.collect,_panel_x,_panel_y,_palette);

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}