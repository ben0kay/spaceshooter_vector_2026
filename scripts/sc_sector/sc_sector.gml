/// @description Initializes a new temporary campaign at the central sector.
function sc_sector_campaign_begin()
{
    global.game.sector = {
        active: true,
        x: 0,
        y: 0,
        entry_side: "centre",
        entry_axis: 0.5,
        transitioning: false,
		debug_seed_offset: 0,
    };

    return true;
}

/// @description Returns whether the active room belongs to the sector campaign.
function sc_sector_campaign_active()
{
    return room == r_sector
        && variable_struct_exists(global.game, "sector")
        && is_struct(global.game.sector)
        && global.game.sector.active;
}

/// @description Creates one deterministic seed from sector coordinates and debug offset.
function sc_sector_seed_get(_sector_x, _sector_y)
{
    var _seed = GCFG.sector.world_seed;
    _seed += _sector_x * 73856093;
    _seed += _sector_y * 19349663;
    _seed += _sector_x * _sector_y * 83492791;

    if (variable_struct_exists(global.game.sector, "debug_seed_offset"))
        _seed += global.game.sector.debug_seed_offset * 2654435761;

    _seed = abs(_seed mod 2147483647);
    return max(1, floor(_seed));
}

/// @description Returns whether a proposed formation is separated from existing formations.
function sc_sector_field_centre_valid(
    _centres,
    _x,
    _y,
    _radius,
    _separation
)
{
    for (var _i = 0; _i < array_length(_centres); ++_i)
    {
        var _centre = _centres[_i];
        var _required = max(
            _separation,
            (_centre.radius + _radius) * 0.55
        );

        if (sc_point_distance_sq(
            _x,
            _y,
            _centre.x,
            _centre.y
        ) < sqr(_required))
            return false;
    }

    return true;
}

/// @description Keeps generated asteroid formations clear of the starting base.
function sc_sector_field_structure_clear(_x, _y, _radius)
{
    var _clearance =
        GCFG.sector.asteroid_fields.structure_clearance;

    var _count = instance_number(o_world_structure);

    for (var _i = 0; _i < _count; ++_i)
    {
        var _structure = instance_find(o_world_structure, _i);
        if (!instance_exists(_structure) || !_structure.initialized) continue;
        if (_structure.structure.key != "player_starting_base") continue;

        var _broad_radius =
            _structure.structure.data.collision.broad_radius;

        if (sc_point_distance_sq(
            _x,
            _y,
            _structure.x,
            _structure.y
        ) < sqr(_radius + _broad_radius + _clearance))
            return false;
    }

    return true;
}

/// @description Generates varied asteroid formations within count and instance budgets.
function sc_sector_asteroid_fields_spawn(_layer)
{
    var _sector = global.game.sector;
    var _config = GCFG.sector.asteroid_fields;

    var _formation_limit = irandom_range(
        _config.amount_min,
        _config.amount_max
    );

    var _asteroid_budget = irandom_range(
        _config.budget_min,
        _config.budget_max
    );

    var _fields = [];
    var _centres = [];
    var _formations_spawned = 0;
    var _asteroids_spawned = 0;
    var _attempts = 0;
    var _attempts_max = _formation_limit * 80;

    while (_formations_spawned < _formation_limit
    && _asteroids_spawned < _asteroid_budget
    && _attempts < _attempts_max)
    {
        _attempts++;

        var _request =
            sc_asteroid_spawn_request_create();

        var _radius = _request.radius;

        var _padding = max(
            _config.centre_padding,
            _radius + 320
        );

        if (_padding * 2 >= room_width
        || _padding * 2 >= room_height)
            continue;

        var _x = random_range(
            _padding,
            room_width - _padding
        );

        var _y = random_range(
            _padding,
            room_height - _padding
        );

        if (sc_point_distance_sq(
            _x,
            _y,
            room_width * 0.5,
            room_height * 0.5
        ) < sqr(_config.spawn_clear_radius))
            continue;

        if (!sc_sector_field_structure_clear(
            _x,
            _y,
            _radius
        ))
            continue;

        if (!sc_sector_field_centre_valid(
            _centres,
            _x,
            _y,
            _radius,
            _config.centre_separation
        ))
            continue;

        var _field_index = _request.field
            ? array_length(_fields)
            : -1;

        var _remaining_budget =
            _asteroid_budget
            - _asteroids_spawned;

        var _spawn = sc_asteroid_spawn_create(
            _x,
            _y,
            _layer,
            _request,
            _field_index,
            undefined,
            _remaining_budget
        );

        if (_spawn.amount <= 0)
            continue;

        array_push(_centres, {
            x: _x,
            y: _y,
            radius: _radius
        });

        if (_spawn.field)
            array_push(_fields, _spawn);

        _asteroids_spawned += _spawn.amount;
        _formations_spawned++;
    }

    _sector.asteroid_fields = _fields;

    show_debug_message(
        "ASTEROID GENERATION - "
        + string(_formations_spawned)
        + " FORMATIONS // "
        + string(_asteroids_spawned)
        + " ASTEROIDS // BUDGET "
        + string(_asteroid_budget)
    );

    return array_length(_fields);
}

