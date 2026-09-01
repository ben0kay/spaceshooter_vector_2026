/// @description Registers the reusable Simulant pulse projectile.
function sc_projectile_register_simulant_pulse()
{
    var _palette = sc_faction_palette_get(Faction.SIMULANT);

    return sc_projectile_register({
        identity: { key: "projectile_simulant_pulse", name: "Simulant Pulse" },
        movement: { speed: 17.5 },
        damage: { amount: 3, type: DamageType.PLASMA },
        collision: { radius: 6 },
        life: { maximum: 180 },

        visual: {
            radius: 6,
            length: 24,
            colour_primary: _palette.energy,
            colour_secondary: _palette.core
        }
    });
}

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

/// @description Registers the first complete Twin Fighter.
function sc_enemy_register_twin_fighter()
{
    return sc_enemy_register({
        identity: {
            key: "enemy_twin_fighter",
            name: "Twin Fighter",
            faction: Faction.SIMULANT
        },

        defence: {
            shield_max: 10,
            armour_max: 200,
            hull_max: 60
        },

        movement: {
            speed_max: 5.5,
            acceleration: 0.3,
            friction: 0.985,
            turn_speed: 4
        },

        range: {
            detection: 1080,
            combat: 840,
            forget: 1280
        },

        visual: {
	    radius: 58,
	    palette: sc_faction_palette_get(Faction.SIMULANT),

	    draw: {
	        body: sc_enemy_twin_fighter_body_draw,
	        core: sc_enemy_twin_fighter_core_draw
	    },

	    thrust: {
	        draw_script: sc_enemy_simulant_thrust_draw,
	        ignition_script: sc_particles_simulant_ignition,
	        particle_script: sc_particles_simulant_thrust
	    },

	    bake: {
	        body_canvas_size: 256,
	        core_canvas_size: 128,
	        hardpoint_canvas_size: 128,
	        thrust_canvas_size: 128
	    }
	},

        collision: {
            radius_scale: 0.62,
            blocks_player: true
        },

        hardpoints: [
            {
                key: "cannon_left",
                group: "cannons",
                forward: 0.83,
                side: -0.48,
                angle: 0,
                muzzle_forward: 0.48,
                draw_script: sc_enemy_twin_fighter_cannon_draw
            },
            {
                key: "cannon_right",
                group: "cannons",
                forward: 0.83,
                side: 0.48,
                angle: 0,
                muzzle_forward: 0.48,
                draw_script: sc_enemy_twin_fighter_cannon_draw
            }
        ],

        thrusters: [
            {
                key: "thruster_left",
                forward: -0.86,
                side: -0.32,
                angle: 180,
                scale: 0.9
            },
            {
                key: "thruster_right",
                forward: -0.86,
                side: 0.32,
                angle: 180,
                scale: 0.9
            }
        ],

        attack_controller: {
            selection: AttackSelection.WEIGHTED,

            attacks: [
                {
                    key: "alternating_cannons",
                    weight: 100,
                    hardpoint_group: "cannons",
                    weapon_key: "weapon_simulant_pulse",

                    aim: {
                        mode: AimMode.TARGET,
                        angle_offset: 0,
                        inaccuracy: 2
                    },

                    shot: {
                        pattern: ShotPattern.SINGLE,
                        amount: 1
                    },

                    firing: {
                        order: HardpointFireOrder.SEQUENTIAL,
                        interval: 10,
                        volley_max: 16,
                        cooldown: 120
                    }
                }
            ]
        }
    });
}