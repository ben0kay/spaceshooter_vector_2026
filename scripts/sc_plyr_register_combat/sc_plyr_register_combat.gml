/// @description Registers the Shard's reusable animated aqua pulse projectile.
function sc_projectile_register_shard_pulse()
{
    var _palette = variable_struct_get(global.data.ships, "ship_shard").visual.palette;

    return sc_projectile_register({
        identity: { key: "projectile_shard_pulse", name: "Shard Pulse" },
        movement: { speed: 19 },
        damage: { amount: 8, type: DamageType.ENERGY, effect: DamageEffect.NONE },
        collision: { radius: 5 },
        life: { maximum: 150 },

        visual: {
            radius: 5,
            length: 21,
            palette: _palette,
            draw_script: sc_projectile_shard_pulse_draw,

            bake: {
                canvas_size: 96,
                frames: 6,
                frame_speed: 2
            }
        }
    });
}
/// @description Registers the Shard's alternating primary pulse cannons.
function sc_weapon_register_shard_pulse()
{
    return sc_weapon_register({
        identity: { key: "weapon_shard_pulse", name: "Shard Pulse Cannons" },

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
            interval: 8
        },

        audio: {
            sound: noone,
            volume: 0.3,
            pitch_range: 0.06
        }
    });
}