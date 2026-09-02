/// @description Bakes all registered enemy visual components once.
function sc_enemy_visual_cache_init()
{
    if (variable_global_exists("enemy_visual_cache")) sc_enemy_visual_cache_destroy();

    global.enemy_visual_cache = {};
    var _keys = variable_struct_get_names(global.data.enemies);

    for (var _i = 0; _i < array_length(_keys); _i++)
    {
        var _key = _keys[_i];
        var _data = variable_struct_get(global.data.enemies, _key);
        var _visual = _data.visual;
        var _hardpoint_count = array_length(_data.hardpoints);
        var _fragment_count = array_length(_visual.death.draw_scripts);

        var _cache = {
            body: sc_enemy_visual_component_bake(_key, _data, "body", -1, _visual.bake.body_canvas_size),
            core: sc_enemy_visual_component_bake(_key, _data, "core", -1, _visual.bake.core_canvas_size),
            thrust: sc_enemy_visual_component_bake(_key, _data, "thrust", -1, _visual.bake.thrust_canvas_size),
            shield: _data.stats_base.shield_max > 0
                ? sc_enemy_visual_component_bake(_key, _data, "shield", -1, _visual.bake.body_canvas_size)
                : -1,

            hardpoints: array_create(_hardpoint_count, -1),
            fragments: array_create(_fragment_count, -1)
        };

        for (var _h = 0; _h < _hardpoint_count; _h++)
            _cache.hardpoints[_h] = sc_enemy_visual_component_bake(_key, _data, "hardpoint", _h, _visual.bake.hardpoint_canvas_size);

        for (var _f = 0; _f < _fragment_count; _f++)
            _cache.fragments[_f] = sc_enemy_visual_component_bake(_key, _data, "fragment", _f, _visual.bake.fragment_canvas_size);

        variable_struct_set(global.enemy_visual_cache, _key, _cache);
        show_debug_message("ENEMY VISUAL CACHE BAKED - " + _key);
    }

    show_debug_message("ENEMY VISUAL CACHE INITIALIZED - " + string(array_length(_keys)) + " enemies");
    return true;
}

/// @description Bakes one enemy primitive component into a sprite.
function sc_enemy_visual_component_bake(_enemy_key, _data, _component, _component_index, _canvas_size)
{
    if (_canvas_size <= 0)
    {
        show_debug_message("ENEMY VISUAL BAKE ERROR - invalid canvas: " + _enemy_key + " / " + _component);
        return -1;
    }

    var _surface = surface_create(_canvas_size, _canvas_size);

    if (!surface_exists(_surface))
    {
        show_debug_message("ENEMY VISUAL BAKE ERROR - surface failed: " + _enemy_key + " / " + _component);
        return -1;
    }

    var _visual = _data.visual;
    var _centre = _canvas_size * 0.5;

    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);
    draw_set_alpha(1);
    draw_set_colour(c_white);

    switch (_component)
    {
        case "body":
            _visual.draw.body(_centre, _centre, _visual.radius, 0, _visual);
        break;

        case "core":
            _visual.draw.core(_centre, _centre, _visual.radius, 0, _visual, 1);
        break;

        case "thrust":
            _visual.thrust.draw_script(_centre, _centre, _visual.radius, 0, _visual, 1);
        break;

        case "shield":
            sc_visual_shield_bake_draw(_centre, _centre, _visual.radius, _visual.palette);
        break;

        case "hardpoint":
            var _hardpoint = _data.hardpoints[_component_index];
            _hardpoint.draw_script(_centre, _centre, _visual.radius, 0, _visual, 1);
        break;

        case "fragment":
            var _fragment_script = _visual.death.draw_scripts[_component_index];
            _fragment_script(_centre, _centre, _visual.radius, 0, _visual);
        break;
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
    surface_reset_target();

    var _sprite = sprite_create_from_surface(_surface, 0, 0, _canvas_size, _canvas_size, false, false, _centre, _centre);
    surface_free(_surface);

    if (!sprite_exists(_sprite))
    {
        show_debug_message("ENEMY VISUAL BAKE ERROR - sprite failed: " + _enemy_key + " / " + _component);
        return -1;
    }

    return _sprite;
}

/// @description Returns one enemy's shared visual cache.
function sc_enemy_visual_cache_get(_enemy_key)
{
    if (!variable_global_exists("enemy_visual_cache")) return undefined;
    if (!variable_struct_exists(global.enemy_visual_cache, _enemy_key)) return undefined;

    return variable_struct_get(global.enemy_visual_cache, _enemy_key);
}

/// @description Deletes every generated enemy component sprite.
function sc_enemy_visual_cache_destroy()
{
    if (!variable_global_exists("enemy_visual_cache")) return;

    var _keys = variable_struct_get_names(global.enemy_visual_cache);

    for (var _i = 0; _i < array_length(_keys); _i++)
    {
        var _cache = variable_struct_get(global.enemy_visual_cache, _keys[_i]);

        if (sprite_exists(_cache.body)) sprite_delete(_cache.body);
        if (sprite_exists(_cache.core)) sprite_delete(_cache.core);
        if (sprite_exists(_cache.thrust)) sprite_delete(_cache.thrust);
        if (sprite_exists(_cache.shield)) sprite_delete(_cache.shield);

        for (var _h = 0; _h < array_length(_cache.hardpoints); _h++)
            if (sprite_exists(_cache.hardpoints[_h])) sprite_delete(_cache.hardpoints[_h]);

        for (var _f = 0; _f < array_length(_cache.fragments); _f++)
            if (sprite_exists(_cache.fragments[_f])) sprite_delete(_cache.fragments[_f]);
    }

    global.enemy_visual_cache = {};
    show_debug_message("ENEMY VISUAL CACHE DESTROYED");
}