/// @description Returns the standard internal-system foundation for a ship.
/// These records are currently dormant. Hull damage, penalties, repairs and physical rooms can use them later.
function sc_ship_systems_standard()
{
    return {
        engines: { condition_max: 100 },
        thrusters: { condition_max: 100 },
        shield_generator: { condition_max: 100 },
        reactor: { condition_max: 100 },
        weapons: { condition_max: 100 },
        sensors: { condition_max: 100 },
        cargo_hold: { condition_max: 100 },
        life_support: { condition_max: 100 }
    };
}

/// @description Validates the required internal-system foundation during ship registration.
function sc_ship_systems_validate(_systems)
{
    if (!is_struct(_systems)) return false;

    var _required = ["engines", "thrusters", "shield_generator", "reactor", "weapons", "sensors", "cargo_hold", "life_support"];

    for (var _i = 0; _i < array_length(_required); _i++)
    {
        var _key = _required[_i];

        if (!variable_struct_exists(_systems, _key)) return false;

        var _system = variable_struct_get(_systems, _key);

        if (!is_struct(_system)
        || !variable_struct_exists(_system, "condition_max")
        || _system.condition_max <= 0)
            return false;
    }

    return true;
}

/// @description Creates an independent runtime copy of registered internal systems.
function sc_ship_systems_runtime_create(_definitions)
{
    var _systems = variable_clone(_definitions);
    var _names = variable_struct_get_names(_systems);

    for (var _i = 0; _i < array_length(_names); _i++)
    {
        var _system = variable_struct_get(_systems, _names[_i]);
        _system.condition_current = _system.condition_max;
    }

    return _systems;
}