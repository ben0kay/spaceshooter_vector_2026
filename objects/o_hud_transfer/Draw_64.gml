/// @description Draws one glowing core with converging data fragments.
var _progress = transfer.progress;
var _remaining = 1 - _progress;
var _pulse = 0.88 + sin(GAME_TICK * 0.35) * 0.12;
var _core_size = lerp(7,4,_progress) * _pulse;
var _travel = power(_progress,1.55);

gpu_set_blendmode(bm_add);

// Soft faction-coloured energy surrounding the transfer.
if (sprite_exists(s_blur))
{
    var _blur_size = lerp(34,20,_progress);
    var _blur_scale = _blur_size / sprite_get_width(s_blur);

    draw_sprite_ext(
        s_blur,
        0,
        transfer.x,
        transfer.y,
        _blur_scale,
        _blur_scale,
        0,
        transfer.glow_colour,
        0.34 * _remaining + 0.14
    );
}

// Data fragments trail behind and converge into the core.
for (var _i = transfer.fragment_amount - 1; _i >= 0; --_i)
{
    var _delay = (_i + 1) * 0.032;
    var _fragment_progress = max(0,_travel - _delay);
    var _position = sc_hud_transfer_curve_position(
        transfer,
        _fragment_progress
    );

    var _phase = transfer.curve_variation
        + _i * 91
        + GAME_TICK * 0.08;

    var _spread = transfer.fragment_spread
        * _remaining
        * (0.45 + _i * 0.12);

    var _offset_x = lengthdir_x(
        _spread,
        sin(_phase) * 90
    );

    var _offset_y = lengthdir_y(
        _spread,
        sin(_phase) * 90
    );

    var _size = lerp(3.8,1.8,_progress)
        * (1 - _i * 0.08);

    sc_hud_transfer_diamond_draw(
        _position.x + _offset_x,
        _position.y + _offset_y,
        _size,
        transfer.colour,
        0.65 * _remaining + 0.2
    );
}

// Bright main packet.
sc_hud_transfer_diamond_draw(
    transfer.x,
    transfer.y,
    _core_size * 1.5,
    transfer.colour,
    0.5
);

sc_hud_transfer_diamond_draw(
    transfer.x,
    transfer.y,
    _core_size,
    transfer.core_colour,
    1
);

gpu_set_blendmode(bm_normal);

draw_set_alpha(1);
draw_set_colour(c_white);