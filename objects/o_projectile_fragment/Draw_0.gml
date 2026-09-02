/// @description Draws one fading baked projectile fragment.
var _fragment = fragment;

gpu_set_blendmode(bm_add);
draw_sprite_ext(_fragment.sprite, 0, x, y, _fragment.scale, _fragment.scale, _fragment.angle, c_white, _fragment.alpha);
gpu_set_blendmode(bm_normal);