/// @description Registers the Rebel Skirmisher's improvised kinetic slug cannon.
function sc_weapon_register_rebel_slug_cannon()
{
    return sc_weapon_register({
        identity: {
            key: "weapon_rebel_slug_cannon",
            name: "Rebel Scrap Cannon"
        },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_rebel_slug",

            projectile: {
                scale: 1,
                speed: 27,
                life: 120
            },

            damage: {
                amount: 7,
                type: DamageType.KINETIC,
                effect: DamageEffect.NONE
            },

            guidance: {
                homing: 0
            }
        },

        audio: {
            sound: noone,
            volume: 0.38,
            pitch_range: 0.12
        }
    });
}