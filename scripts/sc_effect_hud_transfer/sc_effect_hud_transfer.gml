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

/// @description Creates an enemy-coloured experience transfer.
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
    var _start = sc_hud_transfer_world_to_gui(
        _world_x,
        _world_y
    );

    // Off-screen kills begin from the nearest visible screen edge.
    _start.x = clamp(_start.x,24,_gui_width - 24);
    _start.y = clamp(_start.y,90,_gui_height - 24);

    var _target = sc_hud_transfer_target_get(
        HudTransferType.EXPERIENCE
    );

    var _vertical_distance = abs(
        _target.y - _start.y
    );

    var _control = {
        x: lerp(_start.x,_target.x,0.32)
            + random_range(-90,90),

        y: _start.y
            - max(80,_vertical_distance * 0.38)
    };

    return instance_create_depth(
        0,
        0,
        -100000,
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
                    0.45
                ),

                life: 34,
                fragment_amount: 5,
                fragment_spread: 18,
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