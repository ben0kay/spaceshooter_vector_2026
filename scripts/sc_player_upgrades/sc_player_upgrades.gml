/*
PLAYER UPGRADES

Persistent upgrade ranks generate the player's persistent stat modifiers.
String keys are used because purchased ranks are written into profile JSON.
*/

/// @description Creates one data-driven player upgrade definition.
function sc_player_upgrade_create(
    _key,_name,_description,_category,_x,_y,_maximum_rank,_requirements,_modifiers,
    _effect_script = undefined
)
{
    return {
        key: _key,
        name: _name,
        description: _description,
        category: _category,
        position: { x: _x, y: _y },
        maximum_rank: _maximum_rank,
        cost_per_rank: 1,
        requirements: _requirements,
        modifiers: _modifiers,
        effect_script: _effect_script
    };
}

/// @description Returns the universal four-direction player upgrade tree.
function sc_player_upgrades_get()
{
    static _upgrades = [
        // Weapons branch: right.
        sc_player_upgrade_create(
            "weapon_calibration","WEAPON CALIBRATION",
            "Increases all player weapon damage by 5% per rank.",
            UpgradeCategory.WEAPONS,610,425,3,[],
            [{ stat: "damage_multiplier", multiply_per_rank: 0.05 }]
        ),

        sc_player_upgrade_create(
            "weapon_cycling","CYCLING SYSTEMS",
            "Increases weapon fire rate by 4% per rank.",
            UpgradeCategory.WEAPONS,760,425,3,
            [{ key: "weapon_calibration", rank: 1 }],
            [{ stat: "fire_rate_multiplier", multiply_per_rank: 0.04 }]
        ),

        sc_player_upgrade_create(
            "weapon_ordnance","ORDNANCE RACKS",
            "Increases explosive ammunition capacity by 20 per rank.",
            UpgradeCategory.WEAPONS,910,425,3,
            [{ key: "weapon_calibration", rank: 2 }],
            [{ stat: "explosives_max", add_per_rank: 20 }]
        ),

        // Defence branch: left.
        sc_player_upgrade_create(
            "defence_hull","REINFORCED FRAME",
            "Increases maximum hull by 20 per rank.",
            UpgradeCategory.DEFENCE,340,425,3,[],
            [{ stat: "hull_max", add_per_rank: 20 }]
        ),

        sc_player_upgrade_create(
            "defence_armour","COMPOSITE ARMOUR",
            "Increases maximum armour by 20 per rank.",
            UpgradeCategory.DEFENCE,190,425,3,
            [{ key: "defence_hull", rank: 1 }],
            [{ stat: "armour_max", add_per_rank: 20 }]
        ),

        sc_player_upgrade_create(
		    "defence_shield","SHIELD GENERATOR",
		    "Installs a defensive shield generator and increases shield capacity by 40 per rank.",
		    UpgradeCategory.DEFENCE,40,425,3,
		    [{ key: "defence_armour", rank: 1 }],
		    [{ stat: "shield_max", add_per_rank: 40 }]
		),

        // Systems branch: up.
        sc_player_upgrade_create(
            "systems_reactor","REACTOR CAPACITY",
            "Increases maximum energy by 40 per rank.",
            UpgradeCategory.SYSTEMS,475,290,3,[],
            [{ stat: "energy_max", add_per_rank: 40 }]
        ),

        sc_player_upgrade_create(
            "systems_cargo","CARGO EXPANSION",
            "Increases cargo capacity by 15 per rank.",
            UpgradeCategory.SYSTEMS,475,140,3,
            [{ key: "systems_reactor", rank: 1 }],
            [{ stat: "cargo_capacity", add_per_rank: 15 }]
        ),

        sc_player_upgrade_create(
		    "systems_extraction","EXTRACTION ANALYSIS",
		    "Increases mining strength and asteroid resource yield per rank.",
		    UpgradeCategory.SYSTEMS,475,-10,3,
		    [{ key: "systems_cargo", rank: 1 }],
		    [
		        { stat: "mining_strength", add_per_rank: 1 },
		        { stat: "resource_yield_multiplier", multiply_per_rank: 0.05 }
		    ]
		),

        // Mobility branch: down.
        sc_player_upgrade_create(
            "mobility_thrusters","THRUSTER RESPONSE",
            "Increases acceleration by 0.04 per rank.",
            UpgradeCategory.MOBILITY,475,560,3,[],
            [{ stat: "acceleration", add_per_rank: 0.04 }]
        ),

        sc_player_upgrade_create(
            "mobility_velocity","VECTOR DRIVE",
            "Increases maximum speed by 0.35 per rank.",
            UpgradeCategory.MOBILITY,475,710,3,
            [{ key: "mobility_thrusters", rank: 1 }],
            [{ stat: "speed_max", add_per_rank: 0.35 }]
        ),

        sc_player_upgrade_create(
            "mobility_handling","MANEUVERING JETS",
            "Increases turning speed by 0.4 per rank.",
            UpgradeCategory.MOBILITY,475,860,3,
            [{ key: "mobility_velocity", rank: 1 }],
            [{ stat: "turn_speed", add_per_rank: 0.4 }]
        ),

        // Cross-category hybrid nodes.
        sc_player_upgrade_create(
            "hybrid_overcharge","WEAPON OVERCHARGE",
            "Combines weapon calibration and reactor output for greater damage and energy.",
            UpgradeCategory.WEAPONS,680,225,1,
            [
                { key: "weapon_cycling", rank: 2 },
                { key: "systems_reactor", rank: 2 }
            ],
            [
                { stat: "damage_multiplier", multiply_per_rank: 0.08 },
                { stat: "energy_max", add_per_rank: 60 }
            ]
        ),

        sc_player_upgrade_create(
            "hybrid_vector_armour","VECTOR ARMOUR",
            "Improves armour and reduces dash recovery time.",
            UpgradeCategory.DEFENCE,270,625,1,
            [
                { key: "defence_armour", rank: 2 },
                { key: "mobility_velocity", rank: 2 }
            ],
            [
                { stat: "armour_max", add_per_rank: 30 },
                { stat: "dash_cooldown", add_per_rank: -10 }
            ]
        ),

        sc_player_upgrade_create(
            "hybrid_expedition","EXPEDITION MATRIX",
            "Combines mobility and industrial systems for extended operations.",
            UpgradeCategory.SYSTEMS,680,625,1,
            [
                { key: "mobility_handling", rank: 2 },
                { key: "systems_cargo", rank: 2 }
            ],
            [
                { stat: "fuel_max", add_per_rank: 150 },
                { stat: "resource_yield_multiplier", multiply_per_rank: 0.08 }
            ]
        )
    ];

    return _upgrades;
}

