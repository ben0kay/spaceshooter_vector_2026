/*
REBEL MINIGUN

Reuses the shared golden minigun projectile.
Damage, projectile scale, speed and firing behavior belong to this weapon.
*/

/// @description Registers the standard Rebel rotating minigun.
function sc_weapon_register_rebel_minigun()
{
    return sc_weapon_register({
        identity: {
            key: "weapon_rebel_minigun",
            name: "Rebel Minigun"
        },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_minigun",

            projectile: {
                scale: 1,
                speed: 48,
                life: 120
            },

            damage: {
                amount: 2.5,
                type: DamageType.KINETIC,
                effect: DamageEffect.NONE
            },

            guidance: {
                homing: 0
            }
        },

        audio: {
            sound: noone,
            volume: 0.26,
            pitch_range: 0.16
        }
    });
}