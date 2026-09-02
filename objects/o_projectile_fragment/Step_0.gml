/// @description Moves, spins, shrinks and fades one cosmetic projectile fragment.
var _fragment = fragment;

x += _fragment.velocity_x;
y += _fragment.velocity_y;

_fragment.velocity_x *= 0.96;
_fragment.velocity_y *= 0.96;
_fragment.angle += _fragment.spin;
_fragment.spin *= 0.97;
_fragment.scale *= _fragment.shrink;
_fragment.age++;
_fragment.alpha = sqr(1 - _fragment.age / _fragment.life);

if (_fragment.age >= _fragment.life) instance_destroy();