/*
ASTEROID SPAWN DATA

Spawn definitions control spatial layout only.
Material and asteroid-size composition can be supplied separately later.
*/

/// @description Registers one reusable asteroid spawn layout.
function sc_asteroid_spawn_register(_data)
{
    var _key = _data.identity.key;

    if (variable_struct_exists(global.data.asteroid_spawns, _key))
    {
        show_debug_message(
            "ASTEROID SPAWN REGISTRATION ERROR - duplicate key: "
            + _key
        );

        return false;
    }

    variable_struct_set(global.data.asteroid_spawns, _key, _data);

    array_push(global.data.asteroid_spawn_pool, {
        key: _key,
        weight: _data.weight
    });

    return true;
}

/// @description Returns one registered asteroid spawn layout.
function sc_asteroid_spawn_get(_key)
{
    return variable_struct_get(global.data.asteroid_spawns, _key);
}

/// @description Selects one weighted asteroid spawn layout.
function sc_asteroid_spawn_weighted_choose()
{
    var _pool = global.data.asteroid_spawn_pool;
    var _entry = sc_asteroid_weighted_choose(_pool);

    return sc_asteroid_spawn_get(_entry.key);
}

/// @description Registers the initial reusable asteroid spawn layouts.
function sc_asteroid_spawn_register_all()
{
    return sc_asteroid_spawn_register_lone()
        && sc_asteroid_spawn_register_small_dense()
        && sc_asteroid_spawn_register_small_sparse()
        && sc_asteroid_spawn_register_large_sparse()
        && sc_asteroid_spawn_register_large_sparse_pockets();
}

/// @description Registers rare groups of isolated asteroids.
function sc_asteroid_spawn_register_lone()
{
    return sc_asteroid_spawn_register({
        identity: {
            key: "asteroid_lone",
            name: "Lone Asteroids"
        },

        weight: 8,
        field: false,

        radius: {
            minimum: 120,
            maximum: 620
        },

        amount: {
            minimum: 1,
            maximum: 5
        },

        shape: {
            aspect_min: 0.65,
            aspect_max: 1,
            irregularity_min: 0,
            irregularity_max: 0.08,
            lobes_min: 2,
            lobes_max: 3
        },

        spacing_scale: 1.3,
        pockets: []
    });
}

/// @description Registers a compact, heavily populated asteroid field.
function sc_asteroid_spawn_register_small_dense()
{
    return sc_asteroid_spawn_register({
        identity: {
            key: "asteroid_small_dense",
            name: "Small Dense Field"
        },

        weight: 24,
        field: true,

        radius: {
            minimum: 850,
            maximum: 1400
        },

        amount: {
            minimum: 18,
            maximum: 30
        },

        shape: {
            aspect_min: 0.7,
            aspect_max: 1,
            irregularity_min: 0.08,
            irregularity_max: 0.18,
            lobes_min: 3,
            lobes_max: 6
        },

        spacing_scale: 1,
        pockets: []
    });
}

/// @description Registers a compact field containing wider navigation gaps.
function sc_asteroid_spawn_register_small_sparse()
{
    return sc_asteroid_spawn_register({
        identity: {
            key: "asteroid_small_sparse",
            name: "Small Sparse Field"
        },

        weight: 20,
        field: true,

        radius: {
            minimum: 1400,
            maximum: 2300
        },

        amount: {
            minimum: 10,
            maximum: 18
        },

        shape: {
            aspect_min: 0.65,
            aspect_max: 1,
            irregularity_min: 0.1,
            irregularity_max: 0.22,
            lobes_min: 3,
            lobes_max: 7
        },

        spacing_scale: 1.2,
        pockets: []
    });
}

