/*
ENEMY TERRITORY

Optional territory constraints for enemies tied to asteroid regions, fixed
sector locations or moving anchor instances.

Enemies without territory_controller never create territory runtime data and
immediately skip all territory processing.

FUTURE SPAWN PIPELINE

Simulant Wisps should enter a sector's eligible enemy pool only when asteroid
generation produced a surviving dense field or dense subregion.

Future generation order:
1. Generate sector geometry.
2. Generate asteroid fields and subregions.
3. Build the eligible enemy pool from those sector features.
4. Exclude Wisps when no dense asteroid region exists.
5. Spawn Wisps inside and pre-bind them to the selected region.

The current F1 debug spawner bypasses those rules. Therefore debug-spawned
Wisps locate and bind their own nearest dense region.
*/

/// @description Initializes optional territory data for one specialized enemy.
function sc_enemy_territory_init(_enemy, _definition)
{
    if (!variable_struct_exists(_definition, "territory_controller"))
        return true;

    _enemy.enemy.territory_controller =
        variable_clone(_definition.territory_controller);

    _enemy.enemy.territory = {
        bound: false,
        type: EnemyTerritoryType.NONE,

        field_index: -1,
        zone_index: -1,

        centre_x: _enemy.x,
        centre_y: _enemy.y,
        radius: 0,
        anchor_id: noone,

        returning: false,
        fallback: EnemyTerritoryFallback.NONE,

        next_check_tick: GAME_TICK,
        next_search_tick: GAME_TICK
    };

    sc_enemy_territory_resolve(_enemy);
    return true;
}

/// @description Returns whether one cached asteroid territory still exists.
function sc_enemy_territory_asteroid_region_valid(_enemy)
{
    if (!sc_sector_campaign_active())
        return false;

    var _territory = _enemy.enemy.territory;
    var _fields = global.game.sector.asteroid_fields;

    if (_territory.field_index < 0
    || _territory.field_index >= array_length(_fields))
        return false;

    var _zones = _fields[_territory.field_index].zones;

    if (_territory.zone_index < 0
    || _territory.zone_index >= array_length(_zones))
        return false;

    return _zones[_territory.zone_index].remaining_amount > 0;
}

/// @description Returns the asteroid shape currently assigned to an enemy.
function sc_enemy_territory_asteroid_shape_get(_enemy)
{
    var _territory = _enemy.enemy.territory;
    var _field = global.game.sector.asteroid_fields[
        _territory.field_index
    ];

    return _field.zones[_territory.zone_index].shape;
}

/// @description Binds an enemy to one generated asteroid zone.
function sc_enemy_territory_asteroid_bind(
    _enemy,
    _field_index,
    _zone_index
)
{
    var _territory = _enemy.enemy.territory;
    var _zone = global.game.sector
        .asteroid_fields[_field_index]
        .zones[_zone_index];

    _territory.bound = true;
    _territory.type = EnemyTerritoryType.ASTEROID_REGION;
    _territory.field_index = _field_index;
    _territory.zone_index = _zone_index;

    _territory.centre_x = _zone.shape.x;
    _territory.centre_y = _zone.shape.y;
    _territory.radius = _zone.shape.radius;
    _territory.anchor_id = noone;

    _territory.returning =
        !sc_sector_asteroid_shape_contains(
            _zone.shape,
            _enemy.x,
            _enemy.y
        );

    _territory.fallback = EnemyTerritoryFallback.NONE;
    return true;
}

