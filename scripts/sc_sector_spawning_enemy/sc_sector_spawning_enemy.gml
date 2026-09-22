/*
SECTOR ENEMY SPAWNING

Sector profiles choose which faction activity zones to place. Each zone
profile owns its enemy pool, population, size and placement rules.

Zones determine initial spawn locations. Enemies are free to leave their
zones afterward. Patrol behavior can be added separately later.
*/

#region PROFILES - STARTING SECTOR

/// @description Returns the starting sector's deliberately small Rebel zone.
function sc_sector_enemy_starting_profile_get()
{
    return {
        faction: Faction.REBEL,

        enemy_pool: [
            { key: "e_rebel_skirmisher", weight: 100 }
        ],

        assignment: {
            mode: "ZONE",
            return_after_combat: false
        },

        population_min: 3,
        population_max: 5,

        zone_radius_min: 6500,
        zone_radius_max: 8500,
        zone_edge_padding: 2400,
        zone_separation: 1500,
        starting_base_clearance: 8500,

        enemy_edge_padding: 900,
        enemy_obstacle_clearance: 240,
        enemy_separation: 900,

        zone_attempts: 80,
        enemy_attempts: 100
    };
}

#endregion

#region PROFILES - REBEL SECTORS

/// @description Returns a Rebel zone appropriate for the surrounding sectors.
function sc_sector_enemy_rebel_profile_get(_stage)
{
    var _profile = {
        faction: Faction.REBEL,

        enemy_pool: [
            { key: "e_rebel_skirmisher", weight: 80 },
            { key: "enemy_rebel_gunship", weight: 20 }
        ],

        assignment: {
            mode: "ROAM",
            return_after_combat: false
        },

        population_min: 3,
        population_max: 5,

        zone_radius_min: 4800,
        zone_radius_max: 6500,
        zone_edge_padding: 2400,
        zone_separation: 1500,
        starting_base_clearance: 8500,

        enemy_edge_padding: 900,
        enemy_obstacle_clearance: 240,
        enemy_separation: 900,

        zone_attempts: 80,
        enemy_attempts: 100
    };

    switch (_stage)
    {
        case "skirmishes":
            _profile.enemy_pool = [
                { key: "e_rebel_skirmisher", weight: 60 },
                { key: "enemy_rebel_gunship", weight: 30 },
                { key: "e_rebel_napalm_gunship", weight: 10 }
            ];
            _profile.population_min = 4;
            _profile.population_max = 6;
            break;

        case "territory":
            _profile.enemy_pool = [
                { key: "e_rebel_skirmisher", weight: 45 },
                { key: "enemy_rebel_gunship", weight: 35 },
                { key: "e_rebel_napalm_gunship", weight: 20 }
            ];
            _profile.assignment.mode = "ZONE";
            _profile.assignment.return_after_combat = true;
            _profile.population_min = 4;
            _profile.population_max = 7;
            break;
    }

    return _profile;
}

#endregion

#region PROFILES - SECTOR SELECTION

/// @description Chooses the activity-zone groups belonging to one sector.
function sc_sector_enemy_profile_get(_sector_x, _sector_y)
{
    if (_sector_x == 0 && _sector_y == 0)
    {
        return {
            key: "starting_sector",
            zones: [
                {
                    profile: sc_sector_enemy_starting_profile_get(),
                    amount_min: 1,
                    amount_max: 1
                }
            ]
        };
    }

    if ((_sector_x == 0 && abs(_sector_y) == 1)
    || (_sector_x == 1 && _sector_y == 0))
    {
        return {
            key: "rebel_outskirts",
            zones: [
                {
                    profile: sc_sector_enemy_rebel_profile_get("outskirts"),
                    amount_min: 1,
                    amount_max: 2
                }
            ]
        };
    }

    if (_sector_x == 1 && abs(_sector_y) == 1)
    {
        return {
            key: "rebel_skirmishes",
            zones: [
                {
                    profile: sc_sector_enemy_rebel_profile_get("skirmishes"),
                    amount_min: 2,
                    amount_max: 3
                }
            ]
        };
    }

    if (_sector_x == 2 && abs(_sector_y) <= 1)
    {
        return {
            key: "rebel_territory",
            zones: [
                {
                    profile: sc_sector_enemy_rebel_profile_get("territory"),
                    amount_min: 3,
                    amount_max: 4
                }
            ]
        };
    }

    return undefined;
}

