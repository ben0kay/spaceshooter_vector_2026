/*
PLAYER DEFENCE UPGRADES

The left-facing defence branch of the universal upgrade tree.
*/

/// @description Returns all defence-category player upgrades.
function sc_player_upgrades_defence_get()
{
    return [
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
        )
    ];
}