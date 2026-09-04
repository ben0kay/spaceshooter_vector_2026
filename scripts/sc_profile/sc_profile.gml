/// @description Returns the filename for one profile slot.
function sc_profile_path(_slot)
{
    return "ssv_profile_" + string(_slot) + ".json";
}

/// @description Creates a new default profile struct.
function sc_profile_default(_slot, _pilot_name)
{
    return {
        version: 1,
        slot: _slot,
        pilot_name: _pilot_name,
        created_at: date_current_datetime(),
        last_played_at: date_current_datetime(),
        credits: 0,
        selected_ship_key: "ship_fighter",
        unlocked_ship_keys: ["ship_shard", "ship_fighter", "ship_bastion"],
        persistent_modifiers: []
    };
}

/// @description Validates and supplies safe defaults for loaded profile data.
function sc_profile_validate(_profile, _slot)
{
    if (!is_struct(_profile)) return false;

    if (!variable_struct_exists(_profile, "version")) _profile.version = 1;
    if (!variable_struct_exists(_profile, "slot")) _profile.slot = _slot;
    if (!variable_struct_exists(_profile, "pilot_name")) _profile.pilot_name = "Pilot " + string(_slot + 1);
    if (!variable_struct_exists(_profile, "created_at")) _profile.created_at = date_current_datetime();
    if (!variable_struct_exists(_profile, "last_played_at")) _profile.last_played_at = date_current_datetime();
    if (!variable_struct_exists(_profile, "credits")) _profile.credits = 0;
    if (!variable_struct_exists(_profile, "selected_ship_key")) _profile.selected_ship_key = "ship_fighter";

    if (!variable_struct_exists(_profile, "unlocked_ship_keys") || !is_array(_profile.unlocked_ship_keys))
        _profile.unlocked_ship_keys = ["ship_shard", "ship_fighter", "ship_bastion"];

    if (!variable_struct_exists(_profile, "persistent_modifiers") || !is_array(_profile.persistent_modifiers))
        _profile.persistent_modifiers = [];

    _profile.slot = _slot;
    return true;
}

/// @description Reads a profile without making it active.
function sc_profile_read(_slot)
{
    var _path = sc_profile_path(_slot);
    if (!file_exists(_path)) return undefined;

    var _file = file_text_open_read(_path);
    if (_file < 0) return undefined;

    var _json = "";
    while (!file_text_eof(_file))
    {
        _json += file_text_read_string(_file);
        file_text_readln(_file);
    }

    file_text_close(_file);
    if (string_length(_json) <= 0) return undefined;

    var _profile;
    try { _profile = json_parse(_json); }
    catch (_error)
    {
        show_debug_message("PROFILE READ ERROR - slot " + string(_slot + 1));
        return undefined;
    }

    if (!sc_profile_validate(_profile, _slot))
    {
        show_debug_message("PROFILE VALIDATION ERROR - slot " + string(_slot + 1));
        return undefined;
    }

    return _profile;
}

/// @description Creates, saves and activates a new profile.
function sc_profile_create(_slot, _pilot_name)
{
    _pilot_name = string_trim(string(_pilot_name));
    if (string_length(_pilot_name) <= 0) return false;

    global.profile = sc_profile_default(_slot, _pilot_name);
    return sc_profile_save();
}

/// @description Loads and activates an existing profile.
function sc_profile_load(_slot)
{
    var _profile = sc_profile_read(_slot);
    if (!is_struct(_profile)) return false;

    _profile.last_played_at = date_current_datetime();
    global.profile = _profile;

    sc_profile_save();
    show_debug_message("PROFILE LOADED - " + global.profile.pilot_name);
    return true;
}

/// @description Saves the currently active profile.
function sc_profile_save()
{
    if (!is_struct(global.profile) || !variable_struct_exists(global.profile, "slot"))
        return false;

    var _path = sc_profile_path(global.profile.slot);
    var _file = file_text_open_write(_path);

    if (_file < 0)
    {
        show_debug_message("PROFILE SAVE ERROR - could not open file");
        return false;
    }

    file_text_write_string(_file, json_stringify(global.profile));
    file_text_close(_file);
    return true;
}