/// @description Registers a huge sparse asteroid field around a 7000-pixel baseline.
function sc_asteroid_spawn_register_large_sparse()
{
    return sc_asteroid_spawn_register({
        identity: {
            key: "asteroid_large_sparse",
            name: "Large Sparse Field"
        },

        weight: 28,
        field: true,

        radius: {
            minimum: 6200,
            maximum: 7600
        },

        amount: {
            minimum: 65,
            maximum: 95
        },

        shape: {
            aspect_min: 0.72,
            aspect_max: 1,
            irregularity_min: 0.08,
            irregularity_max: 0.18,
            lobes_min: 4,
            lobes_max: 8
        },

        spacing_scale: 1.25,
        pockets: []
    });
}

/// @description Registers a huge sparse field containing several dense pockets.
function sc_asteroid_spawn_register_large_sparse_pockets()
{
    return sc_asteroid_spawn_register({
        identity: {
            key: "asteroid_large_sparse_pockets",
            name: "Large Sparse Field with Dense Pockets"
        },

        weight: 20,
        field: true,

        radius: {
            minimum: 6500,
            maximum: 7800
        },

        amount: {
            minimum: 50,
            maximum: 75
        },

        shape: {
            aspect_min: 0.72,
            aspect_max: 1,
            irregularity_min: 0.1,
            irregularity_max: 0.2,
            lobes_min: 4,
            lobes_max: 8
        },

        spacing_scale: 1.25,

        pockets: [
            {
                key: "asteroid_small_dense",
                chance: 0.85,
                amount_min: 2,
                amount_max: 4,
                distance_min_scale: 0.2,
                distance_max_scale: 0.72
            }
        ]
    });
}

/// @description Creates one randomized organic shape from a spawn definition.
function sc_asteroid_spawn_shape_create(_x, _y, _radius, _definition)
{
    var _shape = _definition.shape;

    return {
        x: _x,
        y: _y,
        radius: _radius,
        aspect: random_range(
            _shape.aspect_min,
            _shape.aspect_max
        ),
        angle: random(360),
        irregularity: random_range(
            _shape.irregularity_min,
            _shape.irregularity_max
        ),
        lobes: irandom_range(
            _shape.lobes_min,
            _shape.lobes_max
        ),
        phase: random(360)
    };
}

/// @description Returns one randomized position inside an organic field shape.
function sc_asteroid_spawn_shape_position_get(_shape)
{
    var _direction = random(360);
    var _wave = 1 + dsin(
        _direction * _shape.lobes
        + _shape.phase
    ) * _shape.irregularity;

    var _distance = sqrt(random(1))
        * _shape.radius
        * _wave;

    var _forward = dcos(_direction) * _distance;
    var _side = dsin(_direction)
        * _distance
        * _shape.aspect;

    return {
        x: _shape.x
            + lengthdir_x(_forward, _shape.angle)
            + lengthdir_x(_side, _shape.angle + 90),

        y: _shape.y
            + lengthdir_y(_forward, _shape.angle)
            + lengthdir_y(_side, _shape.angle + 90)
    };
}

/// @description Resolves optional composition data against global defaults.
function sc_asteroid_spawn_composition_resolve(_composition)
{
    var _config = global.config.sector.asteroid_fields;

    if (!is_struct(_composition))
    {
        return {
            materials: _config.materials,
            sizes: _config.sizes
        };
    }

    return {
        materials: is_undefined(_composition.materials)
            ? _config.materials
            : _composition.materials,

        sizes: is_undefined(_composition.sizes)
            ? _config.sizes
            : _composition.sizes
    };
}

