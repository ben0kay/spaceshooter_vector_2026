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