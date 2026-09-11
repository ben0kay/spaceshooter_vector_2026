/*
ASTEROID SPAWN DATA

Fields are procedurally assembled from independent scale, density and layout data.
Dense pockets are reusable keyed subformations belonging to large fields.
*/

/// @description Creates all asteroid-field generation definitions.
function sc_asteroid_spawn_generation_data()
{
    return {
        lone_chance: 0.08,

        lone: {
            radius_min: 120,
            radius_max: 620,
            amount_min: 1,
            amount_max: 5,
            spacing_scale: 1.3
        },

        scales: [
            {
                scale: AsteroidFieldScale.SMALL,
                name: "SMALL",
                weight: 35,
                fixed_radius: true,
                radius_min: 2000,
                radius_max: 3000,
                amount_min: 20,
                amount_max: 34
            },
            {
                scale: AsteroidFieldScale.MEDIUM,
                name: "MEDIUM",
                weight: 45,
                fixed_radius: false,
                radius_min_scale: 0.09,
                radius_max_scale: 0.16,
                amount_min: 40,
                amount_max: 65
            },
            {
                scale: AsteroidFieldScale.LARGE,
                name: "LARGE",
                weight: 20,
                fixed_radius: false,
                radius_min_scale: 0.25,
                radius_max_scale: 0.37,
                amount_min: 85,
                amount_max: 140
            }
        ],

        densities: [
            {
                density: AsteroidFieldDensity.SPARSE,
                name: "SPARSE",
                weights: [20, 45, 85],
                amount_multiplier: 0.68,
                spacing_scale: 1.2,
                navigation_density: 0.3
            },
            {
                density: AsteroidFieldDensity.STANDARD,
                name: "STANDARD",
                weights: [35, 45, 15],
                amount_multiplier: 1,
                spacing_scale: 1.04,
                navigation_density: 0.55
            },
            {
                density: AsteroidFieldDensity.DENSE,
                name: "DENSE",
                weights: [45, 10, 0],
                amount_multiplier: 1.3,
                spacing_scale: 0.9,
                navigation_density: 0.85
            }
        ],

        layouts: [
            {
                layout: AsteroidFieldLayout.STANDARD,
                name: "FIELD",
                weights: [55, 40, 35],
                amount_multiplier: 1,

                distribution: {
                    inner_radius_scale: 0,
                    radial_power: 0.5,
                    local_mode: "uniform"
                },

                shape: {
                    aspect_min: 0.68,
                    aspect_max: 1,
                    irregularity_min: 0.08,
                    irregularity_max: 0.2,
                    lobes_min: 3,
                    lobes_max: 8
                },

                subformation_keys: [
                    "asteroid_cluster_local_medium",
                    "asteroid_cluster_local_sparse_large",
                    "asteroid_pocket_rich_medium",
                    "asteroid_pocket_rich_large",
                    "asteroid_pocket_dense_optional"
                ]
            },
            {
                layout: AsteroidFieldLayout.BELT,
                name: "BELT",
                weights: [0, 30, 25],
                amount_multiplier: 1,

                distribution: {
                    inner_radius_scale: 0.55,
                    radial_power: 0.32,
                    local_mode: "belt"
                },

                shape: {
                    aspect_min: 0.74,
                    aspect_max: 1,
                    irregularity_min: 0.04,
                    irregularity_max: 0.12,
                    lobes_min: 3,
                    lobes_max: 6
                },

                subformation_keys: []
            },
            {
                layout: AsteroidFieldLayout.DENSE_CORE,
                name: "DENSE CORE",
                weights: [45, 30, 0],
                amount_multiplier: 1,

                distribution: {
                    inner_radius_scale: 0,
                    radial_power: 1.7,
                    local_mode: "core"
                },

                shape: {
                    aspect_min: 0.72,
                    aspect_max: 1,
                    irregularity_min: 0.08,
                    irregularity_max: 0.16,
                    lobes_min: 3,
                    lobes_max: 7
                },

                subformation_keys: []
            },
            {
                layout: AsteroidFieldLayout.ARCHIPELAGO,
                name: "ARCHIPELAGO",
                weights: [0, 0, 40],
                amount_multiplier: 0.12,

                distribution: {
                    inner_radius_scale: 0,
                    radial_power: 0.5,
                    local_mode: "uniform"
                },

                shape: {
                    aspect_min: 0.68,
                    aspect_max: 1,
                    irregularity_min: 0.1,
                    irregularity_max: 0.22,
                    lobes_min: 4,
                    lobes_max: 8
                },

                subformation_keys: [
                    "asteroid_pocket_archipelago"
                ]
            }
        ],

        subformations: [
            {
                key: "asteroid_cluster_local_medium",
                name: "LOCAL CLUSTER",
                allocation: "redistribute",
                composition_mode: "parent",

                scale_required: AsteroidFieldScale.MEDIUM,
                density_required: -1,
                layout_required: AsteroidFieldLayout.STANDARD,

                chance: 0.25,
                amount_min: 1,
                amount_max: 2,

                radius_min_scale: 0.075,
                radius_max_scale: 0.12,
                distance_min_scale: 0.15,
                distance_max_scale: 0.72,

                asteroid_min: 5,
                asteroid_max: 9,

                background_min_scale: 0.6,
                density: 0.55,
                spacing_scale: 1.04,

                rich_share_min: 0,
                rich_share_max: 0
            },
            {
                key: "asteroid_cluster_local_sparse_large",
                name: "LOCAL CLUSTER",
                allocation: "redistribute",
                composition_mode: "parent",

                scale_required: AsteroidFieldScale.LARGE,
                density_required: AsteroidFieldDensity.SPARSE,
                layout_required: AsteroidFieldLayout.STANDARD,

                chance: 1,
                amount_min: 3,
                amount_max: 5,

                radius_min_scale: 0.055,
                radius_max_scale: 0.085,
                distance_min_scale: 0.16,
                distance_max_scale: 0.78,

                asteroid_min: 7,
                asteroid_max: 12,

                background_min_scale: 0.5,
                density: 0.45,
                spacing_scale: 1.04,

                rich_share_min: 0,
                rich_share_max: 0
            },
            {
                key: "asteroid_pocket_rich_medium",
                name: "ORE-RICH POCKET",
                allocation: "redistribute",
                composition_mode: "rich",

                scale_required: AsteroidFieldScale.MEDIUM,
                density_required: -1,
                layout_required: AsteroidFieldLayout.STANDARD,

                chance: 0.15,
                amount_min: 1,
                amount_max: 1,

                radius_min_scale: 0.08,
                radius_max_scale: 0.13,
                distance_min_scale: 0.16,
                distance_max_scale: 0.72,

                asteroid_min: 8,
                asteroid_max: 14,

                background_min_scale: 0.55,
                density: 0.6,
                spacing_scale: 1,

                rich_share_min: 0.55,
                rich_share_max: 0.68
            },
            {
                key: "asteroid_pocket_rich_large",
                name: "ORE-RICH POCKET",
                allocation: "redistribute",
                composition_mode: "rich",

                scale_required: AsteroidFieldScale.LARGE,
                density_required: -1,
                layout_required: AsteroidFieldLayout.STANDARD,

                chance: 0.3,
                amount_min: 1,
                amount_max: 1,

                radius_min_scale: 0.05,
                radius_max_scale: 0.09,
                distance_min_scale: 0.16,
                distance_max_scale: 0.76,

                asteroid_min: 12,
                asteroid_max: 20,

                background_min_scale: 0.45,
                density: 0.65,
                spacing_scale: 1,

                rich_share_min: 0.58,
                rich_share_max: 0.72
            },
            {
                key: "asteroid_pocket_dense_optional",
                name: "DENSE POCKET",
                allocation: "additive",
                composition_mode: "parent",

                scale_required: AsteroidFieldScale.LARGE,
                density_required: -1,
                layout_required: AsteroidFieldLayout.STANDARD,

                chance: 0.7,
                amount_min: 2,
                amount_max: 4,

                radius_min_scale: 0.045,
                radius_max_scale: 0.08,
                distance_min_scale: 0.18,
                distance_max_scale: 0.75,

                asteroid_min: 18,
                asteroid_max: 30,

                background_min_scale: 0,
                density: 0.9,
                spacing_scale: 0.9,

                rich_share_min: 0,
                rich_share_max: 0
            },
            {
                key: "asteroid_pocket_archipelago",
                name: "ASTEROID ISLAND",
                allocation: "additive",
                composition_mode: "parent",

                scale_required: AsteroidFieldScale.LARGE,
                density_required: -1,
                layout_required: AsteroidFieldLayout.ARCHIPELAGO,

                chance: 1,
                amount_min: 5,
                amount_max: 9,

                radius_min_scale: 0.045,
                radius_max_scale: 0.085,
                distance_min_scale: 0.12,
                distance_max_scale: 0.82,

                asteroid_min: 18,
                asteroid_max: 30,

                background_min_scale: 0,
                density: 0.9,
                spacing_scale: 0.9,

                rich_share_min: 0,
                rich_share_max: 0
            }
        ]
    };
}

