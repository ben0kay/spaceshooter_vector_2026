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

/// @description Initializes one projectile from registered data and shared baked visuals.
function sc_projectile_init(_projectile, _create)
{
    if (!variable_struct_exists(global.data.projectiles, _create.key))
    {
        show_debug_message("PROJECTILE INITIALIZATION ERROR - unknown key: " + _create.key);
        return false;
    }

    var _data = variable_struct_get(global.data.projectiles, _create.key);
    var _visual = variable_clone(_data.visual);
    var _cache = sc_projectile_visual_cache_get(_create.key);
    var _frame_count = array_length(_cache.sprites);

    _visual.runtime = {
        cache: _cache,
        phase: _frame_count > 1 ? irandom(_frame_count - 1) : 0
    };

    _projectile.projectile = {
        key: _create.key,
        source: _create.source,
        direction: _create.direction,
        movement: variable_clone(_data.movement),
        damage: sc_damage_packet_create(_data.damage, _create.source),
        collision: variable_clone(_data.collision),
        visual: _visual,

        life: {
            remaining: _data.life.maximum,
            maximum: _data.life.maximum
        }
    };

    _projectile.mask_index = s_collision_circle;

    var _mask_scale = _projectile.projectile.collision.radius / 16;
    _projectile.image_xscale = _mask_scale;
    _projectile.image_yscale = _mask_scale;

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
        instance_destroy(_projectile);
}

/// @description Resolves one projectile collision against a damageable entity.
function sc_projectile_entity_collision(_projectile, _target)
{
    var _data = _projectile.projectile;

    if (_target == _data.source.owner_id) return false;
    if (_target.entity.faction == _data.source.faction) return false;

    var _damage_script = _target.entity.damage_script;
    _damage_script(_target, _data.damage);

    _data.visual.impact_script(_projectile.x, _projectile.y, _data.direction, _target);

    // Insert registered impact audio callback here later.
    instance_destroy(_projectile);
    return true;
}

/// @description Draws one projectile using its shared baked animation frames.
function sc_projectile_draw(_projectile)
{
    var _data = _projectile.projectile;
    var _runtime = _data.visual.runtime;
    var _cache = _runtime.cache;
    var _frame_count = array_length(_cache.sprites);
    var _frame = _frame_count > 1
        ? ((GAME_TICK div _cache.frame_speed) + _runtime.phase) mod _frame_count
        : 0;

    draw_sprite_ext(_cache.sprites[_frame], 0, _projectile.x, _projectile.y, 1, 1, _projectile.draw_angle, c_white, 1);
}