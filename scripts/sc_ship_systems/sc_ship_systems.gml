/// @description Returns the standard internal-system foundation for a ship.
function sc_ship_systems_standard()
{
    return {
        engines:{condition_max:100},
        thrusters:{condition_max:100},
        shield_generator:{condition_max:100},
        reactor:{condition_max:100},
        cooling:{condition_max:100},
        weapons:{condition_max:100},
        sensors:{condition_max:100},
        drone_bay:{condition_max:100},
        cargo_hold:{condition_max:100},
        life_support:{condition_max:100}
    };
}

/// @description Validates the required internal-system foundation during ship registration.
function sc_ship_systems_validate(_systems)
{
    if (!is_struct(_systems)) return false;

    var _required = [
        "engines",
        "thrusters",
        "shield_generator",
        "reactor",
        "cooling",
        "weapons",
        "sensors",
        "drone_bay",
        "cargo_hold",
        "life_support"
    ];

    for (var _i=0;_i<array_length(_required);_i++)
    {
        var _key=_required[_i];
        if (!variable_struct_exists(_systems,_key)) return false;

        var _system=variable_struct_get(_systems,_key);

        if (!is_struct(_system)
        || !variable_struct_exists(_system,"condition_max")
        || _system.condition_max<=0)
            return false;
    }

    return true;
}

/// @description Creates an independent operational runtime for registered ship systems.
function sc_ship_systems_runtime_create(_definitions)
{
    var _systems=variable_clone(_definitions);
    var _names=variable_struct_get_names(_systems);

    for (var _i=0;_i<array_length(_names);_i++)
    {
        var _system=variable_struct_get(_systems,_names[_i]);

        _system.condition_current=_system.condition_max;
        _system.enabled=true;

        _system.disruption={
            remaining:0,
            strength:0
        };
    }

    return _systems;
}

/// @description Returns one ship system, or undefined when the key is unavailable.
function sc_ship_system_get(_ship,_system_key)
{
    if (!is_struct(_ship)
    || !is_struct(_ship.systems)
    || !variable_struct_exists(_ship.systems,_system_key))
        return undefined;

    return variable_struct_get(_ship.systems,_system_key);
}

/// @description Returns whether one ship system can currently perform its job.
function sc_ship_system_operational(_ship,_system_key)
{
    var _system=sc_ship_system_get(_ship,_system_key);
    if (!is_struct(_system)) return false;

    return _system.enabled
        && _system.condition_current>0
        && _system.disruption.remaining<=0;
}

/// @description Returns one system's remaining-condition ratio.
function sc_ship_system_condition_ratio_get(_ship,_system_key)
{
    var _system=sc_ship_system_get(_ship,_system_key);
    if (!is_struct(_system)) return 0;

    return clamp(
        _system.condition_current/max(1,_system.condition_max),
        0,
        1
    );
}

/// @description Applies temporary disruption after general and system resistance.
function sc_ship_system_disruption_apply(
    _owner,
    _system_key,
    _duration,
    _strength=1
)
{
    if (!instance_exists(_owner)) return false;

    var _system=sc_ship_system_get(_owner.ship,_system_key);
    if (!is_struct(_system)) return false;

    var _stats=_owner.ship.stats.final;
    var _general=variable_struct_exists(
        _stats,
        "system_disruption_resistance"
    )
        ? _stats.system_disruption_resistance
        : 0;

    var _stat_key=_system_key+"_disruption_resistance";
    var _specific=variable_struct_exists(_stats,_stat_key)
        ? variable_struct_get(_stats,_stat_key)
        : 0;

    var _resistance=clamp(_general+_specific,0,0.9);
    var _resolved_duration=max(
        1,
        round(_duration*(1-_resistance))
    );

    _system.disruption.remaining=max(
        _system.disruption.remaining,
        _resolved_duration
    );

    _system.disruption.strength=max(
        _system.disruption.strength,
        clamp(_strength,0,1)
    );

    return true;
}

/// @description Updates temporary disruption across every system on one ship.
function sc_ship_systems_update(_owner)
{
    if (!instance_exists(_owner)
    || !is_struct(_owner.ship)
    || !is_struct(_owner.ship.systems))
        return false;

    var _systems=_owner.ship.systems;
    var _names=variable_struct_get_names(_systems);

    for (var _i=0;_i<array_length(_names);_i++)
    {
        var _system=variable_struct_get(_systems,_names[_i]);
        var _disruption=_system.disruption;

        if (_disruption.remaining<=0) continue;

        _disruption.remaining--;

        if (_disruption.remaining<=0)
        {
            _disruption.remaining=0;
            _disruption.strength=0;
        }
    }

    return true;
}