/// @description Initializes the reusable asteroid generator data.
function sc_asteroid_spawn_register_all()
{
    global.data.asteroid_spawn_generation =
        sc_asteroid_spawn_generation_data();

    return true;
}

/// @description Returns an axis entry selected using its normal weight.
function sc_asteroid_spawn_axis_choose(_entries)
{
    var _pool = [];

    for (var _i = 0; _i < array_length(_entries); ++_i)
        array_push(_pool, { index: _i, weight: _entries[_i].weight });

    return _entries[
        sc_asteroid_weighted_choose(_pool).index
    ];
}

/// @description Returns a density or layout using its scale-specific weight.
function sc_asteroid_spawn_scale_axis_choose(_entries, _scale)
{
    var _pool = [];

    for (var _i = 0; _i < array_length(_entries); ++_i)
    {
        var _weight = _entries[_i].weights[_scale];

        if (_weight > 0)
            array_push(_pool, { index: _i, weight: _weight });
    }

    return _entries[
        sc_asteroid_weighted_choose(_pool).index
    ];
}

/// @description Returns one registered subformation profile by string key.
function sc_asteroid_spawn_subformation_get(_key)
{
    var _subformations =
        global.data.asteroid_spawn_generation.subformations;

    for (var _i = 0; _i < array_length(_subformations); ++_i)
        if (_subformations[_i].key == _key)
            return _subformations[_i];

    return undefined;
}