/// @description Finds and binds the nearest surviving asteroid zone dense enough for this enemy.
function sc_enemy_territory_dense_region_find(_enemy)
{
    if (!sc_sector_campaign_active())
        return false;

    var _controller = _enemy.enemy.territory_controller;
    var _fields = global.game.sector.asteroid_fields;
    var _selected_field = -1;
    var _selected_zone = -1;
    var _selected_score = infinity;

    for (var _field_index = 0; _field_index < array_length(_fields); _field_index++)
    {
        var _field = _fields[_field_index];
        var _zones = _field.zones;

        for (var _zone_index = 0; _zone_index < array_length(_zones); _zone_index++)
        {
            var _zone = _zones[_zone_index];

            if (_zone.remaining_amount <= 0
            || _zone.density < _controller.required_density_min)
                continue;

            var _inside = sc_sector_asteroid_shape_contains(
                _zone.shape,
                _enemy.x,
                _enemy.y
            );

            var _distance_sq = sc_point_distance_sq(
                _enemy.x,
                _enemy.y,
                _zone.shape.x,
                _zone.shape.y
            );

            var _score = _inside
                ? -1
                : _distance_sq;

            if (_score >= _selected_score)
                continue;

            _selected_score = _score;
            _selected_field = _field_index;
            _selected_zone = _zone_index;
        }
    }

    if (_selected_field < 0)
        return false;

    return sc_enemy_territory_asteroid_bind(
        _enemy,
        _selected_field,
        _selected_zone
    );
}

/// @description Finds the largest and then nearest suitable allied anchor.
function sc_enemy_territory_ally_anchor_find(_enemy)
{
    var _data = _enemy.enemy;
    var _controller = _data.territory_controller;
    var _selected = noone;
    var _selected_class = -1;
    var _selected_distance_sq = infinity;
    var _count = instance_number(o_enemy);
    var _range_sq = sqr(_controller.fallback.ally_search_range);

    for (var _i = 0; _i < _count; _i++)
    {
        var _candidate = instance_find(o_enemy, _i);

        if (_candidate == _enemy
        || !_candidate.initialized)
            continue;

        var _candidate_data = _candidate.enemy;
        var _candidate_class =
            _candidate_data.identity.ship_class;

        if (_candidate_data.identity.faction != _data.identity.faction
        || _candidate_class < _controller.fallback.ally_class_minimum
        || _candidate_data.state == EnemyState.RETREATING
        || _candidate_data.state == EnemyState.FLEEING
        || _candidate_data.state == EnemyState.DEAD)
            continue;

        var _distance_sq = sc_point_distance_sq(
            _enemy.x,
            _enemy.y,
            _candidate.x,
            _candidate.y
        );

        if (_distance_sq > _range_sq)
            continue;

        if (_candidate_class < _selected_class
        || (_candidate_class == _selected_class
        && _distance_sq >= _selected_distance_sq))
            continue;

        _selected = _candidate;
        _selected_class = _candidate_class;
        _selected_distance_sq = _distance_sq;
    }

    return _selected;
}

/// @description Binds one enemy to a moving allied anchor.
function sc_enemy_territory_ally_anchor_bind(_enemy, _anchor)
{
    if (!instance_exists(_anchor))
        return false;

    var _territory = _enemy.enemy.territory;
    var _fallback =
        _enemy.enemy.territory_controller.fallback;

    _territory.bound = true;
    _territory.type = EnemyTerritoryType.INSTANCE_RADIUS;
    _territory.anchor_id = _anchor;

    _territory.centre_x = _anchor.x;
    _territory.centre_y = _anchor.y;
    _territory.radius = _fallback.ally_orbit_radius;

    _territory.field_index = -1;
    _territory.zone_index = -1;
    _territory.returning = false;
    _territory.fallback = EnemyTerritoryFallback.ALLY_ANCHOR;

    return true;
}

/// @description Resolves a missing territory through region, ally and flight fallbacks.
function sc_enemy_territory_resolve(_enemy)
{
    var _data = _enemy.enemy;
    var _territory = _data.territory;
    var _controller = _data.territory_controller;

    _territory.bound = false;
    _territory.anchor_id = noone;
    _territory.field_index = -1;
    _territory.zone_index = -1;

    if (sc_enemy_territory_dense_region_find(_enemy))
        return true;

    _territory.fallback = EnemyTerritoryFallback.FIND_REGION;

    if (_controller.fallback.ally_anchor_enabled)
    {
        var _anchor = sc_enemy_territory_ally_anchor_find(_enemy);

        if (sc_enemy_territory_ally_anchor_bind(
            _enemy,
            _anchor
        ))
            return true;
    }

    _territory.fallback = EnemyTerritoryFallback.FLEE;

    if (_controller.fallback.flee_when_unavailable)
    {
        _territory.bound = false;
        sc_enemy_attack_cancel(_enemy);
        return sc_enemy_critical_response_fallback_flee(_enemy);
    }

    return false;
}

