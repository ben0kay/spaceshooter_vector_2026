/// @description Creates one generic projectile.
function sc_projectile_create(_projectile_key, _source, _x, _y, _direction, _layer)
{
    return instance_create_layer(_x, _y, _layer, o_projectile, {
        projectile_create: {
            key: _projectile_key,
            source: _source,
            direction: _direction
        }
    });
}

/// @description Initializes one projectile from registered data.
function sc_projectile_init(_projectile, _create)
{
    if (!variable_struct_exists(global.data.projectiles, _create.key))
    {
        show_debug_message("PROJECTILE INITIALIZATION ERROR - unknown key: " + _create.key);
        return false;
    }

    var _data = variable_struct_get(global.data.projectiles, _create.key);

    _projectile.projectile = {
        key: _create.key,
        source: _create.source,
        direction: _create.direction,
        movement: variable_clone(_data.movement),
        damage: sc_damage_packet_create(_data.damage, _create.source),
        collision: variable_clone(_data.collision),
        visual: variable_clone(_data.visual),

        life: {
            remaining: _data.life.maximum,
            maximum: _data.life.maximum
        }
    };

    _projectile.draw_angle = _create.direction;
    _projectile.initialized = true;
    return true;
}

/// @description Updates one basic travelling projectile.
function sc_projectile_update(_projectile)
{
    var _data = _projectile.projectile;

    _projectile.x += lengthdir_x(_data.movement.speed, _data.direction);
    _projectile.y += lengthdir_y(_data.movement.speed, _data.direction);
    _data.life.remaining--;

    if (_data.life.remaining <= 0)
    {
        instance_destroy(_projectile);
        return;
    }

    if (_data.source.faction == Faction.PLAYER || !instance_exists(global.player_id)) return;

    var _player = global.player_id;
    var _hit_radius = _data.collision.radius + _player.ship.collision.radius;
    var _dx = _player.x - _projectile.x;
    var _dy = _player.y - _projectile.y;

    if (_dx * _dx + _dy * _dy > _hit_radius * _hit_radius) return;

    if (sc_player_damage(_player, _data.damage))
        sc_camera_shake(3, 8);

    instance_destroy(_projectile);
}

/// @description Draws one basic pulse projectile.
function sc_projectile_draw(_projectile)
{
    var _visual = _projectile.projectile.visual;
    var _angle = _projectile.draw_angle;
    var _tail_x = _projectile.x - lengthdir_x(_visual.length, _angle);
    var _tail_y = _projectile.y - lengthdir_y(_visual.length, _angle);

    draw_set_colour(_visual.colour_primary);
    draw_line_width(_tail_x, _tail_y, _projectile.x, _projectile.y, _visual.radius);

    draw_set_colour(_visual.colour_secondary);
    draw_circle(_projectile.x, _projectile.y, _visual.radius, false);
}