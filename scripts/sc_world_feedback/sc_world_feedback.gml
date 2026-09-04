/*
WORLD FEEDBACK

Generic floating world-space feedback reusable for credits, resources,
critical hits, repairs, immunities, objective feedback and similar events.
*/

/// @description Creates one generic floating world-feedback instance.
function sc_world_feedback_create(_x, _y, _layer, _text, _colour, _scale = 1)
{
    return instance_create_layer(_x, _y, _layer, o_world_feedback, {
        feedback_create: {
            text: _text,
            colour: _colour,
            scale: _scale,
            life: 54,
            rise_speed: 0.55
        }
    });
}