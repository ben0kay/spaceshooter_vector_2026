/// @description Creates the player stat pipeline from immutable ship base stats.
function sc_player_stats_init(_player,_stats_base)
{
    sc_player_upgrades_modifiers_rebuild();

    var _base = variable_clone(_stats_base);
    sc_player_stats_system_defaults_apply(_base);

    _player.ship.stats = {
        base:_base,

		
		modifiers: {
	    level: [],       // future level-based bonuses
	    persistent: variable_clone(global.profile.persistent_modifiers),  // upgrade tree
	    equipment: [],   // weapons / fitted non-module gear
	    modules: [],     // armour, shield, reactor, thruster, etc.
	    local: [],       // unused / reserved
	    temporary: []    // gas clouds, buffs, debuffs, temporary effects
	},

        final: {},
        dirty: true
    };

    return sc_player_stats_recalculate(_player);
}

/// @description Rebuilds final player stats only when a modifier source changes.
function sc_player_stats_recalculate(_player)
{
    var _stats = _player.ship.stats;
    if (!_stats.dirty) return false;

    _stats.final = variable_clone(_stats.base);

    sc_stats_modifiers_apply(_stats.final,_stats.modifiers.level);
    sc_stats_modifiers_apply(_stats.final,_stats.modifiers.persistent);
    sc_stats_modifiers_apply(_stats.final,_stats.modifiers.equipment);
    sc_stats_modifiers_apply(_stats.final,_stats.modifiers.modules);
    sc_stats_modifiers_apply(_stats.final,_stats.modifiers.local);
    sc_stats_modifiers_apply(_stats.final,_stats.modifiers.temporary);

    _stats.final.mass = max(0.1,_stats.final.mass);

    _stats.dirty = false;
    return true;
}

/// @description Synchronizes calculated final stats into live player capacities without restoring damage or spent resources.
function sc_player_stats_runtime_sync(_player)
{
    var _final = _player.ship.stats.final;

    _player.defence.shield.maximum = _final.shield_max;
    _player.defence.shield.current = min(_player.defence.shield.current,_final.shield_max);

    _player.defence.armour.maximum = _final.armour_max;
    _player.defence.armour.current = min(_player.defence.armour.current,_final.armour_max);

    _player.defence.hull.maximum = _final.hull_max;
    _player.defence.hull.current = min(_player.defence.hull.current,_final.hull_max);

    _player.resources.energy.maximum = _final.energy_max;
    _player.resources.energy.current = min(_player.resources.energy.current,_final.energy_max);

    _player.resources.fuel.maximum = _final.fuel_max;
    _player.resources.fuel.current = min(_player.resources.fuel.current,_final.fuel_max);

    _player.resources.bullets.maximum = _final.bullets_max;
    _player.resources.bullets.current = min(_player.resources.bullets.current,_final.bullets_max);

    _player.resources.explosives.maximum = _final.explosives_max;
    _player.resources.explosives.current = min(_player.resources.explosives.current,_final.explosives_max);

    _player.resources.cargo.capacity = _final.cargo_capacity;
    return true;
}

/// @description Recalculates changed ship stats and synchronizes their live runtime values.
function sc_player_stats_refresh(_player)
{
    _player.ship.stats.dirty = true;
    sc_player_stats_recalculate(_player);
    return sc_player_stats_runtime_sync(_player);
}

/// @description Rebuilds ship-stat modifiers from currently installed modules.
function sc_player_modules_modifiers_rebuild(_player)
{
    var _modifiers = [];
    var _equipment = _player.inventory.equipment;

    // Armour module.
    if (!is_undefined(_equipment.armour))
    {
        var _item = _equipment.armour;
        var _definition = variable_struct_get(global.data.items,_item.key);
        var _module = _definition.module;

        array_push(_modifiers,{
            stat: "armour_max",
            multiply: _module.effectiveness * sc_item_grade_multiplier_get(_item.grade)
        });
    }

    _player.ship.stats.modifiers.modules = _modifiers;
    return true;
}

/// @description Adds default system stats missing from an older ship definition.
function sc_player_stats_system_defaults_apply(_stats)
{
    var _defaults = {
        system_disruption_resistance: 0,
        system_disruption_strength_resistance: 0,
        system_recovery_multiplier: 1,

        engines_disruption_resistance: 0,
        thrusters_disruption_resistance: 0,
        shield_generator_disruption_resistance: 0,
        reactor_disruption_resistance: 0,
        cooling_disruption_resistance: 0,
        weapons_disruption_resistance: 0,
        sensors_disruption_resistance: 0,
        drone_bay_disruption_resistance: 0,

        engines_disruption_strength_resistance: 0,
        thrusters_disruption_strength_resistance: 0,
        shield_generator_disruption_strength_resistance: 0,
        reactor_disruption_strength_resistance: 0,
        cooling_disruption_strength_resistance: 0,
        weapons_disruption_strength_resistance: 0,
        sensors_disruption_strength_resistance: 0,
        drone_bay_disruption_strength_resistance: 0,

        weapon_heat_maximum: 100,
        weapon_heat_generation_multiplier: 1,
        weapon_cooling_rate: 1,
        weapon_cooling_delay_multiplier: 1,

        cooling_capacity: 100,
        cooling_efficiency: 1,

        weapon_spread_multiplier: 1,
        weapon_recoil_multiplier: 1
    };

    var _names = variable_struct_get_names(_defaults);

    for (var _i = 0; _i < array_length(_names); _i++)
    {
        var _key = _names[_i];

        if (!variable_struct_exists(_stats, _key))
        {
            variable_struct_set(
                _stats,
                _key,
                variable_struct_get(_defaults, _key)
            );
        }
    }

    return true;
}