/// @description Returns normalized distance from an organic shape centre.
function sc_sector_asteroid_shape_distance_get(_shape, _x, _y)
{
    var _distance = point_distance(
        _shape.x,
        _shape.y,
        _x,
        _y
    );

    var _direction = point_direction(
        _shape.x,
        _shape.y,
        _x,
        _y
    );

    var _local_direction = _direction - _shape.angle;
    var _wave = 1 + dsin(
        _local_direction * _shape.lobes
        + _shape.phase
    ) * _shape.irregularity;

    var _forward = lengthdir_x(
        _distance,
        _local_direction
    );

    var _side = lengthdir_y(
        _distance,
        _local_direction
    ) / max(0.01, _shape.aspect);

    return sqrt(
        _forward * _forward
        + _side * _side
    ) / max(1, _shape.radius * _wave);
}

/// @description Returns whether a position is inside one organic shape.
function sc_sector_asteroid_shape_contains(_shape, _x, _y)
{
    return sc_sector_asteroid_shape_distance_get(
        _shape,
        _x,
        _y
    ) <= 1;
}

/// @description Returns the asteroid field containing one world position.
function sc_sector_asteroid_field_index_at(_x, _y)
{
    if (!sc_sector_campaign_active()) return -1;

    var _fields = global.game.sector.asteroid_fields;

    for (var _i = 0; _i < array_length(_fields); ++_i)
    {
        var _field = _fields[_i];

        // Completely cleared fields no longer influence gameplay.
        if (_field.remaining_amount <= 0)
            continue;

        if (sc_sector_asteroid_shape_contains(
            _field.shape,
            _x,
            _y
        ))
            return _i;
    }

    return -1;
}

/// @description Returns one zone's depleted local navigation density.
function sc_sector_asteroid_zone_density_get(_zone, _x, _y)
{
    if (_zone.initial_amount <= 0 || _zone.remaining_amount <= 0) return 0;

    var _normalized = sc_sector_asteroid_shape_distance_get(_zone.shape, _x, _y);
    if (_normalized > 1) return 0;

    var _distribution = _zone.distribution;
    var _local_density = _zone.density;

    switch (_distribution.distribution)
    {
        case AsteroidFieldDistribution.EDGE_HEAVY:
        {
            var _inner = clamp(_distribution.inner_radius_scale, 0, 0.98);
            if (_normalized < _inner) return 0;
        }
        break;

        case AsteroidFieldDistribution.DENSE_CORE:
        {
            var _core_strength = power(1 - clamp(_normalized, 0, 1), 0.7);
            _local_density = lerp(_zone.density * 0.25, _zone.density, _core_strength);
        }
        break;
    }

    var _remaining_ratio = clamp(_zone.remaining_amount / _zone.initial_amount, 0, 1);
    var _depletion_power = GCFG.sector.asteroid_fields.density_depletion_power;

    return clamp(_local_density * power(_remaining_ratio, _depletion_power), 0, 1);
}

