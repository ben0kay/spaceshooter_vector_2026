/// @description Returns centralized tuning for one damage type.
function sc_damage_type_config_get(_type)
{
    return global.config.damage.types[_type];
}

/// @description Returns centralized tuning for one damage effect.
function sc_damage_effect_config_get(_effect)
{
    return global.config.damage.effects[_effect];
}

/// @description Creates one immutable damage packet when an attack is spawned.
function sc_damage_packet_create(_definition, _source)
{
    var _type_config = sc_damage_type_config_get(_definition.type);
    var _effect = variable_struct_exists(_definition, "effect")
        ? _definition.effect
        : _type_config.default_effect;

    var _effect_config = sc_damage_effect_config_get(_effect);

    return {
        amount: max(0, _definition.amount),
        type: _definition.type,

        effect: {
            type: _effect,
            chance: variable_struct_exists(_definition, "effect_chance")
                ? _definition.effect_chance
                : _effect_config.chance,
            duration: variable_struct_exists(_definition, "effect_duration")
                ? _definition.effect_duration
                : _effect_config.duration,
            strength: variable_struct_exists(_definition, "effect_strength")
                ? _definition.effect_strength
                : _effect_config.strength,
            tick_interval: variable_struct_exists(_definition, "effect_tick_interval")
                ? _definition.effect_tick_interval
                : _effect_config.tick_interval
        },

        source: {
            owner_id: _source.owner_id,
            faction: _source.faction,
            damage_multiplier: _source.damage_multiplier
        }
    };
}

/// @description Returns packet damage before defence-layer matchups.
function sc_damage_packet_amount_get(_packet)
{
    return _packet.amount * _packet.source.damage_multiplier;
}

/// @description Returns the multiplier for a damage type against one defence layer.
function sc_damage_layer_multiplier_get(_type, _layer)
{
    var _config = sc_damage_type_config_get(_type);

    switch (_layer)
    {
        case "shield": return _config.shield_multiplier;
        case "armour": return _config.armour_multiplier;
        case "hull": return _config.hull_multiplier;
    }

    return 1;
}