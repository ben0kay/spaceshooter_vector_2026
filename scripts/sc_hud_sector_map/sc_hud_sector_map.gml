/*
HUD SECTOR MAP

Caches stationary world contacts and draws a complete sector overview.
The same structure contacts are reused by the smaller tactical minimap.
*/

/// @description Converts one world position into full-sector map coordinates.
function sc_hud_sector_map_position_get(_layout, _world_x, _world_y)
{
    return {
        x: _layout.map_x + _world_x * _layout.scale,
        y: _layout.map_y + _world_y * _layout.scale
    };
}

/// @description Calculates the map rectangle and world-to-map scale.
function sc_hud_sector_map_layout_get(_hud)
{
    var _config = _hud.data.sector_map;
    var _gui_width = display_get_gui_width();
    var _gui_height = display_get_gui_height();

    var _available_width = _gui_width - _config.margin_x * 2;
    var _available_height = _gui_height
        - _config.margin_top
        - _config.margin_bottom;

    var _scale = min(
        _available_width / room_width,
        _available_height / room_height
    );

    var _map_width = room_width * _scale;
    var _map_height = room_height * _scale;

    return {
        scale: _scale,
        map_x: (_gui_width - _map_width) * 0.5,
        map_y: _config.margin_top
            + (_available_height - _map_height) * 0.5,
        width: _map_width,
        height: _map_height
    };
}

/// @description Returns the map category for one world structure.
function sc_hud_sector_map_structure_type_get(_structure)
{
    var _data = _structure.structure.data;

    if (variable_struct_exists(_data, "derelict"))
        return "derelict";

    if (_structure.structure.key == "player_starting_base")
        return "player";

    return "structure";
}

/// @description Rebuilds all stationary asteroid and structure contacts.
function sc_hud_sector_map_cache_rebuild(_hud)
{
    var _map = _hud.sector_map;
    var _asteroids = [];
    var _structures = [];

    var _asteroid_count = instance_number(o_asteroid);

    for (var _i = 0; _i < _asteroid_count; ++_i)
    {
        var _asteroid = instance_find(o_asteroid, _i);
        if (!instance_exists(_asteroid) || !_asteroid.initialized) continue;

        array_push(_asteroids, {
            target_id: _asteroid,
            world_x: _asteroid.x,
            world_y: _asteroid.y,
            radius: _asteroid.asteroid.visual.radius,
            size: sc_hud_minimap_asteroid_size_get(
                _asteroid.asteroid.size
            )
        });
    }

    var _structure_count = instance_number(o_world_structure);

    for (var _i = 0; _i < _structure_count; ++_i)
    {
        var _structure = instance_find(o_world_structure, _i);
        if (!instance_exists(_structure) || !_structure.initialized) continue;

        var _data = _structure.structure.data;

        array_push(_structures, {
            target_id: _structure,
            key: _structure.structure.key,
            name: _data.identity.name,
            type: sc_hud_sector_map_structure_type_get(_structure),
            world_x: _structure.x,
            world_y: _structure.y,
            angle: _structure.draw_angle
        });
    }

    _map.asteroid_contacts = _asteroids;
    _map.structure_contacts = _structures;
    _map.cached_asteroid_count = global.level.asteroids_alive;
    _map.cached_structure_count = _structure_count;

    return true;
}

/// @description Checks whether the stationary map cache needs rebuilding.
function sc_hud_sector_map_cache_update(_hud, _force = false)
{
    var _map = _hud.sector_map;
    var _config = _hud.data.sector_map;

    if (!_force && GAME_TICK < _map.next_cache_check_tick)
        return false;

    _map.next_cache_check_tick =
        GAME_TICK + _config.cache_check_interval;

    var _structure_count = instance_number(o_world_structure);

    if (_force
    || _map.cached_asteroid_count != global.level.asteroids_alive
    || _map.cached_structure_count != _structure_count)
    {
        sc_hud_sector_map_cache_rebuild(_hud);
        return true;
    }

    return false;
}

