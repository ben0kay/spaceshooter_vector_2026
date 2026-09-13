/*
PLAYER HYBRID UPGRADES

Cross-branch milestones requiring investment in multiple categories.
The assigned category controls the node's primary colour.
*/

/// @description Returns all cross-category player upgrades.
function sc_player_upgrades_hybrid_get()
{
    return [
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
}