/// @description Returns one upgrade definition from its persistent string key.
function sc_player_upgrade_get(_key)
{
    var _upgrades = sc_player_upgrades_get();

    for (var _i = 0; _i < array_length(_upgrades); ++_i)
        if (_upgrades[_i].key == _key) return _upgrades[_i];

    return undefined;
}

/// @description Returns the currently purchased rank of one upgrade.
function sc_player_upgrade_rank_get(_key)
{
    var _ranks = global.profile.progression.upgrade_ranks;
    return variable_struct_exists(_ranks,_key)
        ? variable_struct_get(_ranks,_key)
        : 0;
}

/// @description Returns whether every prerequisite for an upgrade is satisfied.
function sc_player_upgrade_requirements_met(_upgrade)
{
    for (var _i = 0; _i < array_length(_upgrade.requirements); ++_i)
    {
        var _requirement = _upgrade.requirements[_i];

        if (sc_player_upgrade_rank_get(_requirement.key) < _requirement.rank)
            return false;
    }

    return true;
}

/// @description Returns whether the player can purchase the next upgrade rank.
function sc_player_upgrade_can_purchase(_upgrade)
{
    var _rank = sc_player_upgrade_rank_get(_upgrade.key);

    return _rank < _upgrade.maximum_rank
        && sc_player_upgrade_requirements_met(_upgrade)
        && global.profile.progression.data_shards >= _upgrade.cost_per_rank;
}

/// @description Rebuilds profile modifiers from all purchased upgrade ranks.
function sc_player_upgrades_modifiers_rebuild()
{
    var _upgrades = sc_player_upgrades_get();
    var _modifiers = [];

    for (var _i = 0; _i < array_length(_upgrades); ++_i)
    {
        var _upgrade = _upgrades[_i];
        var _rank = sc_player_upgrade_rank_get(_upgrade.key);
        if (_rank <= 0) continue;

        for (var _j = 0; _j < array_length(_upgrade.modifiers); ++_j)
        {
            var _source = _upgrade.modifiers[_j];
            var _modifier = { stat: _source.stat };

            if (variable_struct_exists(_source,"add_per_rank"))
                _modifier.add = _source.add_per_rank * _rank;

            if (variable_struct_exists(_source,"multiply_per_rank"))
                _modifier.multiply = 1 + _source.multiply_per_rank * _rank;

            array_push(_modifiers,_modifier);
        }
    }

    global.profile.persistent_modifiers = _modifiers;
    return true;
}

/// @description Applies rebuilt persistent upgrade modifiers to the active player.
function sc_player_upgrades_live_refresh()
{
    if (!instance_exists(global.player_id)) return false;

    var _player = global.player_id;
    var _stats = _player.ship.stats;

    _stats.modifiers.persistent = variable_clone(
        global.profile.persistent_modifiers
    );

    _stats.dirty = true;
    sc_player_stats_recalculate(_player);

    var _final = _stats.final;

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

/// @description Purchases one upgrade rank and refreshes the active player.
function sc_player_upgrade_purchase(_key)
{
    var _upgrade = sc_player_upgrade_get(_key);
    if (is_undefined(_upgrade) || !sc_player_upgrade_can_purchase(_upgrade))
        return false;

    var _progression = global.profile.progression;
    var _rank = sc_player_upgrade_rank_get(_key) + 1;

    variable_struct_set(_progression.upgrade_ranks,_key,_rank);
    _progression.data_shards -= _upgrade.cost_per_rank;

    sc_player_upgrades_modifiers_rebuild();
    sc_player_upgrades_live_refresh();

    if (!is_undefined(_upgrade.effect_script))
        script_execute(_upgrade.effect_script,global.player_id,_rank);

    sc_profile_save();

    // Insert upgrade-purchase audio and particles here later.
    return true;
}

