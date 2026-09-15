/// @description Updates inherited structure and derelict runtime.
if (!GAMEPLAY_ACTIVE) exit;

event_inherited();

if (initialized)
    sc_derelict_update(id);