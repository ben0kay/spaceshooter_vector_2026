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
                speed: 48,
                life: 120
            },

            damage: {
                amount: 2,
                type: DamageType.KINETIC,
                effect: DamageEffect.NONE
            },

            guidance: 0
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

        heat: {
            amount: 1.4,
            cooling_delay: 35
        },

        audio: {
            mode: WeaponAudioMode.LOOP,
            sound: snd_minigun_fire,
            volume: 0.28,
            pitch_range: 0.02,
            priority: 85,
            release_delay: 4
        }
    });
}