/// @description Toggles and updates the full-sector debug map.
function sc_hud_sector_map_update(_hud)
{
    var _map = _hud.sector_map;

    if (global.input.action.map_pressed)
    {
        _map.open = !_map.open;

        if (_map.open)
            sc_hud_sector_map_cache_update(_hud, true);
    }

    // Continue maintaining the shared structure cache for the minimap.
    sc_hud_sector_map_cache_update(_hud);
}

/// @description Draws faint sector-coordinate grid lines.
function sc_hud_sector_map_grid_draw(_hud, _layout)
{
    var _palette = _hud.data.palette;
    var _config = _hud.data.sector_map;
    var _spacing = 2000;

    draw_set_colour(_palette.outline);
    draw_set_alpha(_config.grid_alpha);

    for (var _world_x = _spacing; _world_x < room_width; _world_x += _spacing)
    {
        var _x = _layout.map_x + _world_x * _layout.scale;
        draw_line(_x, _layout.map_y, _x, _layout.map_y + _layout.height);
    }

    for (var _world_y = _spacing; _world_y < room_height; _world_y += _spacing)
    {
        var _y = _layout.map_y + _world_y * _layout.scale;
        draw_line(_layout.map_x, _y, _layout.map_x + _layout.width, _y);
    }
}

/// @description Draws one scaled organic shape boundary.
function sc_hud_sector_map_shape_draw(
    _hud,
    _layout,
    _shape,
    _radius_scale,
    _colour,
    _alpha
)
{
    var _segments = 64;
    var _previous_x = 0;
    var _previous_y = 0;

    draw_set_colour(_colour);
    draw_set_alpha(_alpha);

    for (var _i = 0; _i <= _segments; ++_i)
    {
        var _direction = _i / _segments * 360;
        var _wave = 1 + dsin(
            _direction * _shape.lobes
            + _shape.phase
        ) * _shape.irregularity;

        var _distance =
            _shape.radius
            * _radius_scale
            * _wave;

        var _forward = dcos(_direction) * _distance;
        var _side = dsin(_direction)
            * _distance
            * _shape.aspect;

        var _world_x = _shape.x
            + lengthdir_x(_forward, _shape.angle)
            + lengthdir_x(_side, _shape.angle + 90);

        var _world_y = _shape.y
            + lengthdir_y(_forward, _shape.angle)
            + lengthdir_y(_side, _shape.angle + 90);

        var _position = sc_hud_sector_map_position_get(
            _layout,
            _world_x,
            _world_y
        );

        if (_i > 0)
        {
            draw_line(
                _previous_x,
                _previous_y,
                _position.x,
                _position.y
            );
        }

        _previous_x = _position.x;
        _previous_y = _position.y;
    }
}

/// @description Draws boundaries and runtime information for one field.
function sc_hud_sector_map_field_draw(_hud, _layout, _field)
{
    var _palette = _hud.data.palette;
    var _config = _hud.data.sector_map;
    var _zones = _field.zones;

    sc_hud_sector_map_shape_draw(
        _hud,
        _layout,
        _field.shape,
        1,
        _palette.warning,
        _config.field_alpha
    );

    if (_field.shape_type == AsteroidFieldShape.RING && array_length(_zones) > 0)
    {
        sc_hud_sector_map_shape_draw(
            _hud,
            _layout,
            _field.shape,
            _field.shape.inner_radius_scale,
            _palette.warning,
            _config.field_alpha * 0.65
        );
    }

    for (var _i = 1; _i < array_length(_zones); ++_i)
    {
        var _zone = _zones[_i];

        if (_zone.remaining_amount <= 0) continue;

        sc_hud_sector_map_shape_draw(
            _hud,
            _layout,
            _zone.shape,
            1,
            _palette.accent,
            0.3
        );
    }

    var _centre = sc_hud_sector_map_position_get(
        _layout,
        _field.shape.x,
        _field.shape.y
    );

    var _remaining_ratio = _field.initial_amount > 0
        ? _field.remaining_amount / _field.initial_amount
        : 0;

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_colour(_field.remaining_amount > 0 ? _palette.warning : _palette.muted);
    draw_set_alpha(_field.remaining_amount > 0 ? 0.8 : 0.35);

    draw_text(
        _centre.x,
        _centre.y,
        string_upper(_field.name)
        + "\nDENSITY " + string_format(_field.density, 1, 2)
        + " // " + string(_field.remaining_amount)
        + " / " + string(_field.initial_amount)
        + "\nZONES " + string(array_length(_zones))
        + " // REMAINING " + string(round(_remaining_ratio * 100)) + "%"
    );
}

