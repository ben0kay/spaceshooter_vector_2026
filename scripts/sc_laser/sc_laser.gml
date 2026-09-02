/*
SHARD LASER

Slot 3 test weapon.
Uses one centre-mounted capsule damage query when fired.
The attack-area object remains briefly afterward for visuals only.
*/

/// @description Registers the Shard's centre-mounted aqua laser beam.
function sc_weapon_register_shard_laser()
{
    var _palette = variable_struct_get(global.data.ships, "ship_shard").visual.palette;

    return sc_weapon_register({
        identity: { key: "weapon_shard_laser", name: "Shard Laser" },

        delivery: {
            type: AttackDelivery.BEAM,
            scale: 1,

            damage: {
                amount: 24,
                type: DamageType.ENERGY,
                effect: DamageEffect.NONE
            },

            area: {
                shape: AttackAreaShape.CAPSULE,
                geometry: { length: 1100, radius: 8 },

                behaviour: {
                    duration: 10,
                    tick_interval: 0,
                    hit_once: true,
                    max_targets: 0
                },

                visual: {
                    palette: _palette,
                    draw_script: sc_attack_area_shard_laser_draw
                }
            }
        },

        shot: {
            pattern: ShotPattern.SINGLE,
            amount: 1,
            angle_total: 0
        },

        firing: {
            mount_mode: WeaponMountMode.CENTRE,
            interval: 24,
            recoil: 0,
            muzzle_flash_duration: 0
        },

        audio: {
            sound: noone,
            volume: 0.5,
            pitch_range: 0.03
        }
    });
}

/// @description Draws the short-lived expanding and fading Shard laser.
function sc_attack_area_shard_laser_draw(_area, _data)
{
    var _p = _data.visual.palette;
    var _geometry = _data.geometry;
    var _runtime = _data.runtime;
    var _life_ratio = _runtime.life / _data.behaviour.duration;
    var _birth = 1 - _life_ratio;
    var _width = _geometry.radius * (0.7 + sin(min(1, _birth * 4) * pi * 0.5) * 0.55);
    var _end_x = _area.x + lengthdir_x(_geometry.length, _data.direction);
    var _end_y = _area.y + lengthdir_y(_geometry.length, _data.direction);
    var _alpha = clamp(_life_ratio * 1.35, 0, 1);

    gpu_set_blendmode(bm_add);

    draw_set_alpha(_alpha * 0.13);
    draw_set_colour(_p.glow);
    draw_line_width(_area.x, _area.y, _end_x, _end_y, _width * 4.2);

    draw_set_alpha(_alpha * 0.4);
    draw_set_colour(_p.energy);
    draw_line_width(_area.x, _area.y, _end_x, _end_y, _width * 2.25);

    draw_set_alpha(_alpha * 0.9);
    draw_set_colour(_p.core);
    draw_line_width(_area.x, _area.y, _end_x, _end_y, max(3, _width * 0.85));

    draw_set_alpha(_alpha);
    draw_set_colour(c_white);
    draw_line_width(_area.x, _area.y, _end_x, _end_y, max(1, _width * 0.28));

    draw_set_alpha(_alpha * 0.3);
    draw_set_colour(_p.glow);
    draw_circle(_area.x, _area.y, _width * 3.2, false);

    draw_set_alpha(_alpha);
    draw_set_colour(_p.core);
    draw_circle(_area.x, _area.y, _width * 0.85, false);
}