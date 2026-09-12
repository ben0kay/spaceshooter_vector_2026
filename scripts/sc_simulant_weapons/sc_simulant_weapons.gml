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

            guidance: 0,
        },

        audio: {
            sound: noone,
            volume: 0.3,
            pitch_range: 0.08
        }
    });
}

/// @description Registers the standard Simulant orb cannon.
function sc_weapon_register_simulant_orb()
{
    return sc_weapon_register({
        identity: {
            key: "weapon_simulant_orb",
            name: "Simulant Orb Cannon"
        },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_simulant_orb",

            projectile: {
                scale: 1,
                speed: 11,
                life: 180
            },

            damage: {
                amount: 9,
                type: DamageType.ENERGY,
                effect: DamageEffect.NONE
            },

            guidance: 0
        },

        audio: {
            sound: noone,
            volume: 0.5,
            pitch_range: 0.06
        }
    });
}

/// @description Registers the short-lived Simulant dividing-orb weapon.
function sc_weapon_register_simulant_dividing_orb()
{
    return sc_weapon_register({
        identity: {
            key: "weapon_simulant_dividing_orb",
            name: "Simulant Dividing Orb"
        },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_simulant_dividing_orb",

            projectile: {
                scale: 2,
                speed: 7,
                life: 48
            },

            damage: {
                amount: 14,
                type: DamageType.ENERGY,
                effect: DamageEffect.NONE
            },

            guidance: 0
        },

        audio: {
            sound: noone,
            volume: 0.65,
            pitch_range: 0.05
        }
    });
}

/// @description Registers the rapid-fire Simulant shard cannon.
function sc_weapon_register_simulant_shard()
{
    return sc_weapon_register({
        identity: {
            key: "weapon_simulant_shard",
            name: "Simulant Shard Cannon"
        },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_simulant_shard",

            projectile: {
                scale: 1,
                speed: 22,
                life: 85
            },

            damage: {
                amount: 3,
                type: DamageType.KINETIC,
                effect: DamageEffect.NONE
            },

            guidance: 0
        },

        audio: {
            sound: noone,
            volume: 0.36,
            pitch_range: 0.12
        }
    });
}