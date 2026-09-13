/*
PLAYER SYSTEM UPGRADES

The upward-facing systems branch of the universal upgrade tree.
*/

/// @description Returns all systems-category player upgrades.
function sc_player_upgrades_systems_get()
{
    return [
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
        )
    ];
}