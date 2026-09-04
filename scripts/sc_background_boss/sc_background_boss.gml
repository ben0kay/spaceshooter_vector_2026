/// @description Creates the independently scrolling boss-arena background.
function sc_boss_background_create()
{
    var _tile_size = 1024;

    return {
        tile_size: _tile_size,
        scroll_y: 0,
        speed: 0,
        target_speed: 0,

        stars: [
            {
                sprite: sc_space_star_sprite_create(_tile_size, 240, 7101, 0.45, 1.05, make_colour_rgb(80, 115, 165), 0.015),
                scroll_scale: 0.18,
                alpha: 0.5
            },
            {
                sprite: sc_space_star_sprite_create(_tile_size, 115, 7202, 0.65, 1.5, make_colour_rgb(150, 205, 255), 0.04),
                scroll_scale: 0.48,
                alpha: 0.72
            },
            {
                sprite: sc_space_star_sprite_create(_tile_size, 42, 7303, 1, 2.2, make_colour_rgb(215, 245, 255), 0.1),
                scroll_scale: 1,
                alpha: 0.9
            }
        ]
    };
}

/// @description Smoothly updates the boss-background scrolling.
function sc_boss_background_update(_background)
{
    _background.speed = lerp(_background.speed, _background.target_speed, 0.08);

    if (abs(_background.speed) < 0.001)
        _background.speed = 0;

    _background.scroll_y += _background.speed;
}

/// @description Draws one vertically scrolling baked star layer.
function sc_boss_background_layer_draw(_background, _layer, _camera_x, _camera_y, _view_w, _view_h)
{
    var _tile_size = _background.tile_size;
    var _scroll_y = _background.scroll_y * _layer.scroll_scale;
    var _start_x = floor(_camera_x / _tile_size) * _tile_size - _tile_size;
    var _start_y = floor((_camera_y - _scroll_y) / _tile_size) * _tile_size + _scroll_y - _tile_size;
    var _end_x = _camera_x + _view_w + _tile_size;
    var _end_y = _camera_y + _view_h + _tile_size;

    for (var _x = _start_x; _x <= _end_x; _x += _tile_size)
    {
        for (var _y = _start_y; _y <= _end_y; _y += _tile_size)
            draw_sprite_ext(_layer.sprite, 0, _x, _y, 1, 1, 0, c_white, _layer.alpha);
    }
}

/// @description Draws the dedicated scrolling boss background.
function sc_boss_background_draw(_background)
{
    var _camera_id = view_camera[0];
    var _camera_x = camera_get_view_x(_camera_id);
    var _camera_y = camera_get_view_y(_camera_id);
    var _view_w = camera_get_view_width(_camera_id);
    var _view_h = camera_get_view_height(_camera_id);

    draw_clear(make_colour_rgb(1, 4, 10));

    for (var _i = 0; _i < array_length(_background.stars); _i++)
        sc_boss_background_layer_draw(_background, _background.stars[_i], _camera_x, _camera_y, _view_w, _view_h);
}

/// @description Deletes the boss background's runtime-generated sprites.
function sc_boss_background_destroy(_background)
{
    for (var _i = 0; _i < array_length(_background.stars); _i++)
        sprite_delete(_background.stars[_i].sprite);
}