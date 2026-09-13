/*
PLAYER RADIAL COMMAND

A held drone-command opens the radial selection interface.
A completed double tap deploys the currently selected physical drone.
*/

/// @description Updates Delete hold and double-tap command recognition.
function sc_player_radial_command_update(_player)
{
    var _config = GCFG.player.radial;
    var _input = global.input.action;
    var _runtime = _player.combat.radial;
    var _deployed = false;

    if (_runtime.tap_remaining > 0)
        _runtime.tap_remaining--;

    if (_input.drone_command_pressed)
    {
        if (_runtime.tap_remaining > 0
        && !_runtime.open)
        {
            _runtime.tap_remaining = 0;
            _deployed = sc_player_drone_selected_deploy(_player);
        }
        else
        {
            _runtime.tap_remaining =
                _config.double_tap_window;
        }
    }

    if (_input.drone_command_held)
    {
        _runtime.hold_frames++;

        if (_runtime.hold_frames >= _config.hold_threshold)
        {
            _runtime.open = true;
            _runtime.tap_remaining = 0;
        }
    }

    if (_input.drone_command_released)
    {
        _runtime.open = false;
        _runtime.hold_frames = 0;
    }

    if (!_deployed)
        sc_player_weapon_runtime_release(
            _player.combat.drone
        );

    _runtime.block_combat =
        _runtime.open
        || _input.drone_command_held;

    return _runtime.block_combat;
}