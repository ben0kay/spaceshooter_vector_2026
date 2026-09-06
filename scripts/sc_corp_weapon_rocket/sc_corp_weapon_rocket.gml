/// @description Registers the Corporation battleship rocket launcher.
function sc_weapon_register_corporation_rocket()
{
    return sc_weapon_register({
        identity: {
            key: "weapon_corporation_rocket",
            name: "Corporation Rocket Launcher"
        },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_corporation_rocket",

            projectile: {
                scale: 1.25,
                speed: 12,
                life: 240
            },

            damage: {
                amount: 8,
                type: DamageType.EXPLOSIVE,
                effect: DamageEffect.NONE
            },

            guidance: {
                homing: 1,
                acquire_range: 1800,
                turn_speed: 1.6,
                reacquire_interval: 10
            },

            detonation: {
                scale: 1,

                damage: {
                    amount: 18,
                    type: DamageType.EXPLOSIVE,
                    effect: DamageEffect.STAGGER,
                    knockback_force: 3
                }
            }
        },

        audio: {
            sound: noone,
            volume: 0.62,
            pitch_range: 0.05
        }
    });
}