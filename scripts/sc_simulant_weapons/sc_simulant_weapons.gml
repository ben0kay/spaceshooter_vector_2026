/// @description Registers the reusable Simulant pulse weapon.
function sc_weapon_register_simulant_pulse()
{
    return sc_weapon_register({
        identity: {
            key: "weapon_simulant_pulse",
            name: "Simulant Pulse Cannon"
        },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_simulant_pulse"
        },

        audio: {
            sound: noone,
            volume: 0.3,
            pitch_range: 0.08
        }
    });
}
