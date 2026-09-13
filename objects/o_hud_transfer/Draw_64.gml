/// @description Draws the glowing centre packet and its XP amount.
var _progress = transfer.progress;
var _launch_progress = clamp(
    transfer.age/transfer.launch_delay,
    0,
    1
);

var _pulse = 0.9+sin(GAME_TICK*0.4)*0.1;
var _packet_scale = lerp(0.42,0.2,_progress)*_pulse;
var _packet_alpha = lerp(0.35,1,_launch_progress);
var _rotation = transfer.curve_variation+GAME_TICK*3;

gpu_set_blendmode(bm_add);

draw_sprite_ext(
    s_blur,
    0,
    transfer.x,
    transfer.y,
    lerp(2.8,1.5,_progress),
    lerp(2.8,1.5,_progress),
    0,
    transfer.glow_colour,
    0.55*_packet_alpha
);

draw_sprite_ext(
    s_particle_shard,
    0,
    transfer.x,
    transfer.y,
    _packet_scale*1.35,
    _packet_scale*1.35,
    -_rotation*0.55,
    transfer.colour,
    0.48*_packet_alpha
);

draw_sprite_ext(
    s_particle_shard,
    0,
    transfer.x,
    transfer.y,
    _packet_scale,
    _packet_scale,
    _rotation,
    transfer.core_colour,
    _packet_alpha
);

gpu_set_blendmode(bm_normal);

if (transfer.age > transfer.launch_delay
&& _progress < 0.82)
{
    draw_set_font(-1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_colour(transfer.core_colour);
    draw_set_alpha(min(1,_progress*5)*(1-_progress));

    draw_text(
        transfer.x,
        transfer.y-22,
        "+"+string(transfer.amount)+" XP"
    );
}

draw_set_alpha(1);
draw_set_colour(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);