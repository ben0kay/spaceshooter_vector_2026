/// @description Registers one validated enemy definition.
function sc_enemy_register(_enemy)
{
    if (!is_struct(_enemy) || !variable_struct_exists(_enemy, "identity") ||
        !variable_struct_exists(_enemy.identity, "key"))
    {
        show_debug_message("ENEMY REGISTRATION ERROR - invalid enemy definition");
        return false;
    }

    var _key = _enemy.identity.key;

    if (variable_struct_exists(global.data.enemies, _key))
    {
        show_debug_message("ENEMY REGISTRATION ERROR - duplicate key: " + _key);
        return false;
    }

    if (_enemy.range.combat > _enemy.range.detection || _enemy.range.detection > _enemy.range.forget)
    {
        show_debug_message("ENEMY REGISTRATION ERROR - invalid range order: " + _key);
        return false;
    }

    variable_struct_set(global.data.enemies, _key, _enemy);
    return true;
}

/// @description Registers the first basic chasing ranged enemy.
function sc_enemy_register_test_fighter()
{
    return sc_enemy_register({
        identity: {
            key: "enemy_test_fighter",
            name: "Test Fighter"
        },

        stats: {
            hull_max: 60
        },

        range: {
            detection: 900,
            combat: 520,
            forget: 1200
        },

        movement: {
            speed_max: 3.5,
            acceleration: 0.14,
            friction: 0.96,
            turn_speed: 5
        },

        collision: {
            radius: 24,
            blocks_player: true
        },

        visual: {
            radius: 24,
            colour_primary: make_colour_rgb(255, 45, 70),
            colour_secondary: make_colour_rgb(255, 140, 35)
        },

        components: {
            weapon: {
                cooldown: 50,
                projectile_speed: 10,
                projectile_damage: 8,
                projectile_life: 180,
                projectile_radius: 5,
                muzzle_distance: 34
            }
        }
    });
}

/// @description Initializes one enemy from registered data.
function sc_enemy_init(_enemy, _enemy_key)
{
    if (!variable_struct_exists(global.data.enemies, _enemy_key))
    {
        show_debug_message("ENEMY INITIALIZATION ERROR - unknown key: " + _enemy_key);
        return false;
    }

    var _data = variable_struct_get(global.data.enemies, _enemy_key);

    _enemy.enemy = {
        key: _enemy_key,
        identity: variable_clone(_data.identity),
        state: EnemyState.IDLE,
        target_id: noone,
        target_distance_sq: 0,

        stats: {
            hull_max: _data.stats.hull_max,
            hull: _data.stats.hull_max
        },

        range: variable_clone(_data.range),
        movement: variable_clone(_data.movement),
        collision: variable_clone(_data.collision),
        visual: variable_clone(_data.visual)
    };

    _enemy.enemy.range.detection_sq = sqr(_enemy.enemy.range.detection);
    _enemy.enemy.range.combat_sq = sqr(_enemy.enemy.range.combat);
    _enemy.enemy.range.forget_sq = sqr(_enemy.enemy.range.forget);

    _enemy.enemy.movement.velocity_x = 0;
    _enemy.enemy.movement.velocity_y = 0;

    if (variable_struct_exists(_data, "components"))
        sc_enemy_components_init(_enemy, _data.components);

    _enemy.draw_angle = 0;
    _enemy.initialized = true;

    global.level.enemies_alive++;
    show_debug_message("ENEMY INITIALIZED - " + _enemy.enemy.identity.name);
    return true;
}

/// @description Initializes only the components used by this enemy.
function sc_enemy_components_init(_enemy, _components)
{
    if (variable_struct_exists(_components, "weapon"))
    {
        _enemy.weapon = variable_clone(_components.weapon);
        _enemy.weapon.cooldown_remaining = irandom(_enemy.weapon.cooldown);
    }
}

/// @description Updates detection, combat and forget transitions.
function sc_enemy_perception_update(_enemy)
{
    var _data = _enemy.enemy;

    if (!instance_exists(global.player_id))
    {
        _data.target_id = noone;
        _data.state = EnemyState.IDLE;
        return;
    }

    var _dx = global.player_id.x - _enemy.x;
    var _dy = global.player_id.y - _enemy.y;
    _data.target_distance_sq = _dx * _dx + _dy * _dy;

    switch (_data.state)
    {
        case EnemyState.IDLE:
            if (!UPDATE_4) return;

            if (_data.target_distance_sq <= _data.range.detection_sq)
            {
                _data.target_id = global.player_id;
                _data.state = EnemyState.CHASING;
            }
        break;

        case EnemyState.CHASING:
            if (_data.target_distance_sq > _data.range.forget_sq)
            {
                _data.target_id = noone;
                _data.state = EnemyState.IDLE;
            }
            else if (_data.target_distance_sq <= _data.range.combat_sq)
                _data.state = EnemyState.ATTACKING;
        break;

        case EnemyState.ATTACKING:
            if (_data.target_distance_sq > _data.range.forget_sq)
            {
                _data.target_id = noone;
                _data.state = EnemyState.IDLE;
            }
            else if (_data.target_distance_sq > _data.range.combat_sq)
                _data.state = EnemyState.CHASING;
        break;
    }
}

