/// @description Moves and expires generic world feedback.
feedback.remaining--;
x += feedback.drift_x;
y -= feedback.rise_speed;
feedback.rise_speed *= 0.985;

if (feedback.remaining <= 0) instance_destroy();