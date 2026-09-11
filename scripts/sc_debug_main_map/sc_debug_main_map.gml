/// @description Returns the debug-map colour for one nebula type.
function sc_hud_sector_map_nebula_colour_get(_type)
{
    switch (_type)
    {
        case "violet_storm":
            return make_colour_rgb(185, 65, 230);

        case "cyan_veil":
            return make_colour_rgb(35, 195, 215);

        case "crimson_rift":
            return make_colour_rgb(235, 55, 120);

        case "azure_tempest":
            return make_colour_rgb(55, 125, 235);

        case "solar_bloom":
            return make_colour_rgb(240, 145, 45);

        case "ghost_cloud":
            return make_colour_rgb(105, 135, 175);
    }

    return make_colour_rgb(150, 105, 205);
}

/// @description Draws one nebula coverage region on the debug sector map.
function sc_hud_sector_map_nebula_draw(
    _layout,
    _nebula
)
{
    var _segments = 48;

    var _centre = sc_hud_sector_map_position_get(
        _layout,
        _nebula.x,
        _nebula.y
    );

    var _radius_x =
        _nebula.width
        * 0.5
        * _layout.scale;

    var _radius_y =
        _nebula.height
        * 0.5
        * _layout.scale;

    var _colour =
        sc_hud_sector_map_nebula_colour_get(
            _nebula.type
        );

    draw_primitive_begin(pr_trianglefan);

    draw_vertex_colour(
        _centre.x,
        _centre.y,
        _colour,
        0.13
    );

    for (var _i = 0; _i <= _segments; ++_i)
    {
        var _direction =
            _i / _segments * 360;

        var _local_x =
            dcos(_direction)
            * _radius_x;

        var _local_y =
            dsin(_direction)
            * _radius_y;

        var _x = _centre.x
            + lengthdir_x(
                _local_x,
                _nebula.angle
            )
            + lengthdir_x(
                _local_y,
                _nebula.angle + 90
            );

        var _y = _centre.y
            + lengthdir_y(
                _local_x,
                _nebula.angle
            )
            + lengthdir_y(
                _local_y,
                _nebula.angle + 90
            );

        draw_vertex_colour(
            _x,
            _y,
            _colour,
            0.025
        );
    }

    draw_primitive_end();

    draw_set_colour(_colour);
    draw_set_alpha(0.55);

    var _previous_x = 0;
    var _previous_y = 0;

    for (var _i = 0; _i <= _segments; ++_i)
    {
        var _direction =
            _i / _segments * 360;

        var _local_x =
            dcos(_direction)
            * _radius_x;

        var _local_y =
            dsin(_direction)
            * _radius_y;

        var _x = _centre.x
            + lengthdir_x(
                _local_x,
                _nebula.angle
            )
            + lengthdir_x(
                _local_y,
                _nebula.angle + 90
            );

        var _y = _centre.y
            + lengthdir_y(
                _local_x,
                _nebula.angle
            )
            + lengthdir_y(
                _local_y,
                _nebula.angle + 90
            );

        if (_i > 0)
        {
            draw_line(
                _previous_x,
                _previous_y,
                _x,
                _y
            );
        }

        _previous_x = _x;
        _previous_y = _y;
    }

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_colour(_colour);
    draw_set_alpha(0.8);

    draw_text(
        _centre.x,
        _centre.y,
        string_upper(_nebula.type)
    );
}

/// @description Draws all generated nebulae on the debug sector map.
function sc_hud_sector_map_nebulas_draw(_layout)
{
    if (!global.config.debug.sector_map_nebulas)
        return;

    var _background = instance_find(
        o_background_space,
        0
    );

    if (!instance_exists(_background)
    || !variable_instance_exists(
        _background,
        "space_field"
    )
    || !is_struct(_background.space_field))
        return;

    var _nebulas =
        _background.space_field.nebulas;

    for (var _i = 0;
    _i < array_length(_nebulas);
    ++_i)
    {
        sc_hud_sector_map_nebula_draw(
            _layout,
            _nebulas[_i]
        );
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
}