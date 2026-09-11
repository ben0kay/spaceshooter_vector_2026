/*
RADAR INTERFERENCE

Collects radar disruption from environmental fields and, later,
enemy jammers, EMP effects, damaged systems and sector anomalies.
*/

/// @description Combines interference strengths with diminishing stacking.
function sc_radar_interference_combine(_current, _source)
{
    _current = clamp(_current,0,1);
    _source = clamp(_source,0,1);

    return 1 - (1-_current) * (1-_source);
}

/// @description Returns environmental radar interference at one position.
function sc_radar_interference_environment_get(_x, _y)
{
    if (!variable_global_exists("game")
    || !is_struct(global.game)
    || !variable_struct_exists(global.game,"sector")
    || !is_struct(global.game.sector)
    || !variable_struct_exists(global.game.sector,"environment_fields"))
        return 0;

    var _fields = global.game.sector.environment_fields;
    var _combined = 0;

    for (var _i=0; _i<array_length(_fields); ++_i)
    {
        var _field = _fields[_i];

        if (!instance_exists(_field)
        || !_field.initialized)
            continue;

        var _data = _field.environment_field;
        var _interference = _data.interference;

        if (!is_struct(_interference)
        || !variable_struct_exists(_interference,"radar_strength"))
            continue;

        var _distance = sc_environment_field_distance_get(
            _field,
            _x,
            _y
        );

        if (_distance >= 1)
            continue;

        var _boundary_fade =
            variable_struct_exists(
                _interference,
                "radar_boundary_fade"
            )
            ? max(0.01,_interference.radar_boundary_fade)
            : 0.2;

        var _depth = clamp(
            (1-_distance) / _boundary_fade,
            0,
            1
        );

        var _strength =
            _data.density
            * _interference.radar_strength
            * _depth;

        _combined = sc_radar_interference_combine(
            _combined,
            _strength
        );
    }

    return clamp(_combined,0,1);
}

/// @description Returns radar-interference resistance from a ship.
function sc_radar_interference_resistance_get(_owner)
{
    if (!instance_exists(_owner)
    || !variable_instance_exists(_owner,"ship")
    || !is_struct(_owner.ship)
    || !variable_struct_exists(_owner.ship,"stats")
    || !is_struct(_owner.ship.stats)
    || !variable_struct_exists(_owner.ship.stats,"final")
    || !is_struct(_owner.ship.stats.final)
    || !variable_struct_exists(
        _owner.ship.stats.final,
        "radar_interference_resistance"
    ))
        return 0;

    return clamp(
        _owner.ship.stats.final.radar_interference_resistance,
        0,
        1
    );
}

/// @description Returns final combined radar interference for one ship.
function sc_radar_interference_strength_get(_owner)
{
    if (!instance_exists(_owner))
        return 0;

    var _combined = 0;

    _combined = sc_radar_interference_combine(
        _combined,
        sc_radar_interference_environment_get(
            _owner.x,
            _owner.y
        )
    );

    // Enemy jammer, EMP and damage-source collectors can be added here.

    var _resistance =
        sc_radar_interference_resistance_get(_owner);

    return clamp(
        _combined * (1-_resistance),
        0,
        1
    );
}