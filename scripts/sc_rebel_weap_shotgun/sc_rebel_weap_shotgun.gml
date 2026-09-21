/// @description Registers the Mongrel's shrapnel-carrying cannon round.
function sc_weapon_register_rebel_mongrel_carrier()
{
    return sc_weapon_register({
        identity: {
            key: "weapon_rebel_mongrel_carrier",
            name: "Mongrel Scrap Shotgun"
        },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_rebel_mongrel_carrier",

            projectile: {
                scale: 1,
                speed: 22,
                life: 75
            },

            damage: {
                amount: 5,
                type: DamageType.KINETIC,
                effect: DamageEffect.NONE
            },

            guidance: 0
        },

        audio: {
            sound: noone,
            volume: 0.45,
            pitch_range: 0.1
        }
    });
}

/// @description Registers each kinetic shard released by the carrier.
function sc_weapon_register_rebel_shrapnel()
{
    return sc_weapon_register({
        identity: {
            key: "weapon_rebel_shrapnel",
            name: "Mongrel Scrap Shrapnel"
        },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_rebel_shrapnel",

            projectile: {
                scale: 1,
                speed: 20,
                life: 22
            },

            damage: {
                amount: 2.5,
                type: DamageType.KINETIC,
                effect: DamageEffect.NONE
            },

            guidance: 0
        },

        audio: {
            sound: noone,
            volume: 0,
            pitch_range: 0
        }
    });
}