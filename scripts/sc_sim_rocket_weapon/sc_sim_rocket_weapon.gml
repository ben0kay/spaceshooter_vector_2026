
/// @description Registers the Dreadnaught's large homing rocket weapon.
function sc_weapon_register_simulant_dreadnaught_rocket()
{
    return sc_weapon_register({
        identity: {
            key: "weapon_simulant_dreadnaught_rocket",
            name: "Dreadnaught Heavy Rocket"
        },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_simulant_rocket",

            projectile: {
                scale: 2,
                speed: 8.5,
                life: 300
            },

            damage: {
                amount: 18,
                type: DamageType.EXPLOSIVE,
                effect: DamageEffect.NONE
            },

            guidance: {
                homing: 0,
                acquire_range: 1800,
                turn_speed: 1.45,
                reacquire_interval: 10
            },

            detonation: {
                scale: 1.75,

                damage: {
                    amount: 55,
                    type: DamageType.EXPLOSIVE,
                    effect: DamageEffect.STAGGER
                }
            }
        },

        audio: {
            sound: noone,
            volume: 0.8,
            pitch_range: 0.04
        }
    });
}

