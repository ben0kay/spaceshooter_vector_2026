/// @description Draws expanding fading shield-energy layers.
var _data = shield_break;
var _config = global.config.visual.shield.break_effect;
var _progress = 1 - _data.remaining / _data.life;
var _fade = sqr(1 - _progress);
var _inner_scale = lerp(1, _config.inner_scale_end, _progress);
var _outer_scale = lerp(1.03, _config.outer_scale_end, _progress);
var _angle = _data.angle + _progress * _config.rotation;
var _diameter = max(sprite_get_width(_data.sprite), sprite_get_height(_data.sprite));
var _blur_scale = (_diameter / sprite_get_width(s_particle_blur_1024)) * _config.blur_scale;

gpu_set_blendmode(bm_add);

draw_sprite_ext(
    s_particle_blur_1024, 0, x, y,
    _blur_scale * lerp(0.75, 1.35, _progress),
    _blur_scale * lerp(0.75, 1.35, _progress),
    0, _data.glow_colour,
    _config.blur_alpha * _fade
);

draw_sprite_ext(
    _data.sprite, 0, x, y,
    _outer_scale, _outer_scale,
    _angle, _data.glow_colour,
    _config.outer_alpha * _fade
);

draw_sprite_ext(
    _data.sprite, 0, x, y,
    _inner_scale, _inner_scale,
    _data.angle, _data.energy_colour,
    _config.inner_alpha * _fade
);

gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
draw_set_colour(c_white);