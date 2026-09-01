/// @description Creates centralized game-wide tuning values.
function sc_config_init()
{
    global.config = {
        damage: {
            types: [
                {
                    name: "Kinetic",
                    shield_multiplier: 0.65,
                    armour_multiplier: 1.35,
                    hull_multiplier: 1,
                    default_effect: DamageEffect.NONE
                },
                {
                    name: "Energy",
                    shield_multiplier: 1.5,
                    armour_multiplier: 0.75,
                    hull_multiplier: 1,
                    default_effect: DamageEffect.NONE
                },
                {
                    name: "Explosive",
                    shield_multiplier: 0.75,
                    armour_multiplier: 1,
                    hull_multiplier: 1.4,
                    default_effect: DamageEffect.NONE
                },
                {
                    name: "Electric",
                    shield_multiplier: 1.15,
                    armour_multiplier: 0.55,
                    hull_multiplier: 0.75,
                    default_effect: DamageEffect.DISRUPTION
                },
                {
                    name: "Thermal",
                    shield_multiplier: 0.4,
                    armour_multiplier: 1.1,
                    hull_multiplier: 1.25,
                    default_effect: DamageEffect.BURN
                },
                {
                    name: "Corrosive",
                    shield_multiplier: 0.55,
                    armour_multiplier: 1.3,
                    hull_multiplier: 1.2,
                    default_effect: DamageEffect.CORROSION
                }
            ],

            effects: [
                {
                    name: "None",
                    chance: 0,
                    duration: 0,
                    strength: 0,
                    tick_interval: 0
                },
                {
                    name: "Disruption",
                    chance: 0.25,
                    duration: 180,
                    strength: 0.25,
                    tick_interval: 0
                },
                {
                    name: "Burn",
                    chance: 0.2,
                    duration: 180,
                    strength: 0.15,
                    tick_interval: 30
                },
                {
                    name: "Corrosion",
                    chance: 0.25,
                    duration: 240,
                    strength: 0.2,
                    tick_interval: 30
                }
            ]
        }
    };

    return true;
}