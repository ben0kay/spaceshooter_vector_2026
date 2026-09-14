/// @description Registers the Dreadwing's heavy seeker-core weapon.
function sc_weapon_register_simulant_seeker_core()
{
    return sc_weapon_register({
        identity: {
            key: "weapon_simulant_seeker_core",
            name: "Simulant Seeker Core"
        },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_simulant_seeker_core",

            projectile: {
                scale: 1.2,
                speed: 12,
                life: 250
            },

            damage: {
			    amount: 10,
			    type: DamageType.ENERGY,
			    effect: DamageEffect.DISRUPTION,
			    effect_chance: 1,
			    effect_duration: 150,
			    effect_strength: 0.7,

			    effect_systems: [
			        "weapons",
			        "thrusters"
			    ],

			    effect_system_count: 1
			},

            guidance: {
			    acquire_range: 1500,
			    turn_speed: 1.65,
			    reacquire_interval: 8,
			    lead_strength: 0,
			    guidance_delay: 0,
			    lock_angle: 360,
			    avoidance: 0
			},

            detonation: {
                scale: 1.15,

                damage: {
                    amount: 28,
                    type: DamageType.ENERGY,
                    effect: DamageEffect.STAGGER,
                    effect_chance: 1,
                    effect_duration: 18,
                    effect_strength: 0.55,
                    knockback_force: 4
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