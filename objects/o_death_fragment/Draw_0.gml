/// @description Draws the explosion flash and all baked sprite fragments.
var _flash_progress = clamp(effect_age / 12, 0, 1);

gpu_set_blendmode(bm_add);

if (effect_age < 12)
{
    draw_set_colour(glow_colour);
    draw_set_alpha((1 - _flash_progress) * 0.42);
    draw_circle(x, y, lerp(effect_radius * 0.18, effect_radius * 1.15, _flash_progress), false);

    draw_set_colour(flash_colour);
    draw_set_alpha((1 - _flash_progress) * 0.9);
    draw_circle(x, y, lerp(effect_radius * 0.08, effect_radius * 0.42, _flash_progress), false);

    draw_set_alpha((1 - _flash_progress) * 0.8);
    draw_circle(x, y, lerp(effect_radius * 0.25, effect_radius * 1.45, _flash_progress), true);
}

gpu_set_blendmode(bm_normal);
draw_set_colour(c_white);

for (var _i = 0; _i < array_length(fragments); _i++)
{
    var _fragment = fragments[_i];
    draw_sprite_ext(_fragment.sprite, 0, _fragment.x, _fragment.y, _fragment.scale_x, _fragment.scale_y, _fragment.angle, c_white, _fragment.alpha);
}

draw_set_alpha(1);
draw_set_colour(c_white);