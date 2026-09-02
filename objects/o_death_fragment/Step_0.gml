/// @description Updates every fragment within this visual effect.
effect_age++;

for (var _i = 0; _i < array_length(fragments); _i++)
{
    var _fragment = fragments[_i];

    _fragment.x += _fragment.velocity_x;
    _fragment.y += _fragment.velocity_y;
    _fragment.velocity_x *= 0.965;
    _fragment.velocity_y *= 0.965;
    _fragment.angle += _fragment.spin;
    _fragment.spin *= 0.985;
    _fragment.scale *= 0.986;
    _fragment.alpha = sqr(1 - effect_age / effect_life);
}

if (effect_age >= effect_life) instance_destroy();