/// @description Runs this enemy's selected logic pipeline.
if (!initialized || !GAMEPLAY_ACTIVE) exit;

enemy.logic_controller.step_script(id);

image_angle = draw_angle;