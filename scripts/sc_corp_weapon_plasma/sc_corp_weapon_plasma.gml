/// @description Registers the Corporation interceptor's fast plasma cannon.
function sc_weapon_register_corporation_plasma()
{
    return sc_weapon_register({
        identity: {
            key: "weapon_corporation_plasma",
            name: "Corporation Plasma Cannon"
        },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_corporation_plasma",

            projectile: {
                scale: 1,
                speed: 34,
                life: 105
            },

            damage: {
                amount: 4,
                type: DamageType.ENERGY,
                effect: DamageEffect.NONE
            },

            guidance: {
                homing: 0
            }
        },

        audio: {
            sound: noone,
            volume: 0.3,
            pitch_range: 0.06
        }
    });
}