/// @description Resolves one field radius using scale and room dimensions.
function sc_asteroid_spawn_radius_resolve(_scale_data)
{
    if (_scale_data.fixed_radius)
    {
        return random_range(
            _scale_data.radius_min,
            _scale_data.radius_max
        );
    }

    var _room_extent = min(room_width, room_height);

    return random_range(
        _room_extent * _scale_data.radius_min_scale,
        _room_extent * _scale_data.radius_max_scale
    );
}

/// @description Creates one complete randomized formation request.
function sc_asteroid_spawn_request_create()
{
    var _generation =
        global.data.asteroid_spawn_generation;

    var _config =
        global.config.sector.asteroid_fields;

    if (random(1) < _generation.lone_chance)
    {
        var _lone = _generation.lone;

        return {
            field: false,
            key: "asteroid_lone",
            name: "LONE ASTEROIDS",
            scale: AsteroidFieldScale.SMALL,
            density_type: AsteroidFieldDensity.SPARSE,
            layout: AsteroidFieldLayout.STANDARD,
            radius: random_range(
                _lone.radius_min,
                _lone.radius_max
            ),
            amount: irandom_range(
                _lone.amount_min,
                _lone.amount_max
            ),
            density: 0,
            spacing_scale: _lone.spacing_scale,

            distribution: {
                inner_radius_scale: 0,
                radial_power: 0.5,
                local_mode: "uniform"
            },

            shape: {
                aspect_min: 0.65,
                aspect_max: 1,
                irregularity_min: 0,
                irregularity_max: 0.08,
                lobes_min: 2,
                lobes_max: 3
            },

            subformation_keys: []
        };
    }

    var _scale_data = sc_asteroid_spawn_axis_choose(
        _generation.scales
    );

    var _density_data = sc_asteroid_spawn_scale_axis_choose(
        _generation.densities,
        _scale_data.scale
    );

    var _layout_data = sc_asteroid_spawn_scale_axis_choose(
        _generation.layouts,
        _scale_data.scale
    );

    var _radius = sc_asteroid_spawn_radius_resolve(
        _scale_data
    );

    var _amount = round(
        irandom_range(
            _scale_data.amount_min,
            _scale_data.amount_max
        )
        * _density_data.amount_multiplier
        * _layout_data.amount_multiplier
        * _config.population_multiplier
    );

    return {
        field: true,
        key: "asteroid_field",
        name: _scale_data.name
            + " "
            + _density_data.name
            + " "
            + _layout_data.name,

        scale: _scale_data.scale,
        density_type: _density_data.density,
        layout: _layout_data.layout,

        radius: _radius,
        amount: max(1, _amount),
        density: _density_data.navigation_density,
        spacing_scale: _density_data.spacing_scale,

        distribution: variable_clone(
            _layout_data.distribution
        ),

        shape: variable_clone(
            _layout_data.shape
        ),

        subformation_keys: variable_clone(
            _layout_data.subformation_keys
        )
    };
}

