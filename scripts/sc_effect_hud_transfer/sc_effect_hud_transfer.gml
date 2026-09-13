/*
HUD TRANSFERS

Creates lightweight visual packets travelling from world events into HUD
counters. Rewards are granted before the visual transfer begins.
*/

/// @description Converts one world position into current GUI coordinates.
function sc_hud_transfer_world_to_gui(_world_x,_world_y)
{
    var _camera = view_camera[0];
    var _view_x = camera_get_view_x(_camera);
    var _view_y = camera_get_view_y(_camera);
    var _view_width = camera_get_view_width(_camera);
    var _view_height = camera_get_view_height(_camera);
    var _gui_width = display_get_gui_width();
    var _gui_height = display_get_gui_height();

    return {
        x: (_world_x - _view_x) * (_gui_width / _view_width),
        y: (_world_y - _view_y) * (_gui_height / _view_height)
    };
}

/// @description Returns the current HUD destination of one transfer type.
function sc_hud_transfer_target_get(_type)
{
    var _hud = global.level.hud.hud;
    var _data = _hud.data;
    var _top_x = floor(
        (display_get_gui_width() - _data.top.width) * 0.5
    );

    switch (_type)
    {
        case HudTransferType.EXPERIENCE:
        {
            var _bar = _data.top.experience;

            return {
                x: _top_x + _bar.x + _bar.width * 0.5,
                y: _data.top.margin_top + _bar.y + _bar.height * 0.5
            };
        }

        case HudTransferType.CREDITS:
            return {
                x: _top_x + 635,
                y: _data.top.margin_top + 20
            };

        case HudTransferType.DATA_SHARD:
            return {
                x: _top_x + 475,
                y: _data.top.margin_top + 20
            };
    }

    return {
        x: _top_x + _data.top.width * 0.5,
        y: _data.top.margin_top
    };
}

/// @description Returns one point along a curved HUD-transfer path.
function sc_hud_transfer_curve_position(_transfer,_progress)
{
    var _inverse = 1 - _progress;
    var _start = _transfer.start;
    var _control = _transfer.control;
    var _target = _transfer.target;

    return {
        x: _inverse * _inverse * _start.x
            + 2 * _inverse * _progress * _control.x
            + _progress * _progress * _target.x,

        y: _inverse * _inverse * _start.y
            + 2 * _inverse * _progress * _control.y
            + _progress * _progress * _target.y
    };
}

/// @description Creates a visible enemy-coloured experience transfer.
function sc_hud_transfer_experience_create(
    _world_x,
    _world_y,
    _amount,
    _palette
)
{
    if (!instance_exists(global.level.hud))
        return noone;

    var _gui_width = display_get_gui_width();
    var _gui_height = display_get_gui_height();
    var _start = sc_hud_transfer_world_to_gui(_world_x,_world_y);

    // Off-screen kills begin at the nearest visible screen edge.
    _start.x = clamp(_start.x,32,_gui_width - 32);
    _start.y = clamp(_start.y,100,_gui_height - 32);

    var _target = sc_hud_transfer_target_get(
        HudTransferType.EXPERIENCE
    );

    var _vertical_distance = abs(
        _target.y - _start.y
    );

    var _control = {
        x: lerp(_start.x,_target.x,0.32) + random_range(-130,130),
        y: _start.y - max(120,_vertical_distance * 0.42)
    };

    return instance_create_depth(
        _world_x,
        _world_y,
        -10000,
        o_hud_transfer,
        {
            transfer_create: {
                type: HudTransferType.EXPERIENCE,
                amount: _amount,

                start: _start,
                control: _control,
                target: _target,

                colour: _palette.accent,
                core_colour: _palette.core,
                glow_colour: merge_colour(
                    _palette.glow,
                    _palette.accent,
                    0.55
                ),

                life: 64,
                launch_delay: 8,
                fragment_amount: 8,
                fragment_spread: 34,
                curve_variation: random(1000)
            }
        }
    );
}

/// @description Processes the visual arrival of one HUD transfer.
function sc_hud_transfer_arrive(_transfer)
{
    if (!instance_exists(global.level.hud))
        return false;

    var _hud = global.level.hud.hud;

    switch (_transfer.type)
    {
        case HudTransferType.EXPERIENCE:
            sc_hud_level_experience_gain(
                _hud,
                _transfer.amount
            );
        break;

        case HudTransferType.CREDITS:
            sc_hud_level_credit_gain(
                _hud,
                _transfer.amount
            );
        break;

        case HudTransferType.DATA_SHARD:
            _hud.runtime.data_shard_pulse = 1;
        break;
    }

    return true;
}

