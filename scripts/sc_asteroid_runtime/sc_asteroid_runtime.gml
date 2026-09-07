/*
GENERIC ASTEROID RUNTIME

Asteroids are factionless damageable entities.
Damage gradually releases resources.
Mining attacks can provide improved extraction efficiency.
*/

/// @description Returns base values for one asteroid size.
function sc_asteroid_size_data(_size)
{
    switch (_size)
    {
        case AsteroidSize.SMALL: return { radius: 30, health: 45, yield_min: 1, yield_max: 3 };
        case AsteroidSize.MEDIUM: return { radius: 58, health: 130, yield_min: 4, yield_max: 8 };
        case AsteroidSize.LARGE: return { radius: 105, health: 340, yield_min: 8, yield_max: 18 };
		case AsteroidSize.HUGE: return { radius: 256, health: 768, yield_min: 15, yield_max: 35 };
		case AsteroidSize.COLOSSAL: return { radius: 768, health: 2048, yield_min: 35, yield_max: 50 };
    }

    return undefined;
}

/// @description Initializes one generic factionless asteroid.
function sc_asteroid_init(_asteroid, _create)
{
    if (!is_struct(_create) || !variable_struct_exists(global.data.asteroids, _create.key))
        return false;

    var _definition = variable_struct_get(global.data.asteroids, _create.key);
    var _size = sc_asteroid_size_data(_create.size);
    if (!is_struct(_size)) return false;

    var _radius = _size.radius * random_range(0.9, 1.1);
    var _health = round(_size.health * _definition.stats.health_multiplier);
    var _yield = max(1, round(
        irandom_range(_size.yield_min, _size.yield_max)
        * _definition.stats.yield_multiplier
    ));

    _asteroid.draw_angle = random(360);
    _asteroid.asteroid = {
        key: _create.key,
        item_key: _definition.item_key,
        size: _create.size,

        health: {
            current: _health,
            maximum: _health,
            stage: 0
        },

        yield: {
            total: _yield,
            remaining: _yield,
            progress: 0
        },

        collision: {
            radius: _radius * 0.82
        },

        visual: {
            radius: _radius,
            variant: irandom(5),
            start_angle: random(360),
            rotation_speed: random_range(-0.08, 0.08),
            scale_x: random_range(0.92, 1.08) * choose(-1, 1),
            scale_y: random_range(0.92, 1.08) * choose(-1, 1)
        }
    };

    var _collision = {
        radius_forward: _asteroid.asteroid.collision.radius,
        radius_side: _asteroid.asteroid.collision.radius
    };

    if (!sc_entity_init(_asteroid, noone, sc_asteroid_damage, _collision, false))
        return false;

    _asteroid.initialized = true;
    return true;
}

/// @description Returns the yield multiplier supplied by the damage source and extraction method.
function sc_asteroid_source_yield_multiplier_get(_packet)
{
    var _multiplier = 1;

    if (_packet.source.faction == Faction.PLAYER
    && instance_exists(_packet.source.owner_id))
    {
        _multiplier *=
            _packet.source.owner_id.ship.stats.final.resource_yield_multiplier;
    }

    if (is_struct(_packet.extraction)
    && variable_struct_exists(_packet.extraction, "yield_multiplier"))
    {
        _multiplier *= max(
            0,
            _packet.extraction.yield_multiplier
        );
    }

    return _multiplier;
}

/// @description Applies stochastic rounding to multiplied resource output.
function sc_asteroid_yield_output_get(_amount, _multiplier)
{
    var _exact = max(0, _amount * _multiplier);
    var _output = floor(_exact);

    if (random(1) < frac(_exact))
        _output++;

    return _output;
}