/// @description Creates one randomized organic shape.
function sc_asteroid_spawn_shape_create(
    _x,
    _y,
    _radius,
    _shape_data
)
{
    return {
        x: _x,
        y: _y,
        radius: _radius,
        aspect: random_range(
            _shape_data.aspect_min,
            _shape_data.aspect_max
        ),
        angle: random(360),
        irregularity: random_range(
            _shape_data.irregularity_min,
            _shape_data.irregularity_max
        ),
        lobes: irandom_range(
            _shape_data.lobes_min,
            _shape_data.lobes_max
        ),
        phase: random(360)
    };
}

/// @description Returns a randomized position within one organic distribution.
function sc_asteroid_spawn_shape_position_get(
    _shape,
    _distribution
)
{
    var _direction = random(360);
    var _wave = 1 + dsin(
        _direction * _shape.lobes
        + _shape.phase
    ) * _shape.irregularity;

    var _inner = clamp(
        _distribution.inner_radius_scale,
        0,
        0.98
    );

    var _normalized_distance = lerp(
        _inner,
        1,
        power(
            random(1),
            max(0.01, _distribution.radial_power)
        )
    );

    var _distance =
        _normalized_distance
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

/// @description Returns asteroid materials currently available at this sector depth.
function sc_asteroid_spawn_material_pool_get(_rich)
{
    var _source =
        global.config.sector.asteroid_fields.materials;

    var _sector_east = max(
        0,
        global.game.sector.x
    );

    var _pool = [];

    for (var _i = 0; _i < array_length(_source); ++_i)
    {
        var _material = _source[_i];

        if (_sector_east < _material.min_sector_east)
            continue;

        var _weight = _material.weight;

        if (_rich)
        {
            if (_sector_east
            < _material.rich_min_sector_east)
                continue;

            _weight = _material.rich_weight;
        }

        if (_weight <= 0)
            continue;

        array_push(_pool, {
            key: _material.key,
            weight: _weight
        });
    }

    return _pool;
}

/// @description Creates a material mixture dominated by one eligible ore.
function sc_asteroid_spawn_rich_composition_create(
    _composition,
    _share_min,
    _share_max
)
{
    var _rich_pool =
        sc_asteroid_spawn_material_pool_get(true);

    var _dominant =
        sc_asteroid_weighted_choose(_rich_pool);

    var _dominant_share = random_range(
        _share_min,
        _share_max
    );

    var _background_total = 0;

    for (var _i = 0;
    _i < array_length(_composition.materials);
    ++_i)
    {
        var _material = _composition.materials[_i];

        if (_material.key != _dominant.key)
            _background_total += _material.weight;
    }

    var _materials = [];

    for (var _i = 0;
    _i < array_length(_composition.materials);
    ++_i)
    {
        var _material = _composition.materials[_i];
        var _weight = _dominant_share;

        if (_material.key != _dominant.key)
        {
            _weight = _background_total > 0
                ? (_material.weight / _background_total)
                    * (1 - _dominant_share)
                : 0;
        }

        if (_weight > 0)
        {
            array_push(_materials, {
                key: _material.key,
                weight: _weight
            });
        }
    }

    return {
        dominant_key: _dominant.key,

        composition: {
            materials: _materials,
            sizes: _composition.sizes
        }
    };
}

/// @description Resolves optional composition against current sector availability.
function sc_asteroid_spawn_composition_resolve(_composition)
{
    var _config =
        global.config.sector.asteroid_fields;

    if (!is_struct(_composition))
    {
        return {
            materials:
                sc_asteroid_spawn_material_pool_get(false),
            sizes: _config.sizes
        };
    }

    return {
        materials: is_undefined(_composition.materials)
            ? sc_asteroid_spawn_material_pool_get(false)
            : _composition.materials,

        sizes: is_undefined(_composition.sizes)
            ? _config.sizes
            : _composition.sizes
    };
}

/// @description Spawns one asteroid population and returns its actual count.
function sc_asteroid_spawn_population(
    _shape,
    _distribution,
    _amount,
    _spacing_scale,
    _layer,
    _field_index,
    _zone_index,
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
        var _position = sc_asteroid_spawn_shape_position_get(
            _shape,
            _distribution
        );

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
                    field_index: _field_index,
                    zone_index: _zone_index
                }
            }
        );

        _spawned++;
    }

    return _spawned;
}