#endregion

#region ZONE PLACEMENT

/// @description Returns the starting player-base structure when one exists.
function sc_sector_enemy_starting_base_get()
{
    var _count = instance_number(o_world_structure);

    for (var _i = 0; _i < _count; ++_i)
    {
        var _structure = instance_find(o_world_structure, _i);

        if (_structure.initialized
        && _structure.structure.key == "player_starting_base")
            return _structure;
    }

    return noone;
}

/// @description Selects one registered enemy key from a weighted profile pool.
function sc_sector_enemy_pool_roll(_pool)
{
    var _total = 0;

    for (var _i = 0; _i < array_length(_pool); ++_i)
        _total += max(0, _pool[_i].weight);

    if (_total <= 0)
        return "";

    var _roll = random(_total);

    for (var _i = 0; _i < array_length(_pool); ++_i)
    {
        _roll -= max(0, _pool[_i].weight);

        if (_roll < 0)
            return _pool[_i].key;
    }

    return _pool[array_length(_pool) - 1].key;
}

/// @description Checks room edges, the starting base and existing zones.
function sc_sector_enemy_zone_position_valid(_x, _y, _radius, _profile, _zones)
{
    var _padding = _radius + _profile.zone_edge_padding;

    if (_x < _padding || _x > room_width - _padding
    || _y < _padding || _y > room_height - _padding)
        return false;

    var _base = sc_sector_enemy_starting_base_get();

    if (instance_exists(_base))
    {
        var _required = _radius + _profile.starting_base_clearance;

        if (sc_point_distance_sq(_x, _y, _base.x, _base.y) < sqr(_required))
            return false;
    }

    for (var _i = 0; _i < array_length(_zones); ++_i)
    {
        var _other = _zones[_i];
        var _required = _radius + _other.radius + _profile.zone_separation;

        if (sc_point_distance_sq(_x, _y, _other.x, _other.y) < sqr(_required))
            return false;
    }

    return true;
}

/// @description Creates one circular faction activity zone.
function sc_sector_enemy_zone_create(_faction, _profile, _zones, _zone_id)
{
    var _radius = random_range(
        _profile.zone_radius_min,
        _profile.zone_radius_max
    );

    var _padding = _radius + _profile.zone_edge_padding;

    if (_padding * 2 >= room_width || _padding * 2 >= room_height)
        return undefined;

    for (var _attempt = 0; _attempt < _profile.zone_attempts; ++_attempt)
    {
        var _x = random_range(_padding, room_width - _padding);
        var _y = random_range(_padding, room_height - _padding);

        if (!sc_sector_enemy_zone_position_valid(
            _x,
            _y,
            _radius,
            _profile,
            _zones
        ))
            continue;

        return {
            id: _zone_id,
            faction: _faction,
            x: _x,
            y: _y,
            radius: _radius,

            population_requested: 0,
            population_spawned: 0,
            spawns: []
        };
    }

    return undefined;
}

#endregion

#region ENEMY PLACEMENT

/// @description Checks whether an enemy can spawn at one position.
function sc_sector_enemy_spawn_position_valid(_zone, _x, _y, _enemy_radius, _profile)
{
    var _edge = _enemy_radius + _profile.enemy_edge_padding;

    if (_x < _edge || _x > room_width - _edge
    || _y < _edge || _y > room_height - _edge)
        return false;

    var _base = sc_sector_enemy_starting_base_get();

    if (instance_exists(_base)
    && sc_point_distance_sq(_x, _y, _base.x, _base.y)
        < sqr(_profile.starting_base_clearance))
        return false;

    var _clearance = _enemy_radius + _profile.enemy_obstacle_clearance;

    if (collision_circle(
        _x,
        _y,
        _clearance,
        o_asteroid,
        false,
        true
    ) != noone)
        return false;

    if (collision_circle(
        _x,
        _y,
        _clearance,
        o_solid,
        false,
        true
    ) != noone)
        return false;

    for (var _i = 0; _i < array_length(_zone.spawns); ++_i)
    {
        var _spawn = _zone.spawns[_i];

        if (sc_point_distance_sq(_x, _y, _spawn.x, _spawn.y)
            < sqr(_profile.enemy_separation))
            return false;
    }

    return true;
}

