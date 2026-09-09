/// @description Registers the Corporation unguided heavy artillery launcher.
function sc_weapon_register_corporation_artillery_rocket()
{
    return sc_weapon_register({
        identity: {
            key: "weapon_corporation_artillery_rocket",
            name: "Corporation Heavy Artillery Launcher"
        },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_corporation_artillery_rocket",

            projectile: {
                scale: 1.45,
                speed: 18,
                life: 330
            },

            damage: {
                amount: 16,
                type: DamageType.EXPLOSIVE,
                effect: DamageEffect.NONE
            },

            guidance: {
                homing: 0
            },

            detonation: {
                scale: 1.35,

                damage: {
                    amount: 42,
                    type: DamageType.EXPLOSIVE,
                    effect: DamageEffect.STAGGER,
                    knockback_force: 5
                }
            }
        },

        audio: {
            sound: noone,
            volume: 0.82,
            pitch_range: 0.035
        }
    });
}