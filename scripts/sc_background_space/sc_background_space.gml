/// @description Returns a deterministic value from 0–1 without affecting gameplay RNG.
function sc_space_hash(_value)
{
    return frac(abs(sin(_value * 12.9898) * 43758.5453));
}

/// @description Generates and bakes one transparent star tile.
function sc_space_star_sprite_create(_size, _count, _seed, _radius_min, _radius_max, _colour, _bright_chance)
{
    var _surface = surface_create(_size, _size);
    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);

    for (var _i = 0; _i < _count; _i++)
    {
        var _x = sc_space_hash(_seed + _i * 11.17) * _size;
        var _y = sc_space_hash(_seed + _i * 37.91) * _size;
        var _radius = lerp(_radius_min, _radius_max, sc_space_hash(_seed + _i * 71.43));
        var _alpha = lerp(0.3, 0.9, sc_space_hash(_seed + _i * 19.73));
        var _bright = sc_space_hash(_seed + _i * 97.13) <= _bright_chance;

        draw_set_colour(_colour);
        draw_set_alpha(_alpha);
        draw_circle(_x, _y, _radius, false);

        if (_bright)
        {
            draw_set_alpha(_alpha * 0.45);
            draw_line(_x - _radius * 3, _y, _x + _radius * 3, _y);
            draw_line(_x, _y - _radius * 3, _x, _y + _radius * 3);
        }
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
    surface_reset_target();

    var _sprite = sprite_create_from_surface(_surface, 0, 0, _size, _size, false, false, 0, 0);
    surface_free(_surface);
    return _sprite;
}

/// @description Generates and bakes one large translucent nebula.
function sc_space_nebula_sprite_create(_size, _seed, _colour_primary, _colour_secondary)
{
    var _surface = surface_create(_size, _size);
    var _centre = _size * 0.5;

    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);

    for (var _i = 0; _i < 42; _i++)
    {
        var _direction = sc_space_hash(_seed + _i * 17.37) * 360;
        var _distance = power(sc_space_hash(_seed + _i * 41.91), 1.7) * _size * 0.34;
        var _stretch_x = lerp(0.55, 1.35, sc_space_hash(_seed + _i * 23.61));
        var _x = _centre + lengthdir_x(_distance * _stretch_x, _direction);
        var _y = _centre + lengthdir_y(_distance * 0.65, _direction);
        var _radius = lerp(_size * 0.055, _size * 0.19, sc_space_hash(_seed + _i * 67.43));
        var _mix = sc_space_hash(_seed + _i * 83.17);

        draw_set_colour(merge_colour(_colour_primary, _colour_secondary, _mix));
        draw_set_alpha(lerp(0.018, 0.07, sc_space_hash(_seed + _i * 31.79)));
        draw_circle(_x, _y, _radius, false);
    }

    draw_set_colour(_colour_secondary);

    for (var _i = 0; _i < 12; _i++)
    {
        var _angle = sc_space_hash(_seed + _i * 103.7) * 360;
        var _distance = lerp(_size * 0.08, _size * 0.33, sc_space_hash(_seed + _i * 53.11));
        var _x1 = _centre + lengthdir_x(_distance, _angle);
        var _y1 = _centre + lengthdir_y(_distance * 0.55, _angle);
        var _x2 = _centre + lengthdir_x(_distance + _size * 0.18, _angle + 12);
        var _y2 = _centre + lengthdir_y((_distance + _size * 0.18) * 0.55, _angle + 12);

        draw_set_alpha(0.035);
        draw_line_width(_x1, _y1, _x2, _y2, 2);
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
    surface_reset_target();

    var _sprite = sprite_create_from_surface(_surface, 0, 0, _size, _size, false, false, _centre, _centre);
    surface_free(_surface);
    return _sprite;
}