/// @description Rolls valid child formations before the parent population is created.
function sc_asteroid_spawn_subformation_plan_create(
    _request,
    _parent_amount,
    _parent_composition
)
{
    var _plans = [];
    var _reserved = 0;
    var _keys = _request.subformation_keys;

    for (var _key_index = 0;
    _key_index < array_length(_keys);
    ++_key_index)
    {
        var _profile = sc_asteroid_spawn_subformation_get(
            _keys[_key_index]
        );

        if (!is_struct(_profile)
        || _profile.scale_required != _request.scale
        || _profile.layout_required != _request.layout
        || (_profile.density_required >= 0
            && _profile.density_required
                != _request.density_type)
        || random(1) > _profile.chance)
            continue;

        var _formation_amount = irandom_range(
            _profile.amount_min,
            _profile.amount_max
        );

        for (var _i = 0;
        _i < _formation_amount;
        ++_i)
        {
            var _amount = irandom_range(
                _profile.asteroid_min,
                _profile.asteroid_max
            );

            if (_profile.allocation == "redistribute")
            {
                var _background_min = ceil(
                    _parent_amount
                    * _profile.background_min_scale
                );

                var _available = max(
                    0,
                    _parent_amount
                    - _background_min
                    - _reserved
                );

                _amount = min(_amount, _available);
                if (_amount <= 0) break;

                _reserved += _amount;
            }

            var _composition =
                _parent_composition;

            var _dominant_key = "";

            if (_profile.composition_mode == "rich")
            {
                var _rich =
                    sc_asteroid_spawn_rich_composition_create(
                        _parent_composition,
                        _profile.rich_share_min,
                        _profile.rich_share_max
                    );

                _composition =
                    _rich.composition;

                _dominant_key =
                    _rich.dominant_key;
            }

            array_push(_plans, {
                profile: _profile,
                amount: _amount,
                composition: _composition,
                dominant_key: _dominant_key
            });
        }
    }

    return {
        plans: _plans,
        reserved: _reserved
    };
}