/// @description Spawns one asteroid population inside an organic shape.
function sc_asteroid_spawn_population(
    _shape,
    _amount,
    _spacing_scale,
    _layer,
    _field_index,
    _composition
)
{
    var _spawned = 0;
    var _attempts = 0;
    var _attempts_max = _amount * 100;

    while (_spawned < _amount
    && _attempts < _attempts_max)
    {
        _attempts++;

        var _size = sc_asteroid_weighted_choose(
            _composition.sizes
        ).size;

        var _size_data = sc_asteroid_size_data(_size);
        var _position = sc_asteroid_spawn_shape_position_get(_shape);
        var _edge_margin = _size_data.radius * 1.1 + 32;
        var _spawn_clearance = (
            _size_data.radius * 0.95 + 24
        ) * _spacing_scale;

        if (_position.x < _edge_margin
        || _position.x > room_width - _edge_margin
        || _position.y < _edge_margin
        || _position.y > room_height - _edge_margin)
            continue;

        if (collision_circle(
            _position.x,
            _position.y,
            _spawn_clearance,
            o_asteroid,
            false,
            true
        ) != noone)
            continue;

        var _material = sc_asteroid_weighted_choose(
            _composition.materials
        );

        instance_create_layer(
            _position.x,
            _position.y,
            _layer,
            o_asteroid,
            {
                asteroid_create: {
                    key: _material.key,
                    size: _size,
                    field_index: _field_index
                }
            }
        );

        _spawned++;
    }

    return _spawned;
}

/// @description Spawns optional dense pockets belonging to a parent field.
function sc_asteroid_spawn_pockets_create(
    _parent_shape,
    _definition,
    _layer,
    _field_index,
    _composition
)
{
    var _spawned = 0;

    for (var _p = 0; _p < array_length(_definition.pockets); ++_p)
    {
        var _pocket_data = _definition.pockets[_p];

        if (random(1) > _pocket_data.chance)
            continue;

        var _pocket_definition = sc_asteroid_spawn_get(
            _pocket_data.key
        );

        var _pocket_amount = irandom_range(
            _pocket_data.amount_min,
            _pocket_data.amount_max
        );

        for (var _i = 0; _i < _pocket_amount; ++_i)
        {
            var _direction = random(360);
            var _distance = random_range(
                _parent_shape.radius
                    * _pocket_data.distance_min_scale,
                _parent_shape.radius
                    * _pocket_data.distance_max_scale
            );

            var _x = _parent_shape.x
                + lengthdir_x(_distance, _direction);

            var _y = _parent_shape.y
                + lengthdir_y(
                    _distance * _parent_shape.aspect,
                    _direction
                );

            var _radius = random_range(
                _pocket_definition.radius.minimum,
                _pocket_definition.radius.maximum
            );

            var _shape = sc_asteroid_spawn_shape_create(
                _x,
                _y,
                _radius,
                _pocket_definition
            );

            var _amount = irandom_range(
                _pocket_definition.amount.minimum,
                _pocket_definition.amount.maximum
            );

            _spawned += sc_asteroid_spawn_population(
                _shape,
                _amount,
                _pocket_definition.spacing_scale,
                _layer,
                _field_index,
                _composition
            );
        }
    }

    return _spawned;
}

/// @description Creates one complete reusable asteroid spawn layout.
function sc_asteroid_spawn_create(		
    _x,
    _y,
    _layer,
    _spawn_key,
    _field_index = -1,
    _composition_override = undefined
)
{
    var _definition = sc_asteroid_spawn_get(_spawn_key);
    var _composition = sc_asteroid_spawn_composition_resolve(
        _composition_override
    );

    var _radius = random_range(
        _definition.radius.minimum,
        _definition.radius.maximum
    );

    var _shape = sc_asteroid_spawn_shape_create(
        _x,
        _y,
        _radius,
        _definition
    );

    var _amount = irandom_range(
        _definition.amount.minimum,
        _definition.amount.maximum
    );

    var _spawned = sc_asteroid_spawn_population(
        _shape,
        _amount,
        _definition.spacing_scale,
        _layer,
        _field_index,
        _composition
    );

    _spawned += sc_asteroid_spawn_pockets_create(
        _shape,
        _definition,
        _layer,
        _field_index,
        _composition
    );

    return {
        key: _spawn_key,
        name: _definition.identity.name,
        field: _definition.field,
        x: _x,
        y: _y,
        radius: _radius,
        amount: _spawned,
        shape: _shape
    };
}