/// @description Converts accumulated extraction progress into outward world pickups.
function sc_asteroid_yield_emit(_asteroid, _yield_multiplier = 1, _launch_multiplier = 1)
{
    var _data = _asteroid.asteroid;
    var _yield = _data.yield;
    var _config = global.config.asteroid.pickup;
    var _base_amount = min(_yield.remaining, floor(_yield.progress));

    if (_base_amount <= 0) return 0;

    _yield.progress -= _base_amount;
    _yield.remaining -= _base_amount;

    var _output = sc_asteroid_yield_output_get(
        _base_amount,
        _yield_multiplier
    );

    var _remaining = _output;

    while (_remaining > 0)
    {
        var _chunk = min(_remaining, irandom_range(1, 3));
        var _direction = random(360);

        // Begin outside the physical asteroid instead of beneath it.
        var _spawn_distance =
            _data.collision.radius
            + _config.spawn_clearance
            + random_range(0, 8);

        var _spawn_x =
            _asteroid.x
            + lengthdir_x(_spawn_distance, _direction);

        var _spawn_y =
            _asteroid.y
            + lengthdir_y(_spawn_distance, _direction);

        sc_resource_pickup_spawn(
            _spawn_x,
            _spawn_y,
            _asteroid.layer,
            _data.item_key,
            _chunk,
            {
                direction: _direction + random_range(-12, 12),
                speed_multiplier: _launch_multiplier
            }
        );

        _remaining -= _chunk;
    }

    return _output;
}

/// @description Adds recoverable base extraction progress from one asteroid hit.
function sc_asteroid_yield_damage_add(_asteroid, _packet, _damage)
{
    var _data = _asteroid.asteroid;
    var _config = global.config.asteroid;
    var _efficiency = _config.extraction.weapon_efficiency;
    var _mining = is_struct(_packet.extraction);

    if (_mining)
        _efficiency = max(0, _packet.extraction.efficiency);

    var _damage_ratio =
        _damage
        / max(1, _data.health.maximum);

    _data.yield.progress +=
        _damage_ratio
        * _data.yield.total
        * _efficiency;

    return sc_asteroid_yield_emit(
        _asteroid,
        sc_asteroid_source_yield_multiplier_get(_packet),
        _mining
            ? _config.pickup.mining_launch_multiplier
            : 1
    );
}

/// @description Releases the asteroid's final recoverable destruction yield.
function sc_asteroid_yield_destruction_release(_asteroid, _packet)
{
    var _yield = _asteroid.asteroid.yield;

    _yield.progress +=
        _yield.remaining
        * global.config.asteroid.extraction.destruction_efficiency;

    return sc_asteroid_yield_emit(
        _asteroid,
        sc_asteroid_source_yield_multiplier_get(_packet)
    );
}

/// @description Applies damage, enemy demolition power, resource release and damage stages.
function sc_asteroid_damage(_asteroid, _packet)
{
    var _health = _asteroid.asteroid.health;
    var _damage_amount = sc_damage_packet_amount_get(_packet);

    // Enemy demolition receives extra asteroid-only damage.
    // This does not increase damage dealt to the player or other enemies.
    if (_packet.source.faction != Faction.PLAYER
    && _packet.source.faction != noone)
    {
        _damage_amount *=
            global.config.enemy.asteroid.destroy_damage_multiplier;
    }

    var _damage = min(
        _health.current,
        _damage_amount
    );

    if (_damage <= 0) return false;

    _health.current -= _damage;

    sc_asteroid_yield_damage_add(
        _asteroid,
        _packet,
        _damage
    );

    var _ratio = _health.current / _health.maximum;

    _health.stage = _ratio <= 0.25
        ? 3
        : (_ratio <= 0.5
            ? 2
            : (_ratio <= 0.75 ? 1 : 0));

    var _result = {
        shield: 0,
        armour: 0,
        hull: _health.current,
        impact_layer: DefenceLayer.HULL,

        dealt: {
            shield: 0,
            armour: 0,
            hull: _damage,
            total: _damage
        },

        effect: _packet.effect,
        source: _packet.source
    };

    if (_health.current <= 0)
    {
        _health.current = 0;

        sc_asteroid_yield_destruction_release(
            _asteroid,
            _packet
        );

        instance_destroy(_asteroid);
    }

    return _result;
}

