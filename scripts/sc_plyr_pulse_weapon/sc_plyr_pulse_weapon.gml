/// @description Registers the Shard's reusable pulse weapon.
function sc_weapon_register_shard_pulse()
{
    return sc_weapon_register({
        identity: { key: "weapon_shard_pulse", name: "Shard Pulse" },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_shard_pulse"
        },

        shot: {
            pattern: ShotPattern.SINGLE,
            amount: 1,
            angle_total: 0
        },

        firing: {
            mount_mode: WeaponMountMode.HARDPOINT,
            interval: 8,
            recoil: 6,
            muzzle_flash_duration: 8
        },

        audio: {
            sound: noone,
            volume: 0.3,
            pitch_range: 0.06
        }
    });
}