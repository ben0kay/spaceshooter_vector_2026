/*
PROCEDURAL SPACE BACKGROUND

Creates baked star tiles, places visual-only background nebulas and draws
the navigation grid. Nebula construction lives inside sc_nebulae.
*/

/// @description Returns a deterministic value from 0–1 without affecting gameplay RNG.
function sc_space_hash(_value)
{
    return frac(abs(sin(_value * 12.9898) * 43758.5453));
}

/// @description Generates and bakes one transparent star tile.
function sc_space_star_sprite_create(_size, _count, _seed, _radius_min, _radius_max, _colour, _bright_chance)
{
    var _surface = surface_create(_size, _size);

    if (!surface_exists(_surface))
        return -1;

    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);

    for (var _i = 0; _i < _count; ++_i)
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

    var _sprite = sprite_create_from_surface(
        _surface,
        0, 0,
        _size, _size,
        false, false,
        0, 0
    );

    surface_free(_surface);
    return _sprite;
}

/// @description Creates one deterministic procedural combat-space background.
function sc_space_background_create()
{
    var _tile_size = 1024;
    var _sector_seed = sc_space_background_seed_get();

    return {
        tile_size: _tile_size,

        stars: {
            far: {
                sprite: sc_space_star_sprite_create(
                    _tile_size,
                    240,
                    101,
                    0.45,
                    1.05,
                    make_colour_rgb(110, 145, 190),
                    0.015
                ),

                parallax: 0.08,
                alpha: 0.55
            },

            middle: {
                sprite: sc_space_star_sprite_create(
                    _tile_size,
                    110,
                    202,
                    0.65,
                    1.5,
                    make_colour_rgb(185, 215, 255),
                    0.035
                ),

                parallax: 0.2,
                alpha: 0.72
            },

            near: {
                sprite: sc_space_star_sprite_create(
                    _tile_size,
                    35,
                    303,
                    1,
                    2.1,
                    make_colour_rgb(225, 240, 255),
                    0.09
                ),

                parallax: 0.42,
                alpha: 0.9
            }
        },

        nebulas: sc_space_nebulas_sector_create(
            _sector_seed
        ),

        grid: {
            size: 256,
            major_every: 4,
            colour: make_colour_rgb(35, 145, 190),
            alpha_minor: 0.035,
            alpha_major: 0.075
        }
    };
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
        {
            draw_sprite_ext(
                _layer.sprite,
                0,
                _x,
                _y,
                1,
                1,
                0,
                c_white,
                _layer.alpha
            );
        }
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

    // Nebulas sit behind every star and grid layer.
    for (var _i = 0; _i < array_length(_field.nebulas); ++_i)
    {
        sc_space_nebula_draw(
            _field.nebulas[_i],
            _camera_x,
            _camera_y,
            _view_w,
            _view_h
        );
    }

    sc_space_star_layer_draw(
        _field.stars.far,
        _field.tile_size,
        _camera_x,
        _camera_y,
        _view_w,
        _view_h
    );

    sc_space_grid_draw(
        _field.grid,
        _camera_x,
        _camera_y,
        _view_w,
        _view_h
    );

    sc_space_star_layer_draw(
        _field.stars.middle,
        _field.tile_size,
        _camera_x,
        _camera_y,
        _view_w,
        _view_h
    );

    sc_space_star_layer_draw(
        _field.stars.near,
        _field.tile_size,
        _camera_x,
        _camera_y,
        _view_w,
        _view_h
    );

    draw_set_alpha(1);
    draw_set_colour(c_white);
    gpu_set_blendmode(bm_normal);
}

/// @description Deletes runtime-generated background sprites.
function sc_space_background_destroy(_field)
{
    if (sprite_exists(_field.stars.far.sprite))
        sprite_delete(_field.stars.far.sprite);

    if (sprite_exists(_field.stars.middle.sprite))
        sprite_delete(_field.stars.middle.sprite);

    if (sprite_exists(_field.stars.near.sprite))
        sprite_delete(_field.stars.near.sprite);

    for (var _i = 0; _i < array_length(_field.nebulas); ++_i)
    {
        if (sprite_exists(_field.nebulas[_i].sprite))
            sprite_delete(_field.nebulas[_i].sprite);
    }
}

/// @description Returns the deterministic background seed for the active sector.
function sc_space_background_seed_get()
{
    if (variable_global_exists("game")
    && is_struct(global.game)
    && variable_struct_exists(global.game, "sector")
    && is_struct(global.game.sector))
    {
        return sc_sector_seed_get(
            global.game.sector.x,
            global.game.sector.y
        );
    }

    return global.config.sector.world_seed;
}

/// @description Generates deterministic nebula landmarks for one sector.
function sc_space_nebulas_sector_create(_sector_seed)
{
    var _nebulas = [];

    var _types = [
        "violet_storm",
        "cyan_veil",
        "crimson_rift",
        "azure_tempest",
        "solar_bloom",
        "ghost_cloud"
    ];

    var _seed = _sector_seed + 913751;

    var _count = 8 + floor(
        sc_space_hash(_seed + 1) * 5
    );

    var _margin = 2600;

    for (var _i = 0; _i < _count; ++_i)
    {
        var _entry_seed = _seed + _i * 977;

        var _type_index = clamp(
            floor(
                sc_space_hash(_entry_seed + 1)
                * array_length(_types)
            ),
            0,
            array_length(_types) - 1
        );

        var _width = lerp(
            3200,
            4800,
            sc_space_hash(_entry_seed + 2)
        );

        var _aspect = lerp(
            0.78,
            1.12,
            sc_space_hash(_entry_seed + 3)
        );

        var _height = _width * _aspect;

        var _x = lerp(
            _margin,
            room_width - _margin,
            sc_space_hash(_entry_seed + 4)
        );

        var _y = lerp(
            _margin,
            room_height - _margin,
            sc_space_hash(_entry_seed + 5)
        );

        var _angle = lerp(
            -180,
            180,
            sc_space_hash(_entry_seed + 6)
        );

        var _alpha = lerp(
            0.84,
            0.98,
            sc_space_hash(_entry_seed + 7)
        );

        var _visual_seed = floor(
            sc_space_hash(_entry_seed + 8)
            * 1000000
        );

        array_push(
            _nebulas,
            sc_space_nebula_create(
                _types[_type_index],
                _visual_seed,
                _x,
                _y,
                _width,
                _height,
                _angle,
                _alpha
            )
        );
    }

    return _nebulas;
}