/// @description Applies passive idle movement decay.
function sc_enemy_update_idle(_enemy)
{
    var _movement = _enemy.enemy.movement;

    _movement.velocity_x *= _movement.friction;
    _movement.velocity_y *= _movement.friction;

    if (abs(_movement.velocity_x) < 0.001) _movement.velocity_x = 0;
    if (abs(_movement.velocity_y) < 0.001) _movement.velocity_y = 0;

    _enemy.x += _movement.velocity_x;
    _enemy.y += _movement.velocity_y;
}

/// @description Moves the enemy toward its current target.
function sc_enemy_update_chasing(_enemy)
{
    var _data = _enemy.enemy;
    var _target = _data.target_id;
    var _movement = _data.movement;
    var _direction = point_direction(_enemy.x, _enemy.y, _target.x, _target.y);
    var _target_vx = lengthdir_x(_movement.speed_max, _direction);
    var _target_vy = lengthdir_y(_movement.speed_max, _direction);

    _movement.velocity_x += clamp(_target_vx - _movement.velocity_x, -_movement.acceleration, _movement.acceleration);
    _movement.velocity_y += clamp(_target_vy - _movement.velocity_y, -_movement.acceleration, _movement.acceleration);

    _enemy.x += _movement.velocity_x;
    _enemy.y += _movement.velocity_y;

    var _turn = angle_difference(_direction, _enemy.draw_angle);
    _enemy.draw_angle += clamp(_turn, -_movement.turn_speed, _movement.turn_speed);
    _enemy.draw_angle = _enemy.draw_angle mod 360;
}

/// @description Holds combat range and fires the optional weapon.
function sc_enemy_update_attacking(_enemy)
{
    var _data = _enemy.enemy;
    var _target = _data.target_id;
    var _movement = _data.movement;
    var _direction = point_direction(_enemy.x, _enemy.y, _target.x, _target.y);

    _movement.velocity_x *= _movement.friction;
    _movement.velocity_y *= _movement.friction;

    _enemy.x += _movement.velocity_x;
    _enemy.y += _movement.velocity_y;

    var _turn = angle_difference(_direction, _enemy.draw_angle);
    _enemy.draw_angle += clamp(_turn, -_movement.turn_speed, _movement.turn_speed);
    _enemy.draw_angle = _enemy.draw_angle mod 360;

    if (variable_instance_exists(_enemy, "weapon"))
        sc_enemy_weapon_update(_enemy);
}

/// @description Updates and fires one enemy weapon component.
function sc_enemy_weapon_update(_enemy)
{
    var _weapon = _enemy.weapon;

    if (_weapon.cooldown_remaining > 0)
    {
        _weapon.cooldown_remaining--;
        return;
    }

    var _target = _enemy.enemy.target_id;
    var _direction = point_direction(_enemy.x, _enemy.y, _target.x, _target.y);
    var _muzzle_x = _enemy.x + lengthdir_x(_weapon.muzzle_distance, _direction);
    var _muzzle_y = _enemy.y + lengthdir_y(_weapon.muzzle_distance, _direction);

    instance_create_layer(_muzzle_x, _muzzle_y, _enemy.layer, o_enemy_projectile, {
        projectile_data: {
            owner_id: _enemy,
            direction: _direction,
            speed: _weapon.projectile_speed,
            damage: _weapon.projectile_damage,
            life: _weapon.projectile_life,
            radius: _weapon.projectile_radius
        }
    });

    _weapon.cooldown_remaining = _weapon.cooldown;

    // Insert enemy firing audio and muzzle effects here.
}

/// @description Draws the temporary primitive enemy ship.
function sc_enemy_draw(_enemy)
{
    var _visual = _enemy.enemy.visual;
    var _radius = _visual.radius;
    var _angle = _enemy.draw_angle;

    var _nose_x = _enemy.x + lengthdir_x(_radius * 1.4, _angle);
    var _nose_y = _enemy.y + lengthdir_y(_radius * 1.4, _angle);
    var _rear_top_x = _enemy.x + lengthdir_x(_radius, _angle + 145);
    var _rear_top_y = _enemy.y + lengthdir_y(_radius, _angle + 145);
    var _rear_bottom_x = _enemy.x + lengthdir_x(_radius, _angle + 215);
    var _rear_bottom_y = _enemy.y + lengthdir_y(_radius, _angle + 215);

    draw_set_colour(make_colour_rgb(18, 3, 8));
    draw_circle(_enemy.x, _enemy.y, _radius, false);

    draw_set_colour(_visual.colour_primary);
    draw_triangle(_nose_x, _nose_y, _rear_top_x, _rear_top_y, _rear_bottom_x, _rear_bottom_y, false);

    draw_set_colour(_visual.colour_secondary);
    draw_circle(_enemy.x, _enemy.y, _radius * 0.25, false);
    draw_line_width(_enemy.x, _enemy.y, _nose_x, _nose_y, 2);
}