/// @description Creates one complete procedural combat-space background.
function sc_space_background_create()
{
    var _tile_size = 1024;
    var _field = {
        tile_size: _tile_size,

        stars: {
            far: {
                sprite: sc_space_star_sprite_create(_tile_size, 240, 101, 0.45, 1.05, make_colour_rgb(110, 145, 190), 0.015),
                parallax: 0.08,
                alpha: 0.55
            },

            middle: {
                sprite: sc_space_star_sprite_create(_tile_size, 110, 202, 0.65, 1.5, make_colour_rgb(185, 215, 255), 0.035),
                parallax: 0.2,
                alpha: 0.72
            },

            near: {
                sprite: sc_space_star_sprite_create(_tile_size, 35, 303, 1, 2.1, make_colour_rgb(225, 240, 255), 0.09),
                parallax: 0.42,
                alpha: 0.9
            }
        },

        nebulas: [
            {
                sprite: sc_space_nebula_sprite_create(1024, 401, make_colour_rgb(20, 35, 115), make_colour_rgb(35, 180, 220)),
                x: room_width * 0.23, y: room_height * 0.21,
                scale_x: 1.55, scale_y: 1.05, angle: -16, alpha: 0.75
            },
            {
                sprite: sc_space_nebula_sprite_create(1024, 502, make_colour_rgb(75, 15, 105), make_colour_rgb(210, 30, 130)),
                x: room_width * 0.77, y: room_height * 0.34,
                scale_x: 1.8, scale_y: 1.15, angle: 23, alpha: 0.62
            },
            {
                sprite: sc_space_nebula_sprite_create(1024, 603, make_colour_rgb(15, 75, 95), make_colour_rgb(25, 210, 165)),
                x: room_width * 0.53, y: room_height * 0.79,
                scale_x: 1.7, scale_y: 1.1, angle: -31, alpha: 0.58
            }
        ],

        grid: {
            size: 256,
            major_every: 4,
            colour: make_colour_rgb(35, 145, 190),
            alpha_minor: 0.035,
            alpha_major: 0.075
        }
    };

    return _field;
}

/// @description Draws one baked star tile with camera parallax.
function sc_space_star_layer_draw(_layer, _tile_size, _camera_x, _camera_y, _view_w, _view_h)
{
    var _offset_x = (_camera_x * (1 - _layer.parallax)) mod _tile_size;
    var _offset_y = (_camera_y * (1 - _layer.parallax)) mod _tile_size;
    var _start_x = floor((_camera_x - _offset_x) / _tile_size) * _tile_size + _offset_x - _tile_size;
    var _start_y = floor((_camera_y - _offset_y) / _tile_size) * _tile_size + _offset_y - _tile_size;
    var _end_x = _camera_x + _view_w + _tile_size;
    var _end_y = _camera_y + _view_h + _tile_size;

    for (var _x = _start_x; _x <= _end_x; _x += _tile_size)
    {
        for (var _y = _start_y; _y <= _end_y; _y += _tile_size)
            draw_sprite_ext(_layer.sprite, 0, _x, _y, 1, 1, 0, c_white, _layer.alpha);
    }
}

/// @description Draws only visible world grid lines.
function sc_space_grid_draw(_grid, _camera_x, _camera_y, _view_w, _view_h)
{
    var _size = _grid.size;
    var _x1 = floor(_camera_x / _size) * _size;
    var _y1 = floor(_camera_y / _size) * _size;
    var _x2 = _camera_x + _view_w;
    var _y2 = _camera_y + _view_h;

    draw_set_colour(_grid.colour);

    for (var _x = _x1; _x <= _x2; _x += _size)
    {
        var _major = (round(_x / _size) mod _grid.major_every) == 0;
        draw_set_alpha(_major ? _grid.alpha_major : _grid.alpha_minor);
        draw_line(_x, _camera_y, _x, _y2);
    }

    for (var _y = _y1; _y <= _y2; _y += _size)
    {
        var _major = (round(_y / _size) mod _grid.major_every) == 0;
        draw_set_alpha(_major ? _grid.alpha_major : _grid.alpha_minor);
        draw_line(_camera_x, _y, _x2, _y);
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws the procedural space background.
function sc_space_background_draw(_field)
{
    var _camera = view_camera[0];
    var _camera_x = camera_get_view_x(_camera);
    var _camera_y = camera_get_view_y(_camera);
    var _view_w = camera_get_view_width(_camera);
    var _view_h = camera_get_view_height(_camera);

    for (var _i = 0; _i < array_length(_field.nebulas); _i++)
    {
        var _nebula = _field.nebulas[_i];
        draw_sprite_ext(_nebula.sprite, 0, _nebula.x, _nebula.y, _nebula.scale_x, _nebula.scale_y, _nebula.angle, c_white, _nebula.alpha);
    }

    sc_space_star_layer_draw(_field.stars.far, _field.tile_size, _camera_x, _camera_y, _view_w, _view_h);
    sc_space_grid_draw(_field.grid, _camera_x, _camera_y, _view_w, _view_h);
    sc_space_star_layer_draw(_field.stars.middle, _field.tile_size, _camera_x, _camera_y, _view_w, _view_h);
    sc_space_star_layer_draw(_field.stars.near, _field.tile_size, _camera_x, _camera_y, _view_w, _view_h);
}

/// @description Deletes runtime-generated background sprites.
function sc_space_background_destroy(_field)
{
    sprite_delete(_field.stars.far.sprite);
    sprite_delete(_field.stars.middle.sprite);
    sprite_delete(_field.stars.near.sprite);

    for (var _i = 0; _i < array_length(_field.nebulas); _i++)
        sprite_delete(_field.nebulas[_i].sprite);
}