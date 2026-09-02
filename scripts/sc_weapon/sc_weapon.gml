/// @description Fires one registered weapon using a generic owner and shot pattern.
function sc_weapon_fire(_owner, _weapon_key, _shot, _x, _y, _direction, _damage_multiplier)
{
    var _weapon = variable_struct_get(global.data.weapons, _weapon_key);
    if (_weapon.delivery.type != AttackDelivery.PROJECTILE) return false;

    var _source = {
        owner_id: _owner,
        faction: _owner.entity.faction,
        damage_multiplier: _damage_multiplier
    };

    switch (_shot.pattern)
    {
        case ShotPattern.SINGLE:
            sc_projectile_create(_weapon.delivery.projectile_key, _source, _x, _y, _direction, _owner.layer);
        break;

        case ShotPattern.SPREAD:
            var _step = _shot.amount > 1 ? _shot.angle_total / (_shot.amount - 1) : 0;
            var _start = _direction - _shot.angle_total * 0.5;

            for (var _i = 0; _i < _shot.amount; _i++)
                sc_projectile_create(_weapon.delivery.projectile_key, _source, _x, _y, _start + _step * _i, _owner.layer);
        break;

        case ShotPattern.RANDOM_CONE:
            for (var _i = 0; _i < _shot.amount; _i++)
                sc_projectile_create(_weapon.delivery.projectile_key, _source, _x, _y, _direction + random_range(-_shot.angle_total * 0.5, _shot.angle_total * 0.5), _owner.layer);
        break;
    }

    return true;
}