/// @description Returns whether a position belongs to an enemy's core territory.
function sc_enemy_territory_position_valid(_enemy, _x, _y)
{
    if (!variable_struct_exists(_enemy.enemy, "territory"))
        return true;

    var _territory = _enemy.enemy.territory;

    if (!_territory.bound)
        return false;

    switch (_territory.type)
    {
        case EnemyTerritoryType.ASTEROID_REGION:
            if (!sc_enemy_territory_asteroid_region_valid(_enemy))
                return false;

            return sc_sector_asteroid_shape_contains(
                sc_enemy_territory_asteroid_shape_get(_enemy),
                _x,
                _y
            );

        case EnemyTerritoryType.RADIUS:
        case EnemyTerritoryType.INSTANCE_RADIUS:
            return sc_point_distance_sq(
                _x,
                _y,
                _territory.centre_x,
                _territory.centre_y
            ) <= sqr(_territory.radius);
    }

    return true;
}

/// @description Cancels pursuit when a territorial enemy must return home.
function sc_enemy_territory_target_release(_enemy)
{
    var _data = _enemy.enemy;

    if (_data.state == EnemyState.CHASING
    || _data.state == EnemyState.ATTACKING
    || _data.state == EnemyState.INVESTIGATING)
    {
        sc_enemy_attack_cancel(_enemy);
        _data.target_id = noone;
        _data.target_distance_sq = 0;
        _data.state = EnemyState.IDLE;
    }
}

/// @description Overrides the current movement command toward territory.
function sc_enemy_territory_return_command(
    _enemy,
    _target_x,
    _target_y
)
{
    var _data = _enemy.enemy;
    var _command = _data.movement.command;
    var _controller = _data.territory_controller;

    _command.active = true;
    _command.apply_friction = false;
    _command.direction = point_direction(
        _enemy.x,
        _enemy.y,
        _target_x,
        _target_y
    );

    _command.speed_scale = _controller.return_speed_scale;
    _command.face_direction = _command.direction;

    if (_data.movement_controller.facing.default_mode
    != EnemyFacingMode.SPIN)
    {
        _command.facing_mode =
            EnemyFacingMode.MOVEMENT;
    }
}

/// @description Commands idle orbit around a moving territory anchor.
function sc_enemy_territory_anchor_orbit_command(_enemy)
{
    var _data = _enemy.enemy;
    var _territory = _data.territory;
    var _anchor = _territory.anchor_id;

    if (!instance_exists(_anchor))
        return false;

    var _dx = _anchor.x - _enemy.x;
    var _dy = _anchor.y - _enemy.y;
    var _distance = max(
        1,
        point_distance(0, 0, _dx, _dy)
    );

    var _toward = point_direction(0, 0, _dx, _dy);
    var _tangent = _toward + 90;
    var _radial = clamp(
        (_distance - _territory.radius)
        / max(1, _territory.radius),
        -1,
        1
    );

    var _move_x =
        lengthdir_x(1, _tangent)
        + lengthdir_x(_radial, _toward);

    var _move_y =
        lengthdir_y(1, _tangent)
        + lengthdir_y(_radial, _toward);

    var _command = _data.movement.command;
    var _controller = _data.territory_controller;

    _command.active = true;
    _command.apply_friction = false;
    _command.direction = point_direction(
        0,
        0,
        _move_x,
        _move_y
    );

    _command.speed_scale =
        _controller.fallback.ally_orbit_speed_scale;

    return true;
}

