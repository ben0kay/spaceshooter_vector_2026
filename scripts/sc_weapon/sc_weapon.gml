/// @description Emits one registered delivery at one position and direction.
function sc_weapon_delivery_fire(_owner, _weapon, _source, _x, _y, _direction)
{
    switch (_weapon.delivery.type)
    {
        case AttackDelivery.PROJECTILE:
            sc_projectile_create(
                _weapon.delivery.projectile_key,
                _source,
                _x, _y,
                _direction,
                _owner.layer
            );
        break;

        case AttackDelivery.AREA:
        case AttackDelivery.BEAM:
            sc_attack_area_create(
                _weapon.delivery.area,
                _source,
                _x, _y,
                _direction,
                _owner.layer
            );
        break;

        default:
            return false;
    }

    return true;
}

/// @description Fires one registered weapon using a generic owner and shot pattern.
function sc_weapon_fire(_owner, _weapon_key, _shot, _x, _y, _direction, _damage_multiplier)
{
    var _weapon = variable_struct_get(global.data.weapons, _weapon_key);
    var _source = {
        owner_id: _owner,
        faction: _owner.entity.faction,
        damage_multiplier: _damage_multiplier
    };

    switch (_shot.pattern)
    {
        case ShotPattern.SINGLE:
            sc_weapon_delivery_fire(_owner, _weapon, _source, _x, _y, _direction);
        break;

        case ShotPattern.SPREAD:
            var _step = _shot.amount > 1 ? _shot.angle_total / (_shot.amount - 1) : 0;
            var _start = _direction - _shot.angle_total * 0.5;

            for (var _i = 0; _i < _shot.amount; _i++)
                sc_weapon_delivery_fire(_owner, _weapon, _source, _x, _y, _start + _step * _i);
        break;

        case ShotPattern.RANDOM_CONE:
            for (var _i = 0; _i < _shot.amount; _i++)
                sc_weapon_delivery_fire(
                    _owner, _weapon, _source,
                    _x, _y,
                    _direction + random_range(-_shot.angle_total * 0.5, _shot.angle_total * 0.5)
                );
        break;

        default:
            return false;
    }

    return true;
}