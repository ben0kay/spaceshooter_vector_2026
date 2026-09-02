/// @description Registers the standard Simulant pulse cannon.
function sc_weapon_register_simulant_pulse()
{
    return sc_weapon_register({
        identity: {
            key: "weapon_simulant_pulse",
            name: "Simulant Pulse Cannon"
        },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_simulant_pulse",

            projectile: {
                scale: 1,
                speed: 17.5,
                life: 180
            },

            damage: {
                amount: 3,
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
            pitch_range: 0.08
        }
    });
}