/// @description Finds one clear position distributed throughout a faction zone.
function sc_sector_enemy_spawn_position_find(_zone, _enemy_radius, _profile)
{
    var _available_radius = max(0, _zone.radius - _enemy_radius);

    for (var _attempt = 0; _attempt < _profile.enemy_attempts; ++_attempt)
    {
        // Square-root distance prevents positions bunching around the centre.
        var _distance = sqrt(random(1)) * _available_radius;
        var _direction = random(360);
        var _x = _zone.x + lengthdir_x(_distance, _direction);
        var _y = _zone.y + lengthdir_y(_distance, _direction);

        if (sc_sector_enemy_spawn_position_valid(
            _zone,
            _x,
            _y,
            _enemy_radius,
            _profile
        ))
        {
            return {
                found: true,
                x: _x,
                y: _y
            };
        }
    }

    return {
        found: false,
        x: _zone.x,
        y: _zone.y
    };
}

/// @description Populates one faction zone with assigned persistent enemies.
function sc_sector_enemy_zone_population_spawn(_zone, _amount, _profile)
{
    _zone.population_requested = _amount;

    for (var _i = 0; _i < _amount; ++_i)
    {
        var _enemy_key = sc_sector_enemy_pool_roll(_profile.enemy_pool);

        if (_enemy_key == ""
        || !variable_struct_exists(global.data.enemies, _enemy_key))
            continue;

        var _definition = variable_struct_get(global.data.enemies, _enemy_key);

        var _enemy_radius = max(
            _definition.visual.radius
                * _definition.collision.radius_forward_scale,
            _definition.visual.radius
                * _definition.collision.radius_side_scale
        );

        var _position = sc_sector_enemy_spawn_position_find(
            _zone,
            _enemy_radius,
            _profile
        );

        if (!_position.found)
            continue;

        var _persistent_id =
            "zone_"
            + string(_zone.id)
            + "_enemy_"
            + string(_i);

        var _assignment = sc_enemy_assignment_roam_create();

        if (_profile.assignment.mode == "ZONE")
        {
            _assignment = sc_enemy_assignment_zone_create(
                _zone,
                _profile.assignment.return_after_combat
            );
        }

        var _enemy = instance_create_layer(
            _position.x,
            _position.y,
            "Enemy",
            o_enemy,
            {
                enemy_key: _enemy_key,
                enemy_persistent_id: _persistent_id,
                enemy_spawn_assignment: _assignment
            }
        );

        if (!instance_exists(_enemy))
            continue;

        array_push(_zone.spawns, {
            enemy_id: _enemy,
            enemy_key: _enemy_key,
            persistent_id: _persistent_id,
            x: _position.x,
            y: _position.y
        });

        _zone.population_spawned++;
    }

    return _zone.population_spawned;
}

#endregion

#region SECTOR GENERATION