/// @description Draws one visible cached asteroid with runtime variation.
function sc_asteroid_draw(_asteroid)
{
    var _data = _asteroid.asteroid;
    var _visual = _data.visual;
    var _extent = _visual.radius * max(abs(_visual.scale_x), abs(_visual.scale_y));

    if (!sc_optimization_circle_visible(_asteroid.x, _asteroid.y, _extent, 128))
        return;

    var _sprite = sc_asteroid_visual_cache_get(_data.key, _visual.variant, _data.health.stage);
    var _scale = _visual.radius / 108;
    var _angle = (_visual.start_angle + GAME_TICK * _visual.rotation_speed) mod 360;

    draw_sprite_ext(
        _sprite, 0, _asteroid.x, _asteroid.y,
        _scale * _visual.scale_x,
        _scale * _visual.scale_y,
        _angle, c_white, 1
    );
}

/// @description Chooses one weighted test-spawner entry.
function sc_asteroid_weighted_choose(_entries)
{
    var _total = 0;

    for (var _i = 0; _i < array_length(_entries); _i++)
        _total += _entries[_i].weight;

    var _roll = random(_total);

    for (var _i = 0; _i < array_length(_entries); _i++)
    {
        _roll -= _entries[_i].weight;
        if (_roll <= 0) return _entries[_i];
    }

    return _entries[array_length(_entries) - 1];
}

/// @description Spawns one temporary mixed asteroid field with guaranteed giant asteroids.
function sc_asteroid_test_field_spawn(_centre_x,_centre_y,_radius,_amount,_layer)
{
    var _materials = [
        { key: "asteroid_carbon", weight: 24 },
        { key: "asteroid_iron", weight: 22 },
        { key: "asteroid_copper", weight: 16 },
        { key: "asteroid_silicon", weight: 13 },
        { key: "asteroid_titanium", weight: 7 },
        { key: "asteroid_crystal", weight: 8 },
        { key: "asteroid_ice", weight: 10 }
    ];

    var _sizes = [
        { size: AsteroidSize.SMALL, weight: 42 },
        { size: AsteroidSize.MEDIUM, weight: 34 },
        { size: AsteroidSize.LARGE, weight: 19 },
        { size: AsteroidSize.HUGE, weight: 4 },
        { size: AsteroidSize.COLOSSAL, weight: 1 }
    ];

    // Spawn largest first so smaller rocks cannot occupy all available space.
    var _forced_sizes = [
        AsteroidSize.COLOSSAL,
        AsteroidSize.HUGE,
        AsteroidSize.HUGE
    ];

    var _target_amount = max(3,_amount);
    var _spawned = 0;
    var _attempts = 0;
    var _attempts_max = _target_amount*80;

    while (_spawned < _target_amount && _attempts < _attempts_max)
    {
        _attempts++;

        var _size = _spawned < array_length(_forced_sizes)
            ? _forced_sizes[_spawned]
            : sc_asteroid_weighted_choose(_sizes).size;

        var _size_data = sc_asteroid_size_data(_size);
        var _edge_margin = _size_data.radius*1.1+32;
        var _spawn_clearance = _size_data.radius*0.95+24;
        var _direction = random(360);
        var _distance = sqrt(random(1))*_radius;
        var _x = _centre_x+lengthdir_x(_distance,_direction);
        var _y = _centre_y+lengthdir_y(_distance,_direction);

        if (_x < _edge_margin
        || _x > room_width-_edge_margin
        || _y < _edge_margin
        || _y > room_height-_edge_margin)
            continue;

        if (collision_circle(
            _x,_y,_spawn_clearance,
            o_asteroid,false,true
        ) != noone)
            continue;

        var _material = sc_asteroid_weighted_choose(_materials);

        instance_create_layer(_x,_y,_layer,o_asteroid,{
            asteroid_create: {
                key: _material.key,
                size: _size
            }
        });

        _spawned++;
    }

    return _spawned;
}