/// @description Returns effective asteroid density at one world position.
function sc_sector_asteroid_field_density_at(
    _x,
    _y,
    _field_index = -1
)
{
    if (!sc_sector_campaign_active()) return 0;

    if (_field_index < 0)
    {
        _field_index = sc_sector_asteroid_field_index_at(
            _x,
            _y
        );
    }

    var _fields = global.game.sector.asteroid_fields;

    if (_field_index < 0
    || _field_index >= array_length(_fields))
        return 0;

    var _field = _fields[_field_index];
    var _zones = _field.zones;
    var _density = 0;

    for (var _i = 0; _i < array_length(_zones); ++_i)
    {
        _density = max(
            _density,
            sc_sector_asteroid_zone_density_get(
                _zones[_i],
                _x,
                _y
            )
        );
    }

    return clamp(_density, 0, 1);
}

/// @description Removes one destroyed asteroid from its field and density zone.
function sc_sector_asteroid_field_population_remove(_asteroid)
{
    if (!sc_sector_campaign_active()
    || !instance_exists(_asteroid))
        return false;

    var _asteroid_data = _asteroid.asteroid;
    var _field_index = _asteroid_data.field_index;
    var _zone_index = _asteroid_data.zone_index;
    var _fields = global.game.sector.asteroid_fields;

    if (_field_index < 0
    || _field_index >= array_length(_fields))
        return false;

    var _field = _fields[_field_index];

    _field.remaining_amount = max(
        0,
        _field.remaining_amount - 1
    );

    if (_zone_index >= 0
    && _zone_index < array_length(_field.zones))
    {
        var _zone = _field.zones[_zone_index];

        _zone.remaining_amount = max(
            0,
            _zone.remaining_amount - 1
        );
    }

    // Prevent accidental double removal.
    _asteroid_data.field_index = -1;
    _asteroid_data.zone_index = -1;

    return true;
}

/// @description Places a carried player at the correct sector entrance.
function sc_sector_player_entry_apply(_player)
{
    var _sector = global.game.sector;
    var _padding = GCFG.sector.edge_spawn_padding;
    var _extent = max(
        _player.ship.collision.radius_forward,
        _player.ship.collision.radius_side
    );

    switch (_sector.entry_side)
    {
        case "west":
            _player.x = _padding;
            _player.y = clamp(
                _sector.entry_axis * room_height,
                _padding,
                room_height - _padding
            );
        break;

        case "east":
            _player.x = room_width - _padding;
            _player.y = clamp(
                _sector.entry_axis * room_height,
                _padding,
                room_height - _padding
            );
        break;

        case "north":
            _player.x = clamp(
                _sector.entry_axis * room_width,
                _padding,
                room_width - _padding
            );
            _player.y = _padding;
        break;

        case "south":
            _player.x = clamp(
                _sector.entry_axis * room_width,
                _padding,
                room_width - _padding
            );
            _player.y = room_height - _padding;
        break;

        default:
            _player.x = room_width * 0.5;
            _player.y = room_height * 0.5;
        break;
    }

    _player.x = clamp(_player.x, _extent, room_width - _extent);
    _player.y = clamp(_player.y, _extent, room_height - _extent);

    _player.movement.velocity_x = 0;
    _player.movement.velocity_y = 0;
    _player.movement.speed = 0;
    _player.movement.safe_x = _player.x;
    _player.movement.safe_y = _player.y;

    _sector.entry_side = "none";
    _sector.transitioning = false;
}

/// @description Spawns permanent authored content belonging to one sector.
function sc_sector_structures_spawn(_layer)
{
    var _sector = global.game.sector;
    if (_sector.x != 0 || _sector.y != 0) return 0;

    var _base = instance_create_layer(
        1500,
        room_height * 0.5,
        _layer,
        o_world_structure,
        {
            structure_create: {
                key: "player_starting_base",
                angle: 0,
                collision_layer: _layer
            }
        }
    );

    var _derelict = instance_create_layer(
        4400,
        room_height * 0.5 + 850,
        _layer,
        o_derelict,
        {
            structure_create: {
                key: "derelict_test",
                angle: 18,
                collision_layer: _layer
            }
        }
    );

    return instance_exists(_base) && instance_exists(_derelict);
}

