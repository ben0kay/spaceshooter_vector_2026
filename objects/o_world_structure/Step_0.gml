/// @description Updates optional world-structure controllers.
if (!initialized) exit;

if (is_struct(structure.facility))
    sc_facility_update(id);