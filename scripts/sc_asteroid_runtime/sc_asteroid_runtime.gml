/*
GENERIC ASTEROID RUNTIME

Asteroids are factionless damageable entities.
They cannot be selected by homing guidance.
No Step event is required for visual rotation.
*/

/// @description Returns base values for one asteroid size.
function sc_asteroid_size_data(_size)
{
    switch (_size)
    {
        case AsteroidSize.SMALL: return { radius: 30, health: 45, yield_min: 1, yield_max: 3 };
        case AsteroidSize.MEDIUM: return { radius: 58, health: 130, yield_min: 4, yield_max: 8 };
        case AsteroidSize.LARGE: return { radius: 105, health: 340, yield_min: 10, yield_max: 18 };
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

    _asteroid.draw_angle = random(360);
    _asteroid.asteroid = {
        key: _create.key,
        item_key: _definition.item_key,
        size: _create.size,

        health: { current: _health, maximum: _health, stage: 0 },
        yield: {
            remaining: max(1, round(
                irandom_range(_size.yield_min, _size.yield_max)
                * _definition.stats.yield_multiplier
            ))
        },

        collision: { radius: _radius * 0.82 },

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

/// @description Applies damage and updates the baked damage stage.
function sc_asteroid_damage(_asteroid, _packet)
{
    var _health = _asteroid.asteroid.health;
    var _damage = min(_health.current, sc_damage_packet_amount_get(_packet));

    if (_damage <= 0) return false;

    _health.current -= _damage;

    var _ratio = _health.current / _health.maximum;
    _health.stage = _ratio <= 0.25 ? 3 : (_ratio <= 0.5 ? 2 : (_ratio <= 0.75 ? 1 : 0));

    var _result = {
        shield: 0, armour: 0, hull: _health.current,
        impact_layer: DefenceLayer.HULL,

        dealt: {
            shield: 0, armour: 0,
            hull: _damage, total: _damage
        },

        effect: _packet.effect,
        source: _packet.source
    };

    if (_health.current <= 0)
    {
        _health.current = 0;

        // Resource drops, fragments and destruction particles plug in here next.
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
        _scale * _visual.scale_x, _scale * _visual.scale_y,
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

/// @description Spawns one temporary mixed asteroid field.
function sc_asteroid_test_field_spawn(_centre_x, _centre_y, _radius, _amount, _layer)
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
        { size: AsteroidSize.SMALL, weight: 46 },
        { size: AsteroidSize.MEDIUM, weight: 39 },
        { size: AsteroidSize.LARGE, weight: 15 }
    ];

    var _spawned = 0;
    var _attempts = 0;

    while (_spawned < _amount && _attempts < _amount * 20)
    {
        _attempts++;

        var _direction = random(360);
        var _distance = sqrt(random(1)) * _radius;
        var _x = _centre_x + lengthdir_x(_distance, _direction);
        var _y = _centre_y + lengthdir_y(_distance, _direction);

        if (_x < 180 || _x > room_width - 180 || _y < 180 || _y > room_height - 180) continue;
        if (collision_circle(_x, _y, 125, o_asteroid, false, true) != noone) continue;

        var _material = sc_asteroid_weighted_choose(_materials);
        var _size = sc_asteroid_weighted_choose(_sizes);

        instance_create_layer(_x, _y, _layer, o_asteroid, {
            asteroid_create: { key: _material.key, size: _size.size }
        });

        _spawned++;
    }

    return _spawned;
}