/// @description Generates the active sector, restores persistent changes and places the carried player.
function sc_sector_room_create()
{
    if (!sc_sector_campaign_active())
    {
        show_debug_message("SECTOR ERROR - campaign runtime unavailable");
        return false;
    }

    var _sector = global.game.sector;
    var _previous_seed = random_get_seed();
    var _sector_seed = sc_sector_seed_get(_sector.x, _sector.y);
    var _layer = layer_get_id("Instances");

    sc_sector_persistence_prepare(_sector_seed);
    random_set_seed(_sector_seed);

    // Static structures generate before fields so asteroid placement avoids them.
    sc_sector_structures_spawn(_layer);
    sc_sector_asteroid_fields_spawn(_layer);

    // Apply saved asteroid destruction only after the complete deterministic
    // baseline exists, otherwise removed asteroids would alter later placement.
    sc_sector_persistence_restore();

    sc_gas_cloud_sector_spawn(
        _layer,
        _sector_seed
    );

    random_set_seed(_previous_seed);

    if (instance_exists(global.player_id))
        sc_sector_player_entry_apply(global.player_id);

    show_debug_message(
        "SECTOR GENERATED - "
        + string(_sector.x)
        + ", "
        + string(_sector.y)
        + " // SEED "
        + string(_sector_seed)
        + " // VISIT "
        + string(_sector.persistence.state.visit_count)
    );

    return true;
}

/// @description Saves the current sector and moves the campaign into one adjacent sector.
function sc_sector_transition(_direction)
{
    if (!sc_sector_campaign_active()
    || !instance_exists(global.player_id))
        return false;

    var _sector = global.game.sector;
    var _player = global.player_id;
    if (_sector.transitioning) return false;

    var _next_x = _sector.x;
    var _next_y = _sector.y;
    var _entry_side = "";
    var _entry_axis = 0.5;

    switch (_direction)
    {
        case "east":
            _next_x++;
            _entry_side = "west";
            _entry_axis = _player.y / room_height;
        break;

        case "west":
            if (_next_x <= 0) return false;

            _next_x--;
            _entry_side = "east";
            _entry_axis = _player.y / room_height;
        break;

        case "north":
            if (_next_y <= -1) return false;

            _next_y--;
            _entry_side = "south";
            _entry_axis = _player.x / room_width;
        break;

        case "south":
            if (_next_y >= 1) return false;

            _next_y++;
            _entry_side = "north";
            _entry_axis = _player.x / room_width;
        break;

        default:
            return false;
    }

    // Capture under the current coordinates before changing sectors.
    if (!sc_sector_persistence_capture())
    {
        show_debug_message("SECTOR TRANSITION ERROR - persistence capture failed");
        return false;
    }

    if (!sc_profile_save())
    {
        show_debug_message("SECTOR TRANSITION ERROR - profile save failed");
        return false;
    }

    _sector.x = _next_x;
    _sector.y = _next_y;
    _sector.entry_side = _entry_side;
    _sector.entry_axis = clamp(_entry_axis, 0.05, 0.95);
    _sector.transitioning = true;

    sc_player_continuous_weapons_release(_player);
    _player.persistent = true;

    global.PlayerState = PlayerState.INITIALIZING;
    global.LevelState = LevelState.EXITING;

    room_restart();
    return true;
}

/// @description Detects intentional player movement against an available sector edge.
function sc_sector_transition_update()
{
    if (!sc_sector_campaign_active()
    || global.LevelState != LevelState.PLAYING
    || global.PlayerState != PlayerState.ACTIVE
    || !instance_exists(global.player_id))
        return false;

    var _sector = global.game.sector;
    var _player = global.player_id;
    var _movement = _player.movement;
    var _extent = max(
        _player.ship.collision.radius_forward,
        _player.ship.collision.radius_side
    );

    if (_player.x >= room_width - _extent - 1
    && _movement.input_x > 0)
        return sc_sector_transition("east");

    if (_player.x <= _extent + 1
    && _movement.input_x < 0)
        return sc_sector_transition("west");

    if (_player.y <= _extent + 1
    && _movement.input_y < 0)
        return sc_sector_transition("north");

    if (_player.y >= room_height - _extent - 1
    && _movement.input_y > 0)
        return sc_sector_transition("south");

    return false;
}