/// @description Registers the Rebel Incendiary Cannon.
function sc_weapon_register_rebel_incendiary_cannon()
{
    return sc_weapon_register({
        identity: {
            key: "weapon_rebel_incendiary_cannon",
            name: "Rebel Incendiary Cannon"
        },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_rebel_incendiary_canister",

            projectile: {
                scale: 1,
                speed: 16,
                life: 55
            },

            damage: {
                amount: 2,
                type: DamageType.KINETIC,
                effect: DamageEffect.NONE
            },

            guidance: 0,

            detonation: {
                scale: 1,

                damage: {
                    amount: 3,
                    type: DamageType.THERMAL,
                    effect: DamageEffect.BURN,
                    effect_chance: 0.2
                }
            }
        },

        audio: {
            sound: noone,
            volume: 0.48,
            pitch_range: 0.1
        }
    });
}