/*
DAMAGE EFFECT DEFINITION

Weapon damage definitions may override:

effect: DamageEffect.DISRUPTION
effect_chance: 0 to 1
effect_duration: game steps
effect_strength: 0 to 1
effect_tick_interval: game steps
effect_systems: array of ship-system keys
effect_system_count: number of systems selected

Open this file whenever creating or changing a damage effect.
*/

/// @description Returns every ship system that damage effects may target.
function sc_damage_effect_system_keys_get()
{
    return [
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
}

/// @description Returns whether a ship-system effect key is valid.
function sc_damage_effect_system_key_valid(_key)
{
    var _keys = sc_damage_effect_system_keys_get();

    for (var _i = 0; _i < array_length(_keys); _i++)
    {
        if (_keys[_i] == _key)
            return true;
    }

    return false;
}

/// @description Returns the authoritative defaults for one damage effect.
function sc_damage_effect_definition_get(_effect)
{
    switch (_effect)
    {
        case DamageEffect.DISRUPTION:
            return {
                name: "Disruption",
                chance: 0.25,
                duration: 180,
                strength: 0.25,
                tick_interval: 0,
                systems: ["weapons", "thrusters"],
                system_count: 1
            };

        case DamageEffect.BURN:
            return {
                name: "Burn",
                chance: 0.2,
                duration: 180,
                strength: 0.15,
                tick_interval: 30,
                systems: [],
                system_count: 0
            };

        case DamageEffect.CORROSION:
            return {
                name: "Corrosion",
                chance: 0.25,
                duration: 240,
                strength: 0.2,
                tick_interval: 30,
                systems: [],
                system_count: 0
            };

        case DamageEffect.STAGGER:
            return {
                name: "Stagger",
                chance: 1,
                duration: 12,
                strength: 0.45,
                tick_interval: 0,
                systems: [],
                system_count: 0
            };
    }

    return {
        name: "None",
        chance: 0,
        duration: 0,
        strength: 0,
        tick_interval: 0,
        systems: [],
        system_count: 0
    };
}

/// @description Builds one normalized effect from a flat weapon damage definition.
function sc_damage_effect_create(_damage_definition, _default_effect)
{
    var _effect = variable_struct_exists(
        _damage_definition,
        "effect"
    )
        ? _damage_definition.effect
        : _default_effect;

    var _defaults = sc_damage_effect_definition_get(_effect);

    var _requested_systems = variable_struct_exists(
        _damage_definition,
        "effect_systems"
    )
        ? _damage_definition.effect_systems
        : _defaults.systems;

    var _systems = [];

    for (
        var _i = 0;
        _i < array_length(_requested_systems);
        _i++
    )
    {
        var _key = _requested_systems[_i];

        if (sc_damage_effect_system_key_valid(_key))
        {
            array_push(_systems, _key);
        }
        else
        {
            show_debug_message(
                "INVALID DAMAGE EFFECT SYSTEM - "
                + string(_key)
            );
        }
    }

    var _system_count = variable_struct_exists(
        _damage_definition,
        "effect_system_count"
    )
        ? _damage_definition.effect_system_count
        : _defaults.system_count;

    return {
        type: _effect,

        chance: clamp(
            variable_struct_exists(
                _damage_definition,
                "effect_chance"
            )
                ? _damage_definition.effect_chance
                : _defaults.chance,
            0,
            1
        ),

        duration: max(
            0,
            round(
                variable_struct_exists(
                    _damage_definition,
                    "effect_duration"
                )
                    ? _damage_definition.effect_duration
                    : _defaults.duration
            )
        ),

        strength: clamp(
            variable_struct_exists(
                _damage_definition,
                "effect_strength"
            )
                ? _damage_definition.effect_strength
                : _defaults.strength,
            0,
            1
        ),

        tick_interval: max(
            0,
            round(
                variable_struct_exists(
                    _damage_definition,
                    "effect_tick_interval"
                )
                    ? _damage_definition.effect_tick_interval
                    : _defaults.tick_interval
            )
        ),

        systems: _systems,

        system_count: clamp(
            round(_system_count),
            0,
            array_length(_systems)
        )
    };
}

/// @description Rolls whether one normalized damage effect activates.
function sc_damage_effect_triggered(_effect)
{
    if (_effect.type == DamageEffect.NONE)
        return false;

    return random(1) < _effect.chance;
}

/// @description Dispatches an activated damage effect against the player.
function sc_damage_effect_player_apply(_player, _effect)
{
    if (!sc_damage_effect_triggered(_effect))
        return false;

    switch (_effect.type)
    {
        case DamageEffect.DISRUPTION:
            return sc_ship_system_disruption_effect_apply(
                _player,
                _effect
            );

        case DamageEffect.STAGGER:
            sc_player_stagger_begin(
                _player,
                _effect
            );

            return true;
    }

    return false;
}