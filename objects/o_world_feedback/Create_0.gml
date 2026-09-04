/// @description Initializes generic floating world feedback.
feedback = {
    text: feedback_create.text,
    colour: feedback_create.colour,
    scale: feedback_create.scale,
    life: feedback_create.life,
    remaining: feedback_create.life,
    rise_speed: feedback_create.rise_speed,
    drift_x: random_range(-0.08, 0.08)
};

depth = -100;