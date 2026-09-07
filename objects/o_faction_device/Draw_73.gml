// Inherit the parent event
event_inherited();

/// @description Draws temporary faction-device defence bars.
if (initialized)
    sc_health_bar_draw(
        x,
        y,
        device.visual.radius,
        device.defence,
        health_bar
    );