/// @description Generates the current sector's faction activity zones and enemies.
function sc_sector_enemy_spawning_generate()
{
    var _sector = global.game.sector;
    _sector.enemy_spawn_zones = [];

    if (!GCFG.sector.enemy_spawning.enabled)
        return 0;

    var _sector_profile = sc_sector_enemy_profile_get(_sector.x, _sector.y);

    if (!is_struct(_sector_profile))
        return 0;

    var _total_spawned = 0;
    var _zone_id = 0;

    for (var _group_index = 0;
        _group_index < array_length(_sector_profile.zones);
        ++_group_index)
    {
        var _group = _sector_profile.zones[_group_index];
        var _profile = _group.profile;

        var _zone_count = _group.amount_min;

        if (_group.amount_max > _group.amount_min)
            _zone_count = irandom_range(_group.amount_min, _group.amount_max);

        for (var _zone_index = 0; _zone_index < _zone_count; ++_zone_index)
        {
            var _zone = sc_sector_enemy_zone_create(
                _profile.faction,
                _profile,
                _sector.enemy_spawn_zones,
                _zone_id
            );

            if (!is_struct(_zone))
            {
                show_debug_message(
                    "SECTOR ENEMY SPAWNING - FAILED TO PLACE ZONE "
                    + string(_zone_id)
                );

                _zone_id++;
                continue;
            }

            var _amount = irandom_range(
                _profile.population_min,
                _profile.population_max
            );

            _total_spawned += sc_sector_enemy_zone_population_spawn(
                _zone,
                _amount,
                _profile
            );

            array_push(_sector.enemy_spawn_zones, _zone);

            show_debug_message(
                "SECTOR ENEMY SPAWNING - "
                + _sector_profile.key
                + " // ZONE "
                + string(_zone.id)
                + " // "
                + string(_zone.population_spawned)
                + " / "
                + string(_zone.population_requested)
                + " ENEMIES"
            );

            _zone_id++;
        }
    }

    return _total_spawned;
}

/// @description Generates deterministic enemies without altering other sector generators.
function sc_sector_enemy_spawning_generate_seeded(_sector_seed)
{
    var _previous_seed = random_get_seed();
    var _enemy_seed = abs(
        (_sector_seed + 104729) mod 2147483647
    );

    random_set_seed(max(1, _enemy_seed));

    var _spawned = sc_sector_enemy_spawning_generate();

    random_set_seed(_previous_seed);
    return _spawned;
}

#endregion

#region DEBUG SECTOR MAP

/// @description Draws one faction activity zone on the full-sector debug map.
function sc_hud_sector_map_enemy_zone_draw(_layout, _zone)
{
    var _palette = sc_faction_palette_get(_zone.faction);
    var _faction = global.data.factions[_zone.faction];
    var _centre = sc_hud_sector_map_position_get(
        _layout,
        _zone.x,
        _zone.y
    );

    var _radius = _zone.radius * _layout.scale;
    var _segments = 64;

    draw_primitive_begin(pr_trianglefan);

    draw_vertex_colour(
        _centre.x,
        _centre.y,
        _palette.accent,
        0.09
    );

    for (var _i = 0; _i <= _segments; ++_i)
    {
        var _direction = _i / _segments * 360;

        draw_vertex_colour(
            _centre.x + lengthdir_x(_radius, _direction),
            _centre.y + lengthdir_y(_radius, _direction),
            _palette.accent,
            0.015
        );
    }

    draw_primitive_end();

    draw_set_colour(_palette.accent);
    draw_set_alpha(0.7);

    var _previous_x = _centre.x + _radius;
    var _previous_y = _centre.y;

    for (var _i = 1; _i <= _segments; ++_i)
    {
        var _direction = _i / _segments * 360;
        var _x = _centre.x + lengthdir_x(_radius, _direction);
        var _y = _centre.y + lengthdir_y(_radius, _direction);

        draw_line(_previous_x, _previous_y, _x, _y);

        _previous_x = _x;
        _previous_y = _y;
    }

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_colour(_palette.core);
    draw_set_alpha(0.9);

    draw_text(
        _centre.x,
        _centre.y,
        string_upper(_faction.identity.name)
        + " ACTIVITY ZONE\n"
        + string(_zone.population_spawned)
        + " SPAWNED"
    );
}

/// @description Draws every generated faction activity zone on the debug map.
function sc_hud_sector_map_enemy_zones_draw(_layout)
{
    if (!GCFG.sector.enemy_spawning.enabled
    || !sc_sector_campaign_active())
        return;

    var _sector = global.game.sector;

    if (!variable_struct_exists(_sector, "enemy_spawn_zones"))
        return;

    var _zones = _sector.enemy_spawn_zones;

    for (var _i = 0; _i < array_length(_zones); ++_i)
        sc_hud_sector_map_enemy_zone_draw(_layout, _zones[_i]);

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

#endregion