/*
Minigun

Contains the complete registration, baked projectile drawing and impact effects
for the Shard's rapid light-kinetic test weapon.
*/


/// @description Registers the Shard's rapid alternating minigun weapon.
function sc_weapon_register_minigun()
{
    return sc_weapon_register({
        identity: { key: "weapon_minigun", name: "Minigun" },
		
		resource: { type: ResourceType.BULLETS, cost: 1 },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_minigun",

            projectile: {
                scale: 1,
                speed: 30,
                life: 120
            },

            damage: {
                amount: 2,
                type: DamageType.KINETIC,
                effect: DamageEffect.NONE
            },

            guidance: {
                homing: 0
            }
        },

        shot: {
            pattern: ShotPattern.RANDOM_CONE,
            amount: 1,
            angle_total: 4
        },

        firing: {
            mount_mode: WeaponMountMode.HARDPOINT,
            interval: 2,
            recoil: 2.5,
            muzzle_flash_duration: 3
        },

        audio: {
            sound: noone,
            volume: 0.2,
            pitch_range: 0.12
        }
    });
}
