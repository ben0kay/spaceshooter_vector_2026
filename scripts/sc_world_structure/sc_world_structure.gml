/// @description Registers one world-structure definition.
function sc_world_structure_register(_data)
{
    var _key = _data.identity.key;

    if (variable_struct_exists(global.data.structures, _key))
    {
        show_debug_message("WORLD STRUCTURE REGISTRATION ERROR - duplicate key: " + _key);
        return false;
    }

    variable_struct_set(global.data.structures, _key, _data);
    return true;
}


/// @description Registers all current world structures.
function sc_world_structure_register_all()
{
    if (!sc_world_structure_register_player_base()) return false;
    return true;
}


/// @description Returns one registered world-structure definition.
function sc_world_structure_get(_key)
{
    if (!variable_struct_exists(global.data.structures, _key))
    {
        show_debug_message("WORLD STRUCTURE ERROR - unknown key: " + _key);
        return undefined;
    }

    return variable_struct_get(global.data.structures, _key);
}

/// @description Creates every collision piece belonging to one structure.
function sc_world_structure_colliders_create(_structure, _layer)
{
    var _data = _structure.structure.data;
    var _parts = _data.collision.parts;
    var _colliders = [];

    for (var _i = 0; _i < array_length(_parts); ++_i)
    {
        var _part = _parts[_i];
        var _angle = _structure.draw_angle;
        var _x = _structure.x
            + lengthdir_x(_part.forward, _angle)
            + lengthdir_x(_part.side, _angle + 90);

        var _y = _structure.y
            + lengthdir_y(_part.forward, _angle)
            + lengthdir_y(_part.side, _angle + 90);

        var _create = {
            owner_id: _structure,
            part_key: _part.key,
            shape: _part.shape,
            angle: _angle + _part.angle,
            radius: 0,
            width: 0,
            height: 0
        };

        switch (_part.shape)
        {
            case StructureCollisionShape.CIRCLE:
                _create.radius = _part.radius;
            break;

            case StructureCollisionShape.RECTANGLE:
                _create.width = _part.width;
                _create.height = _part.height;
            break;
        }

        var _collider = instance_create_layer(
            _x,
            _y,
            _layer,
            o_structure_collider,
            { collider_create: _create }
        );

        array_push(_colliders, _collider);
    }

    return _colliders;
}

/// @description Initializes one static world structure.
function sc_world_structure_init(_structure, _create)
{
    var _data = sc_world_structure_get(_create.key);
    if (!is_struct(_data)) return false;

    var _sprite = sc_world_structure_visual_cache_get(_create.key);
    if (!sprite_exists(_sprite))
    {
        show_debug_message("WORLD STRUCTURE ERROR - visual cache missing: " + _create.key);
        return false;
    }

    _structure.draw_angle = _create.angle;
    _structure.structure = {
        key: _create.key,
        data: _data,
        sprite: _sprite,
        colliders: []
    };

    _structure.structure.colliders = sc_world_structure_colliders_create(
        _structure,
        _create.collision_layer
    );

    return true;
}

/// @description Draws one baked static world structure.
function sc_world_structure_draw(_structure)
{
    var _runtime = _structure.structure;

    draw_sprite_ext(
        _runtime.sprite,
        0,
        _structure.x,
        _structure.y,
        1,
        1,
        _structure.draw_angle,
        c_white,
        1
    );
}

/// @description Destroys every collision piece owned by one structure.
function sc_world_structure_cleanup(_structure)
{
    var _colliders = _structure.structure.colliders;

    for (var _i = 0; _i < array_length(_colliders); ++_i)
        if (instance_exists(_colliders[_i]))
            instance_destroy(_colliders[_i]);

    _structure.structure.colliders = [];
}

/// @description Draws the exact configured collision pieces of one world structure.
function sc_world_structure_collision_debug_draw(_structure)
{
    if (!global.config.debug.structure_collision) return;

    var _parts = _structure.structure.data.collision.parts;
    var _structure_angle = _structure.draw_angle;

    draw_set_alpha(0.85);
    draw_set_colour(c_lime);

    for (var _i = 0; _i < array_length(_parts); ++_i)
    {
        var _part = _parts[_i];
        var _x = _structure.x
            + lengthdir_x(_part.forward,_structure_angle)
            + lengthdir_x(_part.side,_structure_angle + 90);

        var _y = _structure.y
            + lengthdir_y(_part.forward,_structure_angle)
            + lengthdir_y(_part.side,_structure_angle + 90);

        switch (_part.shape)
        {
            case StructureCollisionShape.CIRCLE:
                draw_circle(_x,_y,_part.radius,true);
            break;

            case StructureCollisionShape.RECTANGLE:
                var _angle = _structure_angle + _part.angle;
                var _half_width = _part.width * 0.5;
                var _half_height = _part.height * 0.5;

                var _x1 = sc_visual_x(_x,1,_angle,-_half_width,-_half_height);
                var _y1 = sc_visual_y(_y,1,_angle,-_half_width,-_half_height);
                var _x2 = sc_visual_x(_x,1,_angle,_half_width,-_half_height);
                var _y2 = sc_visual_y(_y,1,_angle,_half_width,-_half_height);
                var _x3 = sc_visual_x(_x,1,_angle,_half_width,_half_height);
                var _y3 = sc_visual_y(_y,1,_angle,_half_width,_half_height);
                var _x4 = sc_visual_x(_x,1,_angle,-_half_width,_half_height);
                var _y4 = sc_visual_y(_y,1,_angle,-_half_width,_half_height);

                draw_line_width(_x1,_y1,_x2,_y2,2);
                draw_line_width(_x2,_y2,_x3,_y3,2);
                draw_line_width(_x3,_y3,_x4,_y4,2);
                draw_line_width(_x4,_y4,_x1,_y1,2);
            break;
        }
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
}
