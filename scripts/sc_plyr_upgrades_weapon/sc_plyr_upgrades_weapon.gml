/*
PLAYER WEAPON UPGRADES

The right-facing weapon branch of the universal upgrade tree.
*/

/// @description Returns all weapon-category player upgrades.
function sc_player_upgrades_weapons_get()
{
    return [
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
        )
    ];
}