/// @description Applies an asteroid-region territory constraint.
function sc_enemy_territory_asteroid_update(_enemy)
{
    var _data = _enemy.enemy;
    var _territory = _data.territory;
    var _controller = _data.territory_controller;

    if (!sc_enemy_territory_asteroid_region_valid(_enemy))
    {
        _territory.bound = false;
        return sc_enemy_territory_resolve(_enemy);
    }

    var _shape = sc_enemy_territory_asteroid_shape_get(
        _enemy
    );

    var _normalized =
        sc_sector_asteroid_shape_distance_get(
            _shape,
            _enemy.x,
            _enemy.y
        );

    var _outside_limit =
        1 + _controller.boundary_padding
        / max(1, _shape.radius);

    var _return_limit =
        max(
            0,
            1 - _controller.return_padding
            / max(1, _shape.radius)
        );

    if (!_territory.returning
    && _normalized > _outside_limit)
    {
        _territory.returning = true;
        sc_enemy_territory_target_release(_enemy);
    }

    if (!_territory.returning)
        return false;

    if (_normalized <= _return_limit)
    {
        _territory.returning = false;
        return false;
    }

    sc_enemy_territory_return_command(
        _enemy,
        _shape.x,
        _shape.y
    );

    return true;
}

/// @description Applies a moving-anchor territory constraint.
function sc_enemy_territory_anchor_update(_enemy)
{
    var _data = _enemy.enemy;
    var _territory = _data.territory;
    var _controller = _data.territory_controller;
    var _anchor = _territory.anchor_id;

    if (!instance_exists(_anchor)
    || !_anchor.initialized
    || _anchor.enemy.state == EnemyState.DEAD
    || _anchor.enemy.state == EnemyState.FLEEING)
    {
        _territory.bound = false;
        return sc_enemy_territory_resolve(_enemy);
    }

    _territory.centre_x = _anchor.x;
    _territory.centre_y = _anchor.y;

    var _distance = point_distance(
        _enemy.x,
        _enemy.y,
        _anchor.x,
        _anchor.y
    );

    var _outside_limit =
        _territory.radius
        + _controller.boundary_padding;

    var _return_limit = max(
        0,
        _territory.radius
        - _controller.return_padding
    );

    if (!_territory.returning
    && _distance > _outside_limit)
    {
        _territory.returning = true;
        sc_enemy_territory_target_release(_enemy);
    }

    if (_territory.returning)
    {
        if (_distance <= _return_limit)
        {
            _territory.returning = false;
            return false;
        }

        sc_enemy_territory_return_command(
            _enemy,
            _anchor.x,
            _anchor.y
        );

        return true;
    }

    if (_data.state == EnemyState.IDLE)
        return sc_enemy_territory_anchor_orbit_command(
            _enemy
        );

    return false;
}

/// @description Periodically validates and applies one enemy's territory.
function sc_enemy_territory_update(_enemy)
{
    var _data = _enemy.enemy;
    var _territory = _data.territory;
    var _controller = _data.territory_controller;

    if (_data.state == EnemyState.RETREATING
    || _data.state == EnemyState.FLEEING
    || _data.state == EnemyState.DEAD)
        return false;

    if (!_territory.bound)
    {
        if (GAME_TICK < _territory.next_search_tick)
            return false;

        _territory.next_search_tick =
            GAME_TICK + _controller.search_interval;

        return sc_enemy_territory_resolve(_enemy);
    }

    if (GAME_TICK < _territory.next_check_tick
    && !_territory.returning)
    {
        if (_territory.type == EnemyTerritoryType.INSTANCE_RADIUS
        && _data.state == EnemyState.IDLE)
        {
            return sc_enemy_territory_anchor_orbit_command(
                _enemy
            );
        }

        return false;
    }

    _territory.next_check_tick =
        GAME_TICK + _controller.check_interval;

    switch (_territory.type)
    {
        case EnemyTerritoryType.ASTEROID_REGION:
            return sc_enemy_territory_asteroid_update(_enemy);

        case EnemyTerritoryType.INSTANCE_RADIUS:
            return sc_enemy_territory_anchor_update(_enemy);
    }

    return false;
}