/// @description Draws every registered asteroid-field boundary.
function sc_hud_sector_map_fields_draw(_hud, _layout)
{
    if (!sc_sector_campaign_active()) return;

    var _fields = global.game.sector.asteroid_fields;

    for (var _i = 0; _i < array_length(_fields); ++_i)
        sc_hud_sector_map_field_draw(_hud, _layout, _fields[_i]);
}

/// @description Draws one environmental field on the full-sector map.
function sc_hud_sector_map_environment_field_draw(_hud, _layout, _field)
{
    if (!instance_exists(_field) || !_field.initialized)
        return;

    var _data = _field.environment_field;
    var _config = _hud.data.sector_map.environment;
    var _colour = _data.visual.colour_mid;
    var _outline = _data.visual.colour_glow;
    var _segments = _config.segments;
    var _centre = sc_hud_sector_map_position_get(
        _layout,
        _field.x,
        _field.y
    );

    var _radius_x = _data.radius_x * _layout.scale;
    var _radius_y = _data.radius_y * _layout.scale;
    var _fill_alpha = _config.fill_alpha * lerp(0.5, 1, _data.density);

    // Translucent rotated elliptical field interior.
    draw_primitive_begin(pr_trianglefan);
    draw_vertex_colour(
        _centre.x,
        _centre.y,
        _colour,
        _fill_alpha
    );

    for (var _i = 0; _i <= _segments; ++_i)
    {
        var _direction = _i / _segments * 360;
        var _local_x = dcos(_direction) * _radius_x;
        var _local_y = dsin(_direction) * _radius_y;

        var _x = _centre.x
            + lengthdir_x(_local_x, _data.angle)
            + lengthdir_x(_local_y, _data.angle + 90);

        var _y = _centre.y
            + lengthdir_y(_local_x, _data.angle)
            + lengthdir_y(_local_y, _data.angle + 90);

        draw_vertex_colour(
            _x,
            _y,
            _colour,
            _fill_alpha * 0.4
        );
    }

    draw_primitive_end();

    // Inner density region.
    draw_primitive_begin(pr_trianglefan);
    draw_vertex_colour(
        _centre.x,
        _centre.y,
        _outline,
        _config.inner_alpha * _data.density
    );

    for (var _i = 0; _i <= _segments; ++_i)
    {
        var _direction = _i / _segments * 360;
        var _local_x = dcos(_direction) * _radius_x * 0.62;
        var _local_y = dsin(_direction) * _radius_y * 0.62;

        var _x = _centre.x
            + lengthdir_x(_local_x, _data.angle)
            + lengthdir_x(_local_y, _data.angle + 90);

        var _y = _centre.y
            + lengthdir_y(_local_x, _data.angle)
            + lengthdir_y(_local_y, _data.angle + 90);

        draw_vertex_colour(
            _x,
            _y,
            _outline,
            0
        );
    }

    draw_primitive_end();

    // Rotated outer boundary.
    draw_set_colour(_outline);
    draw_set_alpha(_config.outline_alpha);

    var _previous_x = 0;
    var _previous_y = 0;

    for (var _i = 0; _i <= _segments; ++_i)
    {
        var _direction = _i / _segments * 360;
        var _local_x = dcos(_direction) * _radius_x;
        var _local_y = dsin(_direction) * _radius_y;

        var _x = _centre.x
            + lengthdir_x(_local_x, _data.angle)
            + lengthdir_x(_local_y, _data.angle + 90);

        var _y = _centre.y
            + lengthdir_y(_local_x, _data.angle)
            + lengthdir_y(_local_y, _data.angle + 90);

        if (_i > 0)
            draw_line(_previous_x, _previous_y, _x, _y);

        _previous_x = _x;
        _previous_y = _y;
    }

    // Centre marker.
    draw_set_alpha(0.85);
    draw_circle(_centre.x, _centre.y, 3, true);
    draw_line(_centre.x - 5, _centre.y, _centre.x + 5, _centre.y);
    draw_line(_centre.x, _centre.y - 5, _centre.x, _centre.y + 5);

    // Debug map identification.
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_colour(_outline);
    draw_set_alpha(_config.label_alpha);

    draw_text(
        _centre.x,
        _centre.y + 14,
        string_upper(_data.identity.name)
        + "\nDENSITY "
        + string_format(_data.density, 1, 2)
    );
}

