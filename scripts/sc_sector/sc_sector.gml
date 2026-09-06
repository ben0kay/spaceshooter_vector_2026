/// @description Initializes a new temporary campaign at the central sector.
function sc_sector_campaign_begin()
{
    global.game.sector = {
        active: true,
        x: 0,
        y: 0,
        entry_side: "centre",
        entry_axis: 0.5,
        transitioning: false
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

/// @description Creates one deterministic seed from the current sector coordinates.
function sc_sector_seed_get(_sector_x, _sector_y)
{
    var _seed = global.config.sector.world_seed;
    _seed += _sector_x * 73856093;
    _seed += _sector_y * 19349663;
    _seed += _sector_x * _sector_y * 83492791;
    _seed = abs(_seed mod 2147483647);

    return max(1, floor(_seed));
}

/// @description Returns whether a proposed field centre is sufficiently separated.
function sc_sector_field_centre_valid(_centres, _x, _y, _separation)
{
    for (var _i = 0; _i < array_length(_centres); _i++)
    {
        var _centre = _centres[_i];

        if (point_distance(_x, _y, _centre.x, _centre.y) < _separation)
            return false;
    }

    return true;
}

/// @description Generates several separated asteroid clusters throughout the sector.
function sc_sector_asteroid_fields_spawn(_layer)
{
    var _config = global.config.sector.asteroid_fields;
    var _field_amount = irandom_range(
        _config.amount_min,
        _config.amount_max
    );

    var _centres = [];
    var _attempts = 0;

    while (array_length(_centres) < _field_amount
    && _attempts < _field_amount * 40)
    {
        _attempts++;

        var _x = random_range(
            _config.centre_padding,
            room_width - _config.centre_padding
        );

        var _y = random_range(
            _config.centre_padding,
            room_height - _config.centre_padding
        );

        if (point_distance(
            _x, _y,
            room_width * 0.5,
            room_height * 0.5
        ) < _config.spawn_clear_radius)
            continue;

        if (!sc_sector_field_centre_valid(
            _centres,
            _x,
            _y,
            _config.centre_separation
        ))
            continue;

        var _radius = random_range(
            _config.radius_min,
            _config.radius_max
        );

        var _amount = irandom_range(
            _config.asteroids_min,
            _config.asteroids_max
        );

        array_push(_centres, {
            x: _x,
            y: _y,
            radius: _radius,
            amount: _amount
        });

        sc_asteroid_test_field_spawn(
            _x,
            _y,
            _radius,
            _amount,
            _layer
        );
    }

    return array_length(_centres);
}

/// @description Generates the visible asteroid line along one outer world edge.
function sc_sector_boundary_spawn(_top, _layer)
{
    var _config = global.config.sector.boundary;
    var _y = _top
        ? _config.centre_y
        : room_height - _config.centre_y;

    var _cluster_count = ceil(room_width / _config.spacing);

    for (var _i = 0; _i <= _cluster_count; _i++)
    {
        var _x = min(
            room_width - 200,
            max(200, _i * _config.spacing)
        );

        _x += random_range(
            -_config.spacing * 0.18,
            _config.spacing * 0.18
        );

        sc_asteroid_test_field_spawn(
            _x,
            _y,
            _config.radius,
            _config.asteroids_per_cluster,
            _layer
        );
    }
}

/// @description Places a carried player at the correct sector entrance.
function sc_sector_player_entry_apply(_player)
{
    var _sector = global.game.sector;
    var _padding = global.config.sector.edge_spawn_padding;
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

/// @description Generates the active sector and restores any carried player.
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

    random_set_seed(_sector_seed);

    sc_sector_asteroid_fields_spawn(_layer);

    if (_sector.y == -1)
        sc_sector_boundary_spawn(true, _layer);
    else if (_sector.y == 1)
        sc_sector_boundary_spawn(false, _layer);

    random_set_seed(_previous_seed);

    if (instance_exists(global.player_id))
        sc_sector_player_entry_apply(global.player_id);

    show_debug_message(
        "SECTOR GENERATED - "
        + string(_sector.x) + ", "
        + string(_sector.y)
        + " - SEED " + string(_sector_seed)
    );

    return true;
}

/// @description Moves the campaign into one adjacent sector.
function sc_sector_transition(_direction)
{
    if (!sc_sector_campaign_active()
    || !instance_exists(global.player_id))
        return false;

    var _sector = global.game.sector;
    var _player = global.player_id;
    if (_sector.transitioning) return false;

    switch (_direction)
    {
        case "east":
            _sector.x++;
            _sector.entry_side = "west";
            _sector.entry_axis = _player.y / room_height;
        break;

        case "west":
            if (_sector.x <= 0) return false;

            _sector.x--;
            _sector.entry_side = "east";
            _sector.entry_axis = _player.y / room_height;
        break;

        case "north":
            if (_sector.y <= -1) return false;

            _sector.y--;
            _sector.entry_side = "south";
            _sector.entry_axis = _player.x / room_width;
        break;

        case "south":
            if (_sector.y >= 1) return false;

            _sector.y++;
            _sector.entry_side = "north";
            _sector.entry_axis = _player.x / room_width;
        break;

        default:
            return false;
    }

    _sector.entry_axis = clamp(_sector.entry_axis, 0.05, 0.95);
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