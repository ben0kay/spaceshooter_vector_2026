/*
PROJECTILE DETONATION EMISSIONS

Optional one-time projectile spawning triggered through the shared detonation
pipeline. Constructor functions provide the public definition interface.
Emission callbacks determine projectile arrangement.
Referenced weapons determine projectile, speed, scale, damage and guidance.
*/

/// @description Creates an equal-angle 360-degree projectile emission.
/// @param {string} _weapon_key Weapon used by every emitted projectile.
/// @param {real} _amount Number of emitted projectiles.
/// @param {real} _angle_offset Rotation applied relative to the parent direction.
function sc_projectile_emission_radial_create(_weapon_key, _amount, _angle_offset = 0)
{
    return {
        script: sc_projectile_emission_radial,
        weapon_key: _weapon_key,
        amount: max(1, round(_amount)),
        angle_offset: _angle_offset
    };
}

/// @description Creates an evenly distributed forward-cone projectile emission.
/// @param {string} _weapon_key Weapon used by every emitted projectile.
/// @param {real} _amount Number of emitted projectiles.
/// @param {real} _angle_total Total cone width in degrees.
/// @param {real} _angle_offset Rotation away from the parent direction.
function sc_projectile_emission_cone_create(_weapon_key, _amount, _angle_total, _angle_offset = 0)
{
    return {
        script: sc_projectile_emission_cone,
        weapon_key: _weapon_key,
        amount: max(1, round(_amount)),
        angle_total: clamp(_angle_total, 0, 360),
        angle_offset: _angle_offset
    };
}

/// @description Returns one valid projectile weapon used by an emission.
function sc_projectile_emission_weapon_get(_config)
{
    if (!variable_struct_exists(global.data.weapons, _config.weapon_key))
    {
        show_debug_message(
            "PROJECTILE EMISSION ERROR - unknown weapon: "
            + _config.weapon_key
        );

        return undefined;
    }

    var _weapon = variable_struct_get(
        global.data.weapons,
        _config.weapon_key
    );

    if (_weapon.delivery.type != AttackDelivery.PROJECTILE)
    {
        show_debug_message(
            "PROJECTILE EMISSION ERROR - weapon is not projectile delivery: "
            + _config.weapon_key
        );

        return undefined;
    }

    return _weapon;
}

/// @description Emits one child projectile while preserving the original source.
function sc_projectile_emission_child_create(_parent, _weapon, _direction)
{
    var _parent_data = _parent.projectile;
    var _delivery = _weapon.delivery;
    var _child_definition = variable_struct_get(
        global.data.projectiles,
        _delivery.projectile_key
    );

    var _child_radius =
        _child_definition.collision.radius
        * _delivery.projectile.scale;

    var _spawn_distance =
        _parent_data.collision.radius
        + _child_radius
        + 2;

    var _x = _parent.x
        + lengthdir_x(_spawn_distance, _direction);

    var _y = _parent.y
        + lengthdir_y(_spawn_distance, _direction);

    return sc_projectile_create(
        _delivery.projectile_key,
        _parent_data.source,
        _delivery,
        _x,
        _y,
        _direction,
        _parent.layer
    );
}

/// @description Emits projectiles evenly across a complete 360-degree ring.
function sc_projectile_emission_radial(_parent, _config)
{
    var _weapon = sc_projectile_emission_weapon_get(_config);
    if (!is_struct(_weapon)) return false;

    var _amount = _config.amount;
    var _step = 360 / _amount;
    var _start = _parent.projectile.direction + _config.angle_offset;

    for (var _i = 0; _i < _amount; _i++)
    {
        sc_projectile_emission_child_create(
            _parent,
            _weapon,
            _start + _step * _i
        );
    }

    return true;
}

/// @description Emits projectiles evenly across a forward-facing cone.
function sc_projectile_emission_cone(_parent, _config)
{
    var _weapon = sc_projectile_emission_weapon_get(_config);
    if (!is_struct(_weapon)) return false;

    var _amount = _config.amount;
    var _centre =
        _parent.projectile.direction
        + _config.angle_offset;

    if (_amount == 1)
    {
        sc_projectile_emission_child_create(
            _parent,
            _weapon,
            _centre
        );

        return true;
    }

    var _step = _config.angle_total / (_amount - 1);
    var _start = _centre - _config.angle_total * 0.5;

    for (var _i = 0; _i < _amount; _i++)
    {
        sc_projectile_emission_child_create(
            _parent,
            _weapon,
            _start + _step * _i
        );
    }

    return true;
}

/// @description Runs every registered one-time detonation emission.
function sc_projectile_detonation_emissions_emit(_projectile)
{
    var _emissions = _projectile.projectile.detonation.emissions;

    for (var _i = 0; _i < array_length(_emissions); _i++)
    {
        var _emission = _emissions[_i];
        _emission.script(_projectile, _emission);
    }

    return array_length(_emissions) > 0;
}