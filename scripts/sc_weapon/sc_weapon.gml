/// @description Emits one registered weapon delivery and returns its created instance.
function sc_weapon_delivery_fire(_owner, _weapon, _source, _x, _y, _direction)
{
    var _delivery = _weapon.delivery;

    switch (_delivery.type)
    {
        case AttackDelivery.PROJECTILE:
            return sc_projectile_create(
                _delivery.projectile_key, _source, _delivery,
                _x, _y, _direction, _owner.layer
            );

        case AttackDelivery.AREA:
        case AttackDelivery.BEAM:
            return sc_attack_area_create(
                _delivery.area, _source, _delivery.damage,
                _x, _y, _direction, _owner.layer, _delivery.scale
            );
    }

    return noone;
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
            return sc_weapon_delivery_fire(_owner, _weapon, _source, _x, _y, _direction);

        case ShotPattern.SPREAD:
            var _step = _shot.amount > 1 ? _shot.angle_total / (_shot.amount - 1) : 0;
            var _start = _direction - _shot.angle_total * 0.5;

            for (var _i = 0; _i < _shot.amount; _i++)
                sc_weapon_delivery_fire(_owner, _weapon, _source, _x, _y, _start + _step * _i);

            return true;

        case ShotPattern.RANDOM_CONE:
            for (var _i = 0; _i < _shot.amount; _i++)
                sc_weapon_delivery_fire(
                    _owner, _weapon, _source, _x, _y,
                    _direction + random_range(-_shot.angle_total * 0.5, _shot.angle_total * 0.5)
                );

            return true;
    }

    return false;
}