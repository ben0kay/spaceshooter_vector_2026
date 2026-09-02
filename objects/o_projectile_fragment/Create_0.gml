/// @description Initializes one cosmetic projectile deflection.
var _data = fragment_create;

fragment = {
    sprite: _data.sprite,
    velocity_x: lengthdir_x(_data.speed, _data.direction),
    velocity_y: lengthdir_y(_data.speed, _data.direction),
    angle: _data.direction,
    spin: _data.spin,
    scale: _data.scale,
    shrink: _data.shrink,
    alpha: 1,
    age: 0,
    life: _data.life
};

sprite_index = -1;
mask_index = -1;
depth = -30;