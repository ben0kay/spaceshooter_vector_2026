/// @description Draws a large glowing XP packet and trailing data fragments.
var _progress = transfer.progress;
var _travel = transfer.travel;
var _remaining = 1 - _progress;
var _launching = transfer.age <= transfer.launch_delay;
var _pulse = 0.9 + sin(GAME_TICK * 0.4) * 0.1;

gpu_set_blendmode(bm_add);

// Strong soft energy glow.
if (sprite_exists(s_blur))
{
    var _blur_size = lerp(82,46,_progress);
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
        0.55
    );
}

// Continuous curved residual trail.
if (!_launching)
{
    draw_set_colour(transfer.colour);

    for (var _i = 1; _i <= 7; ++_i)
    {
        var _trail_progress = max(
            0,
            _travel - _i * 0.025
        );

        var _trail = sc_hud_transfer_curve_position(
            transfer,
            _trail_progress
        );

        var _trail_size = lerp(7,2,_i / 7);

        sc_hud_transfer_diamond_draw(
            _trail.x,
            _trail.y,
            _trail_size,
            transfer.colour,
            (1 - _i / 8) * 0.5
        );
    }
}

// Fragments scatter at the enemy, then converge during flight.
for (var _i = 0; _i < transfer.fragment_amount; ++_i)
{
    var _delay = (_i + 1) * 0.018;
    var _fragment_travel = max(0,_travel - _delay);

    var _position = sc_hud_transfer_curve_position(
        transfer,
        _fragment_travel
    );

    var _angle = transfer.curve_variation
        + _i * (360 / transfer.fragment_amount)
        + GAME_TICK * 1.8;

    var _burst = _launching
        ? transfer.age / transfer.launch_delay
        : _remaining;

    var _spread = transfer.fragment_spread
        * _burst
        * (0.65 + _i * 0.055);

    var _fragment_x = _position.x
        + lengthdir_x(_spread,_angle);

    var _fragment_y = _position.y
        + lengthdir_y(_spread,_angle);

    var _size = lerp(7,3,_progress)
        * (0.85 + (_i mod 3) * 0.12);

    sc_hud_transfer_diamond_draw(
        _fragment_x,
        _fragment_y,
        _size,
        transfer.colour,
        0.75
    );
}

// Clearly visible central XP packet.
var _core_size = lerp(14,8,_progress) * _pulse;

sc_hud_transfer_diamond_draw(
    transfer.x,
    transfer.y,
    _core_size * 1.65,
    transfer.colour,
    0.55
);

sc_hud_transfer_diamond_draw(
    transfer.x,
    transfer.y,
    _core_size,
    transfer.core_colour,
    1
);

gpu_set_blendmode(bm_normal);

// Small amount label follows the packet.
if (!_launching && _progress < 0.82)
{
    draw_set_font(-1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_colour(transfer.core_colour);
    draw_set_alpha(min(1,_progress * 5) * (1 - _progress));

    draw_text(
        transfer.x,
        transfer.y - 18,
        "+" + string(transfer.amount) + " XP"
    );
}

draw_set_alpha(1);
draw_set_colour(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);