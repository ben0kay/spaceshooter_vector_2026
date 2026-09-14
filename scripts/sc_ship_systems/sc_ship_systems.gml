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

	var _required = sc_damage_effect_system_keys_get();

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

/// @description Applies temporary disruption after duration and strength resistance.
function sc_ship_system_disruption_apply(
    _owner,
    _system_key,
    _duration,
    _strength = 1
)
{
    if (!instance_exists(_owner)) return false;

    var _system = sc_ship_system_get(
        _owner.ship,
        _system_key
    );

    if (!is_struct(_system)) return false;

    var _stats = _owner.ship.stats.final;

    var _duration_general = variable_struct_exists(
        _stats,
        "system_disruption_resistance"
    )
        ? _stats.system_disruption_resistance
        : 0;

    var _duration_key = _system_key
        + "_disruption_resistance";

    var _duration_specific = variable_struct_exists(
        _stats,
        _duration_key
    )
        ? variable_struct_get(_stats, _duration_key)
        : 0;

    var _strength_general = variable_struct_exists(
        _stats,
        "system_disruption_strength_resistance"
    )
        ? _stats.system_disruption_strength_resistance
        : 0;

    var _strength_key = _system_key
        + "_disruption_strength_resistance";

    var _strength_specific = variable_struct_exists(
        _stats,
        _strength_key
    )
        ? variable_struct_get(_stats, _strength_key)
        : 0;

    var _recovery = variable_struct_exists(
        _stats,
        "system_recovery_multiplier"
    )
        ? max(0.1, _stats.system_recovery_multiplier)
        : 1;

    var _duration_resistance = clamp(
        _duration_general + _duration_specific,
        0,
        0.9
    );

    var _strength_resistance = clamp(
        _strength_general + _strength_specific,
        0,
        0.9
    );

    var _resolved_duration = max(
        1,
        round(
            _duration
            * (1 - _duration_resistance)
            / _recovery
        )
    );

    var _resolved_strength = clamp(
        _strength * (1 - _strength_resistance),
        0,
        1
    );

    if (_resolved_strength <= 0)
        return false;

    _system.disruption.remaining = max(
        _system.disruption.remaining,
        _resolved_duration
    );

    _system.disruption.strength = max(
        _system.disruption.strength,
        _resolved_strength
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

/// @description Returns active disruption strength for one ship system.
function sc_ship_system_disruption_strength_get(
    _ship,
    _system_key
)
{
    var _system = sc_ship_system_get(
        _ship,
        _system_key
    );

    if (!is_struct(_system)
    || _system.disruption.remaining <= 0)
        return 0;

    return clamp(
        _system.disruption.strength,
        0,
        1
    );
}

/// @description Applies one disruption effect to unique eligible ship systems.
function sc_ship_system_disruption_effect_apply(
    _owner,
    _effect
)
{
    if (!instance_exists(_owner)
    || !is_array(_effect.systems)
    || array_length(_effect.systems) <= 0)
        return false;

    var _available = variable_clone(_effect.systems);
    var _amount = min(
        max(1, _effect.system_count),
        array_length(_available)
    );

    var _applied = false;

    repeat (_amount)
    {
        var _index = irandom(
            array_length(_available) - 1
        );

        var _system_key = _available[_index];

        if (sc_ship_system_disruption_apply(
            _owner,
            _system_key,
            _effect.duration,
            _effect.strength
        ))
            _applied = true;

        array_delete(
            _available,
            _index,
            1
        );
    }

    return _applied;
}

/// @description Returns the strongest current propulsion disruption.
function sc_ship_propulsion_disruption_strength_get(_ship)
{
    return max(
        sc_ship_system_disruption_strength_get(
            _ship,
            "engines"
        ),

        sc_ship_system_disruption_strength_get(
            _ship,
            "thrusters"
        )
    );
}

/// @description Returns usable system output after condition and disruption.
function sc_ship_system_effectiveness_get(
    _ship,
    _system_key
)
{
    var _system = sc_ship_system_get(
        _ship,
        _system_key
    );

    if (!is_struct(_system)
    || !_system.enabled
    || _system.condition_current <= 0)
        return 0;

    var _condition = sc_ship_system_condition_ratio_get(
        _ship,
        _system_key
    );

    var _disruption = sc_ship_system_disruption_strength_get(
        _ship,
        _system_key
    );

    return clamp(
        _condition * (1 - _disruption),
        0,
        1
    );
}