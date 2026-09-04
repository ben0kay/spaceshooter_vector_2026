/*
BAKED RESOURCE PICKUP VISUALS

Every registered cargo resource receives one cached sprite.
Only position, rotation, bobbing and scale remain dynamic.
*/

/// @description Draws one faceted resource chunk before baking.
function sc_resource_pickup_primitive_draw(_x, _y, _radius, _visual)
{
    var _points;

    switch (_visual.shape)
    {
        case 1:
            _points = [
                [-0.92, -0.18], [-0.38, -0.79], [0.48, -0.66],
                [0.91, -0.12], [0.56, 0.72], [-0.28, 0.88], [-0.82, 0.43]
            ];
        break;

        case 2:
            _points = [
                [-0.72, -0.68], [0.08, -0.92], [0.78, -0.42],
                [0.92, 0.34], [0.21, 0.84], [-0.63, 0.66], [-0.94, 0.05]
            ];
        break;

        case 3:
            _points = [
                [-0.38, -0.92], [0.15, -0.66], [0.77, -0.83],
                [0.58, -0.18], [0.94, 0.42], [0.18, 0.82],
                [-0.46, 0.59], [-0.87, 0.11]
            ];
        break;

        default:
            _points = [
                [-0.86, -0.43], [-0.12, -0.89], [0.67, -0.61],
                [0.91, 0.09], [0.39, 0.81], [-0.43, 0.76], [-0.92, 0.18]
            ];
        break;
    }

    // Static baked glow.
    gpu_set_blendmode(bm_add);

    draw_set_colour(_visual.glow);
    draw_set_alpha(0.11);
    draw_circle(_x, _y, _radius * 1.7, false);

    draw_set_alpha(0.22);
    draw_circle(_x, _y, _radius * 1.25, false);

    gpu_set_blendmode(bm_normal);

    // Filled irregular chunk.
    draw_primitive_begin(pr_trianglefan);
    draw_vertex_colour(_x, _y, _visual.colour, 1);

    for (var _i = 0; _i <= array_length(_points); _i++)
    {
        var _point = _points[_i mod array_length(_points)];

        draw_vertex_colour(
            _x + _point[0] * _radius,
            _y + _point[1] * _radius,
            _visual.colour,
            1
        );
    }

    draw_primitive_end();

    // Dark outline.
    draw_set_colour(_visual.shadow);
    draw_set_alpha(0.9);

    for (var _i = 0; _i < array_length(_points); _i++)
    {
        var _a = _points[_i];
        var _b = _points[(_i + 1) mod array_length(_points)];

        draw_line_width(
            _x + _a[0] * _radius,
            _y + _a[1] * _radius,
            _x + _b[0] * _radius,
            _y + _b[1] * _radius,
            2
        );
    }

    // Facet lines and bright mineral seam.
    draw_set_colour(_visual.shadow);
    draw_set_alpha(0.55);
    draw_line_width(_x, _y, _x - _radius * 0.6, _y - _radius * 0.35, 2);
    draw_line_width(_x, _y, _x + _radius * 0.5, _y - _radius * 0.45, 2);
    draw_line_width(_x, _y, _x + _radius * 0.38, _y + _radius * 0.58, 2);

    draw_set_colour(_visual.highlight);
    draw_set_alpha(0.9);
    draw_line_width(
        _x - _radius * 0.42,
        _y - _radius * 0.30,
        _x + _radius * 0.34,
        _y - _radius * 0.52,
        2
    );

    draw_set_alpha(1);
    draw_set_colour(c_white);
    gpu_set_blendmode(bm_normal);
}

/// @description Bakes one registered resource pickup.
function sc_resource_pickup_visual_bake(_definition)
{
    var _canvas = 64;
    var _centre = _canvas * 0.5;
    var _surface = surface_create(_canvas, _canvas);

    if (!surface_exists(_surface)) return -1;

    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);

    sc_resource_pickup_primitive_draw(
        _centre,
        _centre,
        12,
        _definition.visual
    );

    surface_reset_target();

    var _sprite = sprite_create_from_surface(
        _surface,
        0, 0,
        _canvas, _canvas,
        false, false,
        _centre, _centre
    );

    surface_free(_surface);
    return _sprite;
}

/// @description Bakes every registered resource pickup.
function sc_resource_pickup_visual_cache_init()
{
    if (variable_global_exists("resource_pickup_visual_cache"))
        sc_resource_pickup_visual_cache_destroy();

    global.resource_pickup_visual_cache = {};
    var _keys = variable_struct_get_names(global.data.items);

    for (var _i = 0; _i < array_length(_keys); _i++)
    {
        var _key = _keys[_i];
        var _definition = variable_struct_get(global.data.items, _key);
        var _sprite = sc_resource_pickup_visual_bake(_definition);

        if (!sprite_exists(_sprite))
        {
            sc_resource_pickup_visual_cache_destroy();
            show_debug_message("RESOURCE PICKUP BAKE ERROR - " + _key);
            return false;
        }

        variable_struct_set(
            global.resource_pickup_visual_cache,
            _key,
            _sprite
        );
    }

    show_debug_message("RESOURCE PICKUP VISUAL CACHE BAKED");
    return true;
}

/// @description Returns one cached resource pickup sprite.
function sc_resource_pickup_visual_cache_get(_item_key)
{
    return variable_struct_get(
        global.resource_pickup_visual_cache,
        _item_key
    );
}

/// @description Deletes all generated resource pickup sprites.
function sc_resource_pickup_visual_cache_destroy()
{
    if (!variable_global_exists("resource_pickup_visual_cache")) return;

    var _keys = variable_struct_get_names(
        global.resource_pickup_visual_cache
    );

    for (var _i = 0; _i < array_length(_keys); _i++)
    {
        var _sprite = variable_struct_get(
            global.resource_pickup_visual_cache,
            _keys[_i]
        );

        if (sprite_exists(_sprite))
            sprite_delete(_sprite);
    }

    global.resource_pickup_visual_cache = {};
}