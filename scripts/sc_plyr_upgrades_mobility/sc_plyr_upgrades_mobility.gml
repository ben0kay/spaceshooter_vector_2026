/*
PLAYER MOBILITY UPGRADES

The downward-facing mobility branch of the universal upgrade tree.
*/

/// @description Returns all mobility-category player upgrades.
function sc_player_upgrades_mobility_get()
{
    return [
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
        )
    ];
}