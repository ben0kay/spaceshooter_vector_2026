/// @description Updates optional faction-device controllers.
if (!initialized || !GAMEPLAY_ACTIVE) exit;

sc_faction_device_update(id);
image_angle = draw_angle;