/// @description Draws every active environmental field on the sector map.
function sc_hud_sector_map_environment_fields_draw(_hud, _layout)
{
    if (!sc_sector_campaign_active()
    || !variable_struct_exists(global.game.sector, "environment_fields"))
        return;

    var _fields = global.game.sector.environment_fields;

    for (var _i = 0; _i < array_length(_fields); ++_i)
    {
        sc_hud_sector_map_environment_field_draw(
            _hud,
            _layout,
            _fields[_i]
        );
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws cached individual asteroids.
function sc_hud_sector_map_asteroids_draw(_hud, _layout)
{
    var _palette = _hud.data.palette;
    var _config = _hud.data.sector_map;
    var _contacts = _hud.sector_map.asteroid_contacts;

    draw_set_colour(_palette.muted);
    draw_set_alpha(_config.asteroid_alpha);

    for (var _i = 0; _i < array_length(_contacts); ++_i)
    {
        var _contact = _contacts[_i];
        var _position = sc_hud_sector_map_position_get(
            _layout,
            _contact.world_x,
            _contact.world_y
        );

        var _radius = clamp(
            _contact.radius * _layout.scale,
            1,
            7
        );

        draw_circle(_position.x, _position.y, _radius, false);
    }
}

/// @description Draws one structure symbol suitable for both map displays.
function sc_hud_map_structure_symbol_draw(_x, _y, _size, _type, _palette)
{
    switch (_type)
    {
        case "player":
            draw_set_colour(_palette.core);
            draw_rectangle(
                _x - _size,
                _y - _size,
                _x + _size,
                _y + _size,
                true
            );

            draw_line(_x - _size - 3, _y, _x + _size + 3, _y);
            draw_line(_x, _y - _size - 3, _x, _y + _size + 3);
        break;

        case "derelict":
            draw_set_colour(_palette.warning);
            draw_line(_x, _y - _size, _x + _size, _y);
            draw_line(_x + _size, _y, _x, _y + _size);
            draw_line(_x, _y + _size, _x - _size, _y);
            draw_line(_x - _size, _y, _x, _y - _size);
            draw_line(_x - 2, _y - 2, _x + 3, _y + 3);
        break;

        default:
            draw_set_colour(_palette.text);
            draw_rectangle(
                _x - _size,
                _y - _size,
                _x + _size,
                _y + _size,
                true
            );
        break;
    }
}

/// @description Draws every cached world structure.
function sc_hud_sector_map_structures_draw(_hud, _layout)
{
    var _palette = _hud.data.palette;
    var _size = _hud.data.sector_map.structure_size;
    var _contacts = _hud.sector_map.structure_contacts;

    draw_set_alpha(1);

    for (var _i = 0; _i < array_length(_contacts); ++_i)
    {
        var _contact = _contacts[_i];
        var _position = sc_hud_sector_map_position_get(
            _layout,
            _contact.world_x,
            _contact.world_y
        );

        sc_hud_map_structure_symbol_draw(
            _position.x,
            _position.y,
            _size,
            _contact.type,
            _palette
        );

        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        draw_set_colour(_palette.text);
        draw_set_alpha(0.75);
        draw_text(_position.x, _position.y + _size + 5, _contact.name);
    }
}

/// @description Draws the player's current sector position and facing.
function sc_hud_sector_map_player_draw(_hud, _layout)
{
    if (!instance_exists(global.player_id)) return;

    var _palette = _hud.data.palette;
    var _player = global.player_id;
    var _size = _hud.data.sector_map.player_size;
    var _position = sc_hud_sector_map_position_get(
        _layout,
        _player.x,
        _player.y
    );

    draw_set_colour(_palette.core);
    draw_set_alpha(1);

    draw_triangle(
        _position.x + lengthdir_x(_size, _player.draw_angle),
        _position.y + lengthdir_y(_size, _player.draw_angle),
        _position.x + lengthdir_x(_size * 0.75, _player.draw_angle + 145),
        _position.y + lengthdir_y(_size * 0.75, _player.draw_angle + 145),
        _position.x + lengthdir_x(_size * 0.75, _player.draw_angle - 145),
        _position.y + lengthdir_y(_size * 0.75, _player.draw_angle - 145),
        false
    );
}

/// @description Draws the complete full-sector debug map.
function sc_hud_sector_map_draw(_hud)
{
    var _map = _hud.sector_map;

    if (!_map.open)
        return;

    var _palette = _hud.data.palette;
    var _layout = sc_hud_sector_map_layout_get(_hud);
    var _gui_width = display_get_gui_width();
    var _gui_height = display_get_gui_height();

    draw_set_alpha(0.96);
    draw_set_colour(_palette.void);

    draw_rectangle(
        0,
        0,
        _gui_width,
        _gui_height,
        false
    );

    draw_set_alpha(1);
    draw_set_colour(_palette.panel);

    draw_rectangle(
        _layout.map_x,
        _layout.map_y,
        _layout.map_x + _layout.width,
        _layout.map_y + _layout.height,
        false
    );

    draw_set_colour(_palette.outline);

    draw_rectangle(
        _layout.map_x,
        _layout.map_y,
        _layout.map_x + _layout.width,
        _layout.map_y + _layout.height,
        true
    );

    sc_hud_sector_map_grid_draw(
        _hud,
        _layout
    );

    // Debug-only visual background regions.
    sc_hud_sector_map_nebulas_draw(
        _layout
    );

    // Environmental gameplay regions.
    sc_hud_sector_map_environment_fields_draw(
        _hud,
        _layout
    );

    sc_hud_sector_map_fields_draw(
        _hud,
        _layout
    );

    sc_hud_sector_map_asteroids_draw(
        _hud,
        _layout
    );

    sc_hud_sector_map_structures_draw(
        _hud,
        _layout
    );

    sc_hud_sector_map_player_draw(
        _hud,
        _layout
    );

    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_set_colour(_palette.core);
    draw_set_alpha(1);

    draw_text(
        48,
        28,
        "SECTOR OVERVIEW // DEBUG"
    );

    draw_set_halign(fa_right);
    draw_set_colour(_palette.muted);

    draw_text(
        _gui_width - 48,
        28,
        "M CLOSE // "
        + string(global.level.asteroids_alive)
        + " ASTEROIDS // "
        + string(instance_number(o_environment_field))
        + " ENVIRONMENT FIELDS"
    );

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}
