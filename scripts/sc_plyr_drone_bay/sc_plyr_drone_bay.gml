/*
PLAYER DRONE BAY

Drone items physically move between reserved ship slots and world instances.
Their grade, armour and hull persist when they return.
*/

/// @description Creates an empty player drone bay.
function sc_player_drone_bay_create(_slot_amount)
{
    var _slots = array_create(max(0,floor(_slot_amount)));

    for (var _i = 0; _i < array_length(_slots); ++_i)
    {
        _slots[_i] = {
            state: DroneSlotState.EMPTY,
            item: undefined,
            active_id: noone
        };
    }

    return {
        selected_slot: 0,
        slots: _slots
    };
}

/// @description Creates one persistent physical drone item.
function sc_player_drone_item_create(_item_key,_drone_key,_grade)
{
    var _item = variable_struct_get(global.data.items,_item_key);
    var _definition = variable_struct_get(global.data.drones,_drone_key);
    var _grade_multiplier = sc_item_grade_multiplier_get(_grade);
    var _armour = round(_definition.defence.armour*_grade_multiplier);
    var _hull = round(_definition.defence.hull*_grade_multiplier);

    return {
        key: _item_key,
        name: _item.identity.name,
        drone_key: _drone_key,
        grade: _grade,

        condition: {
            armour: { current: _armour, maximum: _armour },
            hull: { current: _hull, maximum: _hull }
        }
    };
}

/// @description Places one physical drone item into an empty bay slot.
function sc_player_drone_slot_fill(_player,_slot_index,_item)
{
    var _slots = _player.inventory.drone_bay.slots;

    if (_slot_index < 0
    || _slot_index >= array_length(_slots)
    || _slots[_slot_index].state != DroneSlotState.EMPTY)
        return false;

    var _slot = _slots[_slot_index];
    _slot.state = DroneSlotState.DOCKED;
    _slot.item = _item;
    _slot.active_id = noone;
    return true;
}

/// @description Finds the first docked drone matching a registered drone key.
function sc_player_drone_docked_find(_player,_drone_key)
{
    var _slots = _player.inventory.drone_bay.slots;

    for (var _i = 0; _i < array_length(_slots); ++_i)
    {
        var _slot = _slots[_i];

        if (_slot.state == DroneSlotState.DOCKED
        && _slot.item.drone_key == _drone_key)
            return _i;
    }

    return -1;
}

/// @description Moves a docked physical drone from its slot into deployment.
function sc_player_drone_deploy_begin(_player,_slot_index)
{
    var _slots = _player.inventory.drone_bay.slots;

    if (_slot_index < 0
    || _slot_index >= array_length(_slots))
        return undefined;

    var _slot = _slots[_slot_index];
    if (_slot.state != DroneSlotState.DOCKED) return undefined;

    var _payload = _slot.item;

    _slot.state = DroneSlotState.DEPLOYED;
    _slot.item = undefined;
    _slot.active_id = noone;
    return _payload;
}

/// @description Connects the created world drone to its reserved bay slot.
function sc_player_drone_deploy_complete(_player,_slot_index,_drone)
{
    var _slot = _player.inventory.drone_bay.slots[_slot_index];

    _slot.state = DroneSlotState.DEPLOYED;
    _slot.active_id = _drone;
    return true;
}

/// @description Restores a deployment payload when world creation fails.
function sc_player_drone_deploy_cancel(_player,_slot_index,_payload)
{
    var _slot = _player.inventory.drone_bay.slots[_slot_index];

    _slot.state = DroneSlotState.DOCKED;
    _slot.item = _payload;
    _slot.active_id = noone;
    return true;
}

/// @description Marks a deployed physical drone as returning to its reserved slot.
function sc_player_drone_return_begin(_drone)
{
    var _data = _drone.drone;
    var _deployment = _data.deployment;

    if (_deployment.slot_index < 0
    || !instance_exists(_data.owner_id))
        return false;

    var _slot = _data.owner_id.inventory.drone_bay.slots[
        _deployment.slot_index
    ];

    _slot.state = DroneSlotState.RETURNING;
    return true;
}

/// @description Returns a surviving drone and its current condition to its slot.
function sc_player_drone_return_complete(_drone)
{
    var _data = _drone.drone;
    var _deployment = _data.deployment;

    if (_deployment.slot_index < 0
    || !instance_exists(_data.owner_id))
        return false;

    var _payload = _deployment.payload;
    var _defence = _data.defence;
    var _slot = _data.owner_id.inventory.drone_bay.slots[
        _deployment.slot_index
    ];

    _payload.condition.armour.current = _defence.armour.current;
    _payload.condition.armour.maximum = _defence.armour.maximum;
    _payload.condition.hull.current = _defence.hull.current;
    _payload.condition.hull.maximum = _defence.hull.maximum;

    _slot.state = DroneSlotState.DOCKED;
    _slot.item = _payload;
    _slot.active_id = noone;
    return true;
}

/// @description Empties the reserved slot when its physical drone is destroyed.
function sc_player_drone_destroy_complete(_drone)
{
    var _data = _drone.drone;
    var _deployment = _data.deployment;

    if (_deployment.slot_index < 0
    || !instance_exists(_data.owner_id))
        return false;

    var _slot = _data.owner_id.inventory.drone_bay.slots[
        _deployment.slot_index
    ];

    _slot.state = DroneSlotState.EMPTY;
    _slot.item = undefined;
    _slot.active_id = noone;
    return true;
}