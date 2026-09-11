/*
CORPORATION MICRO-MISSILE WEAPONS

Three launcher configurations using one shared projectile.
Enemy attack controllers determine salvo patterns and firing rhythm.
*/

/// @description Registers the balanced Corporation micro-missile launcher.
function sc_weapon_register_corporation_micro_missile()
{
    return sc_weapon_register({
        identity: {
            key: "weapon_corporation_micro_missile",
            name: "Corporation Micro-Missile"
        },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_corporation_micro_missile",

            projectile: {
                scale: 1,
                speed: 24,
                life: 150
            },

            damage: {
                amount: 3,
                type: DamageType.EXPLOSIVE,
                effect: DamageEffect.NONE
            },

            guidance: {
                acquire_range: 1350,
                turn_speed: 3.6,
                reacquire_interval: 8,
				lead_strength: 0,
guidance_delay: 0,
lock_angle: 360,
avoidance: 0
            },

            detonation: {
                scale: 1,

                damage: {
                    amount: 10,
                    type: DamageType.EXPLOSIVE,
                    effect: DamageEffect.NONE,
                    knockback_force: 1.25
                }
            }
        },

        audio: {
            sound: noone,
            volume: 0.42,
            pitch_range: 0.08
        }
    });
}

/// @description Registers the fast high-agility pursuit micro-missile.
function sc_weapon_register_corporation_pursuit_micro_missile()
{
    return sc_weapon_register({
        identity: {
            key: "weapon_corporation_pursuit_micro_missile",
            name: "Corporation Pursuit Micro-Missile"
        },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_corporation_micro_missile",

            projectile: {
                scale: 0.82,
                speed: 31,
                life: 125
            },

            damage: {
                amount: 2,
                type: DamageType.EXPLOSIVE,
                effect: DamageEffect.NONE
            },

            guidance: {

                acquire_range: 1550,
                turn_speed: 5.5,
                reacquire_interval: 5,
				lead_strength: 0,
guidance_delay: 0,
lock_angle: 360,
avoidance: 0
            },

            detonation: {
                scale: 0.78,

                damage: {
                    amount: 7,
                    type: DamageType.EXPLOSIVE,
                    effect: DamageEffect.NONE,
                    knockback_force: 0.75
                }
            }
        },

        audio: {
            sound: noone,
            volume: 0.36,
            pitch_range: 0.12
        }
    });
}

/// @description Registers the slower armour-breaching micro-missile.
function sc_weapon_register_corporation_breach_micro_missile()
{
    return sc_weapon_register({
        identity: {
            key: "weapon_corporation_breach_micro_missile",
            name: "Corporation Breach Micro-Missile"
        },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_corporation_micro_missile",

            projectile: {
                scale: 1.25,
                speed: 18,
                life: 210
            },

            damage: {
                amount: 5,
                type: DamageType.KINETIC,
                effect: DamageEffect.NONE
            },

            guidance: {

                acquire_range: 1700,
                turn_speed: 2.4,
                reacquire_interval: 10,
				lead_strength: 0,
guidance_delay: 0,
lock_angle: 360,
avoidance: 0
            },

            detonation: {
                scale: 1.35,

                damage: {
                    amount: 17,
                    type: DamageType.EXPLOSIVE,
                    effect: DamageEffect.STAGGER,
                    knockback_force: 2.5
                }
            }
        },

        audio: {
            sound: noone,
            volume: 0.52,
            pitch_range: 0.05
        }
    });
}