/// @description Draws one glowing data-fragment diamond.
function sc_hud_transfer_diamond_draw(
    _x,
    _y,
    _size,
    _colour,
    _alpha
)
{
    draw_primitive_begin(pr_trianglefan);

    draw_vertex_colour(_x,_y,_colour,_alpha);
    draw_vertex_colour(_x,_y - _size,_colour,0);
    draw_vertex_colour(_x + _size * 1.4,_y,_colour,_alpha);
    draw_vertex_colour(_x,_y + _size,_colour,0);
    draw_vertex_colour(_x - _size * 1.4,_y,_colour,_alpha);
    draw_vertex_colour(_x,_y - _size,_colour,0);

    draw_primitive_end();
}

/// @description Registers particles used by GUI reward transfers.
function sc_particles_hud_transfer_register()
{
    var _burst = sc_particles_type_create();
    var _trail = sc_particles_type_create();
    var _glow = sc_particles_type_create();

    if (!part_type_exists(_burst)
    || !part_type_exists(_trail)
    || !part_type_exists(_glow))
        return false;

    // Initial shard explosion at the destroyed enemy.
    part_type_sprite(_burst,s_particle_shard,false,false,false);
    part_type_size(_burst,0.055,0.1,-0.004,0.012);
    part_type_alpha3(_burst,1,0.8,0);
    part_type_speed(_burst,2.4,5.2,-0.2,0);
    part_type_direction(_burst,0,359,0,0);
    part_type_orientation(_burst,0,359,0,8,false);
    part_type_life(_burst,9,14);
    part_type_blend(_burst,true);

    // Sharp data fragments left behind the travelling packet.
    part_type_sprite(_trail,s_particle_shard,false,false,false);
    part_type_size(_trail,0.035,0.07,-0.002,0.008);
    part_type_alpha3(_trail,0.9,0.5,0);
    part_type_speed(_trail,0.15,0.65,-0.025,0);
    part_type_direction(_trail,0,359,0,0);
    part_type_orientation(_trail,0,359,0,5,false);
    part_type_life(_trail,14,24);
    part_type_blend(_trail,true);

    // Soft residual energy underneath the shards.
    part_type_sprite(_glow,s_blur,false,false,false);
    part_type_size(_glow,0.35,0.7,0.018,0.035);
    part_type_alpha3(_glow,0.42,0.2,0);
    part_type_speed(_glow,0.05,0.3,-0.012,0);
    part_type_direction(_glow,0,359,0,0);
    part_type_life(_glow,12,22);
    part_type_blend(_glow,true);

    return sc_particles_group_register("hud_transfer",{
        burst: _burst,
        trail: _trail,
        glow: _glow
    });
}

/// @description Emits the initial enemy-coloured XP shard burst.
function sc_particles_hud_transfer_burst_emit(_transfer)
{
    var _particles = sc_particles_group_get("hud_transfer");

    part_type_colour3(
        _particles.burst,
        _transfer.core_colour,
        _transfer.colour,
        _transfer.glow_colour
    );

    part_particles_create(
        global.particles.hud_system,
        _transfer.start.x,
        _transfer.start.y,
        _particles.burst,
        _transfer.fragment_amount
    );

    return true;
}

/// @description Emits a residual enemy-coloured trail behind a travelling transfer.
function sc_particles_hud_transfer_trail_emit(_transfer)
{
    var _particles = sc_particles_group_get("hud_transfer");

    part_type_colour3(
        _particles.trail,
        _transfer.core_colour,
        _transfer.colour,
        _transfer.glow_colour
    );

    part_type_colour3(
        _particles.glow,
        _transfer.core_colour,
        _transfer.glow_colour,
        _transfer.colour
    );

    part_particles_create(
        global.particles.hud_system,
        _transfer.x,
        _transfer.y,
        _particles.trail,
        2
    );

    if ((_transfer.age mod 2) == 0)
    {
        part_particles_create(
            global.particles.hud_system,
            _transfer.x,
            _transfer.y,
            _particles.glow,
            1
        );
    }

    return true;
}

/// @description Draws the shared GUI-coordinate particle system once.
function sc_particles_hud_draw()
{
    part_system_drawit(global.particles.hud_system);
}