/// @description Creates planned child formations and their density zones.
function sc_asteroid_spawn_subformations_create(
    _parent_shape,
    _request,
    _layer,
    _field_index,
    _zones,
    _plans,
    _asteroid_budget
)
{
    var _spawned = 0;

    for (var _plan_index = 0;
    _plan_index < array_length(_plans)
    && _spawned < _asteroid_budget;
    ++_plan_index)
    {
        var _plan = _plans[_plan_index];
        var _profile = _plan.profile;

        var _direction = random(360);

        var _distance = random_range(
            _parent_shape.radius
                * _profile.distance_min_scale,
            _parent_shape.radius
                * _profile.distance_max_scale
        );

        var _x = _parent_shape.x
            + lengthdir_x(
                _distance,
                _direction
            );

        var _y = _parent_shape.y
            + lengthdir_y(
                _distance
                    * _parent_shape.aspect,
                _direction
            );

        var _radius = random_range(
            _parent_shape.radius
                * _profile.radius_min_scale,
            _parent_shape.radius
                * _profile.radius_max_scale
        );

        var _shape = sc_asteroid_spawn_shape_create(
            _x,
            _y,
            _radius,
            {
                aspect_min: 0.72,
                aspect_max: 1,
                irregularity_min: 0.08,
                irregularity_max: 0.18,
                lobes_min: 3,
                lobes_max: 6
            }
        );

        var _distribution = {
            inner_radius_scale: 0,
            radial_power: 0.8,
            local_mode: "uniform"
        };

        var _zone_index =
            array_length(_zones);

        var _amount = min(
            _plan.amount,
            _asteroid_budget - _spawned
        );

        var _formation_spawned =
            sc_asteroid_spawn_population(
                _shape,
                _distribution,
                _amount,
                _profile.spacing_scale,
                _layer,
                _field_index,
                _zone_index,
                _plan.composition
            );

        if (_formation_spawned <= 0)
            continue;

        array_push(_zones, {
            key: _profile.key,
            name: _profile.name,
            allocation: _profile.allocation,
            composition_mode:
                _profile.composition_mode,
            dominant_key:
                _plan.dominant_key,

            shape: _shape,
            distribution: _distribution,
            density: _profile.density,

            initial_amount: _formation_spawned,
            remaining_amount: _formation_spawned
        });

        _spawned += _formation_spawned;
    }

    return {
        spawned: _spawned,
        zones: _zones
    };
}

/// @description Creates one complete resolved asteroid formation.
function sc_asteroid_spawn_create(
    _x,
    _y,
    _layer,
    _request,
    _field_index = -1,
    _composition_override = undefined,
    _asteroid_budget = 2147483647
)
{
    var _composition =
        sc_asteroid_spawn_composition_resolve(
            _composition_override
        );

    var _shape = sc_asteroid_spawn_shape_create(
        _x,
        _y,
        _request.radius,
        _request.shape
    );

    var _parent_amount = min(
        _request.amount,
        max(0, _asteroid_budget)
    );

    var _subformation_plan =
        sc_asteroid_spawn_subformation_plan_create(
            _request,
            _parent_amount,
            _composition
        );

    var _main_target = max(
        0,
        _parent_amount
        - _subformation_plan.reserved
    );

    var _zones = [];

    var _main_spawned =
        sc_asteroid_spawn_population(
            _shape,
            _request.distribution,
            _main_target,
            _request.spacing_scale,
            _layer,
            _field_index,
            _request.field ? 0 : -1,
            _composition
        );

    if (_request.field)
    {
        array_push(_zones, {
            key: "asteroid_field_parent",
            name: _request.name,
            allocation: "parent",
            composition_mode: "parent",
            dominant_key: "",

            shape: _shape,
            distribution: variable_clone(
                _request.distribution
            ),

            density:
                _request.layout
                    == AsteroidFieldLayout.ARCHIPELAGO
                ? _request.density * 0.15
                : _request.density,

            initial_amount: _main_spawned,
            remaining_amount: _main_spawned
        });
    }

    var _child_budget = max(
        0,
        _asteroid_budget
        - _main_spawned
    );

    var _subformations =
        sc_asteroid_spawn_subformations_create(
            _shape,
            _request,
            _layer,
            _field_index,
            _zones,
            _subformation_plan.plans,
            _child_budget
        );

    _zones = _subformations.zones;

    var _total_spawned =
        _main_spawned
        + _subformations.spawned;

    return {
        key: _request.key,
        name: _request.name,
        field: _request.field,

        scale: _request.scale,
        density_type: _request.density_type,
        layout: _request.layout,

        x: _x,
        y: _y,
        radius: _request.radius,
        density: _request.density,

        amount: _total_spawned,
        initial_amount: _total_spawned,
        remaining_amount: _total_spawned,

        shape: _shape,
        zones: _zones
    };
}