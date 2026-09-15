/// @description Updates optional world-structure controllers.
if (!initialized || !GAMEPLAY_ACTIVE) exit;

if (is_struct(structure.facility))
    sc_facility_update(id);